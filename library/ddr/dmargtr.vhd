
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

entity dmargtr is
	port (
		ctlr_clk  : in  std_logic;
		ctlr_dv   : in  std_logic;
		ctlr_rid  : in  std_logic_vector;
		ctlr_addr : in  std_logic_vector;
		ctlr_len  : in  std_logic_vector;

		trans_clk  : in  std_logic;
		trans_rid  : in  std_logic_vector;
		trans_addr : out std_logic_vector;
		trabs_len  : out std_logic_vector);

end;

architecture def of dmargtr is
	signal wr_data : std_logic_vector(0 to ctlr_addr'length+ctlr_len'length-1);
	signal rd_data : std_logic_vector(wr_data'range);
begin

	wr_data <= ctlr_addr & ctlr_len;
	mem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => ctlr_clk,
		wr_ena  => ctlr_dv,
		wr_addr => ctlr_rid,
		wr_data => wr_data,

		rd_clk  => trans_clk,
		rd_addr => trans_rid,
		rd_data => rd_data);

end;
