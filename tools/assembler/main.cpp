#include <fstream>
#include <string>
#include <iostream>
#include "buffer.h"
using namespace std;

int main (int argc, char** argv) {
	fstream infile;
	infile.open(argv[1]);
	buffer prog;
	string line;
	while (!infile.eof()) {
		getline(infile, line);
		if (!infile.eof()) {
			prog.add_line(line);
		}
	}

	char choose = 'r';

	while (choose != 'q') {
		cout<<"---------------"<<endl;
		//cin.ignore();
		for (int c = 0; c < prog.length(); c++) {
			cout<<*prog.access_line(c)<<endl;
		}
		cout<<"---------------"<<endl;
		cout<<"(a)ppend, (d)elete, or (q)uit?"<<endl;
		cin>>choose;
		if (choose == 'a') {
			string to_app;
			cout<<"line to append?"<<endl;
			cin.ignore();
			getline(cin, to_app);
			prog.add_line(to_app);
		} 
		else if (choose == 'd') {
			int n;
			cout<<"line to delete?"<<endl;
			cin>>n;
			prog.remove_line(n);
		}
	}
	return 0;
}
