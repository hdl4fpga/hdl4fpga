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

entity writef is
	port (
		clk      : in  std_logic;
		wr_frm   : in  std_logic;
		wr_irdy  : in  std_logic;
		wr_bin   : in  std_logic_vector;
		buf_trdy : out std_logic;
		buf_do   : out std_logic_vector);
end;

architecture def of testbench is

	signal bin_flt   : std_logic;
	signal bin_irdy  : std_logic;
	signal bin_irdy  : std_logic;
	signal bin_di    : std_logic_vector(0 to 4-1);

begin

	process (wr_frm, wr_bin, clk)
		variable frm  : unsigned(0 to bin'length/4-1);
		variable flt  : unsigned(0 to bin'length/4-1);
	begin
		if wr_frm='0' then
			frm := (others => '1');
			flt(0) := '1';
			flt := flt rol 1;
		elsif rising_edge(clk) then
			if bin_trdy='1' then
				if frm(frm'right)='1' then
					bin := wr_bin;
				end if;
				frm := frm sll 1;
				bin := bin sll 4;
			end if;
		end if;
		bin_di  <= wr_bin(0 to 4-1) when frm(frm'right)='1' else bin;
		bin_frm <= frm(0);
		bin_flt <= flt(0);
	end process;

	writef_e : entity hdl4fpga.writef
	port map (
		clk      => clk,
		bin_frm  => bin_frm,
		bin_irdy => '1',
		bin_trdy => bin_trdy,
		bin_flt  => bin_flt,
		bin_di   => bin_di,
		buf_trdy => buf_trdy,
		buf_do   => buf_do);

end;
