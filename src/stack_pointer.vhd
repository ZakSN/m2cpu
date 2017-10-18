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

	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		oe  : in std_logic; --out put enable (active high)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;
	
	signal addrin : std_logic_vector(7 downto 0);
	signal addrout : std_logic_vector(7 downto 0);
	signal lpp  : std_logic_vector(2 downto 0);
	signal ldaddr : std_logic;
	
begin

	lpp <= ld & ph & pp;
	with lpp select
		addrin <= di when "100",
				    std_logic_vector(unsigned(addrout) + 1) when "010",
					 std_logic_vector(unsigned(addrout) - 1) when "001",
					 "00000000" when others;
	ldaddr <= ld OR ph OR pp;
	
	sp_reg : component register_8bit port map
	(
		di => addrin,
		do => addrout,
		ld => ldaddr,
		oe => oe,
		rs => rs,
		clk => clk
	);
	
	do <= addrout;

end architecture a0; 