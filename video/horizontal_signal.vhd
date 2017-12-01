library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity horizontal_signal is port
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
end entity horizontal_signal;

architecture a0 of horizontal_signal is
	
	constant pixel_number : integer := 799;
	signal pixel_counter : integer := 0;
	signal cen : std_logic;
	signal hsync : std_logic;
	signal colour : std_logic;
	signal line_clk : std_logic;
	
begin

	r_out <= "0000";
	g_out <= "1111"; --colour & colour & colour & colour;
	b_out <= "0000";
	hsync_out <= hsync;
	cen_out <= cen;
	line_clk_out <= line_clk;

	hs : process (clk, rs)
	begin
		if (rs = '1') then
			cen <= '0';
			hsync <= '0';
			colour <= '0';
			pixel_counter <= 0;
			line_clk <= '0';
		elsif (rising_edge(clk)) then
			if (pixel_counter = pixel_number) then
				pixel_counter <= 0;
				line_clk <= '1';
			else
				pixel_counter <= pixel_counter + 1;
				line_clk <= '0';
			end if;
			if (pixel_counter < 96) then
				cen <= '0';
				hsync <= '0';
			elsif (pixel_counter < 144) then
				cen <= '0';
				hsync <= '1';
			elsif (pixel_counter > 783) then
				cen <= '0';
				hsync <= '1';
			else
				cen <= '1';
				hsync <= '1';
			end if;
			--colour <= std_logic_vector(to_unsigned(pixel_counter, 16))(0);
		else
			pixel_counter <= pixel_counter;
			cen <= cen;
			hsync <= hsync;
			colour <= colour;
			line_clk <= line_clk;
		end if;
	end process hs;
	
end architecture a0;