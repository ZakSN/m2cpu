library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity central_processing_unit is port
(
	-- bus names are from the processor's prespective
	data_bus_in  : in std_logic_vector(7 downto 0);
	data_bus_out : out std_logic_vector(7 downto 0);
	addr_bus_out : out std_logic_vector(15 downto 0);
	memory_wren  : out std_logic;
	debug_out    : out std_logic_vector(31 downto 0); -- four byte debug vector 
	rst : in std_logic; -- global reset, all registers, PC, and FSM
	clk : in std_logic
);
end entity central_processing_unit;

architecture a0 of central_processing_unit is

	--------------------------component section-------------------------	
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

	component branch_decoder is port
	(
		status_in : in std_logic_vector(7 downto 0); -- X, X, X, X, Z, N, C, O
		branch_in : in std_logic_vector(7 downto 0); -- BOC, BOS, BCC, BCS, BNC, BNS, BZC, BZS
		ins_incpc : in std_logic; -- from microinstruction
		fsm_incpc : in std_logic; -- from FSM
		increment_pc : out std_logic
	);
	end component branch_decoder;
	
	component finite_state_machine is port
	(
		pass_to_ucode : out std_logic;
		inc_pc : out std_logic;
		load_ir : out std_logic;
		exec_c : in std_logic;
		rs : in std_logic;
		clk : in std_logic
	);
	end component;
	
	component microcode_LUT is port
	(
		address : in std_logic_vector(7 downto 0);
		microinstruction : out std_logic_vector(41 downto 0)
	);
	end component microcode_LUT;

	---------------------------signal section---------------------------
	-- busses:
	signal data_bus : std_logic_vector(7 downto 0);
	signal addr_bus : std_logic_vector(15 downto 0);
	signal cont_bus : std_logic_vector(41 downto 0);
	-- processing signals:
	signal a_out : std_logic_vector(7 downto 0);
	signal g_out : std_logic_vector(7 downto 0);
	signal h_out : std_logic_vector(7 downto 0);
	signal x_out : std_logic_vector(7 downto 0);
	signal y_out : std_logic_vector(7 downto 0);
	signal m_out : std_logic_vector(7 downto 0);
	signal s_out : std_logic_vector(7 downto 0);
	signal sp_out : std_logic_vector(7 downto 0);
	signal alu_result : std_logic_vector(7 downto 0);
	signal alu_status : std_logic_vector(3 downto 0);
	-- addressing signals:
	signal pc_out : std_logic_vector(15 downto 0);
	signal addr_bus_i : std_logic_vector(15 downto 0);
	-- control signals:
	signal ir_out : std_logic_vector(7 downto 0);
	signal fsm_pass_to_ucode : std_logic;
	signal fsm_inc_pc : std_logic;
	signal fsm_load_ir : std_logic;
	signal inc_pc : std_logic;
	signal cont_bus_i : std_logic_vector(41 downto 0);
	signal incpc : std_logic;
	
begin

	debug_out <= s_out & alu_result & pc_out;
	data_bus_out <= data_bus;
	addr_bus_out <= addr_bus;
	m_out <= data_bus_in;
	memory_wren <= cont_bus(15);

	-------------------------processing section-------------------------
	A : component general_purpose_register port map
	(
		ai  => data_bus,
		bi  => alu_result,
		do	 => a_out,
		la  => cont_bus(5),
		lb	 => cont_bus(6),
		rs  => rst,
		clk => clk
	);
	
	G : component general_purpose_register port map
	(
		ai  => data_bus,
		bi  => addr_bus(15 downto 8),
		do	 => g_out,
		la  => cont_bus(7),
		lb	 => cont_bus(8),
		rs  => rst,
		clk => clk
	);
	
	H : component general_purpose_register port map
	(
		ai  => data_bus,
		bi  => addr_bus(7 downto 0),
		do	 => h_out,
		la  => cont_bus(9),
		lb	 => cont_bus(10),
		rs  => rst,
		clk => clk
	);
	
	X : component general_purpose_register port map
	(
		ai  => data_bus,
		bi  => sp_out,
		do	 => x_out,
		la  => cont_bus(11),
		lb	 => cont_bus(12),
		rs  => rst,
		clk => clk
	);
	
	Y : component general_purpose_register port map
	(
		ai  => data_bus,
		bi  => s_out,
		do	 => y_out,
		la  => cont_bus(13),
		lb	 => cont_bus(14),
		rs  => rst,
		clk => clk
	);
	
	S : component status_register port map
	(
		si => "0000" & alu_status,
		so	=> s_out,
		ld	=> cont_bus(16),
		fsc => cont_bus(24 downto 17),
		rs => rst,
		clk => clk
	);
	
	SP : component stack_pointer port map
	(
		pi	 => x_out,
		po	 => sp_out,
		ld	 => cont_bus(25),
		ph  => cont_bus(26),
		pp  => cont_bus(27),
		rs  => rst,
		clk => clk
	);
	
	ALU : component arithmetic_logic_unit port map
	(
		xin => x_out,
		yin => y_out,
		res => alu_result,
		opr => cont_bus(30 downto 28),
		zro => alu_status(3),
		neg => alu_status(2),
		cry => alu_status(1),
		ovf => alu_status(0)
	);
	
	with cont_bus(2 downto 0) select
		data_bus <= a_out when "000",
						g_out when "001",
						h_out when "010",
						x_out when "011",
						y_out when "100",
						m_out when "101",
						"00000000" when others;
	
	-------------------------addressing section-------------------------
	PC : component program_counter port map
	(
		ai  => addr_bus,
		ao  => pc_out,
		ld  => cont_bus(31),
		inc => incpc,
		rs  => rst,
		clk => clk
	);
	
	with cont_bus(4 downto 3) select
		addr_bus_i <= pc_out when "00",
						g_out & h_out when "01",
						"00000000" & sp_out when "10",
						std_logic_vector(unsigned(g_out & h_out) - 1) when "11",
						"0000000000000000" when others;
	
	addr_bus <= addr_bus_i when fsm_pass_to_ucode = '1' else pc_out;
	
	---------------------------control section--------------------------
	IR : component instruction_register port map
	(
		ii	 => m_out,
		io	 => ir_out,
		ld	 => fsm_load_ir,
		inc => cont_bus(41),
		rs  => rst,
		clk => clk
	);
	
	FSM : component finite_state_machine port map
	(
		pass_to_ucode => fsm_pass_to_ucode,
		inc_pc => fsm_inc_pc,
		load_ir => fsm_load_ir,
		exec_c => cont_bus(41),
		rs => rst,
		clk => clk
	);
	
	BD : component branch_decoder port map
	(
		status_in => s_out,
		branch_in => cont_bus(40 downto 33),
		ins_incpc => cont_bus(32),
		fsm_incpc => fsm_inc_pc,
		increment_pc => incpc
	);
	
	cont_bus <= cont_bus_i when fsm_pass_to_ucode = '1' else (0 => '0', others => '0');
	
	MCL : component microcode_LUT port map
	(
		address => ir_out,
		microinstruction => cont_bus_i
	);
	
end architecture a0;