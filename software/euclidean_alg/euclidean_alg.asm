# simple implementation of the euclidean algorithim for signed single byte ints
# uses code from software/simple_divide_simple_divide.asm
# basically no error checking so it's probably pretty easy to break

# finds GCD(a, b) where a > b
$a 0x19 #25_DEC
$b 0x03 #3_DEC
$base_addr 0xFF
$gcd 0x00
$dividend 0x01
$divisor 0x02
$remainder 0x03
$quotient 0x04

:init
	LDG $base_addr
	LDH $dividend
	LDA $a
	LDM A
	LDH $divisor
	LDA $b
	LDM A
	LDH $remainder
	LDA 0x00
	LDM A
	LDH $gcd
	LDM A
:main_loop
	#jump to the division routine
	#the stack ops are a little pretentious since we only call the function
	#once
	LDA +:return_div
	PHA
	LDA -:return_div
	PHA
	LDG +:division
	LDH -:division
	JMP
:return_div
	#return from division routine
	#check if the remaider is zero (end condition)
	LDG $base_addr
	LDH $remainder
	LDX M
	LDY 0x00
	LDG +:end_condition
	LDH -:end_condition
	ADD
	BZC
	JMP
	#if we're not done move divisor -> dividend and remainder -> divisor
	LDG $base_addr
	LDH $divisor
	LDA M
	LDH $dividend
	LDM A
	LDH $remainder
	LDA M
	LDH $divisor
	LDM A
	# reset the division variables
	LDG $base_addr
	LDH $quotient
	LDA 0x00
	LDM A
	LDH $remainder
	LDM A
	#and repeat
	LDG +:main_loop
	LDH -:main_loop
	JMP

:end_condition
	#remainder was zero. copy divisor to gcd
	LDG $base_addr
	LDH $divisor
	LDA M
	LDH $gcd
	LDM A
	LDG +:halt
	LDH -:halt
:halt
	JMP

:division
	#check to see if divisor is zero
	LDG $base_addr
	LDH $divisor
	LDX M
	LDY 0x00
	ADD
	# just give up if it is, strictly incorrect for this application but w/e
	LDG +:halt
	LDH -:halt
	BZC
	JMP

:div_loop
#check if dividend is zero
	LDG $base_addr
	LDH $dividend
	LDX M
	LDY 0x00
	ADD
	LDG +:end_div
	LDH -:end_div
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
	LDG +:div_loop
	LDH -:div_loop
	JMP

:got_remainder
	LDG $base_addr
	LDH $remainder
	LDM X
	LDG +:end_div
	LDH -:end_div
	JMP

:end_div
	#return from the function call
	PPH
	PPG
	#LDG +:return_div
	#LDH -:return_div
	JMP
