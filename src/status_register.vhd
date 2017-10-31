library ieee;
use ieee.std_logic_1164.all;

entity status_register is port
(
	si : out std_logic_vector(7 downto 0); 
	so	: in std_logic_vector(7 downto 0);
	ld	: in std_logic;
	fsc : in std_logic_vector(7 downto 0); -- flag set clear: set znco & clear znco
	rs : in std_logic;
	clk : in std_logic
);
end entity status_register;

architecture a0 of status_register is

	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;

	signal flag_in : std_logic_vector(7 downto 0);
	
begin

	with fsr select
		flag_in <= di when "00000000",
					  di(7 downto 4) & '1' & di(2 downto 0) when "10000000", -- set Z
					  di(7 downto 3) & '1' & di(1 downto 0) when "01000000", -- set N
					  di(7 downto 2) & '1' & di(0) when "00100000", -- set C
					  di(7 downto 1) & '1' when "00010000", -- set O
					  di(7 downto 4) & '0' & di(2 downto 0) when "00001000", -- clear Z
					  di(7 downto 3) & '0' & di(1 downto 0) when "00000100", -- clear N
					  di(7 downto 2) & '0' & di(0) when "00000010", -- clear C
					  di(7 downto 1) & '0' when "00000001", -- clear O
					  di when others;
					  
	sr : component register_8bit port map
	(
		di => flag_in,
		do => do,
		ld => ld
		rs => rs,
		clk => clk
	);

end architecture a0;