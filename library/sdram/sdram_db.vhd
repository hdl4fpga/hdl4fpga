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
use hdl4fpga.base.all;
use hdl4fpga/hdo.all;
use hdl4fpga.sdram_param.all;

package sdram_db is
	constant sdram_chips : string := compact("{" &
		"MT48LC256MA27E : {fmly : sdr,  tWR : " & real'image(14.0e-9+11.0e-9) & ", tRCD  : 15.0e-9, tRP : 15.0e-9, tMRD  : 15.0e-9, tRFC  : 66.0e-9, tREFI : " & real'image(64.0e-3/8192.0) & "}," & -- real/natural Serious Lattice diamond bug
		"MT46V256M6T    : {fmly : ddr,  tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.0e-9,  tMRD : 12.0e-9,  tRFC :  72.0e-9,  tREFI : " & real'image(64.0e-3/8192.0) & "}," &
		"MT47H512M3     : {fmly : ddr2, tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.0e-9,  tRPA : 15.0e-9,  tRFC : 130.0e-9,  tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : 400.0e-6}," &
		"MT41J1G15E     : {fmly : ddr3, tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 15.00e-9, tRFC : 110.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(110.00e-9 + 10.0e-9) & "}," &  -- tMin : tRFC + 10 ns
		"MT41K2G125     : {fmly : ddr3, tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 360.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(360.00e-9 + 10.0e-9) & "}," &  -- tMin : tRFC + 10 ns
		"MT41K4G107     : {fmly : ddr3, tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 20.00e-9, tRFC : 260.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(260.00e-9 + 10.0e-9) & "}," &  -- tMin : tRFC + 10 ns
		"MT41K8G125     : {fmly : ddr3, tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 20.00e-9, tRFC : 350.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(350.00e-9 + 10.0e-9) & "}," &  -- tMin : tRFC + 10 ns
		"AS4CD3LC12     : {fmly : ddr3, tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 260.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & "; tXPR  : " & real'image(260.00e-9 + 10.0e-9) & "}}");   -- tMin : tRFC + 10 ns

	constant sdram_latencies : string := compact("[" &
		"sdr  : {tPreRST : 100.0e-6}," &
		"ddr  : {tPreRST : 100.0e-6, cDLL : 200}," &
		"ddr2 : {tPreRST : 200.0e-6, cDLL : 200, MRD : 2}," &
		"ddr3 : {tPreRST : 200.0e-6, cDLL : 500, tPstRST : 500.0e-6, ZQINIT : 500, MRD : 4, MODu : 12, XPR : 5}]");

	constant phy_latencies : string := compact("[" &
		"xc3sg2 : { STRL : -2, DQSL : -2, DQSZL : -2, DQZL : -2, WWNL : -2, STRXL : 0, DQSZXL : 4, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 2}," &
		"xc5vg4 : { STRL :  9, DQSL :  2, DQSZL :  2, DQZL : -1, WWNL : -3, STRXL : 0, DQSZXL : 1, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 4}," &
		"xc7vg4 : { STRL :  9, DQSL :  1, DQSZL :  1, DQZL : -1, WWNL : -1, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 0, WIDL : 4}," &
		"ecp3g4 : { STRL :  0, DQSL :  0, DQSZL :  0, DQZL :  2, WWNL :  2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}," &
		"ecp5g1 : { STRL :  1, DQSL :  0, DQSZL :  0, DQZL :  0, WWNL :  0, STRXL : 0, DQSZXL : 0, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 1}," &
		"ulx4ld_ecp5g4     : { STRL : 0, DQSL : 4*1-2+2, DQSZL : 4*1+0+2, DQZL : 4*1+0+2, WWNL : 4*1-4+2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}," &
		"orangecrab_ecp5g4 : { STRL : 0, DQSL : 4*1-2+0, DQSZL : 4*1+0+0, DQZL : 4*1+0+0, WWNL : 4*1-4+0, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}]");

	function sdram_schtab (
		constant stdr      : sdram_standards;
		constant latencies : latency_vector;
		constant tabid     : device_latencies)
		return natural_vector;

	function sdram_schtab (
		constant latency   : integer;
		constant latencies : natural_vector)
		return natural_vector;

	function tmng2lat (
		constant period : real;
		constant mark   : sdram_chips;
		constant param  : sdram_parameters)
		return natural;

end package;

package body sdram_db is

	function tmng2lat (
		constant 
		constant period : real;
		constant param  : real)
		return natural is
		variable retval : natural;
	begin
		retval := natural(ceil(sdram_timing(mark, param)/period));
		return retval;
	end;

	function sdram_schtab (
		constant stdr      : sdram_standards;
		constant latencies : latency_vector;
		constant tabid     : device_latencies)
		return natural_vector is

		constant cwlsel : sdram_latency_rgtr := sdram_selcwl(stdr);
		constant cltab  : natural_vector := sdram_lattab(stdr, CL);
		constant cwltab : natural_vector := sdram_lattab(stdr, cwlsel);

		variable lat    : integer := latencies(tabid);
		variable clval  : natural_vector(cltab'range);
		variable cwlval : natural_vector(cwltab'range);

	begin
		case tabid is
		when WWNL =>
			case stdr is
			when sdr|ddr|ddr3 =>
				for i in cwltab'range loop
					cwlval(i) := cwltab(i) + lat;
				end loop;
				return cwlval;
			when ddr2 =>
				for i in cltab'range loop
					clval(i) := cltab(i) + lat;
				end loop;
				return clval;
			when others =>
				return (0 to 0 => 0);
			end case;
		when STRL =>
			for i in cltab'range loop
				assert false
				report " ******* " & natural'image(clval(i)) & " ******* " & integer'image(lat)
				severity NOTE;
				clval(i) := cltab(i) + lat;
			end loop;
			
			return clval;
		when DQSZL|DQSL|DQZL =>
			if stdr=ddr2 then
				lat := lat - 2;
			end if;
			for i in cwltab'range loop
				cwlval(i) := cwltab(i) + lat;
			end loop;
			return cwlval;
		when others =>
			return (0 to 0 => 0);
		end case;
		return (0 to 0 => 0);
	end;

	function sdram_schtab (
		constant latency   : integer;
		constant latencies : natural_vector)
		return natural_vector is
		variable retval : natural_vector(latencies'range);
	begin
		retval := latencies;
		for i in latencies'range loop
			if retval(i)+latency < 0  then
				retval(i) := 0;
			else
				retval(i) := retval(i) + latency;
			end if;
		end loop;
		return retval;
	end;

end package body;