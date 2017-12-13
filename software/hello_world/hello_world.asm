$H 0x48
$e 0x65
$l 0x6c
$o 0x6F
$comma 0x2C
$space 0x20
$w 0x77
$r 0x72
$d 0x64
$center 0xFC
$cursor 0x11

:start
	LDY 0x01

	LDG $center
	LDH $cursor
	LDA $H
	LDM A
	LDX H
	ADD

	LDH A
	LDA $e
	LDM A
	LDX H
	ADD

	LDH A
	LDA $l
	LDM A
	LDX H
	ADD

	LDH A
	LDA $l
	LDM A
	LDX H
	ADD

	LDH A
	LDA $o
	LDM A
	LDX H
	ADD

	LDH A
	LDA $comma
	LDM A
	LDX H
	ADD

	LDH A
	LDA $space
	LDM A
	LDX H
	ADD

	LDH A
	LDA $w
	LDM A
	LDX H
	ADD

	LDH A
	LDA $o
	LDM A
	LDX H
	ADD

	LDH A
	LDA $r
	LDM A
	LDX H
	ADD

	LDH A
	LDA $l
	LDM A
	LDX H
	ADD

	LDH A
	LDA $d
	LDM A
	LDX H
	ADD

	LDG +:cursor_loop
	LDH -:cursor_loop

$indices 0x0A
$index_1 0x01
$index_2 0x02
$cursor_char 0x8E

:cursor_loop
	PHA
	LDY 0x01
	LDA 0x00
	LDG $indices
	LDH $index_1
	LDM A
	LDH $index_2
	LDM A
	#loop 1
	:loop_1
		#loop 2
		:loop_2
			LDX 0x00
			#loop 3
			:loop_3
				ADD
				LDG +:loop_3
				LDH -:loop_3
				LDX A
				#time to kill
				BZS
				JMP
			#end loop 3
			LDG $indices
			LDH $index_2
			LDX M
			ADD
			LDM A
			LDG +:loop_2
			LDH -:loop_2
			BZS
			JMP
		#end loop 2
		LDG $indices
		LDH $index_1
		LDX M
		ADD
		LDX A
		LDY 0x10
		SUB
		LDM A
		LDY 0x01
		LDG +:loop_1
		LDH -:loop_1
		BZS
		JMP
	#end loop 1
	
	LDG $center
	PPA
	LDH A
	LDX M
	LDY $cursor_char
	SUB
	LDX $space
	BZC
	LDM X
	BZS
	LDM Y

	LDA H
	LDG +:cursor_loop
	LDH -:cursor_loop
	JMP
