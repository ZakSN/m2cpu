library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vertical_signal is port
(
	signal vsync_out : out std_logic; -- vertical sync
	signal len_out : out std_logic; -- line enable
	signal clk : in std_logic; -- line clock in
	signal rs : in std_logic -- async reset
);
end entity vertical_signal;

architecture a0 of vertical_signal is

	constant line_number : integer := 524;
	signal line_counter : integer := 0;
	signal len : std_logic;
	signal vsync : std_logic;

begin
	
	vsync_out <= vsync;
	len_out <= len;
	
	vs : process (clk, rs)
	begin
		if (rs = '1') then
			len <= '0';
			vsync <= '0';
			line_counter <= 0;
		elsif (rising_edge(clk)) then
			if (line_counter = line_number) then
				line_counter <= 0;
			else
				line_counter <= line_counter + 1;
			end if;
			if (line_counter < 2) then
				len <= '0';
				vsync <= '0';
			elsif (line_counter < 35) then
				len <= '0';
				vsync <= '1';
			elsif (line_counter > 515) then
				len <= '0';
				vsync <= '1';
			else
				len <= '1';
				vsync <= '1';
			end if;
		else 
			len <= len;
			vsync <= vsync;
			line_counter <= line_counter;
		end if;
	end process vs;

end architecture a0;