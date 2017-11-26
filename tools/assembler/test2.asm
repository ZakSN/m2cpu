#Simple test file for comparing hand assembled to assembler output
#some constants/symbols:
$last_addr 0xFF
$value 0xAA
:start #Technically redundant I guess...
#Just load 0xFFFF with 0xAA 
	LDG $last_addr
	LDH $last_addr
	LDA $value
	LDM A
	LDG +:forward_tag
	LDH -:forward_tag
	ADD
	BZC
:halt_loop
# loop when operation is done
	LDG +:halt_loop
	LDH -:halt_loop
	JMP
:forward_tag
	NOP #need to jump to an address

0x56
0x57
0x58
0x59
0x5A
0x5B
0x5C
0x5D
0x5E
0x5F
