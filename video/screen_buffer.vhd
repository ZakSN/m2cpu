library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity screen_buffer is port
(
	char_n : in integer;
	line_n : in integer;
	char_out : out std_logic_vector(7 downto 0);
	char_in : in std_logic_vector(7 downto 0);
	address : out std_logic_vector(15 downto 0);
	rs : in std_logic;
	clk : in std_logic
);
end entity screen_buffer;

architecture a0 of screen_buffer is

	type char_line_buffer is array (79 downto 0) of std_logic_vector(7 downto 0);
	signal buff : char_line_buffer := (others => "11111111");
	signal address_index : integer;
	signal state : integer;

begin

	address <= std_logic_vector(to_unsigned(16#F87F# + address_index + (80 * line_n), 16));

	char_out <= buff(char_n);
	
	ld : process (clk, rs)
	begin
		if (rs = '1') then
			state <= 0;
			address_index <= 0;
		elsif (rising_edge(clk)) then
			if (address_index = 80) then
				state <= state;
				address_index <= address_index;
			elsif (state = 0) then
				buff(address_index) <= char_in;
				address_index <= address_index + 1;
				state <= state + 1;
			elsif ((state = 1)) then
				state <= state + 1;
			else
				state <= 0;
			end if;
		else
			state <= state;
			address_index <= address_index;
			buff <= buff;
		end if;
	end process ld;
	
end architecture a0;
