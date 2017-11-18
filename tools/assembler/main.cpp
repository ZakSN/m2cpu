#include <fstream>
#include <string>
#include <iostream>
#include "buffer.h"
using namespace std;

buffer strip_file (buffer);
void load_file (buffer*, fstream*);
bool whitespace (char);

int main (int argc, char** argv) {
	if (argc != 2) {
		cout<<"Usage: assembler ${ASSEMBLY_FILE}"<<endl;
	}

	fstream asm_file;
	asm_file.open(argv[1]);
	buffer prog;

	load_file(&prog, &asm_file);
	prog = strip_file(prog);
	
	cout<<"stripped file:"<<endl;
	for (int c = 0; c < prog.length(); c++) {
		cout<<*prog.access_line(c)<<endl;
	}
	
	asm_file.close();
	return 0;
}

buffer strip_file (buffer to_strip) {
	string stripped;
	string unstripped;
	buffer strip;
	for (int c = 0; c < to_strip.length(); c++) {
		unstripped = *to_strip.access_line(c);
		stripped = "";
		for (int d = 0; d < unstripped.length(); d++) {
			if (unstripped[d] == '#') {
				break;
			}
			else if (!whitespace(unstripped[d])) {
				stripped+=unstripped[d];
			}
		}
		if (stripped != "") {
			strip.add_line(stripped);
		}
	}
	return strip;
}

bool whitespace (char test) {
	switch (test) {
		case ' ':
			return true;
			break;
		case '\t':
			return true;
			break;
		case '\n':
			return true;
			break;
		default:
			return false;
			break;
	}
}

void load_file (buffer* to_fill, fstream* file) {
	string line;
	while (!file->eof()) {
		getline(*file, line);
		if (!file->eof()) {
			to_fill->add_line(line);
		}
	}
}
