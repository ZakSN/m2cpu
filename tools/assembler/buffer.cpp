#include <string>
#include <vector>
#include "buffer.h"

void buffer::add_line (std::string line) {
	buf.push_back(line);
}

std::string buffer::access_line (int n) {
	if ((n >= 0) || (n < buf.size())) {
		return buf[n];
	}
	else {
		return "";
	}
}

bool buffer::remove_line (int n) {
	if ((n >= 0) || (n < buf.size())) {
		buf.erase(buf.begin() + n);
		return true;
	}
	else {
		return false;
	}
}
