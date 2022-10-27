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

library hdl4fpga;
use hdl4fpga.base.all;

entity sio_cmp is
    port (
        si_clk   : in  std_logic;
        si_frm   : in  std_logic;
		si1_irdy : in  std_logic;
		si1_trdy : out std_logic;
        si1_data : in  std_logic_vector;
		si2_irdy : in  std_logic;
		si2_trdy : out std_logic;
        si2_data : in  std_logic_vector;
		si_equ   : buffer std_logic);
end;

architecture def of sio_cmp is
	signal cy : std_logic;
begin

	process (si_clk)
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				cy <= '1';
			elsif si1_irdy='1' and si2_irdy='1' then
				cy <= si_equ;
			end if;
		end if;
	end process;
	si1_trdy <= si1_irdy and si2_irdy;
	si2_trdy <= si1_irdy and si2_irdy;
	si_equ   <= setif(si1_data=si2_data) and cy; 

end;
