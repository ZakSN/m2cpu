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
		x_en : out std_logic; -- 1 when active video
		y_en : out std_logic; -- 1 when active video
		pixel : in std_logic; -- value of (x,y) (on or off)
		rs : in std_logic;
		clk : in std_logic
	);
	end component video_generator;
	
	component byte_to_text is port
	(
		byte_in : in std_logic_vector(7 downto 0);
		line_out : out std_logic_vector(9 downto 0);
		line_sel : in std_logic_vector(4 downto 0)
	);
	end component byte_to_text;
	
	component character_counter is port
	(
		pixel_number : out std_logic_vector(3 downto 0);
		character_number : out integer;
		end_line : out std_logic;
		clk : in std_logic;
		rs : in std_logic
	);
	end component character_counter;
	
	component line_counter is port
	(
		scan_line_number : out std_logic_vector(4 downto 0);
		line_number : out integer;
		clk : in std_logic;
		rs : in std_logic
	);
	end component line_counter;
	
	signal current_char_pixel : std_logic_vector(3 downto 0);
	signal current_char_scan_line : std_logic_vector(4 downto 0);
	signal end_scan_line : std_logic;
	signal current_char_current_line : std_logic_vector(9 downto 0);
	signal pixel : std_logic;
	signal x_en : std_logic;
	signal y_en : std_logic;
	signal cc_rst : std_logic;
	signal lc_rst : std_logic;
	signal c_num : integer;
	signal l_num : integer;

begin

	address <= std_logic_vector(to_unsigned(16#F88F#, 16)); -- + c_num + (80 * l_num), 16));

	vid_gen : component video_generator port map
	(
		r => r,
		g => g,
		b => b,
		hsync => hsync,
		vsync => vsync,
		x_en => x_en,
		y_en => y_en,
		pixel => pixel,
		rs => rs,
		clk => clk
	);
	
	cc_rst <= NOT(x_en);
	lc_rst <= NOT(y_en);
	
	char_gen : component byte_to_text port map
	(
		byte_in => byte_to_display,
		line_out => current_char_current_line,
		line_sel => current_char_scan_line
	);
	
	with current_char_pixel select
		pixel <= current_char_current_line(9) when "0000",
					current_char_current_line(8) when "0001",
					current_char_current_line(7) when "0010",
					current_char_current_line(6) when "0011",
					current_char_current_line(5) when "0100",
					current_char_current_line(4) when "0101",
					current_char_current_line(3) when "0110",
					current_char_current_line(2) when "0111",
					current_char_current_line(1) when "1000",
					current_char_current_line(0) when "1001",
					'0' when others;
	
	cc : component character_counter port map
	(
		pixel_number => current_char_pixel,
		character_number => c_num,
		end_line => end_scan_line,
		clk => clk,
		rs => cc_rst
	);
	
	lc : component line_counter port map
	(
		scan_line_number => current_char_scan_line,
		line_number => l_num,
		clk => end_scan_line, --x_en,
		rs => lc_rst
	);

end architecture a0;