library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity text_console is port
(
	-- VGA video signals
	r : out std_logic_vector(3 downto 0);
	g : out std_logic_vector(3 downto 0);
	b : out std_logic_vector(3 downto 0);
	hsync : out std_logic;
	vsync : out std_logic;
	-- memory access signals
	byte_to_display : in std_logic_vector(7 downto 0);
	address : out std_logic_vector(15 downto 0);
	--
	rs : in std_logic;
	clk : in std_logic
);
end entity text_console;

architecture a0 of text_console is

	component video_generator is port
	(
		r : out std_logic_vector(3 downto 0); -- colour channels
		g : out std_logic_vector(3 downto 0);
		b : out std_logic_vector(3 downto 0);
		hsync : out std_logic; -- sync channels
		vsync : out std_logic;
		x : out integer; -- x of current pixel (range of 0..horizontal active_video - 1)
		y : out integer; -- y of current pixel (range of 0..vertical active_video - 1)
		pixel : in std_logic; -- value of (x,y) (on or off)
		rs : in std_logic;
		clk : in std_logic
	);
	end component video_generator;

begin

	address <= "0000000000000000";

	vid_gen : component video_generator port map
	(
		r => r,
		g => g,
		b => b,
		hsync => hsync,
		vsync => vsync,
		x => open,
		y => open,
		pixel => '1',
		rs => rs,
		clk => clk
	);

end architecture a0;