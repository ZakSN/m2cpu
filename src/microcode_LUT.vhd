library ieee;
use ieee.std_logic_1164.all;

entity microcode_LUT is port
(
	address : in std_logic_vector(7 downto 0);
	microinstruction : out std_logic_vector(41 downto 0)
);
end entity microcode_LUT;

architecture a0 of microcode_LUT is
begin

	with address select
		microcinstruction <= "" when "",
									"" when "",
									(0 => '0', others => '0') when others;

end architecture a0;