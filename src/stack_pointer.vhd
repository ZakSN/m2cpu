library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer is port
(
	pi	 : in std_logic_vector(7 downto 0); --pointer in
	po	 : out std_logic_vector(7 downto 0); --pointer out
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
	
	signal ptr_in : std_logic_vector(7 downto 0);
	signal ptr_out : std_logic_vector(7 downto 0);
	signal lpp  : std_logic_vector(2 downto 0);
	signal ld_ptr : std_logic;
	
begin

	lpp <= ld & ph & pp;
	with lpp select
		ptr_in <= pi when "100",
				    std_logic_vector(unsigned(ptr_out) + 1) when "010",
					 std_logic_vector(unsigned(ptr_out) - 1) when "001",
					 "00000000" when others;

	ld_ptr <= ld XOR ph XOR pp;
	
	sp_reg : component register_8bit port map
	(
		di => ptr_in,
		do => ptr_out,
		ld => ld_ptr,
		oe => oe,
		rs => rs,
		clk => clk
	);
	
	po <= ptr_out;

end architecture a0; 