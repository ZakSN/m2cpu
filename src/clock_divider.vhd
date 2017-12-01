library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is 
generic
(
	half_period : integer
);
port
(
	clkin : in std_logic; --50MHz clock from the board
	rst : in std_logic; --async reset
	clkout : out std_logic --slower clock
);
end entity clock_divider;

architecture a0 of clock_divider is

	constant HT : integer := half_period;
	signal clk_count : unsigned(31 downto 0);
	signal HT_pulse : std_logic;
	
	signal tq : std_logic;

begin

	half_period_counter : process (clkin, rst)
	begin
		if (rst = '1') then
			clk_count <= to_unsigned(0, 32);
			HT_pulse <= '0';
		elsif (rising_edge(clkin)) then
			if (clk_count = to_unsigned(HT, 31)) then
				clk_count <= to_unsigned(0, 32);
				HT_pulse <= '1';
			else
				clk_count <= clk_count + 1;
				HT_pulse <= '0';
			end if;
		else
			clk_count <= clk_count;
			HT_pulse <= HT_pulse;
		end if;
	end process half_period_counter;
	
	tff : process (HT_pulse, rst)
	begin
		if (rst = '1') then
			tq <= '0';
		elsif (rising_edge(HT_pulse)) then
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
