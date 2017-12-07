library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity character_counter is port
(
	pixel_number : out std_logic_vector(3 downto 0);
	character_number : out integer;
	end_line : out std_logic;
	clk : in std_logic;
	rs : in std_logic
);
end entity character_counter;

architecture a0 of character_counter is

	signal pix_num : std_logic_vector(3 downto 0);
	signal char_num : integer;
	signal eol : std_logic;

begin

	pixel_number <= pix_num;
	character_number <= char_num;
	end_line <= eol;

	counter : process (clk, rs)
	begin
		if (rising_edge(clk)) then
			if (rs = '1') then
				pix_num <= "0000";
				char_num <= 0;
				eol <= '0';
			else
				if (pix_num = "1001") then
					pix_num <= "0000";
					char_num <= char_num + 1;
				else
					pix_num <= std_logic_vector(unsigned(pix_num) + 1);
					char_num <= char_num;
				end if;
				if (char_num = 79) then
					char_num <= 0;
					eol <= eol;
				elsif (char_num = 0) then
					eol <= '1';
					char_num <= char_num;
				else
					char_num <= char_num;
					eol <= '0';
				end if;
			end if;
		else
			pix_num <= pix_num;
			char_num <= char_num;
			eol <= eol;
		end if;
	end process counter;

end architecture a0;