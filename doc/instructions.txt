abreviations:
8 bit general purpose registers:
	A: A register (accumulator)
	G: G register (hi address byte)
	H: H register (lo address byte)
	X: X register
	Y: Y register
8 bit special purpose registers:
	S: status register bits 3 downto 0 are flags `z', `n', `c', `o'
	SP: stack pointer
16 bit registers:
	PC: program counter (native 16 bit)
	GH: composite register of the G and H registers. treated as a single 16
	    bit register by some instructions. G is hi byte H is lo byte
other:
	M: memory
	ALU: arithmetic and logic unit
	MSB: most significant bit
	LSB: least significant bit
flags:
	z: (zero) set if result of last ALU operation was zero
	n: (negative) set if MSB of result of last ALU operation was one, i.e.
	   result was negative.
	c: (carry) set if: there was an unsigned carry, or borrow. also set to
	   the extra bit of a bit shift operation.
	o: (overflow) set if: the result of a signed arithmetic operation 
	   didn't make sense. i.e. negative + negative = positive
	note: if the last ALU operation didn't effect the flag it is set to 0.
	      flags can also be manually set and cleared progmatically.

no-operation:
	- description: do nothing for one execute state.
	- mnemonic: NOP
	- microcode: signle state instruction
		state 1: unassert all control lines
	-number: 1

8 bit general purpose load:
	- description: load [q] with [r]. Where [q] and [r] are general purpose
	  registers, or memory. load operations on memory occur at the address 
	  stored in the `GH' register. the general purpose load instructions are
	  completely orthogonal. LD[q] [q] is invalid, and symantically 
	  equivalent to the no-operation instruction.
	- mnemonic schema: LD[q] [r]
	- list: LDA G, LDA H, LDA X, LDA Y, LDA M,
		LDG A, LDG H, LDG X, LDG Y, LDG M,
		LDH A, LDH G, LDH X, LDH Y, LDH M,
		LDX A, LDX G, LDX H, LDX Y, LDX M,
		LDY A, LDY G, LDY H, LDY X, LDY M,
		LDM A, LDM G, LDM H, LDM X, LDM Y
	- microcode: two state instruction
		state 1: select [r] with data bus mux. assert `la' line on [q].
			 select `GH' with the address bus mux (only need if 
			 [q] or [r] is M, but could be implemented across the
			 board)
		state 2: unassert `la' line on [q].
		note: for memory `la' is `wren'
	- number: 30

8 bit load from memory:
	- description: load [q] with #, where [q] is an 8 bit register and # is
	  an 8 bit hexadecimal literal. Note LDM # is invalid. copying a literal
	  from one location to another must be done with multiple instructions.
	  the number to load is stored in the address immediately following the
	  instruction. this means that the assembled instruction TAKES TWO 
	  ADDRESSES.
	- mnemonic schema: LD[q] #
	- list: LDA #, LDG #, LDH #, LDX #,LDY #
	- microcode: 3 state instruction.
		state 1: increment the program counter
		state 2: select memory with the data bus mux. select the `GH'
			 register with the address bus mux. assert `la' on [q]
		state 3: un assert `la' line on [q].
	- number: 4

16 bit general purpose load:
	- description: load [qq] with [rr]. where [qq] and [rr] are 16 bit
	  registers. similar to `8 bit general purpose load' instruction.
	- mnemonic schema: LD[qq] [rr]
	- list: LDGH PC, LDPC GH
	- microcode: two state instruction
		state 1: select [rr] with address bus mux. assert load line(s) 
		on [qq].
		state 2: unassert load line on [qq].
	- number: 2

load y with status:
	- description: load y register with the status register.
	- mnemonic: LDY S
	- microcode: single state instruction
		state 1: assert `lb' line on the y register
	- number: 1

x/stack pointer interchange:
	- description: load x or stack pointer with stack pointer or x.
	- mnemonic schema: LD[X|SP] [SP|X]
	- list: LDX SP, LDSP X
	- microcode: single state instruction
		state 1: for LDX SP assert `lb' on the x register. for LDSP X 
			 assert `ld' on stack pointer.
	- number: 2

set status flag:
	- description: set [q] flag in the status register, where [q] is one of
	  the available flags: `z', `n', `c', `o'.
	- mnemonic schema: S[q]F
	- list: SZF, SNF, SCF, SOF
XXXXXXXX- microcode: signle state instruction
XXXXXXXX	state 1: LOGIC NOT PROPERLY IMPLEMENTED
	- number: 4

clear status flag:
	- description: clear [q] flag in the status register, where [q] is one of
	  the available flags: `z', `n', `c', `o'.
	- mnemonic schema: C[q]F
	- list: CZF, CNF, CCF, COF
XXXXXXXX- microcode: single state instruction
XXXXXXXX	state 1: LOGIC NOT PROPERLY IMPLEMENTED
	- number: 4

push general purpose register to stack:
	- description: push [q] to the stack, where [q] is a general purpose 
	  register. stack grows towards higher addresses, so a push incrementes
	  the stack pointer. the stack is the zero page of memory.
	- mnemonic schema: PH[q]
	- list: PHA, PHG, PHH, PHX, PHY
	- microcode: three state instruction
		state 1: assert `ph' line on stack pointer
		state 2: select [q] on data bus mux. select stack pointer on
			 address bus mux. assert `wren' line on memory.
		state 3: unassert `wren' line on memory.
	- number: 5

pop general purpose register from stack:
	- description: pop from the stack to [q], where [q] is a general 
	  purpose register. stack grows towards higher addresses so a pop
	  decrements the stack pointer. the stack is the zero page of memory.
	- mnemonic schema: pp[q]
	- list: PPA, PPG, PPH, PPX, PPY
	- microcode: three state instruction
		state 1: assert `pp' line on stack pointer
		state 2: select memory on data bus mux. select stack pointer on
			 address bus mux. assert `la' line on [q].
		state 3: unassert `la' line on [q].
	- number: 5

register ALU operation:
	- description: perform the selected ALU operation on the X and Y 
	  registers, store the result in the A register.
	- mnemmonic and descriptions:
	  ADD store X + Y in A
	  SUB store X - Y in A
	  AND store X AND Y in A
	  NND store X NAND Y in A
	  ORR store X OR Y in A
	  XOR store X XOR Y in A
	- microcode: two state instruction
		state 1: select operation on ALU. select Y register on ALU bus
			 mux. assert `lb' on A. assert `ld' on status register
		state 2: unassert `lb' and `ld' lines on A and S registers.
	- number: 6

addressed ALU operation:
	- description: perform the selected ALU operation on the X register and
	  the value stored in memory at the address held in `GH'. the result is
	  stored in A.
	- mnemonic and description
	  ADA store X + M@GH in A
	  SUA store X - M@GH in A
	  ANA store X AND M@GH in A
	  NNA store X NAND M@GH in A
	  ORA store X OR M@GH in A
	  XOA store X XOR M@GH in A
	- microcode: two state instruction
		state 1: select `GH' on the address bus mux. select memory on 
			 the data bus mux. select data bus on ALU bus mux.
			 select operation on ALU. assert `lb' on A and `ld' on
			 status register.
		state 2: unassert `lb' and `ld' lines on A and S registers.
	- number: 6

immediate ALU operation:
	- description: perform the selected ALU operation on the X register and
	  a literal hexadecimal number. store the result in A the literal number
	  is stored in the address immediately following the instruction. THIS 
	  INSTRUCTION TAKES TWO ADDRESSES.
	- mnemonic and description:
	  ADI # store X + # in A
	  SUI # store X - # in A
	  ANI # store X AND # in A
	  NNI # store X NAND # in A
	  ORI # store X OR # in A
	  XOI # store X XOR # in A
	- microcode: three state instruction
		state 1: increment PC
		state 2: select `PC' on address bus mux. select memory on the 
			 data bus mux. select data bus on the ALU bus mux. 
			 select operation on ALU. assert `lb' on A and `ld' on
			 status register.
		state 3: unassert `lb' and `ld' lines on A and S registers.
	- number: 6

signle operand ALU operation:
	- description: perform the selected ALU operation on the X register.
	  store the result in the A register.
	- mnemonic and description:
	  STL shift X towards left. MSB is thrown out (carry flag) LSB is set 
	      to 0.
	  STR shift X towards right. LSB is thrown out (carry flag) MSB is set
	      to 0.
	- microcode: two state instruction
		state 1: select operation on ALU. assert `lb' on A and `ld' on
			 status register.
		state 2: unassert `lb' and `ld' lines on A and status register
	- number: 2

conditional branch instructions:
	- description: branch if true. execute the immediately following 
	  instruction if the condition is false. if the condition is true skip
	  the immediately following instruction and execute the next one 
	  instead. note: a false result gets only one instruction to use before
	  the true branch is executed. this means that a useful idiom is the 
	  'escape address' as follows:
	 
	  	.
	 	LDG <from somewhere> #load the hi byte of an escape address
	 	LDH <from somewhere> #load the lo byte
	  	.
		BZS #branch
		LDPC GH #load the PC with the escape address (jump)
		<continue on>
		.

	- mnemonic schema: B[f][s], where [f] is one of the status flags: `z',
	  `n', `c', `o'. and [s] is a state (S)et (1) or (C)lear (0)
	- list: BZS, BZC, BNS, BNC, BCS, BCC, BOS, BOC
	- microcode: single state instruction
		state 1: set `inc' line on `PC' to the value of the appropriate
			 flag.
	- number: 8
	 
total number of instructions: 86
