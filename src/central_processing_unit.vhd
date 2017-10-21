library ieee;
use ieee.std_logic_1164.all;

entity central_processing_unit is port
(

);
end entity central_processing_unit;

architecture a0 of central_processing_unit is

	------------------component section-------------------------
	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;
	
	component arithmetic_logic_unit is port
	(
		xin : in std_logic_vector(7 downto 0); --operand from x register
		yin : in std_logic_vector(7 downto 0); --operand from the y register
		res : out std_logic_vector(7 downto 0); --result of operation between x and y
		opr : in std_logic_vector(2 downto 0); --the operation to perform
		zro, neg, cry, ovf : out std_logic --zero, negative, carry, overflow flag outputs
	);
	end component arithmetic_logic_unit;
	
	component stack_pointer is port
	(
		pi	 : in std_logic_vector(7 downto 0); --data in
		po	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		ph  : in std_logic; --push (increment address)
		pp  : in std_logic; --pop (decrement address)
		clk : in std_logic
	);
	end component stack_pointer;
	
	component program_counter is port
	(
		ai  : in std_logic_vector(15 downto 0); -- address in
		ao  : out std_logic_vector(15 downto 0); -- address out
		inc : in std_logic; -- increase address
		ld  : in std_logic; -- load
		rs  : in std_logic; -- reset
		clk : in std_logic
	);
	end component program_counter;
	
	component general_purpose_register is port
	(
		ai  : in std_logic_vector(7 downto 0); --a data in
		bi  : in std_logic_vector(7 downto 0); --b data in
		do	 : out std_logic_vector(7 downto 0); --data out
		lb	 : in std_logic; --load from bus
		la  : in std_logic; --load from alu
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component general_purpose_register;
	
	------------------signal section-------------------------

begin

end architecture a0;