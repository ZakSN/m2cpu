library ieee;
use ieee.std_logic_1164.all;

entity seven_seg_decoder is port
(
	nybble_in : in std_logic_vector(3 downto 0); --binary to decode
	d_point 	 : in std_logic; --decimal point (active high)
	hex_out   : out std_logic_vector(7 downto 0) --7 seg code (active high)
);
end entity seven_seg_decoder;

architecture a0 of seven_seg_decoder is

	signal hex : std_logic_vector(6 downto 0);

begin
	with nybble_in select
		hex <= "0111111" when "0000", --0x0
				 "0000110" when "0001", --0x1
				 "1011011" when "0010", --0x2
		   	 "1001111" when "0011", --0x3
				 "1100110" when "0100", --0x4
				 "1101101" when "0101", --0x5
				 "1111101" when "0110", --0x6
				 "0000111" when "0111", --0x7
				 "1111111" when "1000", --0x8
				 "1101111" when "1001", --0x9
				 "1110111" when "1010", --0xA
				 "1111100" when "1011", --0xB
				 "0111001" when "1100", --0xC
				 "1011110" when "1101", --0xD
				 "1111001" when "1110", --0xE
				 "1110001" when "1111", --0xF
				 "0000000" when others;
	hex_out <= d_point & hex;
end architecture a0;