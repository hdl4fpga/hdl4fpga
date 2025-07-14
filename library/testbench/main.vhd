-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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

	constant chip_id         : string := "MT41K128M16-125";
	constant sdram_data      : string := hdo(sdram_db)**("."&chip_id);
	constant generation      : string := hdo(sdram_data)**".generation";
	constant generation_data : string := hdo(generation_db)**("."&generation);

	constant al_tab    : natural_vector := lattab(hdo(generation_data)**(".al"), 8);
	constant bl_tab    : natural_vector := lattab(hdo(generation_data)**(".bl"), 8);
	constant cl_tab    : natural_vector := lattab(hdo(generation_data)**(".cl"), 8);
	constant wrl_tab   : natural_vector := lattab(hdo(generation_data)**(".wrl={}.)"), 8);
	constant cwl_tab   : natural_vector := lattab(hdo(generation_data)**(".cwl={}.)"), 8);
	constant wwnl_tab  : natural_vector := sdram_schtab (generation, phytmng_data, "WWNL",  cl_tab, cwl_tab);
	constant strl_tab  : natural_vector := sdram_schtab (generation, phytmng_data, "STRL",  cl_tab, cwl_tab);
	constant dozl_tab  : natural_vector := sdram_schtab (strl_tab, -3);
	constant dqszl_tab : natural_vector := sdram_schtab (generation, phytmng_data, "DQSZL", cl_tab, cwl_tab);
	constant dqsol_tab : natural_vector := sdram_schtab (generation, phytmng_data, "DQSL",  cl_tab, cwl_tab);
	constant dqzl_tab  : natural_vector := sdram_schtab (generation, phytmng_data, "DQZL",  cl_tab, cwl_tab);

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

	-- constant obj : string := string'(hdo'("none")**".generation=none.");
	-- constant obj : string := hdo(generation_db)**("."&string'(hdo'("none")**".generation=none."));-- )); --**".length.al=3.";
	-- constant obj : string := hdo(string'(hdo(generation_db)**("."&string'(hdo'("none")**".generation=sdr."))))**".length.al=3.";

	constant obj : string := hdo'("none")**".length.al=3.";
	alias tab is wwnl_tab;
		constant grid_height : natural := 32;
		constant vt_step : real := 3.3/(2**12);
		constant vt_unit : real := 0.05;
		-- constant xxx : string:= hdo(significand2(32.0*vt_step*1000.0)); --**".sgfc";
		constant yyy : string:= hdo(significand(vt_step)); --**".sgfc";
		constant xxx : string:= hdo(significand(vt_step)); --**".sgfc";
	begin
		report xxx;
		-- report yyy;
		-- report "***** " & string'(hdo(obj)**".wrl['8']=hole.");
		-- report "***** " & escaped(string'(hdo(obj)**".wrl['8']"));
		-- report "***** " & string'(hdo(obj));
		-- report "***** " & string'(hdo(generation_db)**("."&string'(hdo(sdram_data)**".generation")));
		-- for i in tab'range loop
			-- report LF &
			-- natural'image(tab(i)) & ", ";
		-- end loop;
		wait;
	end process;
end;
