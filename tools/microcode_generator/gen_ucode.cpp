# include <iostream>
# include <string>
# include <fstream>
using namespace std;

void write_line(bool*, int, string);
string hex_to_bin(string);
void parse_file(char*);
void interactive();

static const int CONT_BUS_WIDTH = 42;

int main(int argc, char** argv){
	if(argc > 2){
		cout<<"usage:"<<endl;
		cout<<"interactive: gen_ucode"<<endl;
		cout<<"file parse: gen_ucode ${FILE}"<<endl;
		return -1;
	}
	if(argc == 2){
		parse_file(argv[1]);
		return 0;
	}
	if(argc == 1){
		interactive();
		return 0;
	}
	return 0;
}

void interactive(){
	bool cont_bus[CONT_BUS_WIDTH] = {0};
	string u_addr;
	cout<<"Enter the microaddress:"<<endl;
	cin>>u_addr;
	int bit_to_flip = 0;
	while (true){
		cout<<"Enter bit to flip:"<<endl;
		cin>>bit_to_flip;
		if (bit_to_flip < 0 || bit_to_flip > (CONT_BUS_WIDTH - 1))
			break;
		cont_bus[bit_to_flip] = !cont_bus[bit_to_flip];
	}
	write_line(cont_bus, CONT_BUS_WIDTH, u_addr);
}

void parse_file(char* file_name){
	fstream file;
	file.open(file_name);
	string line;
	string u_addr;
	string bit_to_flip_s;
	int bit_to_flip_i;
	getline(file, line);
	while (!file.eof()){
		bool cont = true;
		bool cont_bus[CONT_BUS_WIDTH] = {0};
		u_addr = line.substr(0, line.find_first_of(" "));
		while (cont){
			line = line.substr(line.find_first_of(" ")+1, line.length());
			if(line.find_first_of(" ") != line.npos){
				bit_to_flip_s = line.substr(0, line.find_first_of(" "));
			}
			else{
				bit_to_flip_s = line.substr(0, line.find_first_of("\n"));
				cont = false;
			}
			bit_to_flip_i = stoi(bit_to_flip_s, NULL, 10);
			cont_bus[bit_to_flip_i] = !cont_bus[bit_to_flip_i];
		}
		write_line(cont_bus, CONT_BUS_WIDTH, u_addr);
		getline(file, line);
	}
	file.close();
}

void write_line(bool* cont_bus, int len, string u_addr){
	string bin_u_addr;
	bin_u_addr = hex_to_bin(u_addr);
	cout<<"\"";
	for(int c = len-1; c >=0; c--){
		if (cont_bus[c]==true)
			cout<<"1";
		else
			cout<<"0";
	}
	cout<<"\" when \"";
	cout<<bin_u_addr;
	cout<<"\",";
	cout<<endl;
}

string hex_to_bin(string hex){
	string bin = "";
	for(int c = 0; c < hex.length(); c++){
		switch (hex[c]){
			case '0':
				bin = bin + "0000";
				break;
			case '1':
				bin = bin + "0001";
				break;
			case '2':
				bin = bin + "0010";
				break;
			case '3':
				bin = bin + "0011";
				break;
			case '4':
				bin = bin + "0100";
				break;
			case '5':
				bin = bin + "0101";
				break;
			case '6':
				bin = bin + "0110";
				break;
			case '7':
				bin = bin + "0111";
				break;
			case '8':
				bin = bin + "1000";
				break;
			case '9':
				bin = bin + "1001";
				break;
			case 'a':
			case 'A':
				bin = bin + "1010";
				break;
			case 'b':
			case 'B':
				bin = bin + "1011";
				break;
			case 'c':
			case 'C':
				bin = bin + "1100";
				break;
			case 'd':
			case 'D':
				bin = bin + "1101";
				break;
			case 'e':
			case 'E':
				bin = bin + "1110";
				break;
			case 'f':
			case 'F':
				bin = bin + "1111";
				break;
			default:
				bin = bin + "XXXX";
				break;
		}
	}
	return bin;
}
