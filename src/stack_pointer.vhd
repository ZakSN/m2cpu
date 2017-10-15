library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer is port
(
	di	 : in std_logic_vector(7 downto 0); --data in
	do	 : out std_logic_vector(7 downto 0); --data out
	ld	 : in std_logic; --load (on rising edge)
	oe  : in std_logic; --out put enable (active high)
	rs  : in std_logic; --asynchronus reset (active high, resets to zero)
	ph  : in std_logic; --push (increment address)
	pp  : in std_logic; --pop (decrement address)
	clk : in std_logic
);
end entity stack_pointer;

architecture a0 of stack_pointer is 

	signal d : std_logic_vector(7 downto 0);
	signal lpp : std_logic_vector(2 downto 0);
	
begin

	--tristate buffer
	do <= d when oe = '1' else "ZZZZZZZZ";
	
	lpp <= ld & ph & pp;

	--register process
	dff : process (clk, ld, rs)
	begin
		if (rs = '1') then
			d <= "00000000";
		elsif (rising_edge(clk)) then
			if (lpp = "100") then --reload
				d <= di;
			elsif (lpp = "010") then --increment
				d <= std_logic_vector(unsigned(d) + 1);
			elsif (lpp = "001") then --decrement
				d <= std_logic_vector(unsigned(d) - 1);
			else
				d <= d;
			end if;
		else
			d <= d;
		end if;
	end process dff;

end architecture a0; 