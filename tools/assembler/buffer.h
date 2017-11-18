#include <string>

#ifndef _BUFFER_H_
#define _BUFFER_H_
class buffer {
	public:
		buffer();
		~buffer();
		void add_line(std::string line);
		std::string* access_line(int n);
		bool remove_line(int n);
		int length() {return len;}
	private:
		int len;
		std::string* buf;
};
#endif
