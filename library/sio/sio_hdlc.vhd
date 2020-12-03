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

entity scopeio_hdlc is
	port (
		clk      : in  std_logic;

		rxdv     : in  std_logic;
		rxd      : in  std_logic_vector;

		so_frm   : out std_logic;
		so_irdy  : out std_logic;
		so_data  : out std_logic_vector);
end;

architecture struct of scopeio_hdlc is
	signal frm  : std_logic;
	signal esci : std_logic;
begin

	process (clk)
		variable frm : std_logic;
	begin
		if rising_edge(clk) then
			if rxdv='1' then
				case rxd is
				when hdlc_flag =>
					frm := '0';
			end if;
		end if;
	end process;

	so_frm <=
		'0' when rxd=hdlc_flag and rxdv='1' else
		'0' when rxdv='1' and rxd=eos else
		'1' when rxdv='1' else
		frm;

	so_irdy <= 
		rxdv when esci='1' else
		'0'  when rxd=esc and rxdv='1' else
		'0'  when rxd=eos and rxdv='1' else
		rxdv;

	so_data <= rxd;
end;
