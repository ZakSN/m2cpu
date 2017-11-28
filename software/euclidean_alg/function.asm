:loop
	LDA +:return
	PHA
	LDA -:return
	PHA
	LDG +:func
	LDH -:func
	JMP
:return
	LDG +:loop
	LDH -:loop
	JMP
:func
	PPH
	PPG
	JMP
