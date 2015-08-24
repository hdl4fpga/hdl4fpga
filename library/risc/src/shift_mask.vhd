--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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
