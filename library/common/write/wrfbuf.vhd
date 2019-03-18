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

entity wrfbuf is
	port (
		clk      : in  std_logic;
		bin_frm  : in  std_logic;
		bin_trdy : out  std_logic := '1';
		bin_irdy : in  std_logic;
		bin_flt  : in  std_logic;
		bin_di   : in  std_logic_vector;
		buf_irdy : buffer  std_logic := '1';
		buf_trdy : in  std_logic;
		buf_do   : out std_logic_vector);
end;

architecture def of wrfbuf is

	signal bcd_frm  : std_logic;
	signal bcd_trdy : std_logic;
	signal bcd_irdy : std_logic;
	signal bcd_do   : std_logic_vector(0 to 4-1);

	signal btof_trdy : std_logic;
	signal bcd_left  : std_logic_vector(0 to 4-1);
	signal bcd_right : std_logic_vector(0 to 4-1);

begin

	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		bin_frm   => bin_frm,
		bin_trdy  => btof_trdy,
		bin_irdy  => bin_irdy,
		bin_di    => bin_di,
		bin_flt   => bin_flt,
		bcd_frm   => bcd_frm,
		bcd_right => bcd_right,
		bcd_left  => bcd_left,
		bcd_irdy  => bcd_irdy,
		bcd_trdy  => bcd_trdy,
		bcd_do    => bcd_do);

	fbuf_e : entity hdl4fpga.fbuf
	port map (
		clk      => clk,
		fix_frm  => bcd_frm,
		fix_irdy => bcd_irdy,
		fix_trdy => bcd_trdy,
		fix_di   => bcd_do,
		buf_irdy => buf_irdy,
		buf_trdy => buf_trdy,
		buf_do   => buf_do);

	bin_trdy <= btof_trdy when bin_flt='0' else buf_irdy;
end;
