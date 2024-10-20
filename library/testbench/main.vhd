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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdram_db.all;

entity main is
end;

architecture def of main is
begin
	process 
	constant chip_id   : string := "MT47H512M3";
	constant chip_data : string         := hdo(chips_db)**("."&chip_id);
	constant fmly_id   : string         := hdo(chip_data)**".fmly";
	constant fmly_data : string         := hdo(families_db)**("."&fmly_id);
	constant al_tab    : natural_vector := lattab(hdo(fmly_data)**(".al"), 8);
	constant bl_tab    : natural_vector := lattab(hdo(fmly_data)**(".bl"), 8);
	constant cl_tab    : natural_vector := lattab(hdo(fmly_data)**(".cl"), 8);
	constant wrl_tab   : natural_vector := lattab(hdo(fmly_data)**(".wrl={}.)"), 8);
	constant cwl_tab   : natural_vector := lattab(hdo(fmly_data)**(".cwl={}.)"), 8);
	alias tab is al_tab;

	begin
		for i in tab'range loop
			report LF & natural'image(tab(i));
		end loop;
		wait;
	end process;
end;
