#include <fstream>
#include <string>
#include "buffer.h"

#ifndef _PARSER_H_
#define _PARSER_H_
//if I have time I'll do this better
static const int INSTRUCTION_NUMBER = 75;

buffer load_file (std::fstream*);
buffer strip (buffer);
buffer arrange (buffer);
buffer substitute (buffer, bool*);
buffer eval_const (buffer, bool*, bool*);
buffer address (buffer, int, bool*);
buffer eval_tags (buffer, bool*, bool*);
std::string int_to_hexstr (int, bool*);
std::string int_to_hexstr (int);
std::string lookup(std::string, bool*);
bool whitespace (char);
void parser_errors (int, std::string, bool*);
#endif
