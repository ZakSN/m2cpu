# Simple multiplication program
# repeated addition algorithm

#addresses
$base_addr 0xFF
$multiplier 0x00
$multiplicand 0x01
$product 0x02

#inputs
$operand1 0x08
$operand2 0x10

:start
	LDG $base_addr
	LDH $multiplier
	LDA $operand1
	LDM A
	LDH $multiplicand
	LDA $operand2
	LDM A
	LDH $product
	LDA 0x00
	LDM A
:loop
	#check if the multiplier is zero and prepare an escape address
	LDG $base_addr
	LDH $multiplier
	LDX M
	LDY 0x00
	LDG +:halt
	LDH -:halt
	ADD
	BZC #if Z was clear $multiplier + 0 != 0
	JMP

	#add multiplicand to product
	LDG $base_addr
	LDH $multiplicand
	LDX M
	LDH $product
	LDY M
	ADD
	LDM A

	#decrement multiplier
	LDH $multiplier
	LDX M
	LDY 0x01
	SUB
	LDM A
	#repeat
	LDG +:loop
	LDH -:loop
	JMP

	#halt loop
	LDG +:halt
	LDH -:halt
:halt
	JMP
