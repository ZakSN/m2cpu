library ieee;
use ieee.std_logic_1164.all;

entity video_generator is port
(
	r : out std_logic_vector(3 downto 0);
	g : out std_logic_vector(3 downto 0);
	b : out std_logic_vector(3 downto 0);
	hsync : out std_logic;
	vsync : out std_logic;
	rs : in std_logic;
	clk : in std_logic
);
end entity video_generator;

architecture a0 of video_generator is

	component pixel_pll is port
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	end component pixel_pll;

	component horizontal_signal is
	generic
	(
		-- length of time in line_clk lengths
		front_porch : integer;
		sync_pulse : integer;
		back_porch : integer;
		active_video : integer;
		sync_pulse_pol : std_logic
	);
	port
	(
		hsync_out : out std_logic; -- horizontal sync
		cen_out : out std_logic; -- colour eneable
		clk : in std_logic; -- pixel clock in
		pixel : out std_logic;
		rs : in std_logic -- async reset
	);
	end component horizontal_signal;
	
	component vertical_signal is
	generic
	(
		-- length of time in pixel_clk cycle lengths
		front_porch : integer;
		sync_pulse : integer;
		back_porch : integer;
		active_video : integer;
		sync_pulse_pol : std_logic;
		pixel_per_line : integer
	); 
	port
	(
		vsync_out : out std_logic; -- vertical sync
		len_out : out std_logic; -- line enable
		clk : in std_logic; -- line clock in
		rs : in std_logic -- async reset
	);
	end component vertical_signal;

	signal v_colour_bus : std_logic_vector(11 downto 0);
	signal colour_bus : std_logic_vector(11 downto 0);
	signal h_enable : std_logic;
	signal v_enable : std_logic;
	signal pixel_clk : std_logic;
	signal p : std_logic;
	
begin
	
	pixel_clk_pll : component pixel_pll port map
	(
		areset => rs,
		inclk0 => clk,
		c0	=> pixel_clk,
		locked => open 
	);
	
	-- Generate the actual 'video' should just be a solid fill
	v_colour_bus <= "0000" & p & p & p & p & "0000" when h_enable = '1' else "000000000000";
	colour_bus <= v_colour_bus when v_enable = '1' else "000000000000";
	r <= colour_bus(11 downto 8);
	g <= colour_bus(7 downto 4);
	b <= colour_bus(3 downto 0);

	h_sig : component horizontal_signal
	generic map
	(
		front_porch => 16,
		sync_pulse => 96,
		back_porch => 48,
		active_video => 640,
		sync_pulse_pol => '0'
	)
	port map
	(
		hsync_out => hsync,
		cen_out => h_enable,
		clk => pixel_clk,
		pixel => p,
		rs => rs
	);
	
	v_sig : component vertical_signal
	generic map
	(
		front_porch => 10,
		sync_pulse => 2,
		back_porch => 33,
		active_video => 480,
		sync_pulse_pol => '0',
		pixel_per_line => 800
	)
	port map
	(
		vsync_out => vsync,
		len_out => v_enable,
		clk => pixel_clk,
		rs => rs
	);
	
end architecture a0;