library ieee;
use ieee.std_logic_1164.all;

entity video_generator is port
(
	signal r : out std_logic_vector(3 downto 0);
	signal g : out std_logic_vector(3 downto 0);
	signal b : out std_logic_vector(3 downto 0);
	signal hsync : out std_logic;
	signal vsync : out std_logic;
	signal pc : out std_logic;
	signal rs : in std_logic;
	signal clk : in std_logic
);
end entity video_generator;

architecture a0 of video_generator is

	component clock_divider is 
	generic
	(
		half_period : integer
	);
	port
	(
		clkin : in std_logic; --50MHz clock from the board
		rst : in std_logic; --async reset
		clkout : out std_logic --slower clock
	);
	end component clock_divider;
	
	component horizontal_signal is port
	(
		signal hsync_out : out std_logic; -- horizontal sync
		signal r_out : out std_logic_vector(3 downto 0); -- colour channels
		signal g_out : out std_logic_vector(3 downto 0);
		signal b_out : out std_logic_vector(3 downto 0);
		signal cen_out : out std_logic; -- colour eneable
		signal line_clk_out : out std_logic;
		signal clk : in std_logic; -- pixel clock in
		signal rs : in std_logic -- async reset
	);
	end component horizontal_signal;
	
	component vertical_signal is port
	(
		signal vsync_out : out std_logic; -- vertical sync
		signal len_out : out std_logic; -- line enable
		signal clk : in std_logic; -- line clock in
		signal rs : in std_logic -- async reset
	);
	end component vertical_signal;

	signal pixel_clk : std_logic;
	signal line_clk : std_logic;
	signal h_colour_bus : std_logic_vector(11 downto 0);
	signal v_colour_bus : std_logic_vector(11 downto 0);
	signal colour_bus : std_logic_vector(11 downto 0);
	signal h_enable : std_logic;
	signal v_enable : std_logic;
	
begin

--	pixel_clock_generator : component clock_divider
--	generic map
--	(
--		half_period => 1
--	)
--	port map
--	(
--		clkin => clk,
--		rst => rs,
--		clkout => pixel_clk
--	);

	tff : process (clk, rs)
	begin
		if (rs = '1') then
			pixel_clk <= '0';
		elsif (rising_edge(clk)) then
			pixel_clk <= NOT(pixel_clk);
		else
			pixel_clk <= pixel_clk;
		end if;
	end process tff;
	
	pc <= line_clk;
	
	h_sig : component horizontal_signal port map
	(
		hsync_out => hsync,
		r_out => h_colour_bus(11 downto 8),
		g_out => h_colour_bus(7 downto 4),
		b_out => h_colour_bus(3 downto 0),
		cen_out => h_enable,
		line_clk_out => line_clk,
		clk => pixel_clk,
		rs => rs
	);
	
	v_sig : component vertical_signal port map
	(
		vsync_out => vsync,
		len_out => v_enable,
		clk => line_clk,
		rs => rs
	);
	
	--v_colour_bus <= h_colour_bus when h_enable = '1' else "000000000000";
	v_colour_bus <= "000011110000" when h_enable = '1' else "000000000000";
	colour_bus <= v_colour_bus when v_enable = '1' else "000000000000";
	r <= colour_bus(11 downto 8);
	g <= colour_bus(7 downto 4);
	b <= colour_bus(3 downto 0);

end architecture a0;