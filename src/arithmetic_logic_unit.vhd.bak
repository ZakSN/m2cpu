library ieee;
use ieee.std_logic_1164.all;

entity arithmetic_logic_unit is port
(
	x_arg  : in std_logic_vector(7 downto 0); --operand from x register
	y_arg  : in std_logic_vector(7 downto 0); --operand from the y register
	acc_in : in std_logic_vector(7 downto 0);
	result : out std_logic_vector(7 downto 0); --result of operation between x and y
	opr    : in std_logic_vector(2 downto 0); --the operation to perform
	zro, neg, cry, ovf : out std_logic --zero, negative, carry, overflow flag inputs
):
end entity arithmetic_logic_unit;

architecture a0 of aritmetic_logic_unit is

	signal x   : unsigned(7 downto 0);
	signal y   : unsigned(7 downto 0);
	signal add : std_logic_vector(7 downto 0);
	signal sub : std_logic_vector(7 downto 0);

begin
   
	--A/L logic:
	x <= signed(x_arg);
	y <= signed(y_arg);
	add <= std_logic_vector(x + y);
	sub <= std_logic_vector(x - y);
	
	with opr select
		result <= add 							 when "000", --x + y
					 sub 							 when "001", --x - y
					 x_arg AND y_arg 			 when "010", --x AND y
					 x_arg NAND y_arg 		 when "011", --x NAND y
					 x_arg OR y_arg 			 when "100", --x OR y
					 x_arg XOR y_arg         when "101", --x XOR y
					 x_arg(6 downto 0) & '0' when "110", --shift x left (STL)
					 '0' & x_arg(7 downto 1) when "111", --shift x rgiht (STR)
					 "00000000" 				 when others;
					
	--flag set logic:
	with opr select
		cry <= x_arg(7) when "110",
				 x_arg(0) when "111",
				
end architecture a0;