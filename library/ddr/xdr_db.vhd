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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

package xdr_db is

	type tmrk_ids is (ANY, M6T, M15E);
	type tmng_ids is (ANY, tPreRST, tPstRST, tXPR, tWR, tRP, tRCD, tRFC, tMRD, tREFI);
	type latr_ids is (ANY, CL, BL, WRL, CWL);
	type cltabs_ids  is (STRT,  RWNT);
	type cwltabs_ids is (WWNT, DQSZT, DQST, DQSZXT, DQZT, DQZXT);
	type laty_ids is (ANY, cDLL, MRD, MODu, XPR, STRL, RWNL, DQSZL, DQSL, DQZL, WWNL,
		STRXL, RWNXL, DQSZXL, DQSXL, DQZXL, WWNXL, WIDL, ZQINIT);

	constant code_size : natural := 3;
	subtype code_t is std_logic_vector(0 to code_size-1);
	type cnfglat_record is record
		stdr : positive;
		reg  : latr_ids;
		lat  : integer;
		code : code_t;
	end record;

	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	type tmark_record is record
		mark : tmrk_ids;
		stdr  : natural;
	end record;

	type tmark_tab is array (natural range <>) of tmark_record;

	constant tmark_db : tmark_tab (1 to 2) :=
		tmark_record'(mark => M6T,  stdr => 1) &
		tmark_record'(mark => M15E, stdr => 3);

	type latency_record is record
		stdr   : positive;
		param : laty_ids;
		value : integer;
	end record;

	type latency_tab is array (natural range <>) of latency_record;

	constant latency_db : latency_tab  := 
		latency_record'(stdr => 1, param => cDLL,  value => 200) &
		latency_record'(stdr => 1, param => STRL,  value => 4*0) &
		latency_record'(stdr => 1, param => RWNL,  value => 4*0) &
		latency_record'(stdr => 1, param => DQSZL, value => 4*2) &
		latency_record'(stdr => 1, param => DQSL,  value =>   2) &
		latency_record'(stdr => 1, param => DQZL,  value =>   1) &
		latency_record'(stdr => 1, param => WWNL,  value =>   1) &
		latency_record'(stdr => 1, param => STRXL, value =>   2) &
		latency_record'(stdr => 1, param => RWNXL, value => 4*0) &
		latency_record'(stdr => 1, param => DQSZXL, value =>  2) &
		latency_record'(stdr => 1, param => DQSXL, value =>   2) &
		latency_record'(stdr => 1, param => DQZXL, value =>   1) &
		latency_record'(stdr => 1, param => WWNXL, value =>   1) &
		latency_record'(stdr => 1, param => WIDL,  value =>   4) &

		latency_record'(stdr => 2, param => cDLL,  value => 200) &
		latency_record'(stdr => 2, param => STRL,  value =>  -3) &
		latency_record'(stdr => 2, param => RWNL,  value =>   8) &
		latency_record'(stdr => 2, param => DQSZL, value =>  -8) &
		latency_record'(stdr => 2, param => DQSL,  value =>  -2) &
		latency_record'(stdr => 2, param => DQZL,  value =>  -7) &
		latency_record'(stdr => 2, param => WWNL,  value =>  -3) &
		latency_record'(stdr => 2, param => STRXL, value =>   4) &
		latency_record'(stdr => 2, param => RWNXL, value =>   4) &
		latency_record'(stdr => 2, param => DQSZXL, value =>  8) &
		latency_record'(stdr => 2, param => DQSXL, value =>   4) &
		latency_record'(stdr => 2, param => DQZXL, value =>   4) &
		latency_record'(stdr => 2, param => WWNXL, value =>   4) &
		latency_record'(stdr => 2, param => WIDL,  value =>   8) &

		latency_record'(stdr => 3, param => cDLL,  value => 500) &
		latency_record'(stdr => 3, param => STRL,  value => 4*0) &
		latency_record'(stdr => 3, param => RWNL,  value => 4*2) &
		latency_record'(stdr => 3, param => DQSL,  value =>  -4) &
		latency_record'(stdr => 3, param => DQSZL, value =>  -4) &
		latency_record'(stdr => 3, param => DQZL,  value =>  -4) &
		latency_record'(stdr => 3, param => WWNL,  value =>  -8) &
		latency_record'(stdr => 3, param => STRXL, value =>   2) &
		latency_record'(stdr => 3, param => RWNXL, value => 4*0) &
		latency_record'(stdr => 3, param => DQSXL, value =>   2) &
		latency_record'(stdr => 3, param => DQSZXL, value =>  2) &
		latency_record'(stdr => 3, param => DQZXL, value =>   4) &
		latency_record'(stdr => 3, param => WWNXL, value =>   1) &
		latency_record'(stdr => 3, param => ZQINIT, value =>  500) &
		latency_record'(stdr => 3, param => MRD,   value =>   4) &
		latency_record'(stdr => 3, param => MODu,  value =>  12) &
		latency_record'(stdr => 3, param => XPR,   value =>   5) &
		latency_record'(stdr => 3, param => WIDL,  value =>   8);

	type timing_record is record
		mark  : tmrk_ids;
		param : tmng_ids;
		value : natural;
	end record;

	type timing_tab is array (natural range <>) of timing_record;

	constant timing_db : timing_tab(0 to 16-1) := 
		timing_record'(mark => M6T,  param => tPreRST, value => 200000000) &
		timing_record'(mark => M6T,  param => tWR,   value => 15000) &
		timing_record'(mark => M6T,  param => tRP,   value => 15000) &
		timing_record'(mark => M6T,  param => tRCD,  value => 15000) &
		timing_record'(mark => M6T,  param => tRFC,  value => 72000) &
		timing_record'(mark => M6T,  param => tMRD,  value => 12000) &
		timing_record'(mark => M6T,  param => tREFI, value => 7000000) &
		timing_record'(mark => M15E, param => tPreRST, value => 200000000) &
		timing_record'(mark => M15E, param => tPstRST, value => 500000000) &
--		timing_record'(mark => M15E, param => tPreRST, value => 2000000) &
--		timing_record'(mark => M15E, param => tPstRST, value => 2000000) &
		timing_record'(mark => M15E, param => tWR,   value => 15000) &
		timing_record'(mark => M15E, param => tRCD,  value => 13910) &
		timing_record'(mark => M15E, param => tRP,   value => 13910) &
		timing_record'(mark => M15E, param => tMRD,  value => 15000) &
		timing_record'(mark => M15E, param => tRFC,  value => 110000) &
		timing_record'(mark => M15E, param => tXPR,  value => 110000 + 10000) &
		timing_record'(mark => M15E, param => tREFI, value => 7800000);

	constant cnfglat_db : cnfglat_tab :=

		-- DDR1 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => 1, reg => CL,  lat =>  4*2, code => "010") &
		cnfglat_record'(stdr => 1, reg => CL,  lat =>  2*5, code => "110") &
		cnfglat_record'(stdr => 1, reg => CL,  lat =>  4*3, code => "011") &

		-- BL register --

		cnfglat_record'(stdr => 1, reg => BL,  lat =>  2*2, code => "001") &
		cnfglat_record'(stdr => 1, reg => BL,  lat =>  2*4, code => "010") &
		cnfglat_record'(stdr => 1, reg => BL,  lat =>  2*8, code => "011") &

		-- CWL register --

		cnfglat_record'(stdr => 1, reg => CWL, lat =>  4*1, code => "---") &

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => 2, reg => CL,  lat =>  4*3, code => "011") &
		cnfglat_record'(stdr => 2, reg => CL,  lat =>  4*4, code => "100") &
		cnfglat_record'(stdr => 2, reg => CL,  lat =>  4*5, code => "101") &
		cnfglat_record'(stdr => 2, reg => CL,  lat =>  4*6, code => "110") &
		cnfglat_record'(stdr => 2, reg => CL,  lat =>  4*7, code => "111") &

		-- BL register --

		cnfglat_record'(stdr => 2, reg => BL,  lat =>  4, code => "010") &
		cnfglat_record'(stdr => 2, reg => BL,  lat =>  8, code => "011") &

		-- CWL register --

		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*2, code => "001") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*3, code => "010") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*4, code => "011") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*5, code => "100") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*6, code => "101") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*7, code => "110") &
		cnfglat_record'(stdr => 2, reg => WRL, lat =>  4*8, code => "111") &

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => 3, reg => CL, lat =>  4*5, code => "001") &
		cnfglat_record'(stdr => 3, reg => CL, lat =>  4*6, code => "010") &
		cnfglat_record'(stdr => 3, reg => CL, lat =>  4*7, code => "011") &
		cnfglat_record'(stdr => 3, reg => CL, lat =>  4*8, code => "100") &
		cnfglat_record'(stdr => 3, reg => CL, lat =>  4*9, code => "101") &
		cnfglat_record'(stdr => 3, reg => CL, lat => 4*10, code => "110") &
		cnfglat_record'(stdr => 3, reg => CL, lat => 4*11, code => "111") &

		-- BL register --

		cnfglat_record'(stdr => 3, reg => BL, lat => 2*8, code => "000") &
		cnfglat_record'(stdr => 3, reg => BL, lat => 2*8, code => "001") &
		cnfglat_record'(stdr => 3, reg => BL, lat => 2*8, code => "010") &

		-- WRL register --

		cnfglat_record'(stdr => 3, reg => WRL, lat =>  4*5, code => "001") &
		cnfglat_record'(stdr => 3, reg => WRL, lat =>  4*6, code => "010") &
		cnfglat_record'(stdr => 3, reg => WRL, lat =>  4*7, code => "011") &
		cnfglat_record'(stdr => 3, reg => WRL, lat =>  4*8, code => "100") &
		cnfglat_record'(stdr => 3, reg => WRL, lat => 4*10, code => "101") &
		cnfglat_record'(stdr => 3, reg => WRL, lat => 4*12, code => "110") &

		-- CWL register --

		cnfglat_record'(stdr => 3, reg => CWL, lat =>  4*5, code => "000") &
		cnfglat_record'(stdr => 3, reg => CWL, lat =>  4*6, code => "001") &
		cnfglat_record'(stdr => 3, reg => CWL, lat =>  4*7, code => "010") &
		cnfglat_record'(stdr => 3, reg => CWL, lat =>  4*8, code => "011");

end package;
