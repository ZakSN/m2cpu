# Simple integer division of positive signed integers via repeated subtraction
# Calculates quotient and remainder

$a 0x19
$b 0x04
$base_addr 0xFF
$dividend 0x00
$divisor 0x01
$quotient 0x02
$remainder 0x03
:init
	LDG $base_addr
	LDH $dividend
	LDA $a
	LDM A
	LDH $divisor
	LDA $b
	LDM A
	LDH $quotient
	LDA 0x00
	LDM A
	LDH $remainder
	LDM A
#check to see if divisor is zero
	LDH $divisor
	LDX M
	LDY 0x00
	ADD
	LDG +:halt
	LDH -:halt
	BZC
	JMP

:loop
#check if dividend is zero
	LDG $base_addr
	LDH $dividend
	LDX M
	LDY 0x00
	ADD
	LDG +:halt
	LDH -:halt
	BZC
	JMP
#subtract divisor from dividend
	LDG $base_addr
	LDH $dividend
	LDX M
	LDH $divisor
	LDY M
	SUB
#check to see if we have a remainder
	LDG +:got_remainder
	LDH -:got_remainder
	BNC
	JMP
#write back dividend
	LDG $base_addr
	LDH $dividend
	LDM A
#increment quotient
	LDG $base_addr
	LDH $quotient
	LDX M
	LDY 0x01
	ADD
	LDM A
#repeat
	LDG +:loop
	LDH -:loop
	JMP

:got_remainder
	LDG $base_addr
	LDH $remainder
	LDM X
	LDG +:halt
	LDH -:halt
	JMP

:halt
	JMP
