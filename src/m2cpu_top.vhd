library ieee;
use ieee.std_logic_1164.all;

entity m2cpu_top is port
(
	--this I/O reflects what is available on the DE10-lite dev-board
   LED      : out std_logic_vector (9 downto 0); --leds
   SW       : in std_logic_vector (9 downto 0); --toggle switches
   KEY      : in std_logic_vector (1 downto 0); --momentary push buttons
	--7 segment (+ dp) displays
	HEX0		: out std_logic_vector (7 downto 0); 
	HEX1		: out std_logic_vector (7 downto 0);
	HEX2		: out std_logic_vector (7 downto 0);
	HEX3		: out std_logic_vector (7 downto 0);
	HEX4		: out std_logic_vector (7 downto 0);
	HEX5		: out std_logic_vector (7 downto 0);
   CLK50    : in std_logic --system clock
);
end entity m2cpu_top;

architecture a0 of m2cpu_top is

------------------component section-------------------------

	component seven_seg_decoder is port
	(
		nybble_in : in std_logic_vector(3 downto 0); --binary to decode
		d_point 	 : in std_logic; --decimal point (active high)
		hex_out   : out std_logic_vector(7 downto 0) --7 seg code (active high)
	);
	end component seven_seg_decoder;
	
	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		oe  : in std_logic; --out put enable (active high)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component register_8bit;
	
	component arithmetic_logic_unit is port
	(
		xin : in std_logic_vector(7 downto 0); --operand from x register
		yin : in std_logic_vector(7 downto 0); --operand from the y register
		res : out std_logic_vector(7 downto 0); --result of operation between x and y
		opr : in std_logic_vector(2 downto 0); --the operation to perform
		zro, neg, cry, ovf : out std_logic --zero, negative, carry, overflow flag outputs
	);
	end component arithmetic_logic_unit;

------------------signal section----------------------------
	
	--signal data_bus : std_logic_vector(7 downto 0);
	signal x : std_logic_vector(7 downto 0);
	signal y : std_logic_vector(7 downto 0);
	signal result : std_logic_vector(7 downto 0);
	
begin
	
	--x register and display
	x_reg : component register_8bit port map
	(
		di  => SW(7 downto 0),
		do  => x,
		ld  => not(KEY(0)),
		oe  => SW(9),
		rs  => '0',
		clk => CLK50
	);
	x_disp_hi : component seven_seg_decoder port map
	(
		nybble_in => x(7 downto 4),
		d_point => '0',
		hex_out => HEX5
	);
	x_disp_lo : component seven_seg_decoder port map
	(
		nybble_in => x(3 downto 0),
		d_point => '0',
		hex_out => HEX4
	);
	
	--y register and display
	y_reg : component register_8bit port map
	(
		di  => SW(7 downto 0),
		do  => y,
		ld  => not(KEY(1)),
		oe  => SW(8),
		rs  => '0',
		clk => CLK50
	);
	y_disp_hi : component seven_seg_decoder port map
	(
		nybble_in => y(7 downto 4),
		d_point => '0',
		hex_out => HEX3
	);
	y_disp_lo : component seven_seg_decoder port map
	(
		nybble_in => y(3 downto 0),
		d_point => '0',
		hex_out => HEX2
	);
	
	--alu and result displa
	alu : component arithmetic_logic_unit port map
	(
		xin => x,
		yin => y,
		res => result,
		opr => SW(2 downto 0),
		zro => LED(0),
		neg => LED(1),
		cry => LED(2),
		ovf => LED(3)
	);
	alu_disp_hi : component seven_seg_decoder port map
	(
		nybble_in => result(7 downto 4),
		d_point => '0',
		hex_out => HEX1
	);
	alu_disp_lo : component seven_seg_decoder port map
	(
		nybble_in => result(3 downto 0),
		d_point => '0',
		hex_out => HEX0
	);

end architecture a0;