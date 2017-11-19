#include <fstream>
#include <string>
#include <iostream>
#include <sstream>
#include <iomanip>
#include "buffer.h"
using namespace std;

buffer strip (buffer);
buffer arrange (buffer);
buffer load_file (fstream*);
buffer substitute (buffer, int);
string int_to_hexstr (int);
string lookup(string);
bool whitespace (char);
void errors (int, string);

static const int RESET_VECTOR = 256;
static const int INSTRUCTION_NUMBER = 75;

int main (int argc, char** argv) {
	if (argc != 2) {
		cout<<"Usage: assembler ${ASSEMBLY_FILE}"<<endl;
		return -1;
	}

	fstream asm_file;
	asm_file.open(argv[1]);
	buffer prog;
	prog = load_file(&asm_file);
	asm_file.close();

	prog = strip(prog);
	prog = arrange(prog);
	prog = substitute(prog, RESET_VECTOR);
	
	cout<<"addressed and substituted file:"<<endl;
	for (int c = 0; c < prog.length(); c++) {
		cout<<prog.access_line(c)<<endl;
	}

	return 0;
}

buffer substitute (buffer to_sub, int base_addr) {
	buffer subbed;
	string us_line;
	string s_line;
	int line_number = 0;
	for (int c = 0; c < to_sub.length(); c++) {
		us_line = to_sub.access_line(c);
		s_line = "";
		switch (us_line[0]) {
			case '0':
				if (us_line.length() > 2) {
					if (us_line[1] != 'x') {
						errors(3, us_line);
					}
					else {
						s_line += int_to_hexstr(line_number + base_addr);
						s_line += us_line.substr(2);
					}
				}
				else {
					errors(2, us_line);
				}
				break;
			case '$':
			case ':':
			case '+':
			case '-':
				s_line = us_line;
				break;
			default:
				s_line += int_to_hexstr(line_number + base_addr);
				s_line += lookup(us_line);
				line_number++;
				break;
		}
		subbed.add_line(s_line);
	}
	return subbed;
}

string lookup(string mnemonic) {
	string LUT[INSTRUCTION_NUMBER][2] = {
		"NOP", "00",
		"LDAG", "01",
		"LDAH", "03",
		"LDAX", "05",
		"LDAY", "07",
		"LDSPX", "09",
		"ADD", "0C",
		"BZS", "0E",
		"LDGA", "11",
		"LDGH", "13",
		"LDGX", "15",
		"LDGY", "17",
		"LDXSP", "19",
		"SUB", "1C",
		"BZC", "1E",
		"LDHA", "21",
		"LDHG", "23",
		"LDHX", "25",
		"LDHY", "27",
		"LDYS", "29",
		"AND", "2C",
		"BNS", "2E",
		"LDXA", "31",
		"LDXG", "33",
		"LDXH", "35",
		"LDXY", "37",
		"LDGHPC", "39",
		"NND", "3C",
		"BNC", "3E",
		"LDYA", "41",
		"LDYG", "43",
		"LDYH", "45",
		"LDYX", "47",
		"LDPCGH", "49",
		"ORR", "4C",
		"BCS", "4E",
		"XOR", "5C",
		"BCC", "5E",
		"LDMA", "60",
		"LDAM", "63",
		"LDA", "67",
		"STL", "6C",
		"BOS", "6E",
		"LDMG", "70",
		"LDGM", "73",
		"LDG", "77",
		"STR", "7C",
		"BOC", "7E",
		"LDMH", "80",
		"LDHM", "83",
		"LDH", "87",
		"SZF", "8E",
		"LDMX", "90",
		"LDXM", "93",
		"LDX", "97",
		"CZF", "9E",
		"LDMY", "A0",
		"LDYM", "A3",
		"LDY", "A7",
		"SNF", "AE",
		"PHA", "B0",
		"PPA", "B5",
		"CNF", "BE",
		"PHG", "C0",
		"PPG", "C5",
		"SCF", "CE",
		"PHH", "D0",
		"PPH", "D5",
		"CCF", "DE",
		"PHX", "E0",
		"PPX", "E5",
		"SOF", "EE",
		"PHY", "F0",
		"PPY", "F5",
		"COF", "FE"
	};
	for (int c = 0; c < INSTRUCTION_NUMBER; c++) {
		if (mnemonic == LUT[c][0]) {
			return LUT[c][1];
		}
	}
	errors(2, mnemonic);
	return "XX";
}

string int_to_hexstr (int in) {
	if (in >= 65536) {
		errors (1, "");
	}
	stringstream s;
	s<<hex<<setfill('0')<<setw(4)<<in;
	return s.str();
}

/*
* arranges an input buffer so that each line evaluates to either a hex literal
* or a tag.
*/
buffer arrange (buffer to_arrange) {
	buffer arranged;
	string unar_line;
	string ar_line;
	bool cont;
	for (int c = 0; c < to_arrange.length(); c++) {
		unar_line = to_arrange.access_line(c);
		ar_line = "";
		cont = true;
		for (int d = 0; d < unar_line.length() && cont; d++) {
			switch (unar_line[d]) {
				case '$':
				case '0':
				case '+':
				case '-':
					cont = false;
					if (d != 0) {
						arranged.add_line(ar_line);
					}
					arranged.add_line(unar_line.substr(d));
					break;
				default:
					ar_line += unar_line[d];
					break;
			}
		}
		if (cont) {
			arranged.add_line(ar_line);
		}
	}
	return arranged;
}

/*
* strips comments and whitespace from an input buffer.
* returns a stripped buffer
*/
buffer strip (buffer to_strip) {
	string stripped;
	string unstripped;
	buffer strip;
	for (int c = 0; c < to_strip.length(); c++) {
		unstripped = to_strip.access_line(c);
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

buffer load_file (fstream* file) {
	string line;
	buffer to_fill;
	while (!file->eof()) {
		getline(*file, line);
		if (!file->eof()) {
			to_fill.add_line(line);
		}
	}
	return to_fill;
}

void errors (int e, string s) {
	switch (e) {
		case 0:
			cerr<<"CRITICAL ERROR"<<endl;
			break;
		case 1:
			cerr<<"ERROR: address beyond 65536. wrapping address space"<<endl;
			break;
		case 2:
			cerr<<"ERROR: UNRECOGNIZED INSTRUCTION: "<<s<<endl;
			break;
		case 3:
			cerr<<"ERROR: BAD HEX: "<<s<<endl;
			break;
		default:
			cerr<<"UNDEFINED ERROR"<<endl;
			break;
	}
}
