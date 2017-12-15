library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is port
(
	sw_in : in std_logic;
	sw_out : out std_logic;
	clk : in std_logic
);
end entity debouncer;

architecture a0 of debouncer is

	signal q1 : std_logic;
	signal q2 : std_logic;
	
	constant max_count : integer := 1000000;
	signal stop_count : std_logic;
	signal count : unsigned(31 downto 0);
	
begin

	-- synchronizer:
	dff1 : process (clk)
	begin
		if (rising_edge(clk)) then
			q1 <= sw_in;
		else
			q1 <= q1;
		end if;
	end process dff1;
	
	dff2 : process (clk)
	begin
		if (rising_edge(clk)) then
			q2 <= q1;
		else
			q2 <= q2;
		end if;
	end process dff2;

	counter : process (clk)
	begin
		if (rising_edge(clk)) then
			if (q2 = '1') then
				if (count = to_unsigned(max_count, 32)) then
					stop_count <= '1';
				else
					stop_count <= '0';
					count <= count + 1;
				end if;
			else
				count <= to_unsigned(0, 32);
				stop_count <= '0';
			end if;
		else
			count <= count;
			stop_count <= stop_count;
		end if;
	end process counter;
	
	sw_out <= stop_count;
	
end architecture a0;