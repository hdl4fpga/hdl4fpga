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

entity xdr_dqi is
	generic (
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 2);
	port (
		sys_clk : in  std_logic_vector;
		sys_dqi : in  std_logic_vector(byte_size*data_phases-1 downto 0);
		xdr_dqi : out std_logic_vector(byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture std of xdr_dqo is
begin
	byte_g : for i in byte_size-1 downto 0 generate
		signal dqi : std_logic_vector(0 to data_phases-1);
	begin
		ixdr_i : entity hdl4fpga.iddr
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges)
		port map (
			clk => sys_clk(sys_clk'right),
			d   => xdr_dqi(i),
			q   => dqi);
	end generate;
end;
