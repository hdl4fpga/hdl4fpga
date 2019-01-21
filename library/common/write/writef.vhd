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
		bin_frm  : in  std_logic;
		bin_trdy : out  std_logic := '1';
		bin_irdy : in  std_logic;
		bin_flt  : in  std_logic;
		bin_di   : in  std_logic_vector;
		buf_irdy : out  std_logic := '1';
		buf_trdy : in  std_logic;
		buf_do   : out std_logic_vector);
end;

architecture def of writef is

	signal fix_frm  : std_logic;
	signal fix_trdy : std_logic := '1';
	signal fix_irdy : std_logic;
	signal fix_do   : std_logic_vector(0 to 4-1);

begin

	btof_e : entity hdl4fpga.btof
	port map (
		clk      => clk,
		bin_frm  => bin_frm,
		bin_trdy => bin_trdy,
		bin_irdy => bin_irdy,
		bin_di   => bin_di,
		bin_flt  => bin_flt,
		fix_frm  => fix_frm,
		fix_irdy => fix_irdy,
		fix_trdy => fix_trdy,
		fix_do   => fix_do);

	fbuf_e : entity hdl4fpga.fbuf
	port map (
		clk      => clk,
		fix_frm  => fix_frm,
		fix_irdy => fix_irdy,
		fix_trdy => fix_trdy,
		fix_di   => fix_do,
		buf_irdy => buf_irdy,
		buf_trdy => buf_trdy,
		buf_do   => buf_do);

end;
