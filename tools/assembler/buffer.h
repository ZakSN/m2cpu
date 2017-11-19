#include <string>
#include <vector>

#ifndef _BUFFER_H_
#define _BUFFER_H_
class buffer {
	public:
		void add_line(std::string line);
		std::string access_line(int n);
		bool remove_line(int n);
		int length() {return buf.size();}
	private:
		std::vector<std::string> buf;
};
#endif
