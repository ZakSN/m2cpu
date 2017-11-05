library ieee;
use ieee.std_logic_1164.all;

entity m2cpu_top is port
(
	--this I/O reflects what is available on the DE10-lite dev-board
   LED      : out std_logic_vector (9 downto 0); --leds
   SW       : in std_logic_vector (9 downto 0); --toggle switches
   KEY      : in std_logic_vector (1 downto 0); --momentary push buttons
	--7 segment (+ dp) displays
	HEX0		: out std_logic_vector (7 downto 0); 
	HEX1		: out std_logic_vector (7 downto 0);
	HEX2		: out std_logic_vector (7 downto 0);
	HEX3		: out std_logic_vector (7 downto 0);
	HEX4		: out std_logic_vector (7 downto 0);
	HEX5		: out std_logic_vector (7 downto 0);
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
		address	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;
	
	component clock_divider is port
	(
		clkin : in std_logic; --50MHz clock from the board
		rst : in std_logic; --async reset
		clkout : out std_logic --slow clock (human visible)
	);
	end component clock_divider;
	
	component central_processing_unit is port
	(
		-- bus names are from the processor's prespective
		data_bus_in  : in std_logic_vector(7 downto 0);
		data_bus_out : out std_logic_vector(7 downto 0);
		addr_bus_out : out std_logic_vector(15 downto 0);
		memory_wren  : out std_logic;
		debug_out    : out std_logic_vector(23 downto 0); -- general purpose debug vector
		rst : in std_logic; -- global reset, all registers, PC, and FSM
		clk : in std_logic
	);
	end component central_processing_unit;
	
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

------------------signal section----------------------------
	signal sys_clk : std_logic; -- system clock
	signal EXEC_PROG : std_logic; -- execute/program mode switch
	signal FULL_SLOW : std_logic; -- clock speed switch
	signal nkey : std_logic_vector(1 downto 0); -- inverted key signals
	signal ndkey : std_logic_vector(1 downto 0); -- inverted and debounced key signals
	
	signal cpu_data_bus_out : std_logic_vector(7 downto 0);
	signal cpu_addr_bus_out : std_logic_vector(15 downto 0);
	signal cpu_mem_wren : std_logic;
	signal cpu_debug_out : std_logic_vector(23 downto 0);
	
	signal control_addr_bus_out : std_logic_vector(15 downto 0);
	
	signal mem_addr_bus_in : std_logic_vector(15 downto 0);
	signal mem_data_bus_in : std_logic_vector(7 downto 0);
	signal mem_data_bus_out : std_logic_vector(7 downto 0);
	signal mem_mem_wren : std_logic;
	signal mem_clk : std_logic;
	
	signal slow_clk : std_logic;
	signal clk_sel : std_logic_vector(1 downto 0);
	
	signal disp_bus : std_logic_vector(23 downto 0);
	
begin

	nkey <= NOT(KEY);

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
	
	EXEC_PROG <= SW(9);
	FULL_SLOW <= SW(8);
	LED(8) <= sys_clk; -- shows clock speed
	LED(9) <= EXEC_PROG; -- light on when executing
	
	CPU : component central_processing_unit port map
	(
		data_bus_in  => mem_data_bus_out,
		data_bus_out => cpu_data_bus_out,
		addr_bus_out => cpu_addr_bus_out,
		memory_wren  => cpu_mem_wren,
		debug_out    => cpu_debug_out,
		rst => NOT(EXEC_PROG),
		clk => sys_clk
	);
	
	addr_shift : component address_shift_register port map
	(
		byte_in => SW(7 downto 0),
		word_out => control_addr_bus_out,
		shift => ndkey(1)
	);
	
	MEM : component memory port map
	(
		address	=> mem_addr_bus_in,
		clock		=> mem_clk,
		data		=> mem_data_bus_in,
		wren		=> mem_mem_wren,
		q			=> mem_data_bus_out
	);
	
	mem_addr_bus_in <= control_addr_bus_out when EXEC_PROG = '0' else cpu_addr_bus_out;
	mem_data_bus_in <= SW(7 downto 0) when EXEC_PROG = '0' else cpu_data_bus_out;
	mem_mem_wren <= ndkey(0) when EXEC_PROG = '0' else cpu_mem_wren;
	
	clk_div : component clock_divider port map
	(
		clkin => CLK50,
		rst => '0',
		clkout => slow_clk
	);
	
	clk_sel <= EXEC_PROG & FULL_SLOW;
	with  clk_sel select
		sys_clk <= '0' when "00",
					  slow_clk when "10",
					  CLK50 when "11",
					  '0' when others;
	mem_clk <= CLK50 when EXEC_PROG = '0' else sys_clk;
	
	disp_bus <= mem_data_bus_out & control_addr_bus_out when EXEC_PROG = '0' else cpu_debug_out;
	
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
	
end architecture a0;