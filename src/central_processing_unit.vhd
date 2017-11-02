library ieee;
use ieee.std_logic_1164.all;

entity central_processing_unit is port
(
	-- bus names are from the processor's prespective
	data_bus_in  : in std_logic_vector(7 downto 0);
	data_bus_out : out std_logic_vector(7 downto 0);
	addr_bus_out : out std_logic_vector(15 downto 0);
	memory_wren  : out std_logic;
	debug_out    : out std_logic_vector(15 downto 0); -- general purpose debug vector
	rst : in std_logic; -- global reset, all registers, PC, and FSM
	clk : in std_logic
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
		ph  : in std_logic; --push (increment address)
		pp  : in std_logic; --pop (decrement address)
		rs  : in std_logic; --asynchronus reset (active high, resets to zero)
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

	component status_register is port
	(
		si : in std_logic_vector(7 downto 0); 
		so	: out std_logic_vector(7 downto 0);
		ld	: in std_logic;
		fsc : in std_logic_vector(7 downto 0); -- flag set clear: set znco & clear znco
		rs : in std_logic;
		clk : in std_logic
	);
	end component status_register;

	component instruction_register is port
	(
		ii	 : in std_logic_vector(7 downto 0); -- instruction in
		io	 : out std_logic_vector(7 downto 0); -- instruction out
		ld	 : in std_logic; -- load (on rising edge)
		inc : in std_logic; -- increment instruction
		rs  : in std_logic; -- asynchronus reset (active high, resets to zero)
		clk : in std_logic
	);
	end component instruction_register;

	component finite_state_machine is port
	(
		assert_pc      : out std_logic;
		inc_pc         : out std_logic;
		microcode_rden : out std_logic;
		load_ir        : out std_logic;
		inc_ir         : out std_logic;
		exec_cont      : in std_logic;
		rs             : in std_logic;
		clk            : in std_logic
	);
	end component finite_state_machine;

	component branch_decoder is port
	(
		status_in : in std_logic_vector(7 downto 0); -- X, X, X, X, Z, N, C, O
		branch_in : in std_logic_vector(7 downto 0); -- BOC, BOS, BCC, BCS, BNC, BNS, BZC, BZS
		ins_incpc : in std_logic; -- from microinstruction
		fsm_incpc : in std_logic; -- from FSM
		increment_pc : out std_logic
	);
	end component branch_decoder;

	component microcode_rom is port
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
	);
	end component microcode_rom;

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
	signal so : std_logic_vector(7 downto 0); -- status (S) register output
	signal lSzncoCznco : std_logic_vector(8 downto 0); -- load status register & set & clear status register flags
	signal spo : std_logic_vector(7 downto 0); -- stack pointer (SP) output
	signal ldphpp : std_logic_vector(2 downto 0); -- load & push & pop SP
	signal pco : std_logic_vector(15 downto 0); -- program counter (PC) output
	signal pcldinc : std_logic_vector(1 downto 0); -- load & increment PC
	signal iro : std_logic_vector(7 downto 0); -- instruction register (IR) output
	signal irldinc : std_logic_vector(1 downto 0); -- load IR & increment IR
	-- alu signals
	signal alu_op : std_logic_vector(2 downto 0); -- alu operation code
	signal znco : std_logic_vector(3 downto 0); -- alu status flag vector
	signal alu_y : std_logic_vector(7 downto 0); -- alu y operand
	signal alu_r : std_logic_vector(7 downto 0); -- alu result
	signal alu_mx : std_logic; -- alu y operand mux select
	-- memory
	signal mo : std_logic_vector(7 downto 0); -- mem out
	signal lm : std_logic; -- load mem (@ addr)
	-- control logic signals:
	signal uins_bus : std_logic_vector(47 downto 0); -- microinstruction bus
	signal ucode_rden : std_logic; -- microcode read enable
	signal fsm_addr_sel_override : std_logic;
	signal fsm_incpc : std_logic;
	signal addr_sel_in : std_logic_vector(1 downto 0);
	
begin
	debug_out <= "0000000000000000"; -- not needed (yet...)
	mo <= data_bus_in;
	data_bus_out <= data_bus;
	memory_wren <= lm;
	addr_bus_out <= addr_bus;

	------------------8 bit processing logic-------------------------
	-- accumulator
	A : component general_purpose_register port map
	(
		ai => data_bus,
		bi => alu_r,
		do => ao,
		la => laab(1),
		lb => laab(0),
		rs => rst,
		clk => clk
	);
	
	-- G register (general purpose/address hi)
	G : component general_purpose_register port map
	(
		ai => data_bus,
		bi => addr_bus(15 downto 8),
		do => go,
		la => lgab(1),
		lb => lgab(0),
		rs => rst,
		clk => clk
	);
	
	-- H register (general purpose/address lo)
	H : component general_purpose_register port map
	(
		ai => data_bus,
		bi => addr_bus(7 downto 0),
		do => ho,
		la => lhab(1),
		lb => lhab(0),
		rs => rst,
		clk => clk
	);
	
	-- X register (alu operand 1)
	X : component general_purpose_register port map
	(
		ai => data_bus,
		bi => spo,
		do => xo,
		la => lxab(1),
		lb => lxab(0),
		rs => rst,
		clk => clk
	);
	
	-- Y register (alu operand 2)
	Y : component general_purpose_register port map
	(
		ai => data_bus,
		bi => so,
		do => yo,
		la => lyab(1),
		lb => lyab(0),
		rs => rst,
		clk => clk
	);
	
	--data bus mux:
	with data_sel select
		data_bus <= ao when "000",
						go when "001",
						ho when "010",
						mo when "011",
						xo when "100",
						yo when "101",
						"00000000" when others;
	
	-- alu, y operand mux, and status register
	ALU : component arithmetic_logic_unit port map
	(
		xin => xo,
		yin => alu_y,
		res => alu_r,
		opr => alu_op,
		zro => znco(3),
		neg => znco(2),
		cry => znco(1),
		ovf => znco(0)
	);
	
	with alu_mx select
		alu_y <= yo when '0',
					data_bus when '1',
					"00000000" when others;
	
	S : component status_register port map
	(
		si	=> "0000" & znco,
		so	=> so,
		ld	=> lSzncoCznco(8),
		fsc => lSzncoCznco(7 downto 0),
		rs => rst,
		clk => clk
	);
	
	-- stack pointer
	SP : component stack_pointer port map
	(
		pi	=> xo,
		po	=> spo,
		ld	=> ldphpp(2),
		ph => ldphpp(1),
		pp => ldphpp(0),
		rs => rst,
		clk => clk
	);
	------------------end 8 bit processing logic-------------------------
	
	------------------16 bit addressing logic-------------------------
	PC : component program_counter port map
	(
		ai => addr_bus,
		ao => pco,
		ld => pcldinc(1),
		inc => pcldinc(0),
		rs => rst,
		clk => clk
	);

	with addr_sel select
		addr_bus <= pco when "00",
						go & ho when "01",
						"00000000" & spo when "10",
						"0000000000000000" when others;
	------------------end 16 bit addressing logic-------------------------
	
	------------------control logic-------------------------
	IR : component instruction_register port map
	(
		ii	 => mo,
		io	 => iro,
		ld	 => irldinc(1),
		inc => irldinc(0),
		rs  => rst,
		clk => clk
	);
	
	-- address select override
	addr_sel <= "00" when fsm_addr_sel_override = '1' else addr_sel_in;

	FSM : component finite_state_machine port map
	(
		assert_pc => fsm_addr_sel_override,
		inc_pc => fsm_incpc,
		microcode_rden => ucode_rden,
		load_ir => irldinc(1),
		inc_ir => irldinc(0),
		exec_cont => uins_bus(42),
		rs => rst,
		clk => clk
	);

	BD : component branch_decoder port map
	(
		status_in => so,
		branch_in => uins_bus(41 downto 34), -- microinstruction branch bits
		ins_incpc => uins_bus(23), -- microinstruction increment pc bit
		fsm_incpc => fsm_incpc,
		increment_pc => pcldinc(0)
	);

	MCR : component microcode_rom port map
	(
		address => iro, -- instruction register provides microcode address
		clock => clk,
		rden => ucode_rden,
		q => uins_bus
	);

	-- connect microinstruction bus to control bits.
	-- this bit is a little awkward, 
	-- but I think it makes things a little more readable

	data_sel <= uins_bus(2 downto 0);
	addr_sel_in <= uins_bus(4 downto 3);
	alu_mx <= uins_bus(5);
	alu_op <= uins_bus(8 downto 6);
	laab <= uins_bus(10 downto 9);
	lgab <= uins_bus(12 downto 11);
	lhab <= uins_bus(14 downto 13);
	lxab <= uins_bus(16 downto 15);
	lyab <= uins_bus(18 downto 17);
	lm <= uins_bus(19);
	ldphpp <= uins_bus(22 downto 20);
	pcldinc(1) <= uins_bus(24); -- increment PC goes through the branch decoder
	lSzncoCznco <= uins_bus(33 downto 25);

	-- the other control signals are routed directly
	-- the above signals could be, however I think the above routing makes the 
	-- microcode more self-documenting... I might change this in a future commit
	------------------end control logic-------------------------

end architecture a0;