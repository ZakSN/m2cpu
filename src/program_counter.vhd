library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is port
(
	ai  : in std_logic_vector(15 downto 0); -- address in
	ao  : out std_logic_vector(15 downto 0); -- address out
	ld  : in std_logic; -- load
	inc : in std_logic; -- increase address
	rs  : in std_logic; -- reset
	clk : in std_logic
);
end entity program_counter;

architecture a0 of program_counter is

	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;
	
	signal addr_in : std_logic_vector(15 downto 0);
	signal addr_out : std_logic_vector(15 downto 0);
	signal li : std_logic_vector(1 downto 0);
	signal ld_addr : std_logic;
	
begin

	li <= ld & inc;
	
	with li select
		addr_in <= ai when "10",
					  std_logic_vector(unsigned(addr_out) + 1) when "01",
					  "0000000000000000" when others;

	ld_addr <= ld XOR inc;
	
	pc_hi : component register_8bit port map
	(
		di => addr_in(15 downto 8),
		do => addr_out(15 downto 8),
		ld => ld_addr,
		rs => rs,
		clk => clk
	);
	
	pc_lo : component register_8bit port map
	(
		di => addr_in(7 downto 0),
		do => addr_out(7 downto 0),
		ld => ld_addr,
		rs => rs,
		clk => clk
	);

	ao <= addr_out;
end architecture a0;