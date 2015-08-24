--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity xdr_dqs is
	generic (
		data_phases : natural := 2;
		data_edges  : natural := 2);
	port (
		sys_dclk : in  std_logic;
		sys_dqso : in  std_logic;
		sys_zclk : in  std_logic;
		sys_dqsz : in  std_logic;
		xdr_dqsz : out std_logic;
		xdr_dqso : out std_logic);
end;

architecture std of xdr_dqs is
begin

	oxdrt_i : entity hdl4fpga.oddrt
	port map (
		clk => sys_zclk,
		d   => sys_dqsz,
		q   => xdr_dqsz);

	oxdr_i : entity hdl4fpga.oddr
	port map (
		clk => sys_dclk,
		d   => df,
		q   => xdr_dqso);

end;
