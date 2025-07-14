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
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

package sdrampkg is
	constant sdram_db : string := compact("{" &
		"MT48LC16M16MA2-7E : {generation : sdr,  orgz : {addr : { ba : 2, row : 13, col :  9}, data : { dm : 2, dq : 16}}, tmng : {tWR : 25.0e-9, tRCD  : 15.0e-9, tRP : 15.00e-9, tMRD : 15.0e-9,  tRFC :  66.0e-9,  tREFI : 7.8125e-6}}," & -- tWR = 14.0e-9+11.0e-9
		"MT46V16M16M-6T    : {generation : ddr,  orgz : {addr : { ba : 2, row : 13, col :  9}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.00e-9, tMRD : 12.0e-9,  tRFC :  72.0e-9,  tREFI : 7.8125e-6}}," &
		"MT41K128M16-125   : {generation : ddr3, orgz : {addr : { ba : 3, row : 14, col : 10}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 360.00e-9, tREFI : 7.8125e-6, tXPR  : 370.00e-9}}," &  -- tMin : tRFC + 10 ns
		"MT4HTF12864HZ     : {generation : ddr2, orgz : {addr : { ba : 3, row : 14, col :  9}, data : { dm : 8, dq : 64}}, tmng : {tWR : 15.0e-9, tRCD : 15.0e-9,  tRP : 15.00e-9, tRPA : 15.0e-9,  tRFC : 130.0e-9,  tREFI : 7.8125e-6, tXPR  : 400.0e-6}}," &
		"MT41J64M16-15E    : {generation : ddr3, orgz : {addr : { ba : 3, row : 13, col : 10}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 15.00e-9, tRFC : 110.00e-9, tREFI : 7.8125e-6, tXPR  : 120.00e-9)}}," &  -- tMin : tRFC + 10 ns
		"MT41K256M16-107   : {generation : ddr3, orgz : {addr : { ba : 3, row : 15, col : 10}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 13.91e-9, tRP : 13.91e-9, tMRD : 20.00e-9, tRFC : 260.00e-9, tREFI : 7.8125e-6, tXPR  : 270.00e-9)}}," &  -- tMin : tRFC + 10 ns
		"MT41K256M16-125   : {generation : ddr3, orgz : {addr : { ba : 3, row : 15, col : 10}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 20.00e-9, tRFC : 350.00e-9, tREFI : 7.8125e-6, tXPR  : 360.00e-9)}}," &  -- tMin : tRFC + 10 ns
		"AS4C512M16D3L-C12 : {generation : ddr3, orgz : {addr : { ba : 3, row : 16, col : 10}, data : { dm : 2, dq : 16}}, tmng : {tWR : 15.0e-9, tRCD : 13.75e-9, tRP : 13.75e-9, tMRD : 15.00e-9, tRFC : 260.00e-9, tREFI : 7.8125e-6; tXPR  : 270.00e-9)}}}");  -- tMin : tRFC + 10 ns

	constant generation_db : string := compact("{" &
		"sdr : {" &
		"    al   : { '000' : 0 }," &
		"    bl   : { '000' : 0, '001' : 1, '010' : 2, '011' : 4 }," &
		"    cl   : { '001' : 1, '010' : 2, '011' : 3 }," &
		"    tmng : { tPreRST : 100.0e-6, cDLL : 200, tCAS : 15.0e-9}}" &
		"ddr : {" &
		"    al   : { '000' : 0}," &
		"    bl   : { '001' : 2, '010' : 4, '011' : 8}," &
		"    cl   : { '010' : 4, '110' : 5, '011' : 6}," &
		"    cwl  : { '000' : 2}," &
		"    tmng : { tPreRST : 200.0e-6, cDLL : 200, tCAS : 15.0e-9}}" &
		-- "    tmng : { tPreRST : 1.0e-6, cDLL : 200, tCAS : 15.0e-9}}" &
		"ddr2 : {" &
		"    al   : { '000' : 0, '001' : 2, '010' :  4, '011' :  6, '100' :  8, '101' : 10, '110' : 12}," &
		"    bl   : { '010' : 4, '011' : 8}," &
		"    cl   : { '011' : 6, '100' : 8, '101' : 10, '110' : 12, '111' : 14}," &
		"    cwl  : { '011' : 4, '100' : 6, '101' :  8, '110' : 10, '111' : 12}," &
		"    wrl  : { 4 : '001', 6 : '010', 8 : '011', 10 : '100', 12 : '101', 14 : '110', 16 : '111'}," &
		"    tmng : { tPreRST : 200.0e-6, cDLL : 200, MRD : 2, tCAS : 12.5e-9}}" &
		-- "    tmng : { tPreRST : 1.0e-6, cDLL : 200, MRD : 2}}" &
		"ddr3 : {" &
		"    length : {bl : 2, cl : 4, rtt : 3, ods : 2}," &
		"    al   : { '000' :  0, '001' :  2, '010' :  4}," &
		"    bl   : { '00' :  8, '01' :  8, '10' :  8}," &
		"    cl   : { '0010' : 10, '0100' : 12, '0110' : 14, '1000' : 16, '1010' : 18, '1100' : 20, '1110' : 22, '0001' : 24, '0011' : 26, '0101' : 28}," &
		"    cwl  : { '000' : 10, '001' : 12, '010' : 14, '011' : 16}" &
		"    wrl  : {  6 : '001',  8 : '001', 10 : '001', 12 : '010', 14 : '011', 16 : '100', 18 : '101', 20 : '101', 22 : '110', 24 : '110', 26: '111', 28 : '111', 30 : '000', 32 : '000'}," &
		"    tmng : { tPreRST : 200.0e-6, tPstRST : 500.0e-6, cDLL : 500, ZQINIT : 500, MRD : 4, MODu : 12, XPR : 5, WLDQSEN : 25, tCAS : 13.125e-9}}}");
		-- "    tmng : { tPreRST : 1.0e-6, tPstRST : 2.0e-6, cDLL : 500, ZQINIT : 500, MRD : 4, MODu : 12, XPR : 91, WLDQSEN : 25}}}");

	constant phy_db : string := compact("[" &
		"ecp5g1 : { orgz : { gear : 1}, tmng : {STRL :  1, DQSL :  0, DQSZL :  0, DQZL :  0, WWNL :  0, STRXL : 0, DQSZXL : 0, DQSXL : 0, DQZXL : 0, WWNXL : 0}}," &
		"xc3sg2 : { orgz : { gear : 2}, tmng : {STRL : -2, DQSL : -2, DQSZL : -2, DQZL : -2, WWNL : -2, STRXL : 0, DQSZXL : 4, DQSXL : 0, DQZXL : 0, WWNXL : 0}}," &
		"ecp3g4 : { orgz : { gear : 4}, tmng : {STRL :  0, DQSL :  0, DQSZL :  0, DQZL :  2, WWNL :  2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2}}," &
		"xc5vg4 : { orgz : { gear : 4}, tmng : {STRL :  9, DQSL :  2, DQSZL :  2, DQZL : -1, WWNL : -3, STRXL : 0, DQSZXL : 1, DQSXL : 0, DQZXL : 0, WWNXL : 0}}," &
		"xc7vg4 : { orgz : { gear : 4}, tmng : {STRL :  9, DQSL :  1, DQSZL :  1, DQZL : -1, WWNL : -1, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 0}}," &
		"ulx4ld_ecp5g4     : { orgz : { gear : 4}, tmng : { STRL : 0, DQSL : 4*1-2+2, DQSZL : 4*1+0+2, DQZL : 4*1+0+2, WWNL : 4*1-4+2, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2}}," &
		"orangecrab_ecp5g4 : { orgz : { gear : 4}, tmng : { STRL : 0, DQSL : 4*1-2+0, DQSZL : 4*1+0+0, DQZL : 4*1+0+0, WWNL : 4*1-4+0, STRXL : 0, DQSZXL : 2, DQSXL : 2, DQZXL : 0, WWNXL : 2}}]");

	constant mpu_nop   : std_logic_vector(0 to 2) := "111";
	constant mpu_act   : std_logic_vector(0 to 2) := "011";
	constant mpu_read  : std_logic_vector(0 to 2) := "101";
	constant mpu_write : std_logic_vector(0 to 2) := "100";
	constant mpu_pre   : std_logic_vector(0 to 2) := "010";
	constant mpu_aut   : std_logic_vector(0 to 2) := "001";
	constant mpu_dcare : std_logic_vector(0 to 2) := "000";

	function lattab (
		constant table  : string;
		constant length : natural;
		constant tabtag : string := "")
		return natural_vector;

	function sdram_schtab (
		constant generation   : string;
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
		constant length : natural;
		constant tabtag : string := "")
		return natural_vector is
		variable retval : natural_vector(0 to length-1);
	begin
		for i in retval'range loop
			retval(i) := hdo(table)**("."&"'"&to_string(to_unsigned(i,unsigned_num_bits(length-1)))&"'"&"=0.");
			-- assert false
			-- report tabtag & " : " & natural'image(retval(i))
			-- severity note;
		end loop;
		return retval;
	end;

	function sdram_schtab (
		constant generation   : string;
		constant phytmng_data : string;
		constant latency : string;
		constant cl_tab : natural_vector;
		constant cwl_tab : natural_vector)
		return natural_vector is

		variable lat    : integer := hdo(phytmng_data)**("."&latency);
		variable clval  : natural_vector(cl_tab'range);
		variable cwlval : natural_vector(cwl_tab'range);
		variable temp   : integer;

	begin
		if latency="WWNL" then
			for i in cwl_tab'range loop
				temp := cwl_tab(i) + lat;
				if temp < 0 then
					cwlval(i) := 0;
				else
					cwlval(i) := temp;
				end if;
			end loop;
			return cwlval;
		elsif latency="STRL" then
			for i in cl_tab'range loop
				temp := cl_tab(i) + lat;
				if temp <0 then
					clval(i) := 0;
				else
					clval(i) := temp;
				end if;
			end loop;
			return clval;
		elsif latency="DQSZL" or latency="DQSL" or latency="DQZL" then
			for i in cwl_tab'range loop
				temp := cwl_tab(i)+lat;
				if temp < 0 then
					cwlval(i) := 0;
				else
					cwlval(i) := temp;
				end if;
			end loop;
			return cwlval;
		else
			return (0 to 0 => 0);
		end if;
	end;

	function sdram_schtab (
		constant latencies : natural_vector;
		constant latency   : integer)
		return natural_vector is
		variable temp   : integer;
		variable retval : natural_vector(latencies'range);
	begin
		retval := latencies;
		for i in latencies'range loop
			temp := retval(i)+latency;
			if temp < 0  then
				retval(i) := 0;
			else
				retval(i) := temp;
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
