# Instruction Codes, Mnemonics, and Detailed State Descriptions:
The layout of the instruction space is also presented in `doc/m2cpu_ISA.ods`

### No-operation:
- Mnemonic and Code:
	- `NOP` (0x00)
- Description: Do nothing for one EXEC state. This instruction takes 6 clks to complete
- States:
	- state 1: set control bus to 0.
- Number: 1

### General Purpose Load:
- Mnemonics and Codes:
	- `LDA G` (0x01), `LDA H` (0x03), `LDA X` (0x05) `LDA Y` (0x07)
	- `LDG A` (0x11), `LDG H` (0x13), `LDG X` (0x15) `LDG Y` (0x17)
	- `LDH A` (0x21), `LDH G` (0x23), `LDH X` (0x25) `LDH Y` (0x27)
	- `LDX A` (0x31), `LDX G` (0x33), `LDX H` (0x35) `LDX Y` (0x37)
	- `LDY A` (0x41), `LDY G` (0x43), `LDY H` (0x45) `LDY X` (0x47)
- Description: Loads 'q' with the value of 'r', where 'q' and 'r' are general purpose registers. Mnemonic schema: `LDq r`.
- States:
	- state 1: select 'r' on the data bus mux. assert `la` on 'q'
	- state 2: unassert `la` on 'q'
- Number: 20

### 16 Bit Load:
- Mnemonics and Codes:
	- `LDGH PC` (0x39)
	- `LDPC GH` (0x49)
- Description: Loads 'q' with the value of 'r', where 'q' and 'r' are 16 bit registers. Mnemonic schema: `LDq r`.
- States:
	- state 1: select 'r' on the address bus mux. assert load lines on 'q'.
	- state 2: unassert load lines on 'q'
- Number: 2

### X Register Stack Pointer Load:
- Mnemonics and Codes:
	- `LDSP X` (0x09)
	- `LDX SP` (0x19)
- Description: Load x with the stack pointer or load the stack pointer with x.
- States: 
	- state 1: assert `lb` on X for `LDX SP`, or assert `ld` on SP for `LDSP X`.
- Number: 2

### Load Y with status register:
- Mnemonics and Codes:
	- `LDY S` (0x29)
- Description: Load the Y register with the value of the status register.
- States:
	- state 1: assert `lb` on Y.
- Number: 1

### Load Memory from General Purpose Register:
- Mnemonics and Codes:
	- `LDM A` (0x60)
	- `LDM G` (0x70)
	- `LDM H` (0x80)
	- `LDM X` (0x90)
	- `LDM Y` (0xA0)
- Description: Load the memory at the address held in GH with the value of 'q' where 'q' is one of the general purpose registers.
- States:
	- state 1: select GH on the address bus mux. select 'q' on the data bus mux.
	- state 2: assert `wren`
	- state 3: unassert `wren`
- Number: 5

### Load General Purpose Register from Memory:
- Mnemonics and Codes:
	- `LDA M` (0x63)
	- `LDG M` (0x73)
	- `LDH M` (0x83)
	- `LDX M` (0x93)
	- `LDY M` (0xA3)
- Description: Load 'q' with the value of held in memory at the address GH.
- States:
	- state 1: select GH on the address bus mux. select M on the data bus mux.
	- state 2: same as state 1 (memory access)
	- state 3: assert `la` on 'q'
	- state 4: unassert `la`
- Number: 5

### Load General Purpose Register With Constant:
- Mnemonics and Codes:
	- `LDA #` (0x67)
	- `LDG #` (0x77)
	- `LDH #` (0x87)
	- `LDX #` (0x97)
	- `LDY #` (0xA7)
- Description: Load 'q' with the constant #. # is stored in the address directly following the instruction. this instruction TAKES TWO ADDRESSES.
- States:
	- state 1: select PC on the address bus mux. select M on the data bus mux. assert incpc
	- state 2: unassert incpc. maintain mux selections (memory access 1)
	- state 3: maintain mux selections (memory access 2)
	- state 4: assert `la` on 'q'
	- state 5: unassert `la` on 'q'
- Number: 5

### Push General Purpose Register To Stack:
- Mnemonics and Codes:
	- `PHA` (0xB0)
	- `PHG` (0xC0)
	- `PHH` (0xD0)
	- `PHX` (0xE0)
	- `PHY` (0xF0)
- Description: Push the contents of 'q' to the zero page stack, where 'q' is a general purpose register. The stack grows from low addresses to high addresses so this operation INCREMENTS the stack pointer.
- States:
	- state 1: select SP on address bus mux. select 'q' on data bus mux. assert `ph` on SP.
	- state 2: unassert `ph`. maintain mux selections (memory access)
	- state 3: assert `wren`
	- state 4: unassert `wren`
- Number: 5

### Pop General Purpose Register From Stack:
- Mnemonics and Codes:
	- `PPA` (0xB5)
	- `PPG` (0xC5)
	- `PPH` (0xD5)
	- `PPX` (0xE5)
	- `PPY` (0xF5)
- Description: Pop the top of the zero page stack into 'q', where 'q' is a general purpose register. The stack grows from low addresses to high addresses so this operation DECREMENTS the stack pointer.
- States: 
	- state 1: select SP on address bus mux. select M on data bus mux. assert `pp` on SP.
	- state 2: unassert `pop`. maintain mux selections (memory access 1)
	- state 3: maintain mux selections (memory access 2)
	- state 4: assert `la` on 'q'
	- state 5: unassert `la` 
- Number: 5

### ALU Operations:
- Mnemonics and Codes:
	- `ADD` (0x0C)
	- `SUB` (0x1C)
	- `AND` (0x2C)
	- `NND` (0x3C)
	- `ORR` (0x4C)
	- `XOR` (0x5C)
	- `STL` (0x6C)
	- `STR` (0x7C)
- Description: perform the selected operation between the X and Y (just X) registers and store the result in the A register. overwrite the status flags in S. the following eight operations are supported:
	- `ADD`: store X + Y in A
	- `SUB`: store X - Y in A
	- `AND`: store X AND Y in A
	- `NND`: store X NAND Y in A
	- `ORR`: store X OR Y in A
	- `XOR`: store X XOR Y in A
	- `STL`: shift X towards the left. LSB becomes 0. store in A
	- `STR`: shift X towards the right. MSB becomes 0. store in A
- States: 
	- state 1: select operation in alu operation bus. assert `lb` on A. assert `ld` on S
	- state 2: unassert `lb` and `ld`
- Number: 8

### Set Status Flags:
- Mnemonics and Codes:
	- SZF (0x8E)
	- SNF (0xAE)
	- SCF (0xCE)
	- SOF (0xEE)
- Description: (S)ets ('r') (F)lag where 'r' is one of (Z)ero, (N)egative, (C)arry (O)overflow.
- States:
	- state 1: assert appropriate flag set line
- Number: 4

### Clear Status Flags
- Mnemonics and Codes
	- CZF (0x9E)
	- CNF (0xBE)
	- CCF (0xDE)
	- COF (0xFE)
- Description: (C)lears ('r') (F)lag where 'r' is one of Z)ero, (N)egative, (C)arry (O)overflow.
- States:
	- state 1: assert appropriate flag clear line
- Number: 4

### Branch Instructions
- Mnemonics and Codes:
	- BZS (0x0E)
	- BZC (0x1E)
	- BNS (0x2E)
	- BNC (0x3E)
	- BCS (0x4E)
	- BCC (0x5E)
	- BOS (0x6E)
	- BOC (0x7E)
- description: branch if true. execute the immediately following instruction if the condition is false. if the condition is true skipthe immediately following instruction and execute the next one instead. note: a false result gets only one instruction to use before the true branch is executed. this means that a useful idiom is the 'escape address' as follows:

	  	.
	 	LDG <from somewhere> #load the hi byte of an escape address
	 	LDH <from somewhere> #load the lo byte
	  	.
		BZS #branch
		LDPC GH #load the PC with the escape address (jump)
		<continue on>
		.
- States:
	- state 1: assert appropriate branch line. line is ANDed with appropriate flag (or NOT flag) and the result is applied to `incpc`
- Number: 8

### Total number of instructions: 75
