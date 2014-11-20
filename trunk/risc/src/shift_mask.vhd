library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_mask is
	generic (
		N : natural := 32;
		M : natural := 6);
	port (
		sht  : in  std_ulogic_vector(M-1 downto 0);
		mout : out std_ulogic_vector(N-1 downto 0));
end;

architecture beh of shift_mask is
begin
	process (sht)
	begin
		for i in 0 to 2**(M-1)-1 loop
			if i < TO_INTEGER(UNSIGNED(sht(M-2 downto 0))) then
				case sht(sht'left) is
				when '1'  =>
					mout(i) <= '1';
				when others  =>
					mout(i) <= '0';
				end	case;
			else
				case not sht(sht'left) is
				when '1'  =>
					mout(i) <= '1';
				when others  =>
					mout(i) <= '0';
				end	case;
			end if;
		end loop;
	end process;
end;
