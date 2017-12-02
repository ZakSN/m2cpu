library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity horizontal_signal is 
generic
(
	-- length of time in line_clk lengths
	front_porch : integer;
	sync_pulse : integer;
	back_porch : integer;
	active_video : integer
);
port
(
	hsync_out : out std_logic; -- horizontal sync
	cen_out : out std_logic; -- colour eneable
	line_clk_out : out std_logic;
	clk : in std_logic; -- pixel clock in
	rs : in std_logic -- async reset
);
end entity horizontal_signal;

architecture a0 of horizontal_signal is
	
	constant pixel_number : integer := front_porch + sync_pulse + back_porch + active_video;
	constant fpsp : integer := front_porch + sync_pulse;
	constant fpspbp : integer := front_porch + sync_pulse + back_porch;
	signal pixel_counter : integer := 1;
	signal cen : std_logic;
	signal hsync : std_logic;
	signal line_clk : std_logic;
	
begin

	hsync_out <= hsync;
	cen_out <= cen;
	line_clk_out <= line_clk;

	hs : process (clk, rs)
	begin
		if (rs = '1') then
			cen <= '0';
			hsync <= '0';
			pixel_counter <= 1;
			line_clk <= '0';
		elsif (rising_edge(clk)) then
		
			if (pixel_counter = pixel_number) then
				pixel_counter <= 1;
				line_clk <= '1';
			else
				pixel_counter <= pixel_counter + 1;
				line_clk <= '0';
			end if;
			
			if (pixel_counter <= front_porch) then
				cen <= '0';
				hsync <= '1';
			elsif ((pixel_counter > front_porch) AND (pixel_counter <= fpsp)) then
				cen <= '0';
				hsync <= '0';
			elsif ((pixel_counter > fpsp) AND (pixel_counter <= fpspbp)) then
				cen <= '0';
				hsync <= '1';
			else
				cen <= '1';
				hsync <= '1';
			end if;
			
		else
			pixel_counter <= pixel_counter;
			cen <= cen;
			hsync <= hsync;
			line_clk <= line_clk;
		end if;
	end process hs;
	
end architecture a0;