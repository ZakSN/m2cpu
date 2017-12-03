library ieee;
use ieee.std_logic_1164.all;

entity video_generator is port
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
end entity video_generator;

architecture a0 of video_generator is

	component horizontal_signal is
	generic
	(
		front_porch : integer;
		sync_pulse : integer;
		back_porch : integer;
		active_video : integer;
		sync_pulse_pol : std_logic
	);
	port
	(
		hsync_out : out std_logic;
		cen_out : out std_logic;
		x : out integer;
		clk : in std_logic;
		rs : in std_logic
	);
	end component horizontal_signal;
	
	component vertical_signal is
	generic
	(
		front_porch : integer;
		sync_pulse : integer;
		back_porch : integer;
		active_video : integer;
		sync_pulse_pol : std_logic;
		pixel_per_line : integer
	); 
	port
	(
		vsync_out : out std_logic;
		len_out : out std_logic;
		y : out integer;
		clk : in std_logic;
		rs : in std_logic
	);
	end component vertical_signal;

	signal v_colour_bus : std_logic_vector(11 downto 0);
	signal colour_bus : std_logic_vector(11 downto 0);
	signal h_enable : std_logic;
	signal v_enable : std_logic;
	signal pixel_clk : std_logic;
	
begin
	
	-- output pixel, manage blanking
	v_colour_bus <= (7 downto 4 => pixel, others => '0') when h_enable = '1' else "000000000000";
	colour_bus <= v_colour_bus when v_enable = '1' else "000000000000";
	r <= colour_bus(11 downto 8);
	g <= colour_bus(7 downto 4);
	b <= colour_bus(3 downto 0);

	-- generate horizontal signal and x pixel number
	h_sig : component horizontal_signal
	generic map
	(
		-- set x resolution
		front_porch => 56,
		sync_pulse => 120,
		back_porch => 64,
		active_video => 800,
		sync_pulse_pol => '1'
	)
	port map
	(
		hsync_out => hsync,
		cen_out => h_enable,
		x => x,
		clk => clk,
		rs => rs
	);
	
	-- generate vertical signal and y pixel number
	v_sig : component vertical_signal
	generic map
	(
		-- set y resolution
		front_porch => 37,
		sync_pulse => 6,
		back_porch => 23,
		active_video => 600,
		sync_pulse_pol => '1',
		pixel_per_line => 1040
	)
	port map
	(
		vsync_out => vsync,
		len_out => v_enable,
		y => y,
		clk => clk,
		rs => rs
	);
	
end architecture a0;