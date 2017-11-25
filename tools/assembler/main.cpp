#include <iostream>
#include <fstream>
#include <string>
#include "buffer.h"
#include "cmd_line.h"
#include "parser.h"
#include "hex_formatter.h"
using namespace std;

int main (int argc, char** argv) {
	bool verbose;
	bool ERROR = false;
	int RESET_VECTOR = 256;
	cmd start_cmd;
	start_cmd = parse_cmd(argc, argv);
	if (start_cmd.give_up) {
		parser_errors(-1, "SOMETHING BAD HAPPENED", &ERROR);
		return -1;
	}

	verbose = start_cmd.verbose;
	RESET_VECTOR = start_cmd.base_addr;

	fstream asm_file;
	asm_file.open(start_cmd.infile.c_str());
	if (asm_file.fail()) {
		parser_errors(7, start_cmd.infile, &ERROR);
		return -1;
	}
	buffer prog;
	prog = load_file(&asm_file);
	asm_file.close();

	prog = strip(prog);
	prog = arrange(prog);
	prog = substitute(prog, &ERROR);
	prog = eval_const(prog, &verbose, &ERROR);
	prog = address(prog, RESET_VECTOR, &ERROR);
	prog = eval_tags(prog, &verbose, &ERROR);
	
	if (verbose) {
		cout<<endl;
		cout<<"addresses and instructions:"<<endl;
		cout<<"AAAA II"<<endl;
		for (int c = 0; c < prog.length(); c++) {
			cout<<prog.access_line(c).substr(0, 4)<<" ";
			cout<<prog.access_line(c).substr(4)<<endl;
		}
	}
	if(ERROR) {
		return -1;
	}

	prog = format_buffer(prog);
	
	ofstream outfile;
	outfile.open(start_cmd.outfile.c_str());
	if (outfile.fail()){
		cerr<<"FATAL ERROR: COULD NOT CREATE OUTFILE: '"<<start_cmd.outfile<<"'"<<endl;
		return -1;
	}
	for (int c = 0; c < prog.length(); c++) {
		outfile<<prog.access_line(c)<<endl;
	}
	outfile.close();

	return 0;
}
