library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is port
(
	ai  : in std_logic_vector(15 downto 0); -- address in
	ao  : out std_logic_vector(15 downto 0); -- address out
	ld  : in std_logic; -- load
	inc : in std_logic; -- increase address
	rs  : in std_logic; -- reset
	clk : in std_logic
);
end entity program_counter;

architecture a0 of program_counter is

	signal d : std_logic_vector(15 downto 0);
	signal li : std_logic_vector(1 downto 0);
	
begin

	li <= ld & inc;

	pc_reg : process (clk, ld, rs)
	begin
		if (rs = '1') then
			d <= "0000000000000100"; -- reset vector
		elsif (rising_edge(clk)) then
			if (li = "10") then
				d <= ai; -- load new address
			elsif (li = "01") then
				d <= std_logic_vector(unsigned(d) + 1); -- increment
			else
				d <= d;
			end if;
		else
			d <= d;
		end if;
	end process pc_reg;

	ao <= d;
end architecture a0;