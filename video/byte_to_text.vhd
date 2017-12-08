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

	signal lo : std_logic_vector(9 downto 0);

begin

	with line_sel select
		lo <= "1111111111" when "00000",
						"1010101010" when "11000",
						"100000000" & line_sel(0) when others;
	line_out <= lo when byte_in = "11111111" else "0000000000";

end architecture a0;