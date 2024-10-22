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
use hdl4fpga.hdo.all;

package sdrampkg is
	constant chips_db : string := compact("{" &
		"MT48LC256MA27E : {fmly : sdr,  orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : " & real'image(14.0e-9+11.0e-9) & ", tRCD  : 15.0e-9, tRP : 15.0e-9, tMRD  : 15.0e-9, tRFC  : 66.0e-9, tREFI : " & real'image(64.0e-3/8192.0) & "}}," & -- real/natural Serious Lattice diamond bug
		"MT46V256M6T    : {fmly : ddr,  orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.0e-9,  tMRD : 12.0e-9,  tRFC :  72.0e-9,  tREFI : " & real'image(64.0e-3/8192.0) & "}}," &
		"MT47H512M3     : {fmly : ddr2, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.0e-9,  tRPA : 15.0e-9,  tRFC : 130.0e-9,  tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : 400.0e-6}}," &
		"MT41J1G15E     : {fmly : ddr3, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 15.00e-9, tRFC : 110.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(110.00e-9 + 10.0e-9) & "}}," &  -- tMin : tRFC + 10 ns
		"MT41K2G125     : {fmly : ddr3, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 360.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(360.00e-9 + 10.0e-9) & "}}," &  -- tMin : tRFC + 10 ns
		"MT41K4G107     : {fmly : ddr3, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 20.00e-9, tRFC : 260.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(260.00e-9 + 10.0e-9) & "}}," &  -- tMin : tRFC + 10 ns
		"MT41K8G125     : {fmly : ddr3, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 20.00e-9, tRFC : 350.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & ", tXPR  : " & real'image(350.00e-9 + 10.0e-9) & "}}," &  -- tMin : tRFC + 10 ns
		"AS4CD3LC12     : {fmly : ddr3, orgz : {addr : { bank : , row : col : }, data { dm : dq : }} }, tmmg : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 260.00e-9, tREFI : " & real'image(64.0e-3/8192.0) & "; tXPR  : " & real'image(260.00e-9 + 10.0e-9) & "}}}");  -- tMin : tRFC + 10 ns

	constant families_db : string := compact("{" &
		"sdr : {" &
		"    al   : { '000' : 0 }," &
		"    bl   : { '000' : 0, '001' : 1, '010' : 2, '011' : 4 }," &
		"    cl   : { '001' : 1, '010' : 2, '011' : 3 }," &
		"    cwl  : { '000' : 0 }," &
		"    tmmg : { tPreRST : 100.0e-6, cDLL : 200}}" &
		"ddr : {" &
		"    al   : { '000' : 0}" &
		"    bl   : { '001' : 2, '010' : 4, '011' : 8}," &
		"    cl   : { '010' : 4, '110' : 5, '011' : 3}," &
		"    cwl  : { '000' : 2}," &
		"    tmmg : { tPreRST : 100.0e-6, cDLL : 200}}" &
		"ddr2 : {" &
		"    al   : { '000' : 0, '001' : 2, 010 :  4, 011 :  6, 100 :  8, 101 : 10, 110: 12}," &
		"    bl   : { '010' : 2, '011' : 8}," &
		"    cl   : { '011' : 6, '100' : 8, '101' : 10, '110' : 12, '111' : 14}," &
		"    wrl  : { '001' : 4, '010' : 6, '011' :  8, '100' : 10, '101' : 12, '110' : 14, '111' : 16}," &
		"    tmmg : { tPreRST : 200.0e-6, cDLL : 200, MRD : 2}}" &
		"ddr3 : {" &
		"    al   : { '000' :  0, '001' :  2, '010' :  4}," &
		"    bl   : { '000' :  8, '001' :  8, '010' :  8}," &
		"    cl   : { '001' : 10, '010' : 12, '011' : 14, '100' : 16, '101' : 18, '110' : 20, '111' : 22}," &
		"    wrl  : { '001' : 10, '010' : 12, '011' : 14, '100' : 16, '101' : 20, '110' : 24}," &
		"    cwl  : { '000' : 10, '001' : 12, '010' : 14, '011' : 16}" &
		"    tmmg : { tPreRST : 200.0e-6, tPstRST : 500.0e-6, cDLL : 500, ZQINIT : 500, MRD : 4, MODu : 12, XPR : 5, WLDQSEN : 25}}}");

	constant phy_db : string := compact("[" &
		"xc3sg2 : { STRL : -2, DQSL : -2, DQSZL : -2, DQZL : -2, WWNL : -2, STRXL : 0, DQSZXL : 4, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 2}," &
		"xc5vg4 : { STRL :  9, DQSL :  2, DQSZL :  2, DQZL : -1, WWNL : -3, STRXL : 0, DQSZXL : 1, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 4}," &
		"xc7vg4 : { STRL :  9, DQSL :  1, DQSZL :  1, DQZL : -1, WWNL : -1, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 0, WIDL : 4}," &
		"ecp3g4 : { STRL :  0, DQSL :  0, DQSZL :  0, DQZL :  2, WWNL :  2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}," &
		"ecp5g1 : { STRL :  1, DQSL :  0, DQSZL :  0, DQZL :  0, WWNL :  0, STRXL : 0, DQSZXL : 0, DQSXL : 0, DQZXL : 0, WWNXL : 0, WIDL : 1}," &
		"ulx4ld_ecp5g4     : { STRL : 0, DQSL : 4*1-2+2, DQSZL : 4*1+0+2, DQZL : 4*1+0+2, WWNL : 4*1-4+2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}," &
		"orangecrab_ecp5g4 : { STRL : 0, DQSL : 4*1-2+0, DQSZL : 4*1+0+0, DQZL : 4*1+0+0, WWNL : 4*1-4+0, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2, WIDL : 4}]");

	constant mpu_nop   : std_logic_vector(0 to 2) := "111";
	constant mpu_act   : std_logic_vector(0 to 2) := "011";
	constant mpu_read  : std_logic_vector(0 to 2) := "101";
	constant mpu_write : std_logic_vector(0 to 2) := "100";
	constant mpu_pre   : std_logic_vector(0 to 2) := "010";
	constant mpu_aut   : std_logic_vector(0 to 2) := "001";
	constant mpu_dcare : std_logic_vector(0 to 2) := "000";

	function lattab (
		constant table  : string;
		constant length : natural)
		return natural_vector;

	function sdram_schtab (
		constant fmly    : string;
		constant phytmng_data : string;
		constant latency : string;
		constant cl_tab  : natural_vector;
		constant cwl_tab : natural_vector)
		return natural_vector;

	function sdram_schtab (
		constant latencies : natural_vector;
		constant latency   : integer)
		return natural_vector;

	function shuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural)
		return std_logic_vector;

	function unshuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural)
		return std_logic_vector;

end package;

package body sdrampkg is

	function lattab (
		constant table  : string;
		constant length : natural)
		return natural_vector is
		variable retval : natural_vector(0 to length-1);
	begin
		retval := (others => 0);
		for i in 0 to length-1 loop
			retval(i) := hdo(table)**("."&"'"&to_string(to_unsigned(i,unsigned_num_bits(length-1)))&"'"&"=0.");
		end loop;
		return retval;
	end;

	function sdram_schtab (
		constant fmly    : string;
		constant phytmng_data : string;
		constant latency : string;
		constant cl_tab : natural_vector;
		constant cwl_tab : natural_vector)
		return natural_vector is

		variable lat    : integer := hdo(phytmng_data)**("."&latency);
		variable clval  : natural_vector(cl_tab'range);
		variable cwlval : natural_vector(cwl_tab'range);

	begin
		if latency="WWNL" then
			for i in cwl_tab'range loop
				cwlval(i) := cwl_tab(i) + lat;
			end loop;
			return cwlval;
		elsif latency="STRL" then
			for i in cl_tab'range loop
				clval(i) := cl_tab(i) + lat;
			end loop;
			return clval;
		elsif latency="DQSZL" or latency="DQSL" or latency="DQZL" then
			for i in cwl_tab'range loop
				cwlval(i) := cwl_tab(i)+lat;
				if fmly="ddr2" then
					cwlval(i) := cwl_tab(i)-2;
				end if;
			end loop;
			return cwlval;
		else
		end if;
		return (0 to 0 => 0);
	end;

	function sdram_schtab (
		constant latencies : natural_vector;
		constant latency   : integer)
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

	function shuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in gear-1 downto 0 loop
				for l in size-1 downto 0 loop
					val((i*gear+j)*size+l) := data(j*(data'length/gear)+i*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

	function unshuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in gear-1 downto 0 loop
				for l in size-1 downto 0 loop
					val(j*(data'length/gear)+i*size+l) := data((i*gear+j)*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

end package body;