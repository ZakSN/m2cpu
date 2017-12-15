library ieee;
use ieee.std_logic_1164.all;

entity register_8bit is port
(
	di	 : in std_logic_vector(7 downto 0); --data in
	do	 : out std_logic_vector(7 downto 0); --data out
	ld	 : in std_logic; --load (on rising edge)
	rs  : in std_logic; --asynchronus reset (active high, resets to zero)
	clk : in std_logic
);
end entity register_8bit;

architecture a0 of register_8bit is

	signal d : std_logic_vector(7 downto 0);

begin
	do <= d;
	
	--register process
	reg : process (clk, ld, rs)
	begin
		if (rs = '1') then
			d <= "00000000";
		elsif (rising_edge(clk)) then
			if (ld = '1') then
				d <= di;
			else
				d <= d;
			end if;
		else
			d <= d;
		end if;
	end process reg;
	
end architecture a0;