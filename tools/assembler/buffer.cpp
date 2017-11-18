#include <string>
#include "buffer.h"

buffer::buffer () {
	len = 0;
	buf = NULL;
}

buffer::~buffer () {
	len = -1;
	if (buf != NULL) {
		delete[] buf;
	}
}

void buffer::add_line (std::string line) {
	std::string* tmp_buf;
	tmp_buf = new std::string[len + 1];
	for (int c = 0; c < len; c++) {
		tmp_buf[c] = buf[c];
	}
	tmp_buf[len] = line;
	std::string* swp;
	swp = buf;
	buf = tmp_buf;
	delete[] swp;
	len++;
}

std::string* buffer::access_line (int n) {
	if ((n >= 0) || (n < len)) {
		return buf + n;
	}
	else {
		return NULL;
	}
}

bool buffer::remove_line (int n) {
	if ((n < 0) || (n >= len)) {
		return false;
	}
	std::string* tmp_buf;
	tmp_buf = new std::string[len - 1];
	for (int c = 0; c < len -1; c++ ) {
		if (c < n) {
			tmp_buf[c] = buf[c];
		}
		else if (c > n) {
			tmp_buf[c] = buf[c + 1];
		}
	}
	std::string* swp;
	swp = buf;
	buf = tmp_buf;
	delete[] swp;
	len--;
	return true;
}
