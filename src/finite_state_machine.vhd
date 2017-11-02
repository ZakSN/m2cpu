library ieee;
use ieee.std_logic_1164.all;

entity finite_state_machine is port
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
end entity finite_state_machine;

architecture a0 of finite_state_machine is

	type state is (FETCH, DECODE, EXECUTE, INCPC);
	signal cur : state;
	signal nxt : state;

begin
	transition_logic : process (cur, exec_cont)
	begin
		case cur is
			when FETCH =>
				nxt <= DECODE;
			when DECODE =>
				nxt <= EXECUTE;
			when EXECUTE =>
				if (exec_cont = '1') then
					nxt <= EXECUTE; -- more microcode to exec
				else
					nxt <= INCPC; -- insruction is done
				end if;
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
				microcode_rden <= '0';
				load_ir <= '1'; -- load IR on next clk
				inc_ir <= '0';
			when DECODE =>
				assert_pc <= '1';
				inc_pc <= '0';
				microcode_rden <= '0';
				load_ir <= '0'; -- caught this clk
				inc_ir <= '0';
			when EXECUTE =>
				assert_pc <= '0'; -- relinquish control over the address bus
				inc_pc <= '0';
				microcode_rden <= '1'; -- apply control signals
				load_ir <= '0';
				inc_ir <= '1'; -- increment IR on next clk
			when INCPC =>
				assert_pc <= '1';
				inc_pc <= '1'; -- does what it says on the tin
				microcode_rden <= '0';
				load_ir <= '0';
				inc_ir <= '0';
			when others => -- lock up the processor
				assert_pc <= '1';
				inc_pc <= '0';
				microcode_rden <= '0';
				load_ir <= '0';
				inc_ir <= '0';
		end case;
	end process;

end architecture a0;