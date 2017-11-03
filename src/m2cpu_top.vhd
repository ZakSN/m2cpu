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
		rden		: IN STD_LOGIC  := '1';
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

------------------signal section----------------------------
	signal memory_in : std_logic_vector(7 downto 0);
	signal memory_out : std_logic_vector(7 downto 0);
	signal memory_address : std_logic_vector(15 downto 0);
	signal memory_write : std_logic;
	signal debug_bus : std_logic_vector(23 downto 0);
	signal system_clock : std_logic;
	signal reset : std_logic;
	
begin

	reset <= NOT(KEY(0));
	
	clk_div : component clock_divider port map
	(
		clkin => CLK50,
		rst => reset,
		clkout => system_clock
	);
	
	mem : component  memory port map
	(
		address	=> memory_address,
		clock		=> system_clock,
		data		=> memory_in,
		rden		=> '1',
		wren		=> memory_write, 
		q			=> memory_out
	);
	
	CPU : component central_processing_unit port map
	(
		data_bus_in => memory_out,
		data_bus_out => memory_in,
		addr_bus_out => memory_address,
		memory_wren => memory_write,
		debug_out => debug_bus,
		rst => reset,
		clk => system_clock
	);
	
	data_disp : component byte_display port map
	(
		byte_in => debug_bus(23 downto 16),
		d_point => "01",
		hex_out_hi => HEX5,
		hex_out_lo => HEX4
	);
	
	addr_disp_hi : component byte_display port map
	(
		byte_in => debug_bus(15 downto 8),
		d_point => "00",
		hex_out_hi => HEX3,
		hex_out_lo => HEX2
	);
	
	addr_disp_lo : component byte_display port map
	(
		byte_in => debug_bus(7 downto 0),
		d_point => "00",
		hex_out_hi => HEX1,
		hex_out_lo => HEX0
	);

end architecture a0;