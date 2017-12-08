library ieee;
use ieee.std_logic_1164.all;

entity screen_buffer is port
(
	char_n : in integer;
	line_n : in integer;
	char_out : out std_logic_vector(7 downto 0);
	char_in : in std_logic_vector(7 downto 0);
	write_char : in std_logic
);
end entity screen_buffer;

architecture a0 of screen_buffer is

	type buf is array ( 79 downto 0, 23 downto 0) of std_logic_vector(7 downto 0);
	signal scr_buf : buf := (others => (others => "11111111"));

begin

	scr_buf(1, 12) <= "00000000";
	scr_buf(0, 12) <= "11111111";
	scr_buf(3, 12) <= "00000000";
	scr_buf(2, 12) <= "11111111";
	scr_buf(0, 0) <= "00000000";
	scr_buf(0, 23) <= "00000000";
	char_out <= scr_buf(char_n, line_n);

end architecture a0;