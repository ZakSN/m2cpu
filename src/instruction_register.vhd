library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_register is port
(
	ii	 : in std_logic_vector(7 downto 0); -- instruction in
	io	 : out std_logic_vector(7 downto 0); -- instruction out
	ld	 : in std_logic; -- load (on rising edge)
	inc : in std_logic; -- increment instruction
	rs  : in std_logic; -- asynchronus reset (active high, resets to zero)
	clk : in std_logic
);
end entity instruction_register;

architecture a0 of instruction_register is 

	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;
	
	signal inst_in : std_logic_vector(7 downto 0);
	signal inst_out : std_logic_vector(7 downto 0);
	signal li : std_logic_vector(1 downto 0);
	signal ld_inst : std_logic;

begin

	li <= ld & inc;
	
	with li select
		inst_in <= ii when "10",
					  std_logic_vector(unsigned(inst_out) + 1) when "01",
					  "00000000" when others;

	ld_inst <= ld XOR inc;
	
	ir : component register_8bit port map
	(
		di => inst_in,
		do => inst_out,
		ld => ld_inst,
		rs => rs,
		clk => clk
	);

	io <= inst_out;
	
end architecture a0;