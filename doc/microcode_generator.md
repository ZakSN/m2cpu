## Microcode Generator
The microcode generator: `tools/microcode_generator/` is a simple program that translates addresses and bit numbers into VHDL for the microcode LUT.

The microcode LUT (`src/microcode_LUT.vhd`) is a large multiplexer that encodes the state of the cont_bus during execute states. Essentially a given instruction is used to select a 41-bit control vector.

In order to translate the information in `doc/m2cpu_ISA.*` into microcode states one must know the instruction code/address, and the bit numbers of the lines on the control bus that are to be asserted during that instruction.

basically `gen_ucode` will turn this:
```
E5 6 5 4 41
```

into
```
"10000000000000000000000000000000001110000" when "11100101"
# ^                                 ^^^                 ^
#41st bit                     6th, 5th, 4th bits       E5
```

(without the `#`'d comments)
so as input the generator takes newline terminated space separated list of values. the first value (`E5` above) is a hexadecimal address. the remaining numbers are the decimal address of the bit to **toggle** on the 41 bit `cont_bus`. the `cont_bus` starts as all zeros. The generator can run in interactive mode (no command line args) where it will prompt the user for each piece of data in the list before spitting out the line of VHDL. Or it can parse a text file (first command line arg) laid out as described above generating one line of VHDL for each input line.

the the data in the multiplexer in `src/microcode_LUT.vhd` was generated with:
```
./gen_ucode microcode_states > ucode_gen.vhd
```

the microcode state source files are: `tools/microcode_generator/microcode_states` and `tools/microcode_generator/microcode_states_commented`. the two files contain the same data, however `gen_ucode` doesn't parse comments so the commented file is for convenience only. (If I was smarter I'd use the c preprocessor to strip it).

the source for `gen_ucode` is `gen_ucode.cpp`