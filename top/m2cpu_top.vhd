library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity m2cpu_top is port
(
	-- this I/O reflects what is available on the DE10-lite dev-board
   LED      : out std_logic_vector (9 downto 0); --leds
   SW       : in std_logic_vector (9 downto 0); --toggle switches
   KEY      : in std_logic_vector (1 downto 0); --momentary push buttons
	-- 7 segment (+ dp) displays
	HEX0		: out std_logic_vector (7 downto 0); 
	HEX1		: out std_logic_vector (7 downto 0);
	HEX2		: out std_logic_vector (7 downto 0);
	HEX3		: out std_logic_vector (7 downto 0);
	HEX4		: out std_logic_vector (7 downto 0);
	HEX5		: out std_logic_vector (7 downto 0);
	-- VGA video signals
	R			: out std_logic_vector (3 downto 0);
	G			: out std_logic_vector (3 downto 0);
	B			: out std_logic_vector (3 downto 0);
	HSYNC		: out std_logic;
	VSYNC		: out std_logic;
   CLK50    : in std_logic --system clock
);
end entity m2cpu_top;

architecture a0 of m2cpu_top is

------------------component section-------------------------

	component byte_display is port
	(
		byte_in : in std_logic_vector(7 downto 0);
		d_point : in std_logic_vector(1 downto 0); -- hi & low
		hex_out_hi : out std_logic_vector(7 downto 0);
		hex_out_lo : out std_logic_vector(7 downto 0)
	);
	end component byte_display;
	
	component memory is port
	(
		address_a		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component memory;
	
	component clock_divider is 
	generic
	(
		half_period : integer
	);
	port
	(
		clkin : in std_logic; --50MHz clock from the board
		rst : in std_logic; --async reset
		clkout : out std_logic --slow clock (human visible)
	);
	end component clock_divider;
	
	component address_shift_register is port
	(
		byte_in : in std_logic_vector(7 downto 0);
		word_out : out std_logic_vector(15 downto 0);
		shift : in std_logic
	);
	end component address_shift_register;
	
	component debouncer is port
	(
		sw_in : in std_logic;
		sw_out : out std_logic;
		clk : in std_logic
	);
	end component debouncer;
	
	component central_processing_unit is port
	(
		-- bus names are from the processor's prespective
		data_bus_in  : in std_logic_vector(7 downto 0);
		data_bus_out : out std_logic_vector(7 downto 0);
		addr_bus_out : out std_logic_vector(15 downto 0);
		memory_wren  : out std_logic;
		debug_out    : out std_logic_vector(31 downto 0); -- four byte debug vector 
		rst : in std_logic; -- global reset, all registers, PC, and FSM
		clk : in std_logic
	);
	end component central_processing_unit;
	
	component text_console is port
	(
		-- VGA video signals
		r : out std_logic_vector(3 downto 0);
		g : out std_logic_vector(3 downto 0);
		b : out std_logic_vector(3 downto 0);
		hsync : out std_logic;
		vsync : out std_logic;
		-- memory access signals
		byte_in : in std_logic_vector(7 downto 0);
		address : out std_logic_vector(15 downto 0);
		--
		rs : in std_logic;
		clk : in std_logic
	);
	end component  text_console;
	
------------------signal section----------------------------
	signal sys_clk : std_logic; -- system clock
	signal MODE : std_logic_vector(1 downto 0); -- the mode that the computer is in: program, single step, low speed, full speed
	signal nkey : std_logic_vector(1 downto 0); -- inverted key signals
	signal ndkey : std_logic_vector(1 downto 0); -- inverted and debounced key signals
	signal control_addr_bus_out : std_logic_vector(15 downto 0); -- front panel address (used in program mode)
	signal disp_bus : std_logic_vector(31 downto 0); -- leds & hex digits (hex digits are grouped as byte & address)
	signal slow_clk : std_logic;
	signal reset : std_logic;

	-- signals from cpu
	signal cpu_data_bus_out : std_logic_vector(7 downto 0);
	signal cpu_addr_bus_out : std_logic_vector(15 downto 0);
	signal cpu_mem_wren : std_logic;
	signal cpu_debug_out : std_logic_vector(31 downto 0);

	-- signals to/from memory
	-- some memory signals have different inputs depending on the mode
	signal mem_addr_bus_in_a : std_logic_vector(15 downto 0);
	signal mem_addr_bus_in_b : std_logic_vector(15 downto 0);
	signal mem_data_bus_in_a : std_logic_vector(7 downto 0);
	signal mem_data_bus_out_b : std_logic_vector(7 downto 0);
	signal mem_data_bus_out_a : std_logic_vector(7 downto 0);
	signal mem_mem_wren_a : std_logic;
	signal mem_clk : std_logic;

begin

	nkey <= NOT(KEY);
	reset <= '1' when MODE = "00" else '0'; -- only reset when in program mode

	debounce_0 : component debouncer port map
	(
		sw_in => nkey(0),
		sw_out => ndkey(0),
		clk => CLK50
	);

	debounce_1 : component debouncer port map
	(
		sw_in => nkey(1),
		sw_out => ndkey(1),
		clk => CLK50
	);

	MODE <= SW(9 downto 8);
	LED(8) <= sys_clk; -- shows clock speed
	LED(9) <= '0' when MODE = "00" else '1'; -- light on when executing

	addr_shift : component address_shift_register port map
	(
		byte_in => SW(7 downto 0),
		word_out => control_addr_bus_out,
		shift => ndkey(1)
	);

	clk_div : component clock_divider 
	generic map
	(
		half_period => 5000000
	)
	port map
	(
		clkin => CLK50,
		rst => reset,
		clkout => slow_clk
	);

	MEM : component memory port map
	(
		address_a => mem_addr_bus_in_a,
		address_b => mem_addr_bus_in_b,
		clock => mem_clk,
		data_a => mem_data_bus_in_a,
		data_b => "00000000",
		wren_a => mem_mem_wren_a,
		wren_b => '0',
		q_a => mem_data_bus_out_a,
		q_b => mem_data_bus_out_b
	);

	CPU : component central_processing_unit port map
	(
		data_bus_in  => mem_data_bus_out_a,
		data_bus_out => cpu_data_bus_out,
		addr_bus_out => cpu_addr_bus_out,
		memory_wren  => cpu_mem_wren,
		debug_out    => cpu_debug_out,
		rst => reset,
		clk => sys_clk
	);

	mem_addr_bus_in_a <= control_addr_bus_out when MODE = "00" else cpu_addr_bus_out;
	mem_data_bus_in_a <= SW(7 downto 0) when MODE = "00" else cpu_data_bus_out;
	mem_mem_wren_a <= ndkey(0) when MODE = "00" else cpu_mem_wren;

	with  MODE select
		sys_clk <= '0' when "00", -- program mode
					  ndkey(1) when "01", -- single step mode
					  slow_clk when "10", -- slow speed mode
					  CLK50 when "11", -- full speed mode
					  '0' when others;
	mem_clk <= CLK50 when MODE = "00" else sys_clk;

	disp_bus <= "00000000" & mem_data_bus_out_a & control_addr_bus_out when MODE = "00" else cpu_debug_out(31 downto 0);

	LED(7 downto 0) <= disp_bus(31 downto 24);

	byte_disp : component byte_display port map
	(
		byte_in => disp_bus(23 downto 16),
		d_point => "01",
		hex_out_hi => HEX5,
		hex_out_lo => HEX4
	);

	addr_disp_hi : component byte_display port map
	(
		byte_in => disp_bus(15 downto 8),
		d_point => "00",
		hex_out_hi => HEX3,
		hex_out_lo => HEX2
	);

	addr_disp_lo : component byte_display port map
	(
		byte_in => disp_bus(7 downto 0),
		d_point => "00",
		hex_out_hi => HEX1,
		hex_out_lo => HEX0
	);

	-- note: video only works in full speed mode since it must be synchronised with memory
	console : component text_console port map
	(
		r => R,
		g => G,
		b => B,
		hsync => HSYNC,
		vsync => VSYNC,
		byte_in => mem_data_bus_out_b,
		address => mem_addr_bus_in_b,
		rs => reset,
		clk => CLK50
	);

end architecture a0;