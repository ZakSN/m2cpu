library ieee;
use ieee.std_logic_1164.all;

entity branch_decoder is port
(
	status_in : in std_logic_vector(7 downto 0); -- X, X, X, X, Z, N, C, O
	branch_in : in std_logic_vector(7 downto 0); -- BZC, BZS, BNC, BNS, BCC, BCS, BOC, BOS
	ins_incpc : in std_logic; -- from microinstruction
	fsm_incpc : in std_logic; -- from FSM
	increment_pc : out std_logic
);
end entity branch_decoder;

architecture a0 of branch_decoder is

	signal status : std_logic_vector(7 downto 0);
	signal inc : std_logic_vector(7 downto 0);

begin

	status(7) <= NOT(status_in(3));
	status(6) <= status_in(3);
	status(5) <= NOT(status_in(2));
	status(4) <= status_in(2);
	status(3) <= NOT(status_in(1));
	status(2) <= status_in(1);
	status(1) <= NOT(status_in(0));
	status(0) <= status_in(0);

	inc <= status AND branch_in;

	increment_pc <= '0' when fsm_incpc & ins_incpc & inc = "0000000000" else '1';

end architecture a0;
