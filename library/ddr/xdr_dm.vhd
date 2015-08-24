--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

entity xdr_dm is
	generic (
		data_strobe : string  := "NONE_LOOPBACK";
		data_edges  : natural := 2;
		data_phases : natural := 2);
	port (
		sys_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		sys_dmi  : in  std_logic_vector(data_phases-1 downto 0);
		sys_st   : in  std_logic_vector(data_phases-1 downto 0);
		sys_dmx  : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_phases-1 downto 0));
end;

architecture arch of xdr_dm is
	signal clks : std_logic_vector(data_phases-1 downto 0);
begin

	clks(xdr_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases-1 downto data_phases/data_edges) <= not sys_clks;
	end generate;

	dmff_g: for i in clks'range generate
		signal di : std_logic;
	begin
		di <=
			sys_dmi when data_strobe /= "INTERNAL_LOOPBACK" else
			sys_dmi when sys_dmx(i)='1' else
			sys_st(i);

		ffd_i : entity hdl4fpga.ff
		port map (
			clk => clks(i),
			d => di,
			q => xdr_dmo(i));
	end generate;

end;
