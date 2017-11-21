# This is a full line comment
# the following is some assembly
$constant 0xFF
:start # This is an inline comment
	LDG $constant            
	LDH $constant
	LDX	 0xA0
	LDY      0x0B
:address
:second_address
   ADD


		
THISISNOTACOMMAND
	   LDM	A
	LDG +:address #high byte of address
	LDH -:second_address #low byte of address
# In General: 			
	#$... evaluates to a 8-bit literal
	#:... evaluates to a 16-bit literal (address)
	#+:... is the high byte of ...
	#-:... is the low byte of ...
