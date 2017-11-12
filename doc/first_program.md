### Successfully Executed a Program!

Successfully executed first program at:
2017-12-11 3:50PM EST

The program successfully wrote the number `0xAA` to memory address `0xFFFF`.

assembly code: 
```
LDG 0xFF
LDH 0xFF
LDX 0xAA
LDM X
```

machine code and addresses in hexadecimal:
```
0x0101 0x77
0x0102 0xFF
0x0103 0x87
0x0104 0xFF
0x0105 0x97
0x0106 0xAA
0x0107 0x90
```

#### Notes:
Just a basic program to test register loading and memory access timings. No branching. Rooted at address `0x0101` to avoid coming out of reset weirdly and executing instruction `0x0100` incorrectly. I don't think this was necessary, but haven't tested reset behaviour thoroughly yet.