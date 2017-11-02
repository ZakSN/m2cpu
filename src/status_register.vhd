library ieee;
use ieee.std_logic_1164.all;

entity status_register is port
(
	si : in std_logic_vector(7 downto 0); 
	so	: out std_logic_vector(7 downto 0);
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

	with fsc select
		flag_in <= si when "00000000",
					  si(7 downto 4) & '1' & si(2 downto 0) when "10000000", -- set Z
					  si(7 downto 3) & '1' & si(1 downto 0) when "01000000", -- set N
					  si(7 downto 2) & '1' & si(0) when "00100000", -- set C
					  si(7 downto 1) & '1' when "00010000", -- set O
					  si(7 downto 4) & '0' & si(2 downto 0) when "00001000", -- clear Z
					  si(7 downto 3) & '0' & si(1 downto 0) when "00000100", -- clear N
					  si(7 downto 2) & '0' & si(0) when "00000010", -- clear C
					  si(7 downto 1) & '0' when "00000001", -- clear O
					  si when others;
					  
	sr : component register_8bit port map
	(
		di => flag_in,
		do => so,
		ld => ld,
		rs => rs,
		clk => clk
	);

end architecture a0;