# include <iostream>
# include <stdint.h>
using namespace std;

int intpow(int, int);

int main(){
	uint64_t micro_ins = 1;
	int bit_to_toggle = 0;
	uint64_t bit_mask = 0;
	while (bit_to_toggle >= 0 && bit_to_toggle < 48){
		cout<<"Enter number of bit to toggle"<<endl;
		cin>>bit_to_toggle;
		bit_mask = intpow(2, bit_to_toggle);
		micro_ins = micro_ins ^ bit_mask;
	}
	cout<<"microinstruction in unpadded hex is:"<<endl;
	printf("%X\n", micro_ins);
	return 0;
}

int intpow(int base, int exp){
	int result = 1;
	for(int c=0; c<exp; c++){
		result = result*base;
	}
	return result;
}
