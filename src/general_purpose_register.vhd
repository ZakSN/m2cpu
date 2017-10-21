library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity general_purpose_register is port
(
	ai  : in std_logic_vector(7 downto 0); -- a data in
	bi  : in std_logic_vector(7 downto 0); -- b data in
	do	 : out std_logic_vector(7 downto 0); --data out
	lb	 : in std_logic; --load from bus
	la  : in std_logic; --load from alu
	oe  : in std_logic; --out put enable (active high)
	rs  : in std_logic; --asynchronus reset (active high, resets to zero)
	clk : in std_logic
);
end entity general_purpose_register;

architecture a0 of general_purpose_register is

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

	signal a_in : std_logic_vector(7 downto 0);
	signal a_out : std_logic_vector(7 downto 0);
	signal ba : std_logic_vector(1 downto 0);
	signal ld_a : std_logic;
	
begin
	
	ba <= lb & la;
	
	with ba select
		a_in <= bi when "10",
				  ai when "01",
				  "00000000" when others;
				  
	ld_a <= lb XOR la;
	
	a_reg : component register_8bit port map
	(
		di => a_in,
		do => a_out,
		ld => ld_a,
		oe => oe,
		rs => rs,
		clk => clk
	);
	
	do <= a_out;

end architecture a0;