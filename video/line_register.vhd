library ieee;
use ieee.std_logic_1164.all;

entity line_register is port
(
	lri : in std_logic_vector(9 downto 0);
	lro : out std_logic_vector(9 downto 0);
	ld : in std_logic;
	rs : in std_logic;
	clk : in std_logic
);
end entity line_register;

architecture a0 of line_register is

	signal d : std_logic_vector(9 downto 0);

begin

	lro <= d;

	reg : process (clk, rs)
	begin
		if (rs = '1') then
			d <= "0000000000";
		elsif (rising_edge(clk)) then
			if(ld = '1') then
				d <= lri;
			else
				d <= d;
			end if;
		else
			d <= d;
		end if;
	end process reg;

end architecture a0;