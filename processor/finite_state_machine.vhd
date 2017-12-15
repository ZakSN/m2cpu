library ieee;
use ieee.std_logic_1164.all;

entity finite_state_machine is port
(
	pass_to_ucode : out std_logic;
	inc_pc : out std_logic;
	load_ir : out std_logic;
	exec_c : in std_logic;
	rs : in std_logic;
	clk : in std_logic
);
end entity finite_state_machine;

architecture a0 of finite_state_machine is

	type state is (SETUP, FETCH1, FETCH2, LOADIR, EXEC, INCPC);
	signal cur : state;
	signal nxt : state;
	signal cont_sig : std_logic_vector(2 downto 0);

begin

	transition_logic : process (cur, exec_c)
	begin
		case cur is
			when SETUP =>
				nxt <= FETCH1;
			when FETCH1 =>
				nxt <= FETCH2;
			when FETCH2 =>
				nxt <= LOADIR;
			when LOADIR =>
				nxt <= EXEC;
			when EXEC =>
				if (exec_c = '1') then
					nxt <= EXEC;
				else
					nxt <= INCPC;
				end if;
			when INCPC =>
				nxt <= SETUP;
			when others =>
				nxt <= cur;
			end case;
	end process transition_logic;
	
	state_register : process (clk, rs)
	begin
		if (rs = '1') then
			cur <= SETUP;
		elsif (rising_edge(clk)) then
			cur <= nxt;
		else
			cur <= cur;
		end if;
	end process state_register;
	
	decode_logic : process (cur)
	begin
		case cur is
			when SETUP =>
				cont_sig <= "000";
			when FETCH1 =>
				cont_sig <= "000";
			when FETCH2 =>
				cont_sig <= "001";
			when LOADIR =>
				cont_sig <= "000";
			when EXEC =>
				cont_sig <= "100";
			when INCPC =>
				cont_sig <= "010";
			when others =>
				cont_sig <= "000";
			end case;
	end process decode_logic;
	
	pass_to_ucode <= cont_sig(2);
	inc_pc <= cont_sig(1);
	load_ir <= cont_sig(0);
	
end architecture a0;