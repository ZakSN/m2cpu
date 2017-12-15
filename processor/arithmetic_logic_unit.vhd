library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arithmetic_logic_unit is port
(
	xin : in std_logic_vector(7 downto 0); --operand from x register
	yin : in std_logic_vector(7 downto 0); --operand from the y register
	res : out std_logic_vector(7 downto 0); --result of operation between x and y
	opr : in std_logic_vector(2 downto 0); --the operation to perform
	zro, neg, cry, ovf : out std_logic --zero, negative, carry, overflow flag outputs
);
end entity arithmetic_logic_unit;

architecture a0 of arithmetic_logic_unit is
	
	--9 bit collections to perserve carry bit
	signal x_u9     : unsigned(8 downto 0);
	signal y_u9     : unsigned(8 downto 0);
	signal add_slv9 : std_logic_vector(8 downto 0);
	signal sub_slv9 : std_logic_vector(8 downto 0);
	
	--8 bit output vector
	signal add_slv8 : std_logic_vector(7 downto 0);
	signal sub_slv8 : std_logic_vector(7 downto 0);
	
	signal ppn : std_logic;
	signal nnp : std_logic;
	
	signal result : std_logic_vector(7 downto 0);

begin
   
	res <= result;
	
	--------------artihmetic--------------
	x_u9 <= unsigned('0' & xin);
	y_u9 <= unsigned('0' & yin);
	add_slv9 <= std_logic_vector(x_u9 + y_u9);
	sub_slv9 <= std_logic_vector(x_u9 - y_u9);
	add_slv8 <= add_slv9(7 downto 0);
	sub_slv8 <= sub_slv9(7 downto 0);
	
	--------------select output--------------
	with opr select
		result <= add_slv8 when "000", --x + y
					 sub_slv8 when "001", --x - y
					 xin AND  yin when "010", --x AND y
					 xin NAND yin when "011", --x NAND y
					 xin OR   yin when "100", --x OR y
					 xin XOR  yin when "101", --x XOR y
					 xin(6 downto 0) & '0' when "110", --shift x left (STL)
					 '0' & xin(7 downto 1) when "111", --shift x rgiht (STR)
					 "00000000" when others;
				 
	--------------flag set logic--------------
	with opr select
		cry <= add_slv9(8) when "000", --carry (addition)
				 sub_slv9(8) when "001", --borrow (subtraction)
				 xin(7) when "110", --leftmost bit of shift
				 xin(0) when "111", --rightmost bit of shift
				 '0' when others;

	ppn <= NOT(xin(7)) AND NOT(yin(7)) AND result(7); --positive arguments, negative result
	nnp <= xin(7) AND yin(7) AND NOT(result(7)); --negative arguments, positive result
	ovf <= ppn OR nnp when opr="000" else '0'; --overflow only occurs during (signed) addition
	
	neg <= result(7); --sign of result
	
	zro <= '1' when result="00000000" else '0'; --result is zero
				
end architecture a0;