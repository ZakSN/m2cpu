library ieee;
use ieee.std_logic_1164.all;

-- utility register since the DE10-lite does not have enough switches
-- shift in two 8 bit words and output a 16 bit vector

entity address_shift_register is port
(
	byte_in : in std_logic_vector(7 downto 0);
	word_out : out std_logic_vector(15 downto 0);
	shift : in std_logic
);
end entity address_shift_register;

architecture a0 of address_shift_register is

	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;

	signal addr_lo : std_logic_vector(7 downto 0);
	signal addr_hi : std_logic_vector(7 downto 0);
	
begin

	addr_lo_register : component register_8bit port map
	(
		di	 => byte_in,
		do	 => addr_lo,
		ld	 => '1',
		rs  => '0',
		clk => shift
	);
	
	addr_hi_register : component register_8bit port map
	(
		di	 => addr_lo,
		do	 => addr_hi,
		ld	 => '1',
		rs  => '0',
		clk => shift
	);
	
	word_out <= addr_hi & addr_lo;

end architecture a0;