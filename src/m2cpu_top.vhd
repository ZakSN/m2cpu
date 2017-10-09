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

	component seven_seg_decoder is port
	(
		nybble_in : in std_logic_vector(3 downto 0); --binary to decode
		d_point 	 : in std_logic; --decimal point (active high)
		hex_out   : out std_logic_vector(7 downto 0) --7 seg code (active high)
	);
	end component seven_seg_decoder;
	
	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		oe  : in std_logic; --out put enable (active high)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;

------------------signal section----------------------------
	
	signal data_bus : std_logic_vector(7 downto 0) bus := "LLLLLLLL"; --aparently this is how you do busses
	
begin
	
	reg_1 : component register_8bit port map
	(
		di  => data_bus,
		do  => data_bus,
		ld  => not(KEY(0)),
		oe  => SW(9),
		rs  => '0',
		clk => CLK50
	);
	
	reg_2 : component register_8bit port map
	(
		di  => SW(7 downto 0),
		do  => data_bus,
		ld  => not(KEY(1)),
		oe  => SW(8),
		rs  => '0',
		clk => CLK50
	);
	
	LED(7 downto 0) <= data_bus;

end architecture a0;