library ieee;
use ieee.std_logic_1164.all;

entity central_processing_unit is port
(
	signal memory_in : in std_logic_vector(7 downto 0); -- RAM interface
	signal data_out : out std_logic_vector(7 downto 0); -- data bus
	signal address_out : out std_logic_vector(15 downto 0); -- address bus
	signal rst : in std_logic; -- global reset, all registers, PC, and FSM
	signal clk : in std_logic
);
end entity central_processing_unit;

architecture a0 of central_processing_unit is

	------------------component section-------------------------
	component register_8bit is port
	(
		di	 : in std_logic_vector(7 downto 0); --data in
		do	 : out std_logic_vector(7 downto 0); --data out
		ld	 : in std_logic; --load (on rising edge)
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
		ld  : in std_logic; -- load
		inc : in std_logic; -- increase address
		rs  : in std_logic; -- reset
		clk : in std_logic
	);
	end component program_counter;
	
	component general_purpose_register is port
	(
		ai  : in std_logic_vector(7 downto 0); --a data in
		bi  : in std_logic_vector(7 downto 0); --b data in
		do	 : out std_logic_vector(7 downto 0); --data out
		la  : in std_logic; --load from a
		lb	 : in std_logic; --load from b
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component general_purpose_register;
	
	------------------signal section-------------------------
	-- busses and bus selects
	signal data_bus : std_logic_vector(7 downto 0);
	signal data_sel : std_logic_vector(2 downto 0);
	signal addr_bus : std_logic_vector(15 downto 0);
	signal addr_sel : std_logic_vector(1 downto 0);
	-- general purpose register signals:
	-- where '_' is the register letter;
	-- 	_o -> register output bus
	-- 	l_ab -> load a input & load b input
	signal ao : std_logic_vector(7 downto 0);
	signal laab : std_logic_vector(1 downto 0);
	signal go : std_logic_vector(7 downto 0);
	signal lgab : std_logic_vector(1 downto 0);
	signal ho : std_logic_vector(7 downto 0);
	signal lhab : std_logic_vector(1 downto 0);
	signal xo : std_logic_vector(7 downto 0);
	signal lxab : std_logic_vector(1 downto 0);
	signal yo : std_logic_vector(7 downto 0);
	signal lyab : std_logic_vector(1 downto 0);
	-- special purpose register signals:
	signal status : std_logic_vector(7 downto 0); -- status (S) register output
	signal ls : std_logic; -- load S
	signal spo : std_logic_vector(7 downto 0); -- stack pointer (SP) output
	signal ldphpp : std_logic_vector(2 downto 0); -- load & push & pop SP
	signal pco : std_logic_vector(15 downto 0); -- program counter (PC) output
	signal ldinc : std_logic_vector(1 downto 0); -- load & increment PC
	-- alu signals
	signal alu_op : std_logic_vector(2 downto 0); -- alu operation code
	signal znco : std_logic_vector(3 downto 0); -- alu status flag vector
	signal alu_y : std_logic_vector(7 downto 0); -- alu y operand
	signal alu_r : std_logic_vector(7 downto 0); -- alu result
	signal alu_mx : std_logic; -- alu y operand mux select 
	
begin

	------------------8 bit processing logic-------------------------
	-- accumulator
	A : component general_purpose_register port map
	(
		ai => data_bus,
		bi => alu_r,
		do => ao,
		la => laab(0),
		lb => laab(1),
		rs => rst,
		clk => clk
	);
	
	-- G register (general purpose/address hi)
	G : component general_purpose_register port map
	(
		ai => data_bus,
		bi => addr_bus(15 downto 8),
		do => go,
		la => lgab(0),
		lb => lgab(1),
		rs => rst,
		clk => clk
	);
	
	-- H register (general purpose/address lo)
	H : component general_purpose_register port map
	(
		ai => data_bus,
		bi => addr_bus(7 downto 0),
		do => ho,
		la => lhab(0),
		lb => lhab(1),
		rs => rst,
		clk => clk
	);
	
	-- X register (alu operand 1)
	X : component general_purpose_register port map
	(
		ai => data_bus,
		bi => spo,
		do => xo,
		la => lxab(0),
		lb => lxab(1),
		rs => rst,
		clk => clk
	);
	
	-- Y register (alu operand 2)
	Y : component general_purpose_register port map
	(
		ai => data_bus,
		bi => status,
		do => yo,
		la => lyab(0),
		lb => lyab(1),
		rs => rst,
		clk => clk
	);
	
	--data bus mux:
	with data_sel select
		data_bus <= ao when "000",
						go when "001",
						ho when "010",
						memory_in when "011",
						xo when "100",
						yo when "101",
						"00000000" when others;
	data_out <= data_bus;
	
	-- alu, y operand mux, and status register
	ALU : component arithmetic_logic_unit port map
	(
		xin => xo,
		yin => alu_y,
		res => alu_r,
		opr => alu_op,
		zro => znco(0),
		neg => znco(1),
		cry => znco(2),
		ovf => znco(3)
	);
	with alu_mx select
		alu_y <= yo when '0',
					data_bus when '1',
					"00000000" when others;
	S : component register_8bit port map
	(
		di	=> "0000" & znco,
		do	=> status,
		ld	=> ls,
		rs => rst,
		clk => clk
	);
	
	-- stack pointer
	SP : component stack_pointer port map
	(
		pi	=> xo,
		po	=> spo,
		ld	=> ldphpp(0),
		rs => rst,
		ph => ldphpp(1),
		pp => ldphpp(2),
		clk => clk
	);
	------------------end 8 bit processing logic-------------------------
	
	------------------16 bit addressing logic-------------------------
	PC : component program_counter port map
	(
		ai => addr_bus,
		ao => pco,
		ld => ldinc(0),
		inc => ldinc(1),
		rs => rst,
		clk => clk
	);
	with addr_sel select
		addr_bus <= pco when "00",
						go & ho when "01",
						"00000000" & spo when "10",
						"0000000000000000" when others;
	address_out <= addr_bus;
	------------------end 16 bit addressing logic-------------------------
	
end architecture a0;