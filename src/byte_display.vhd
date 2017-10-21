library ieee;
use ieee.std_logic_1164.all;

entity byte_display is port
(
	byte_in : in std_logic_vector(7 downto 0);
	d_point : in std_logic_vector(1 downto 0); -- hi & low
	hex_out_hi : out std_logic_vector(7 downto 0);
	hex_out_lo : out std_logic_vector(7 downto 0)
);
end entity byte_display;

architecture a0 of byte_display is

	component seven_seg_decoder is port
	(
		nybble_in : in std_logic_vector(3 downto 0); --binary to decode
		d_point 	 : in std_logic; --decimal point (active high)
		hex_out   : out std_logic_vector(7 downto 0) --7 seg code (active high)
	);
	end component seven_seg_decoder;
	
	signal hex_hi : std_logic_vector(7 downto 0);
	signal hex_lo : std_logic_vector(7 downto 0);

begin

	hi : component seven_seg_decoder port map
	(
		nybble_in => byte_in(7 downto 4),
		d_point => d_point(1),
		hex_out => hex_hi
	);
	
	lo : component seven_seg_decoder port map
	(
		nybble_in => byte_in(3 downto 0),
		d_point => d_point(0),
		hex_out => hex_lo
	);
	
	hex_out_hi <= NOT(hex_hi); -- digits on DE-10 Lite are common anode
	hex_out_lo <= NOT(hex_lo);

end architecture a0;