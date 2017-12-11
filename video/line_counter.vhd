library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity line_counter is port
(
	scan_line_number : out std_logic_vector(4 downto 0);
	line_number : out integer;
	rs : in std_logic;
	clk : in std_logic
);
end entity line_counter;

architecture a0 of line_counter is

	signal sl_num : std_logic_vector(4 downto 0);
	signal l_num : integer;

begin

	scan_line_number <= sl_num;
	line_number <= l_num;
	
	counter : process(clk, rs)
	begin
		if (rising_edge(clk)) then
			if (rs = '1') then
				sl_num <= "11000"; -- tweak to fix OBOE somewhere... 
				l_num <= 24;
			else
				if (sl_num = "11000") then
					sl_num <= "00000";
					l_num <= l_num + 1;
				else
					sl_num <= std_logic_vector(unsigned(sl_num) + 1);
					l_num <= l_num;
				end if;
				if (l_num = 24) then
					l_num <= 0;
				end if;
			end if;
		else
			sl_num <= sl_num;
			l_num <= l_num;
		end if;
	end process counter;

end architecture a0;