#include <fstream>
#include <string>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include "parser.h"

/*
* The (embarrassingly ugly) guts of the assembler. most of these function take 
* a pass over the input buffer and return a slightly modified output buffer
* occasionally generating errors
*/

/*
* prepends address to the buffer. starts at base_addr, complains if it steps 
* outside of the address space.
*/
buffer address (buffer to_addr, int base_addr, bool* e) {
	buffer addressed;
	if (base_addr < 0) {
		parser_errors(8, "BTWH", e);
	}
	std::string ua_line;
	std::string a_line;
	int line_number = 0;
	for (int c = 0; c < to_addr.length(); c++) {
		ua_line = to_addr.access_line(c);
		a_line = "";
		switch (ua_line[0]) {
			case ':':
				addressed.add_line(ua_line);
				break;
			default:
				a_line += int_to_hexstr(line_number + base_addr, e);
				a_line += ua_line;
				addressed.add_line(a_line);
				line_number++;
				break;
		}
	}
	return addressed;
}

/*
* evaluates address tags. similar to constants, except that tags are two bytes, and
* must be refered to by either the hi/lo byte.
*/
buffer eval_tags (buffer to_eval, bool* v, bool* e) {
	buffer evaled;
	std::string ue_line;
	std::string e_line;
	std::vector<std::string> tags;
	std::vector<std::string> addresses;
	for (int c = 0; c < to_eval.length(); c++) {
		ue_line = to_eval.access_line(c);
		e_line = "";
		if (ue_line[0] == ':') {
			tags.push_back(ue_line);
			if (c == (to_eval.length() - 1)) {parser_errors(6, ue_line, e);}
			else {
				bool cont = true;
				for (int d = c+1; d < to_eval.length() && cont; d++) {
					if (to_eval.access_line(d)[0] != ':') {
						std::string addr = to_eval.access_line(d).substr(0, 4);
						addresses.push_back(addr);
						cont = false;
						if(*v) {
							std::cout<<"found tag: '"<<ue_line<<"' for addr: '"<<addr<<"'"<<std::endl;
						}
					}
				}
				if (cont) {
					parser_errors(6, ue_line, e);
				}
			}
		}
		else if ((ue_line.find("+:") != std::string::npos) || (ue_line.find("-:") != std::string::npos)) {
			e_line += ue_line.substr(0, 4);
			std::string tag = ue_line.substr(5);
			bool cont = true;
			for (int d = 0; d < tags.size() && cont; d++) {
				if (tags[d] == tag) {
					if (ue_line.find("+:") != std::string::npos) {
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
				parser_errors(5, ue_line, e);
			}
		}
		else {
			evaled.add_line(ue_line);
		}
	}
	return evaled;
}

/*
* evaluates constants. i.e. search and replace constants with the value it was
* defined as. complains if it finds an undefined constant, or if a constant is
* defined to be more than one byte long.
*/
buffer eval_const (buffer to_eval, bool* v, bool* e) {
	buffer evaled;
	std::string ue_line;
	std::vector<std::string> symbols;
	std::vector<std::string> codes;
	for (int c = 0; c < to_eval.length(); c++) {
		ue_line = to_eval.access_line(c);
		if (ue_line[0] != '$') {
			evaled.add_line(ue_line);
		}
		else {
			int code_index = ue_line.find("0x");
			if (code_index != std::string::npos) {
				std::string symbol = ue_line.substr(0, code_index);
				std::string code = ue_line.substr(code_index+2);
				if (*v) {
					std::cout<<"found symbol: '"<<symbol<<"' for code: '"<<code<<"'"<<std::endl;
				}
				if (code.length() != 2) {
					parser_errors(3, ue_line, e);
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
					parser_errors(4, ue_line, e);
					evaled.add_line(ue_line);
				}
			}
		}
	}
	return evaled;
}

/*
* substitutes everything that looks like a command for it's equivalent hex.
* also strips the "0x" off of single byte hex literals. complains if it finds
* a hex literal greater than one byte.
* ignores constants, addresses, and hi/lo address refrences
*/
buffer substitute (buffer to_sub, bool* e) {
	buffer subbed;
	std::string us_line;
	std::string s_line;
	for (int c = 0; c < to_sub.length(); c++) {
		us_line = to_sub.access_line(c);
		s_line = "";
		switch (us_line[0]) {
			case '0':
				if (us_line.length() > 2) {
					if (us_line[1] != 'x') {
						parser_errors(3, us_line, e);
					}
					else if (us_line.length() != 4) {
						parser_errors(3, us_line, e);
					}
					else {
						s_line += us_line.substr(2);
					}
				}
				else {
					parser_errors(3, us_line, e);
				}
				break;
			case '$':
			case ':':
			case '+':
			case '-':
				s_line = us_line;
				break;
			default:
				s_line += lookup(us_line, e);
				break;
		}
		subbed.add_line(s_line);
	}
	return subbed;
}

/*
* Takes a string and tries to find the matching intruction. If it finds it it
* returns the 2 digit hexcode. otherwise it generates an error and returns "XX"
*/
std::string lookup(std::string mnemonic, bool* e) {
	std::string LUT[INSTRUCTION_NUMBER][2] = {
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
	parser_errors(2, mnemonic, e);
	return "XX";
}

/*
* takes an integer and returns a string containing it's uppercase hex equivalent
* since this is used for addresses excusively it generates an error if it's passed
* a number out of the available address space
*/
std::string int_to_hexstr (int in, bool* e) {
	if (in >= 65536) {
		parser_errors (1, "BAD ADDR", e);
	}
	std::stringstream s;
	s<<std::hex<<std::uppercase<<std::setfill('0')<<std::setw(4)<<in;
	return s.str();
}

/*
* arranges an input buffer so that each line evaluates to either a hex literal
* or a tag.
*/
buffer arrange (buffer to_arrange) {
	buffer arranged;
	std::string unar_line;
	std::string ar_line;
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
	std::string stripped;
	std::string unstripped;
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

/*
* simple whitesppace checker, tabs, spaces and newlines are whitespace.
*/
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

/*
*takes a pointer to a file stream and returns a buffer with the contents of the 
*file
*/
buffer load_file (std::fstream* file) {
	std::string line;
	buffer to_fill;
	while (!file->eof()) {
		getline(*file, line);
		if (!file->eof()) {
			to_fill.add_line(line);
		}
	}
	return to_fill;
}

/*
*All the errors that parsing can generate:
*/
void parser_errors (int e, std::string s, bool* error_flag) {
	switch (e) {
		case 0:
			std::cerr<<"CRITICAL ERROR"<<std::endl;
			break;
		case 1:
			std::cerr<<"ERROR: address beyond 65535"<<std::endl;
			break;
		case 2:
			std::cerr<<"ERROR: UNRECOGNIZED INSTRUCTION: "<<s<<std::endl;
			break;
		case 3:
			std::cerr<<"ERROR: BAD HEX: "<<s<<std::endl;
			break;
		case 4:
			std::cerr<<"ERROR: UNRECOGNIZED SYMBOL: "<<s<<std::endl;
			break;
		case 5:
			std::cerr<<"ERROR: UNRECOGNIZED ADDRESS TAG: "<<s<<std::endl;
			break;
		case 6:
			std::cerr<<"ERROR: REDUNDANT TAG: "<<s<<std::endl;
			break;
		case 7:
			std::cerr<<"NO SUCH FILE: "<<s<<std::endl;
			break;
		case 8:
			std::cerr<<"ERROR: address less than 0"<<std::endl;
			break;
		default:
			std::cerr<<"FATAL ERROR"<<std::endl;
			break;
	}
	*error_flag = true;
}
