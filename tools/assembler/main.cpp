#include <fstream>
#include <string>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include "buffer.h"
#include "cmd_line.h"
using namespace std;

buffer strip (buffer);
buffer arrange (buffer);
buffer load_file (fstream*);
buffer substitute (buffer);
buffer eval_const (buffer);
buffer address (buffer, int);
buffer eval_tags (buffer);
string int_to_hexstr (int);
string lookup(string);
bool whitespace (char);
void errors (int, string);

int RESET_VECTOR = 256;
static const int INSTRUCTION_NUMBER = 75;

cmd start_cmd;

int main (int argc, char** argv) {
	start_cmd = parse_cmd(argc, argv);
	if (start_cmd.give_up) {
		errors(-1, "SOMETHING BAD HAPPENED");
		return -1;
	}

	RESET_VECTOR = start_cmd.base_addr;
	cout<<"OUTFILE: "<<start_cmd.outfile<<endl;

	fstream asm_file;
	asm_file.open(start_cmd.infile);
	if (asm_file.fail()) {
		errors(7, start_cmd.infile);
		return -1;
	}
	buffer prog;
	prog = load_file(&asm_file);
	asm_file.close();

	prog = strip(prog);
	prog = arrange(prog);
	prog = substitute(prog);
	prog = eval_const(prog);
	prog = address(prog, RESET_VECTOR);
	prog = eval_tags(prog);
	
	cout<<"substituted file:"<<endl;
	for (int c = 0; c < prog.length(); c++) {
		cout<<prog.access_line(c)<<endl;
	}

	return 0;
}

buffer address (buffer to_addr, int base_addr) {
	buffer addressed;
	string ua_line;
	string a_line;
	int line_number = 0;
	for (int c = 0; c < to_addr.length(); c++) {
		ua_line = to_addr.access_line(c);
		a_line = "";
		switch (ua_line[0]) {
			case ':':
				addressed.add_line(ua_line);
				break;
			default:
				a_line += int_to_hexstr(line_number + base_addr);
				a_line += ua_line;
				addressed.add_line(a_line);
				line_number++;
				break;
		}
	}
	return addressed;
}

buffer eval_tags (buffer to_eval) {
	buffer evaled;
	string ue_line;
	string e_line;
	vector<string> tags;
	vector<string> addresses;
	for (int c = 0; c < to_eval.length(); c++) {
		ue_line = to_eval.access_line(c);
		e_line = "";
		if (ue_line[0] == ':') {
			tags.push_back(ue_line);
			if (c == (to_eval.length() - 1)) {errors(6, ue_line);}
			else {
				bool cont = true;
				for (int d = c+1; d < to_eval.length() && cont; d++) {
					if (to_eval.access_line(d)[0] != ':') {
						string addr = to_eval.access_line(d).substr(0, 4);
						addresses.push_back(addr);
						cont = false;
						//cout<<"found tag: '"<<ue_line<<"' for addr: '"<<addr<<"'"<<endl;
					}
				}
				if (cont) {
					errors(6, ue_line);
				}
			}
		}
		else if ((ue_line.find("+:") != string::npos) || (ue_line.find("-:") != string::npos)) {
			e_line += ue_line.substr(0, 4);
			string tag = ue_line.substr(5);
			bool cont = true;
			for (int d = 0; d < tags.size() && cont; d++) {
				if (tags[d] == tag) {
					if (ue_line.find("+:") != string::npos) {
						e_line += addresses[d].substr(0, 2);
					}
					else {
						e_line += addresses[d].substr(2);
					}
					cont = false;
					evaled.add_line(e_line);
				}
			}
			if (cont) {
				evaled.add_line(ue_line);
				errors(5, ue_line);
			}
		}
		else {
			evaled.add_line(ue_line);
		}
	}
	return evaled;
}

buffer eval_const (buffer to_eval) {
	buffer evaled;
	string ue_line;
	vector<string> symbols;
	vector<string> codes;
	for (int c = 0; c < to_eval.length(); c++) {
		ue_line = to_eval.access_line(c);
		if (ue_line[0] != '$') {
			evaled.add_line(ue_line);
		}
		else {
			int code_index = ue_line.find("0x");
			if (code_index != string::npos) {
				string symbol = ue_line.substr(0, code_index);
				string code = ue_line.substr(code_index+2);
				//cout<<"found symbol: '"<<symbol<<"' for code: '"<<code<<"'"<<<<endl;
				if (code.length() != 2) {
					errors(3, ue_line);
				}
				symbols.push_back(symbol);
				codes.push_back(code);
			}
			else {
				bool cont = true;
				for (int c = 0; c < symbols.size() && cont; c++) {
					if (symbols[c] == ue_line) {
						evaled.add_line(codes[c]);
						cont = false;
					}
				}
				if (cont) {
					errors(4, ue_line);
					evaled.add_line(ue_line);
				}
			}
		}
	}
	return evaled;
}

buffer substitute (buffer to_sub) {
	buffer subbed;
	string us_line;
	string s_line;
	for (int c = 0; c < to_sub.length(); c++) {
		us_line = to_sub.access_line(c);
		s_line = "";
		switch (us_line[0]) {
			case '0':
				if (us_line.length() > 2) {
					if (us_line[1] != 'x') {
						errors(3, us_line);
					}
					else if (us_line.length() != 4) {
						errors(3, us_line);
					}
					else {
						s_line += us_line.substr(2);
					}
				}
				else {
					errors(3, us_line);
				}
				break;
			case '$':
			case ':':
			case '+':
			case '-':
				s_line = us_line;
				break;
			default:
				s_line += lookup(us_line);
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
	s<<hex<<uppercase<<setfill('0')<<setw(4)<<in;
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
		case 4:
			cerr<<"ERROR: UNRECOGNIZED SYMBOL: "<<s<<endl;
			break;
		case 5:
			cerr<<"ERROR: UNRECOGNIZED ADDRESS TAG: "<<s<<endl;
			break;
		case 6:
			cerr<<"ERROR: REDUNDANT TAG: "<<s<<endl;
			break;
		case 7:
			cerr<<"NO SUCH FILE: "<<s<<endl;
		default:
			cerr<<"FATAL ERROR"<<endl;
			break;
	}
}
