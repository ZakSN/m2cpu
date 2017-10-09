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

------------------signal section----------------------------

	signal h0 : std_logic_vector(7 downto 0);
	signal h1 : std_logic_vector(7 downto 0);
	signal h2 : std_logic_vector(7 downto 0);
	signal h3 : std_logic_vector(7 downto 0);
	signal h4 : std_logic_vector(7 downto 0);
	signal h5 : std_logic_vector(7 downto 0);

begin

	dec0: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h0
	);
	HEX0 <= not(h0);
	
	dec1: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h1
	);
	HEX1 <= not(h1);
	
	dec2: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h2
	);
	HEX2 <= not(h2);
	
	dec3: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h3
	);
	HEX3 <= not(h3);
	
	dec4: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h4
	);
	HEX4 <= not(h4);
	
	dec5: component seven_seg_decoder port map
	(
		nybble_in => SW(3 downto 0),
		d_point   => not(KEY(0)),
		hex_out   => h5
	);
	HEX5 <= not(h5);

end architecture a0;