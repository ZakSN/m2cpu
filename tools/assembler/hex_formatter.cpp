#include "buffer.h"
#include "hex_formatter.h"
#include "parser.h"
#include <string>
#include <sstream>
#include <iomanip>

buffer format_buffer(buffer to_fmt) {
	buffer fmtd;
	std::string uf_line;
	std::string f_line;
	std::string addr;
	std::string prog_base = to_fmt.access_line(0).substr(0, 4);
	bool prog_addr = false;
	int d =0;
	for (int c = 0; c < 65536; c++) {
		addr = int_to_hexstr(c);
		if (addr == prog_base || prog_addr) {
			uf_line = to_fmt.access_line(d);
			f_line = ":01";
			f_line += uf_line.substr(0, 4);
			f_line += "00";
			f_line += uf_line.substr(4);
			f_line += checksum (f_line);
			fmtd.add_line(f_line);
			d++;
			if (d < to_fmt.length()) {
				prog_addr = true;
			}
			else {
				prog_addr = false;
			}
		}
		else {
			f_line = ":01";
			f_line += addr;
			f_line += "0000";
			f_line += checksum(f_line);
			fmtd.add_line(f_line);
		}
	}
	fmtd.add_line(":00000001FF");
	return fmtd;
}

std::string checksum (std::string u_chk) {
	unsigned int line_sum;
	u_chk = u_chk.substr(1);
	for (int c = 0; c < u_chk.length(); c+=2){
		line_sum += hexstr_to_int(u_chk.substr(c, 2));
	}
	line_sum = ~line_sum;
	line_sum++;
	int line_sum_LSB = line_sum & 0xFF;
	std::stringstream converter;
	converter<<std::hex<<std::uppercase<<std::setfill('0')<<std::setw(2)<<line_sum_LSB;
	return converter.str();
}

unsigned int hexstr_to_int (std::string h) {
	std::stringstream converter(h);
	unsigned int v;
	converter>>std::hex>>v;
	return v;
}
