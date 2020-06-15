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

entity scopeio_istream is
	generic (
		esc     : std_logic_vector;
		eos     : std_logic_vector);
	port (
		clk     : in  std_logic;

		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_data : in  std_logic_vector;

		esc_dv  : out std_logic;
		txdv    : out std_logic;
		txd     : out std_logic_vector);
end;

architecture struct of scopeio_istream is

	signal dv   : std_logic;

begin

	process (clk)
	begin
		if rising_edge(clk) then
			dv <= si_frm;
		end if;
	end process;

	txdv   <= si_frm and si_irdy when si_frm='1' else ;
	txd    <= si_data when si_frm='0' else eos;
	esc_dv <= setif(si_data=esc or si_data=eos);

end;
