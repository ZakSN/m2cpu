library ieee;
use ieee.std_logic_1164.all;
use work.m2cpu_states.all;

entity finite_state_machine is port
(
	-- bus control signals:
	data_c : out std_logic_vector(2 downto 0);
	addr_c : out std_logic_vector(1 downto 0);
	-- GPR control signals:
	aab_c : out std_logic_vector(1 downto 0);
	gab_c : out std_logic_vector(1 downto 0);
	hab_c : out std_logic_vector(1 downto 0);
	xab_c : out std_logic_vector(1 downto 0);
	yab_c : out std_logic_vector(1 downto 0);
	-- SPR control signals:
	s_c : out std_logic;
	ldphpp_c : out std_logic_vector(2 downto 0);
	ldinc_c : out std_logic_vector(1 downto 0);
	ir_c : out std_logic;
	-- ALU control signals:
	alu_op_c : std_logic_vector(2 downto 0);
	alu_mx_c : std_logic;
	instruction : in std_logic_vector(7 downto 0); -- current instruction
	status : in std_logic_vector(7 downto 0); -- processor status
	rs : in std_logic;
	clk : in std_logic
);
end entity finite_state_machine;

architecture a0 of finite_state_machine is

	signal cur : control_state;
	signal nxt : control_state;

begin
	transition_logic : process (cur)
	begin
		case cur is
			when => LOAD_IR
				nxt <= DECODE;
			when => 
		end case;
	end process;
	
	state_register : process (clk, rs)
	begin
		if (rs = '1') then
			cur <= LOAD_IR;
		elsif (rising_edge(clk)) then
			cur <= nxt;
		else
			cur <= cur;
		end if;
	end process;
	
	decode_logic : process (cur)
	begin
		case cur is 
			when =>
		end case;
	end process;

end architecture a0;