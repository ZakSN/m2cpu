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
	byte_in : in std_logic_vector(7 downto 0);
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
		rs : in std_logic;
		clk : in std_logic
	);
	end component character_counter;
	
	component line_counter is port
	(
		scan_line_number : out std_logic_vector(4 downto 0);
		line_number : out integer;
		rs : in std_logic;
		clk : in std_logic
	);
	end component line_counter;
	
	component screen_buffer is port
	(
		char_n : in integer;
		line_n : in integer;
		char_out : out std_logic_vector(7 downto 0);
		char_in : in std_logic_vector(7 downto 0);
		address : out std_logic_vector(15 downto 0);
		rs : in std_logic;
		clk : in std_logic
	);
	end component screen_buffer;
	
	signal current_char_pixel : std_logic_vector(3 downto 0);
	signal current_char_scan_line : std_logic_vector(4 downto 0);
	signal current_char_current_line : std_logic_vector(9 downto 0);
	signal pixel : std_logic;
	signal x_en : std_logic;
	signal y_en : std_logic;
	signal cc_rst : std_logic;
	signal lc_rst : std_logic;
	signal c_num : integer;
	signal l_num : integer;
	signal char_to_disp : std_logic_vector(7 downto 0);

begin

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
	
	sb : component screen_buffer port map
	(
		char_n => c_num,
		line_n => l_num,
		char_out => char_to_disp,
		char_in => byte_in,
		address => address,
		rs => x_en,
		clk => clk
	);
	
	char_gen : component byte_to_text port map
	(
		byte_in => char_to_disp,
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
		rs => cc_rst,
		clk => clk
	);
	
	lc : component line_counter port map
	(
		scan_line_number => current_char_scan_line,
		line_number => l_num,
		rs => lc_rst,
		clk => x_en
	);

end architecture a0;