#read each byte of a string into location 0xFFFF stopping when '\0' is encountered
#think 'serial out' loosely speaking

#lower case letters followed by a ':' always resolve to a number
#if no literal follows number is an implicit address e.g. 'start'
#if the literal is followed by a colon it is the first address of the following byte string
#otherwise it's just a value
#assmebler (you) will generate an error if a 16bit literal is passed as an 8bit argument

start: #(implicitly address 0x0100)
	LDY 0x01 #load increment value in Y-register
	LDX base #load base (0xFF) in X-register
loop: #(implicityl address 0x0102)
	LDG X #load X in G-register (implicit MSB of address)
	LDH 0x00 #load zero in H-register (implicit LSB of address)
	LDA M #load memory (address GH) into A-register (accumulator)
	LDG target_hi #load G, and then H with the address of our 'serial port'
	LDH target_lo
	LDM A #load memory (address GH) with the accumulator
	BZC #branch if Z flag is clear if A!=0
	JMP end #branch false; Z flag is set therefore A=0
	ADD #branch true; A now contains X + Y
	LDX A #load X with X + Y (in effect x=x+1 (since y=1))
	JMP loop #load the address of loop: into the PC
end: #(implicitly 0x010D)
	HLT #stop execution; string has been shifted out
#our string at 0xCC00-0xCC0B
message:
	0xCC00: 'H','E','L','L','O',' ','W','O','R','L','D','\0'
target_hi:
	0xFF
target_lo:
	0xFF
base:
	0xCC
