library ieee;
use ieee.std_logic_1164.all;

entity finite_state_machine is port
(
	assert_pc      : out std_logic;
	inc_pc         : out std_logic;
	inc_block		: out std_logic;
	load_ir        : out std_logic;
	inc_ir         : out std_logic;
	exec_cont      : in std_logic;
	rs             : in std_logic;
	clk            : in std_logic
);
end entity finite_state_machine;

architecture a0 of finite_state_machine is

	type state is (FETCH, F_DECODE, ENABLE, EXECUTE, E_DECODE, INCPC);
	signal cur : state;
	signal nxt : state;

begin
	transition_logic : process (cur, exec_cont)
	begin
		case cur is
			when FETCH =>
				nxt <= F_DECODE;
			when F_DECODE =>
				nxt <= ENABLE;
			when ENABLE =>
				nxt <= EXECUTE;
			when EXECUTE =>
				if (exec_cont = '1') then
					nxt <= E_DECODE;
				else
					nxt <= INCPC;
				end if;
			when E_DECODE =>
				nxt <= ENABLE;
			when INCPC =>
				nxt <= FETCH;
			when others =>
				nxt <= cur;
		end case;
	end process;
	
	state_register : process (clk, rs)
	begin
		if (rs = '1') then
			cur <= FETCH;
		elsif (rising_edge(clk)) then
			cur <= nxt;
		else
			cur <= cur;
		end if;
	end process;
	
	decode_logic : process (cur)
	begin
		case cur is 
			when FETCH =>
				assert_pc <= '1';
				inc_pc <= '0';
				load_ir <= '1'; 
				inc_ir <= '0';
				inc_block <= '0';
			when F_DECODE =>
				assert_pc <= '1';
				inc_pc <= '0';
				load_ir <= '0'; 
				inc_ir <= '0';
				inc_block <= '0';
			when ENABLE =>
				assert_pc <= '0';
				inc_pc <= '0';
				load_ir <= '0'; 
				inc_ir <= '0';
				inc_block <= '0';
			when EXECUTE =>
				assert_pc <= '0';
				inc_pc <= '0';
				load_ir <= '0'; 
				if (exec_cont = '1') then
					inc_ir <= '1';
				else
					inc_ir <= '0';
				end if;
				inc_block <= '1';
			when E_DECODE =>
				assert_pc <= '0';
				inc_pc <= '0';
				load_ir <= '0'; 
				inc_ir <= '0';
				inc_block <= '0';
			when INCPC =>
				assert_pc <= '0';
				inc_pc <= '1';
				load_ir <= '0'; 
				inc_ir <= '0';
				inc_block <= '0';
			when others => -- lock up the processor
				assert_pc <= '1';
				inc_pc <= '0';
				load_ir <= '0';
				inc_ir <= '0';
		end case;
	end process;

end architecture a0;