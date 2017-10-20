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
	
	component stack_pointer is port
	(
		pi	 : in std_logic_vector(7 downto 0); --data in
		po	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
		oe  : in std_logic; --out put enable (active high)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		ph  : in std_logic; --push (increment address)
		pp  : in std_logic; --pop (decrement address)
		clk : in std_logic
	);
	end component stack_pointer;
	
	component program_counter is port
	(
		ai  : in std_logic_vector(15 downto 0); -- address in
		ao  : out std_logic_vector(15 downto 0); -- address out
		inc : in std_logic; -- increase address
		ld  : in std_logic; -- load
		oe  : in std_logic; -- output enable
		rs  : in std_logic; -- reset
		clk : in std_logic
	);
	end component program_counter;
	
	component accumulator is port
	(
		bi  : in std_logic_vector(7 downto 0); --bus data in
		ai  : in std_logic_vector(7 downto 0); --alu data in
		do	 : out std_logic_vector(7 downto 0); --data out
		lb	 : in std_logic; --load from bus
		la  : in std_logic; --load from alu
		oe  : in std_logic; --out put enable (active high)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component accumulator;
	
	component memory is port
	(
		address	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;

------------------signal section----------------------------
	
	--signal data_bus : std_logic_vector(7 downto 0);
	signal ah_out : std_logic_vector(7 downto 0);
	signal al_out : std_logic_vector(7 downto 0);
	
begin
	
	addr_hi : component register_8bit port map
	(
		di => SW(7 downto 0),
		do => ah_out,
		ld => SW(9),
		oe => '1',
		rs => '0',
		clk => CLK50
	);
	a_hi_hi : component seven_seg_decoder port map
	(
		nybble_in => ah_out(7 downto 4),
		d_point => '0',
		hex_out => HEX3
	);
	a_hi_lo : component seven_seg_decoder port map
	(
		nybble_in => ah_out(3 downto 0),
		d_point => '0',
		hex_out => HEX2
	);
	
	addr_lo : component register_8bit port map
	(
		di => SW(7 downto 0),
		do => al_out,
		ld => SW(8),
		oe => '1',
		rs => '0',
		clk => CLK50
	);
	a_lo_hi : component seven_seg_decoder port map
	(
		nybble_in => al_out(7 downto 4),
		d_point => '0',
		hex_out => HEX1
	);
	a_lo_lo : component seven_seg_decoder port map
	(
		nybble_in => al_out(3 downto 0),
		d_point => '0',
		hex_out => HEX0
	);
	
	mem64k : component memory port map
	(
		address	=> ah_out & al_out,
		clock		=> CLK50,
		data		=> SW(7 downto 0),
		rden		=> NOT(KEY(0)),
		wren		=> NOT(KEY(1)),
		q			=> LED(7 downto 0)
	);

end architecture a0;