#ifndef _CMD_LINE_H
#define _CMD_LINE_H
struct cmd{
	bool verbose;
	const char* infile;
	const char* outfile;
	int base_addr;
	bool give_up;
};

cmd parse_cmd (int argc, char** argv);
void usage_error();
#endif
