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
use hdl4fpga.std.all;

entity ddrdma is
	port (
		clk     : in  std_logic;
		load    : in  std_logic;
		ena     : in  std_logic;
		iaddr   : in  std_logic_vector;
		ilen    : in  std_logic_vector;
		taddr   : out std_logic_vector;
		tlen    : out std_logic_vector;
		bnk     : buffer std_logic_vector;
		row     : buffer std_logic_vector;
		col     : buffer std_logic_vector;
		bnk_eoc : out std_logic;
		row_eoc : out std_logic;
		col_eoc : out std_logic;
		len_eoc : buffer std_logic);

end;

architecture def of ddrdma is
	signal bnk_cntr : std_logic_vector(bnk'range);
	signal row_cntr : std_logic_vector(row'range);
	signal col_cntr : std_logic_vector(col'range);

	signal cntr_eoc : std_logic;
begin

	addr_e : entity hdl4fpga.dmacntr
	port map (
		clk     => clk,
		load    => load,
		ena     => ena,
		addr    => iaddr,
		bnk     => bnk,
		row     => row,
		col     => col,
		bnk_eoc => bnk_eoc,
		row_eoc => row_eoc,
		col_eoc => col_eoc);
	taddr <= bnk & row & col;

	cntr_e : entity hdl4fpga.dmacntr
	port map (
		clk     => clk,
		load    => load,
		updn    => '1',
		ena     => ena,
		addr    => ilen,
		bnk     => bnk_cntr,
		row     => row_cntr,
		col     => col_cntr,
		bnk_eoc => cntr_eoc);

	process (clk, cntr_eoc)
		variable eoc : std_logic;
	begin
		if rising_edge(clk) then
			if load='1' then
				eoc := '0';
			elsif eoc='0' then
				eoc := cntr_eoc;
			end if;
		end if;
		len_eoc <= eoc or cntr_eoc;
	end process;
	tlen <= bnk_cntr & row_cntr & col_cntr;

end;
