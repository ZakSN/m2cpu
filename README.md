## M2CPU Project Overview

A very simple 8 bit computer written in VHDL. Major Project Features:

- custom 8 bit processor and memory
	- 75 instructions implemented in microcode 
	- 16 bit address space
	- full 64K address space
- assembler written in C++
	- translates *.asm (ascii) files to *.hex files that can be flashed to the 	MAX10's internal memory
	- used to assemble all demonstration software
- 80x24 VGA character terminal
	- memory addresses 0xF87F to 0xFFFF are mapped to the video terminal
	- complete 128 char ascii plus a few graphical elements
	- custom font
	- 800x600@72Hz VGA video

## Project Roadmap
|Directory|Description|
|---|---|
|`doc`|project documentation|
|`memory`|64K memory source code|
|`processor`|processor source code|
|`software`|software written for the processor|
|`tools`|tools written for the computer and for development of the computer|
|`top`|project top level, and some 'front panel' logic|
|`video`|memory mapped VGA text console|

## Author
written by Zak Nafziger, September - December 2017

check out my last cpu: https://hackaday.io/project/665-4-bit-computer-built-from-discrete-transistors

