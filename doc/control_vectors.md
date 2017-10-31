## General Purpose Registers:
GPRs have 2 inputs, a and b. They can be loaded from either one.

### A register (accumulator)
- control bits: `la`, `lb`
- control vector: `laab` = 1:`la` & 0:`lb`
- number: 2

### G register (address hi) 
- control bits: `la`, `lb`
- control vector: `lgab` = 1:`la` & 0:`lb`
- number: 2

### H register (address hi)
- control bits: `la`, `lb`
- control vector: `lhab` = 1:`la` & 0:`lb`
- number: 2

### X register
- control bits: `la`, `lb`
- control vector: `lxab` = 1:`la` & 0:`lb`
- number: 2

### Y register
- control bits: `la`, `lb`
- control vector: `lyab` = 1:`la` & 0:`lb`
- number: 2


## Special Purpose Registers:

### S register (processor status)
- control bits: `ld`, `fsc`
- control vector: `lSzncoCznco` = 8:`ld` & (7 downto 0):`fsc`
- number: 9

### SP register (stack pointer)
- control bits: `ld`, `ph`, `pp`
- control vector: `ldphpp` = 2:`ld` & 1:`ph` & 2:`pp`
- number: 3

### PC register (program counter)
- control bits: `ld`, `inc`
- control vector: `pcldinc` = 1:`ld` & 2:`inc`
- number: 2


## Memory:
Memory is outside of the processor. As such its interface inside the processor is a bit weird

### M (memory)
- control bits: `lm`
- control vector: `lm`
- number: 1


## Multiplexers:

### address bus mux
- control bits: `addr_sel`
- control vector: `addr_sel` = `pco`, `go` & `ho`, 0 & `spo`
- number: 2

### data bus mux
- control bits: `data_sel`
- control vector: `data_sel` = ao, go, ho, memory_in, xo, yo
- number: 3

### ALU bus mux
- control bits: `alu_mx`
- control vector: `alu_mx` = yo, data_bus
- number: 1


## ALU:

### ALU
- control bits: `opr`
- control vector: `opr` = add, sub, AND, NAND, OR, XOR, STL, STR
- number: 3

## control vector width: 32
