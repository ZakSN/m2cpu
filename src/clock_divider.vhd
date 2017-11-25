library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is port
(
	clkin : in std_logic; --50MHz clock from the board
	rst : in std_logic; --async reset
	clkout : out std_logic --slow clock (human visible)
);
end entity clock_divider;

architecture a0 of clock_divider is

	constant q_sec : integer := 5000000;
	signal clk_count : unsigned(31 downto 0);
	signal q_sec_pulse : std_logic;
	
	signal tq : std_logic;

begin

	quarter_second_counter : process (clkin, rst)
	begin
		if (rst = '1') then
			clk_count <= to_unsigned(0, 32);
			q_sec_pulse <= '0';
		elsif (rising_edge(clkin)) then
			if (clk_count = to_unsigned(q_sec, 31)) then
				clk_count <= to_unsigned(0, 32);
				q_sec_pulse <= '1';
			else
				clk_count <= clk_count + 1;
				q_sec_pulse <= '0';
			end if;
		else
			clk_count <= clk_count;
			q_sec_pulse <= q_sec_pulse;
		end if;
	end process quarter_second_counter;
	
	tff : process (q_sec_pulse, rst)
	begin
		if (rst = '1') then
			tq <= '0';
		elsif (rising_edge(q_sec_pulse)) then
			if (tq = '0') then
				tq <= '1';
			else
				tq <= '0';
			end if;
		else
			tq <= tq;
		end if;
	end process tff;
	
	clkout <= tq;

end architecture a0;
