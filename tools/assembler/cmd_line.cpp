#include <iostream>
#include <vector>
#include <string>
#include <iostream>
#include <sstream>
#include "cmd_line.h"

cmd parse_cmd (int argc, char** argv) {
	cmd start_cmd  = {
		false,
		NULL,
		"a.out",
		256,
		false
	};
	if (argc == 1) {
		usage_error();
		start_cmd.give_up = true;
		return start_cmd;
	}
	std::vector<std::string> args;
	for (int c = 0; c < argc; c++) {
		args.push_back(argv[c]);
	}
	for (int c = 0; c < args.size(); c++) {
		if (args[c] == "-v") {
			start_cmd.verbose = true;	
		}
		else if (args[c] == "-r") {
			if (c == args.size() - 1) {
				usage_error();
				start_cmd.give_up=true;
				return start_cmd;
			}
			std::stringstream s_base_addr(args[c+1]);
			c++;
			s_base_addr >> start_cmd.base_addr;
			if ((start_cmd.base_addr < 0) || (start_cmd.base_addr > 65535)) {
				std::cout<<"INVALID BASE ADDRESS. FATAL ERROR. ABORTING"<<std::endl;
				start_cmd.give_up = true;
				return start_cmd;
			}
		}
		else if (args[c] == "-o") {
			if (c == args.size() - 1) {
				usage_error();
				start_cmd.give_up=true;
				return start_cmd;
			}
			start_cmd.outfile = args[c+1].c_str();
			c++;
		}
		else {
			start_cmd.infile = args[c].c_str();
		}
	}
	return start_cmd;
}

void usage_error(){
	std::cout<<"USAGE:"<<std::endl;
	std::cout<<"assembler [-v] [-o outfile] [-r baseaddr] infile"<<std::endl;
}
