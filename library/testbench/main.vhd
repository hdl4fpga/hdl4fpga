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
use hdl4fpga.sdrampkg.all;
use hdl4fpga.scopeiopkg.all;

entity main is
end;

architecture def of main is
begin
	process 

	constant phy_data : string := hdo(phy_db)**".ecp5g1";
	constant phytmng_data : string := hdo(phy_data)**".tmng";

	constant chip_id   : string := "MT41K128M16-125";
	constant sdram_data : string        := hdo(sdram_db)**("."&chip_id);
	constant fmly      : string         := hdo(sdram_data)**".fmly";
	constant fmly_data : string         := hdo(families_db)**("."&fmly);

	constant al_tab    : natural_vector := lattab(hdo(fmly_data)**(".al"), 8);
	constant bl_tab    : natural_vector := lattab(hdo(fmly_data)**(".bl"), 8);
	constant cl_tab    : natural_vector := lattab(hdo(fmly_data)**(".cl"), 8);
	constant wrl_tab   : natural_vector := lattab(hdo(fmly_data)**(".wrl={}.)"), 8);
	constant cwl_tab   : natural_vector := lattab(hdo(fmly_data)**(".cwl={}.)"), 8);
	constant wwnl_tab  : natural_vector := sdram_schtab (fmly, phytmng_data, "WWNL",  cl_tab, cwl_tab);
	constant strl_tab  : natural_vector := sdram_schtab (fmly, phytmng_data, "STRL",  cl_tab, cwl_tab);
	constant dozl_tab  : natural_vector := sdram_schtab (strl_tab, -3);
	constant dqszl_tab : natural_vector := sdram_schtab (fmly, phytmng_data, "DQSZL", cl_tab, cwl_tab);
	constant dqsol_tab : natural_vector := sdram_schtab (fmly, phytmng_data, "DQSL",  cl_tab, cwl_tab);
	constant dqzl_tab  : natural_vector := sdram_schtab (fmly, phytmng_data, "DQZL",  cl_tab, cwl_tab);

	constant STRL   : natural := hdo(phytmng_data)**".STRL";
	constant DQSL   : natural := hdo(phytmng_data)**".DQSL";
	constant DQSZL  : natural := hdo(phytmng_data)**".DQSZL";
	constant DQZL   : natural := hdo(phytmng_data)**".DQZL";
	constant STRXL  : natural := hdo(phytmng_data)**".STRXL";
	constant DQSXL  : natural := hdo(phytmng_data)**".DQSXL";
	constant DQSZXL : natural := hdo(phytmng_data)**".DQSZXL";
	constant DQZXL  : natural := hdo(phytmng_data)**".DQZXL";
	constant WWNL   : natural := hdo(phytmng_data)**".WWNL";
	constant WWNXL  : natural := hdo(phytmng_data)**".WWNXL";
	constant WIDL   : natural := hdo(phytmng_data)**".WIDL";

	-- constant obj : string := string'(hdo'("none")**".fmly=none.");
	-- constant obj : string := hdo(families_db)**("."&string'(hdo'("none")**".fmly=none."));-- )); --**".length.al=3.";
	-- constant obj : string := hdo(string'(hdo(families_db)**("."&string'(hdo'("none")**".fmly=sdr."))))**".length.al=3.";

	constant obj : string := hdo'("none")**".length.al=3.";
	alias tab is wwnl_tab;
		constant grid_height : natural := 32;
		constant vt_unit : real := 50.0e-3;
		-- constant xxx : string := hdo(significand(vt_unit/real(grid_height))).;
	begin
		-- report "***** " & xxx;
		-- report "***** " & string'(hdo(obj)**".wrl['8']=hole.");
		-- report "***** " & escaped(string'(hdo(obj)**".wrl['8']"));
		-- report "***** " & string'(hdo(obj));
		-- report "***** " & string'(hdo(families_db)**("."&string'(hdo(sdram_data)**".fmly")));
		-- for i in tab'range loop
			-- report LF &
			-- natural'image(tab(i)) & ", ";
		-- end loop;
		wait;
	end process;
end;
