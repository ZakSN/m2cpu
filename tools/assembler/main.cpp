#include <iostream>
#include <fstream>
#include <string>
#include "buffer.h"
#include "cmd_line.h"
#include "parser.h"
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
	cout<<"OUTFILE: "<<start_cmd.outfile<<endl;

	fstream asm_file;
	asm_file.open(start_cmd.infile);
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
	
	if(ERROR) {
		return -1;
	}

	cout<<"substituted file:"<<endl;
	for (int c = 0; c < prog.length(); c++) {
		cout<<prog.access_line(c)<<endl;
	}

	return 0;
}
