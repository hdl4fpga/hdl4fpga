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
		"MT48LC16M16MA2-7E:{ generation:sdr,  orgz:{ addr:{ ba:2, row:13, col: 9}, data:{ dm:2, dq:16}}, tmng:{tWR:25.0e-9, tRCD:15.0e-9,  tRP:15.00e-9, tMRD:15.0e-9, tRFC: 66.0e-9, tREFI:7.8125e-6}}," & -- tWR = 14.0e-9+11.0e-9
		"    IS42S16160G-6:{ generation:sdr,  orgz:{ addr:{ ba:2, row:13, col: 9}, data:{ dm:2, dq:16}}, tmng:{tWR:25.0e-9, tRCD:15.00e-9, tRP:15.00e-9, tMRD:15.0e-9, tRFC: 66.0e-9, tREFI:7.8125e-6}}," & -- tWR = 14.0e-9+11.0e-9
		"   MT46V16M16M-6T:{ generation:ddr,  orgz:{ addr:{ ba:2, row:13, col: 9}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:15.0e-9,  tRP:15.00e-9, tMRD:12.0e-9, tRFC: 72.0e-9, tREFI:7.8125e-6}}," &
		"  MT41K128M16-125:{ generation:ddr3, orgz:{ addr:{ ba:3, row:14, col:10}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:13.75e-9, tRP:13.75e-9, tMRD:15.0e-9, tRFC:360.0e-9, tREFI:7.8125e-6, tXPR:370.0e-9}}," &  -- tMin : tRFC + 10 ns
		"    MT4HTF12864HZ:{ generation:ddr2, orgz:{ addr:{ ba:3, row:14, col: 9}, data:{ dm:8, dq:64}}, tmng:{tWR:15.0e-9, tRCD:15.0e-9,  tRP:15.00e-9, tRPA:15.0e-9, tRFC:130.0e-9, tREFI:7.8125e-6, tXPR:400.0e-6}}," &
		"   MT41J64M16-15E:{ generation:ddr3, orgz:{ addr:{ ba:3, row:13, col:10}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:13.91e-9, tRP:13.91e-9, tMRD:15.0e-9, tRFC:110.0e-9, tREFI:7.8125e-6, tXPR:120.0e-9)}}," &  -- tMin : tRFC + 10 ns
		"  MT41K256M16-107:{ generation:ddr3, orgz:{ addr:{ ba:3, row:16, col:10}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:13.91e-9, tRP:13.91e-9, tMRD:20.0e-9, tRFC:260.0e-9, tREFI:7.8125e-6, tXPR:270.0e-9)}}," &  -- tMin : tRFC + 10 ns
		"  MT41K256M16-125:{ generation:ddr3, orgz:{ addr:{ ba:3, row:16, col:10}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:13.75e-9, tRP:13.75e-9, tMRD:20.0e-9, tRFC:350.0e-9, tREFI:7.8125e-6, tXPR:360.0e-9)}}," &  -- tMin : tRFC + 10 ns
		"AS4C256M16D3LC-12:{ generation:ddr3, orgz:{ addr:{ ba:3, row:15, col:10}, data:{ dm:2, dq:16}}, tmng:{tWR:15.0e-9, tRCD:13.75e-9, tRP:13.75e-9, tMRD:15.0e-9, tRFC:260.0e-9, tREFI:7.8125e-6; tXPR:270.0e-9)}}}");  -- tMin : tRFC + 10 ns

	constant generation_db : string := compact("{" &
		"sdr : {" &
			"  al:{ '000':0 }," &
			"  bl:{ '000':0, '001':1, '010':2, '011':4 }," &
			"  cl:{ '001':1, '010':2, '011':3 }," &
			"tmng:{ tPreRST:100.0e-6, cDLL:200, tCAS:15.0e-9}}" &
		"ddr : {" &
			"  al:{ '000':0},"                   &
			"  bl:{ '001':2, '010':4, '011':8}," &
			"  cl:{ '010':4, '110':5, '011':6}," &
			" cwl:{ '000':2},"                   &
			"tmng:{ tPreRST:200.0e-6, cDLL:200, tCAS:15.0e-9}}" &
		-- "    tmng : { tPreRST : 1.0e-6, cDLL : 200, tCAS : 15.0e-9}}" &
		"ddr2 : {" &
			"  al:{ '000':0, '001':2, '010':4, '011':6, '100':8, '101':10, '110':12},"     &
			"  bl:{ '010':4, '011':8},"                                                    &
			"  cl:{ '011':6, '100':8, '101':10, '110':12, '111':14},"                      &
			" cwl:{ '011':4, '100':6, '101':8,  '110':10, '111':12},"                      &
			" wrl:{ 4:'001', 6:'010',  8:'011',  10:'100', 12:'101', 14:'110', 16:'111'}," &
			"tmng:{ tPreRST:200.0e-6, cDLL:200, tCAS:12.5e-9, MRD:2}}" &
		-- "    tmng : { tPreRST : 1.0e-6, cDLL : 200, MRD : 2}}" &
		"ddr3:{" &
			"length:{bl:2, cl:4, rtt:3, ods:2}," &
			"  al:{ '000':0,   '001':2,   '010':4}," &
			"  bl:{  '00':8,    '01':8,    '10':8}," &
			"  cl:{'0010':10, '0100':12, '0110':14,'1000':16, '1010':18, '1100':20, '1110':22, '0001' : 24, '0011' : 26, '0101' : 28}," &
			" cwl:{ '000':10,  '001':12,  '010':14, '011':16}"                                                                                          &
			" wrl:{  6:'001',   8:'001',  10:'001',  12:'010',  14:'011', 16:'100', 18:'101', 20:'101', 22:'110', 24 : '110', 26: '111', 28 : '111', 30 : '000', 32 : '000'}," &
			"tmng:{ tPreRST:200.0e-6, tPstRST:500.0e-6, cDLL:500, ZQINIT:500, MRD:4, MODu:12, XPR:5, WLDQSEN:25, WLMRD:40, tCAS:13.125e-9}}}");
		-- "tmng : { tPreRST:1.0e-6,   tPstRST:2.0e-6, i cDLL:500, ZQINIT:500, MRD:4, MODu:12, XPR:5, WLDQSEN:25, WLMRD:40, tCAS:13.125e-9}}}");

	constant phy_db : string := compact("[" &
		"           ecp5g1:{ device:ecp5, orgz:{gear:1}, tmng:{STRL: 1, DQSL: 0, DQSZL: 0, DQZL: 0, WWNL: 0, STRXL:0, DQSZXL:0, DQSXL:0, DQZXL:0, WWNXL:0}}," &
		"           xc3sg2:{ device:xc3s, orgz:{gear:2}, tmng:{STRL:-2, DQSL:-2, DQSZL:-2, DQZL:-2, WWNL:-2, STRXL:0, DQSZXL:4, DQSXL:0, DQZXL:0, WWNXL:0}}," &
		"           ecp3g4:{ device:ecp5, orgz:{gear:4}, tmng:{STRL: 0, DQSL: 0, DQSZL: 0, DQZL: 2, WWNL: 2, STRXL:0, DQSZXL:2, DQSXL:2, DQZXL:0, WWNXL:2}}," &
		"           xc5vg4:{ device:xc5v, orgz:{gear:4}, tmng:{STRL: 9, DQSL: 2, DQSZL: 2, DQZL:-1, WWNL:-3, STRXL:0, DQSZXL:1, DQSXL:0, DQZXL:0, WWNXL:0}}," &
		"           xc7vg4:{ device:xc7a, orgz:{gear:4}, tmng:{STRL: 9, DQSL: 1, DQSZL: 1, DQZL:-1, WWNL:-1, STRXL:0, DQSZXL:2, DQSXL:2, DQZXL:0, WWNXL:0}}," &
		"    ulx4ld_ecp5g4:{ device:ecp5, orgz:{gear:4}, tmng:{STRL: 0, DQSL:"&natural'image(4*1-2+2)&", DQSZL:"&natural'image(4*1+0+2)&", DQZL:"&natural'image(4*1+0+2)&", WWNL:"&natural'image(4*1-4+2)&", STRXL:0, DQSZXL:2, DQSXL:2, DQZXL:0, WWNXL:2}}," &
		"orangecrab_ecp5g4:{ device:ecp5, orgz:{gear:4}, tmng:{STRL: 0, DQSL:"&natural'image(4*1-2+0)&", DQSZL:"&natural'image(4*1+0+0)&", DQZL:"&natural'image(4*1+0+0)&", WWNL:"&natural'image(4*1-4+0)&", STRXL:0, DQSZXL:2, DQSXL:2, DQZXL:0, WWNXL:2}}]");

	constant cmd : string := "{nop :'111', mrs:'000', act:'011', read:'101', write:'100', pre:'010', aref:'001', zqc:'110'}";

	constant sdr_init_data : string := "{"                                         &
		"sdr:{"                                                                    &
			"seq:["                                                                &
				"{cmd:nop,  timer:PreRST,  data:{cs:1, cke:0}},"                   &
				"{cmd:nop,  timer:XPR,     data:{cs:0, cke:1}},"                   &
				"{cmd:pre,  timer:RP,      data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr0}},"            &
				"{cmd:nop,  timer:REFi,    data:{cs:0, cke:1}}]},"                 &
		"ddr:{"                                                                    &
			"seq:["                                                                &
				"{cmd:nop,  timer:PreRST,  data:{cs:1, cke:0}},"                   &
				"{cmd:nop,  timer:XPR,     data:{cs:0, cke:1}},"                   &
				"{cmd:pre,  timer:RP,      data:{cs:0, cke:1}},"                   &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr1}},"            &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:rst_dll}},"        &
				"{cmd:pre,  timer:RPA,     data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr0}},"            &
				"{cmd:nop,  timer:cDLL,    data:{cs:0, cke:1}},"                   &
				"{cmd:nop,  timer:REFi,    data:{cs:0, cke:1}}]},"                 &
		"ddr2:{"                                                                   &
			"seq:["                                                                &
				"{cmd:nop,  timer:PreRST,  data:{cs:1, cke:0}},"                   &
				"{cmd:nop,  timer:XPR,     data:{cs:0, cke:1}},"                   &
				"{cmd:pre,  timer:RPA,     data:{cs:0, cke:1}},"                   &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr2}},"            &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr3}},"            &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:ena_dll}},"        &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:rst_dll}},"        &
				"{cmd:pre,  timer:RPA,     data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:aref, timer:RFC,     data:{cs:0, cke:1}},"                   &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr0}},"            &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:ena_ocd}},"        &
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, a:mr1}},"            &
				"{cmd:pre,  timer:RPA,     data:{cs:0, cke:1}},"                   &
				"{cmd:nop,  timer:REFi,    data:{cs:0, cke:1}}]},"                 &
		"ddr3:{"                                                                   &
			"seq:["                                                                &
				"{cmd:nop,  timer:PreRST,  data:{cs:1, cke:0, rst:0}},"            &  -- 0
				"{cmd:nop,  timer:PstRST,  data:{cs:1, cke:0, rst:1}},"            &  -- 1
				"{cmd:nop,  timer:XPR,     data:{cs:0, cke:1, rst:1}},"            &  -- 2
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, rst:1, a:mr2}},"     &  -- 3
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, rst:1, a:mr3}},"     &  -- 4
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, rst:1, a:dll_dis}}," &  -- 5
				"{cmd:mrs,  timer:MRD,     data:{cs:0, cke:1, rst:1, a:mr0}},"     &  -- 6
				"{cmd:zqc,  timer:ZQINIT,  data:{cs:0, cke:1, rst:1}},"            &  -- 7
				"{cmd:mrs,  timer:MODu,    data:{cs:0, cke:1, rst:1, a:wl_on}},"   &  -- 8
				"{cmd:nop,  timer:WLDQSEN, data:{cs:0, cke:1, rst:1, odt:1}},"     &  -- 9 It should be WLDQSEN-MODu
				"{cmd:nop,  timer:MRD,     data:{cs:0, cke:1, rst:1, odt:1,wl_req:on}}," & -- 10
				"{cmd:nop,  timer:MRD,     data:{cs:0, cke:1, rst:1, odt:1}},"     &  -- 11
				"{cmd:nop,  timer:MRD,     data:{cs:0, cke:1, rst:1}},"            &  -- 12
				"{cmd:mrs,  timer:MODu,    data:{cs:0, cke:1, rst:1, a:wl_off}},"  &  -- 13
				"{cmd:nop,  timer:cDLL,    data:{cs:0, cke:1, rst:1}},"            &  -- 14
				"{cmd:nop,  timer:REFi,    data:{cs:0, cke:1, rst:1}}]}}";            -- 15

	procedure mr (
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in  std_logic_vector;
		constant asr   : in  std_logic_vector;
		constant bl    : in  std_logic_vector;
		constant bt    : in  std_logic;
		constant cl    : in  std_logic_vector;
		constant cwl   : in  std_logic_vector;
		constant drtt  : in  std_logic_vector;
		constant mpr   : in  std_logic_vector;
		constant mprrf : in  std_logic_vector;
		constant ods   : in  std_logic_vector;
		constant pd    : in  std_logic_vector;
		constant rdqs  : in  std_logic_vector;
		constant rtt   : in  std_logic_vector;
		constant tdqs  : in  std_logic_vector;
		constant wr    : in  std_logic_vector;
		constant generation : in  string;
		constant row   : in  string);

	constant mpu_nop   : std_logic_vector(0 to 2) := hdo(cmd)**".nop";
	constant mpu_act   : std_logic_vector(0 to 2) := hdo(cmd)**".act";
	constant mpu_read  : std_logic_vector(0 to 2) := hdo(cmd)**".read";
	constant mpu_write : std_logic_vector(0 to 2) := hdo(cmd)**".write";
	constant mpu_pre   : std_logic_vector(0 to 2) := hdo(cmd)**".pre";
	constant mpu_aut   : std_logic_vector(0 to 2) := hdo(cmd)**".aref";
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

	procedure sdr_mr (
		signal   b  : out std_logic_vector;
		signal   a  : out std_logic_vector;
		constant bl : in std_logic_vector;
		constant bt : in std_logic;
		constant cl : in std_logic_vector;
		constant row : in string) is
		constant mr  : string := "{mr0 :'00'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (b'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="mr0" then 
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8 downto 7) <= "00";
				a(9) <= '0';
			else
				assert false
					report "sdr_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr_mr(
		signal   b  : out std_logic_vector;
		signal   a  : out std_logic_vector;
		constant bl : in std_logic_vector;
		constant bt : in std_logic;
		constant cl : in std_logic_vector;
		constant row : in string) is
		constant mr  : string := "{mr0 :'00', mr1:'01'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="rst_dll" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8) <= '1';
			elsif reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(2 downto 0) <= bl(3-1 downto 0);
				a(3) <= bt;
				a(6 downto 4) <= cl(3-1 downto 0);
				a(8) <= '0';
			elsif reg="mr1" then
				b <= hdo(mr)**".mr1";
				a <= (a'range =>'0');
			else
				assert false
					report "ddr_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr2_mr(
		signal   b    : out std_logic_vector;
		signal   a    : out std_logic_vector;
		constant al   : in std_logic_vector;
		constant bl   : in std_logic_vector;
		constant bt   : in std_logic;
		constant cl   : in std_logic_vector;
		constant ods  : in std_logic_vector;
		constant pd   : in std_logic_vector;
		constant rdqs : in std_logic_vector;
		constant rtt  : in std_logic_vector;
		constant tdqs : in std_logic_vector;
		constant wr   : in std_logic_vector;
		constant row  : in string) is
		constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif reg'length > 0  then
			report reg;
			if reg="ena_dll" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
			elsif reg="rst_dll" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(8) <= '1';
			elsif reg="ena_ocd" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(5 downto 3) <= al(3-1 downto 0);
				a(6)  <= rtt(1);
				a(9 downto 7) <= "111";
				a(10) <= tdqs(0);
				a(11) <= rdqs(0);
				a(12) <= '0';
			elsif reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a( 2 downto 0) <= bl(3-1 downto 0);
				a(3)  <= bt;
				a( 6 downto 4) <= cl(3-1 downto 0);
				a(7)  <= '0';
				a(8)  <= '0';
				a(11 downto 9) <= wr;
				a(12) <= pd(0);
			elsif reg="mr1" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(5 downto 3) <= al(3-1 downto 0);
				a(6)  <= rtt(1);
				a(9 downto 7) <= "000";
				a(10) <= tdqs(0);
				a(11) <= rdqs(0);
				a(12) <= '0';
			elsif reg="mr2" then
				b <= hdo(mr)**".mr2";
				a <= (a'range => '0');
				a(7) <= '1';
			elsif reg="mr3" then
				b <= hdo(mr)**".mr3";
				a <= (a'range => '0');
			else
				assert false
					report "ddr2_mr () : row => " & row & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure ddr3_mr(
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in std_logic_vector;
		constant asr   : in std_logic_vector;
		constant bl    : in std_logic_vector;
		constant bt    : in std_logic;
		constant cl    : in std_logic_vector;
		constant cwl   : in std_logic_vector;
		constant drtt  : in std_logic_vector;
		constant mprrf : in std_logic_vector;
		constant mpr   : in std_logic_vector;
		constant ods   : in std_logic_vector;
		constant pd    : in std_logic_vector;
		constant rdqs  : in std_logic_vector;
		constant rtt   : in std_logic_vector;
		constant tdqs  : in std_logic_vector;
		constant wr    : in std_logic_vector;
		constant row   : in string) is
		constant mr  : string := "{mr0 :'000', mr1:'001', mr2:'010', mr3:'011'}";
		constant op  : string := hdo(row)**0;
		constant reg : string := hdo(hdo(row)**2)**".a";
	begin
		b <= (b'range => '-');
		a <= (a'range => '-');
		if op ="pre" then
			a(10) <= '1';
		elsif op ="zqc" then
			a(10) <= '1';
		elsif reg'length > 0  then
			if reg="mr0" then
				b <= hdo(mr)**".mr0";
				a <= (a'range => '0');
				a(1 downto 0)  <= bl(2-1 downto 0);
				a(2)  <= cl(0);
				a(3)  <= bt;
				a(6 downto 4)  <= cl(4-1 downto 1);
				a(7)  <= '0';
				a(8)  <= '1'; -- DLL reset
				a(11 downto 9) <= wr;
				a(12) <= pd(0);
			elsif reg="dll_dis" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '1';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '0';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="wl_on" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '1';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="wl_off" then
				b <= hdo(mr)**".mr1";
				a <= (a'range => '0');
				a(0)  <= '0';
				a(1)  <= ods(0);
				a(2)  <= rtt(0);
				a(4 downto 3) <= al(2-1 downto 0);
				a(5)  <= ods(1);
				a(6)  <= rtt(1);
				a(7)  <= '0';
				a(8)  <= '0';
				a(9)  <= rtt(2);
				a(10) <= '0';
				a(11) <= tdqs(0);
				a(12) <= rdqs(0);
			elsif reg="mr2" then
				b <= hdo(mr)**".mr2";
				a <= (a'range => '0');
				a(2 downto 0) <= "000";
				a(5 downto 3) <= cwl;
				a(6) <= asr(0);
				a(7) <= '0'; -- self refresh temperature
				a(8) <= '0';
				a(10 downto 9) <= drtt;
			elsif reg="mr3" then
				b <= hdo(mr)**".mr3";
				a <= (a'range => '0');
				a(1 downto 0) <= mprrf;
				a(2) <= mpr(0);
			else
				assert false
					report "ddr3_mr () : row => " & '"' & row & '"' & " invalid register"
					severity failure;
			end if;
		end if;
	end;

	procedure mr (
		signal   b     : out std_logic_vector;
		signal   a     : out std_logic_vector;
		constant al    : in  std_logic_vector;
		constant asr   : in  std_logic_vector;
		constant bl    : in  std_logic_vector;
		constant bt    : in  std_logic;
		constant cl    : in  std_logic_vector;
		constant cwl   : in  std_logic_vector;
		constant drtt  : in  std_logic_vector;
		constant mpr   : in  std_logic_vector;
		constant mprrf : in  std_logic_vector;
		constant ods   : in  std_logic_vector;
		constant pd    : in  std_logic_vector;
		constant rdqs  : in  std_logic_vector;
		constant rtt   : in  std_logic_vector;
		constant tdqs  : in  std_logic_vector;
		constant wr    : in  std_logic_vector;
		constant generation       : in  string;
		constant row              : in  string) is
	begin
		   if generation="sdr" then
			sdr_mr(b => b, a => a, bl => bl, bt => bt, cl => cl, row => row);
		   elsif generation="ddr" then
			ddr_mr(b => b, a => a, bl => bl, bt => bt, cl => cl, row => row);
		   elsif generation="ddr2" then
			ddr2_mr(b => b, a => a, al => al, bl => bl, bt => bt, cl => cl, ods => ods, pd => pd, rdqs => rdqs, rtt => rtt, tdqs => tdqs, wr => wr, row => row);
		   elsif generation="ddr3" then
			ddr3_mr(b => b, a => a, al => al, asr => asr, bl => bl, bt => bt, cl => cl, cwl => cwl, drtt => drtt, mpr => mpr, mprrf => mprrf, ods => ods, pd => pd, rdqs => rdqs, rtt => rtt, tdqs => tdqs, wr => wr, row => row);
		   else
		   	assert false
		   		report "sdram_init : generation => " & '"' & generation & '"' & " invalid"
		   		severity failure;
		   end if;
	end;

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

		variable lat    : integer := hdo(phytmng_data)**("."&latency&"=*");
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
