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
	
	component central_processing_unit is port
	(
		current_instruction : out std_logic_vector(7 downto 0);
		memory_in : in std_logic_vector(7 downto 0); -- RAM interface
		data_out : out std_logic_vector(7 downto 0); -- data bus
		address_out : out std_logic_vector(15 downto 0); -- address bus
		rst : in std_logic; -- global reset, all registers, PC, and FSM
		clk : in std_logic
	);
	end component central_processing_unit;
	
	component clock_divider is port
	(
		clkin : in std_logic; --50MHz clock from the board
		rst : in std_logic; --async reset
		clkout : out std_logic --slow clock (human visible)
	);
	end component clock_divider;

------------------signal section----------------------------
	signal system_clock : std_logic;
	signal memory_data : std_logic_vector(7 downto 0);
	signal memory_address : std_logic_vector(15 downto 0);
	signal cpu_data : std_logic_vector(7 downto 0);
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
		data		=> "00000000",
		rden		=> '1',
		wren		=> '0', 
		q			=> memory_data
	);
	
	cpu : component central_processing_unit port map
	(
		current_instruction => LED(7 downto 0),
		memory_in => memory_data,
		data_out => cpu_data,
		address_out => memory_address,
		rst => reset,
		clk => CLK50 --system_clock
	);
	
	data_bus_display : component byte_display port map
	(
		byte_in => cpu_data,
		d_point => "00",
		hex_out_hi => HEX5,
		hex_out_lo => HEX4
	);
	
	addr_bus_display_hi : component byte_display port map
	(
		byte_in => memory_address(15 downto 8),
		d_point => "00",
		hex_out_hi => HEX3,
		hex_out_lo => HEX2
	);
	
	addr_bus_display_lo : component byte_display port map
	(
		byte_in => memory_address(7 downto 0),
		d_point => "00",
		hex_out_hi => HEX1,
		hex_out_lo => HEX0
	);

end architecture a0;