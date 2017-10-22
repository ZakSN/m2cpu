library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is port
(
	clkin : in std_logic; --50MHz clock from the board
	rst : in std_logic; --async reset
	clkout : out std_logic --slow clock (human visible)
);
end clock_divider;

architecture a0 of clock_divider is

	signal count : unsigned(0 to 31);
	signal stop :   std_logic;
	constant MainFreq : integer := 50000000; -- ~1Hz

begin

	counter: process (clkin, rst)
	begin
	if (rst = '0') then
		count <= to_unsigned(MainFreq, 32);
		stop <= '0';
	elsif (rising_edge(clkin)) then
		if(count = 0) then
			--reset count to 50m
			count <= to_unsigned(MainFreq, 32);
			stop <= '1';
		else
			count <= count - 1;
			stop <= '0';
		end if;
	else
			count <= count;
			stop <= stop;
		end if;
	end process;

	clkout_gen: process(clkin)
	begin
		if(rising_edge(clkin)) then
			clkout <= stop;
		end if;
	end process;

end architecture a0;
