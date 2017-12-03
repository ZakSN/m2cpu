library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vertical_signal is
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
	clk : in std_logic;
	rs : in std_logic -- async reset
);
end entity vertical_signal;

architecture a0 of vertical_signal is

	constant line_number : integer := (front_porch + sync_pulse + back_porch + active_video) * pixel_per_line;
	constant fpsp : integer := (front_porch + sync_pulse) * pixel_per_line;
	constant fpspbp : integer := (front_porch + sync_pulse + back_porch) * pixel_per_line;
	signal line_counter : integer := 1;
	signal len : std_logic;
	signal vsync : std_logic;

begin
	
	vsync_out <= vsync;
	len_out <= len;
	
	vs : process (clk, rs)
	begin
		if (rs = '1') then
			len <= '0';
			vsync <= '0';
			line_counter <= 1;
		elsif (rising_edge(clk)) then
			
			if (line_counter = line_number) then
				line_counter <= 1;
			else
				line_counter <= line_counter + 1;
			end if;
			
			if (line_counter <= (front_porch * pixel_per_line)) then
				len <= '0';
				vsync <= NOT(sync_pulse_pol);
			elsif ((line_counter > (front_porch * pixel_per_line)) AND (line_counter <= fpsp)) then
				len <= '0';
				vsync <= sync_pulse_pol;
			elsif ((line_counter > fpsp) AND (line_counter <= fpspbp)) then
				len <= '0';
				vsync <= NOT(sync_pulse_pol);
			else
				len <= '1';
				vsync <= NOT(sync_pulse_pol);
			end if;
			
		else 
			len <= len;
			vsync <= vsync;
			line_counter <= line_counter;
		end if;
	end process vs;

end architecture a0;