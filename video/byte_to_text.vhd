library ieee;
use ieee.std_logic_1164.all;

entity byte_to_text is port
(
	byte_in : in std_logic_vector(7 downto 0);
	line_out : out std_logic_vector(9 downto 0);
	line_sel : in std_logic_vector(4 downto 0)
);
end entity byte_to_text;

architecture a0 of byte_to_text is
begin

	with byte_in & line_sel select
		line_out <= "1111111111" when "1111111100000",
						"1010101010" when "1111111111000",
						"100000000" & line_sel(0) when others;

end architecture a0;