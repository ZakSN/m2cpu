# include <iostream>
# include <stdint.h>
using namespace std;

uint64_t intpow(uint64_t, int);

int main(){
	uint64_t micro_ins = 0;
	int bit_to_toggle = 0;
	uint64_t bit_mask = 0;
	while (true){
		cout<<"Enter number of bit to toggle"<<endl;
		cin>>bit_to_toggle;
		if (bit_to_toggle < 0 || bit_to_toggle > 48)
			break;
		bit_mask = intpow(2, bit_to_toggle);
		micro_ins = micro_ins ^ bit_mask;
	}
	cout<<"microinstruction in hex is:"<<endl;
	printf("%.12llX\n", micro_ins);
	return 0;
}

uint64_t intpow(uint64_t base, int exp){
	uint64_t result = 1;
	for(int c=0; c<exp; c++){
		result = result*base;
	}
	return result;
}
