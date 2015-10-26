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

	constant ANY  : natural := 0;

	constant DDR1 : natural := 1;
	constant DDR2 : natural := 2;
	constant DDR3 : natural := 3;

	constant M6T  : natural := 1;
	constant M15E : natural := 2;

	constant tPreRST : natural := 1;
	constant tPstRST : natural := 2;
	constant tXPR    : natural := 3;
	constant tWR     : natural := 4;
	constant tRP     : natural := 5;
	constant tRCD    : natural := 6;
	constant tRFC    : natural := 7;
	constant tMRD    : natural := 8;
	constant tREFI   : natural := 9;

	constant CL  : natural := 1;
	constant BL  : natural := 2;
	constant WRL : natural := 3;
	constant CWL : natural := 4;

	-- Latency Tables

	constant STRT   : natural := 1;
	constant RWNT   : natural := 2;
	constant WWNT   : natural := 3;
	constant DQSZT  : natural := 4;
	constant DQST   : natural := 5;
	constant DQSZXT : natural := 6;
	constant DQZT   : natural := 7;
	constant DQZXT  : natural := 8;

	-- Latencies 
	constant cDLL   : natural := 1;
	constant MRD    : natural := 2;
	constant MODu   : natural := 3;
	constant XPR    : natural := 4;
	constant STRL   : natural := 5;
	constant RWNL   : natural := 6;
	constant DQSZL  : natural := 7;
	constant DQSL   : natural := 8;
	constant DQZL   : natural := 9;
	constant WWNL   : natural := 10;
	constant STRXL  : natural := 11;
	constant RWNXL  : natural := 12;
	constant DQSZXL : natural := 13;
	constant DQSXL  : natural := 14;
	constant DQZXL  : natural := 15;
	constant WWNXL  : natural := 16;
	constant WIDL   : natural := 17;
	constant ZQINIT : natural := 18;

	constant code_size : natural := 3;
	subtype code_t is std_logic_vector(0 to code_size-1);
	type cnfglat_record is record
		stdr : natural;
		reg  : natural;
		lat  : integer;
		code : code_t;
	end record;

	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	type tmark_record is record
		mark : natural;
		stdr : natural;
	end record;

	type tmark_tab is array (natural range <>) of tmark_record;

	constant tmark_db : tmark_tab (1 to 2) :=
		tmark_record'(mark => M6T,  stdr => 1) &
		tmark_record'(mark => M15E, stdr => 3);

	type latency_record is record
		stdr  : natural;
		param : natural; -- Latency
		value : integer;
	end record;

	type latency_tab is array (natural range <>) of latency_record;

	type timing_record is record
		mark  : natural;
		param : natural;
		value : natural;
	end record;

	type timing_tab is array (natural range <>) of timing_record;

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


	function xdr_query_size (
		constant stdr : natural;
		constant rgtr  : natural)
		return natural;

	function xdr_cnfglat (
		constant stdr: natural;
		constant reg : natural;
		constant lat : natural)
		return natural;

	function xdr_timing (
		constant timing_db : timing_tab;
		constant mark  : natural;
		constant param : natural) 
		return natural is

	function xdr_latency (
		constant stdr  : natural;
		constant param : natural; 
		constant tCP   : natural :=  250;
		constant tDDR  : natural := 1000);
		return integer;

	function to_xdrlatency (
		period : natural;
		timing : natural)
		return natural;

	function to_xdrlatency (
		constant period : natural;
		constant mark   : natural;
		constant param  : natural)
		return natural;

end package;

package body xdr_db is

	function xdr_query_size (
		constant stdr : natural;
		constant rtgr : natural)
		return natural is
		variable val : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).rgtr = reg then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function xdr_query_data (
		constant stdr : natural;
		constant rgtr : natural)
		return cnfglat_tab is
		constant query_size : natural := xdr_query_size(stdr, reg);
		variable query_data : cnfglat_tab (0 to query_size-1);
		variable query_row  : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).rgtr = rgtr then
					query_row := query_row + 1;
					query_data(query_row) := cnfglat_db(i);
				end if;
			end if;
		end loop;
		return query_data;
	end;

	function xdr_cnfglat (
		constant stdr: natural;
		constant reg : natural;
		constant lat : natural)
		return std_logic_vector is
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).rgtr = rgtr then
					if cnfglat_db(i).lat = lat then
						return cnfglat_db(i).code;
					end if;
				end if;
			end if;
		end loop;

		return "XXX";
	end;

	function xdr_timing (
		constant mark  : natural;
		constant param : natural) 
		return natural is
	begin
		for i in timing_db'range loop
			if timing_db(i).mark = mark then
				if timing_db(i).param = param then
					return timing_db(i).value;
				end if;
			end if;
		end loop;

		return 0;
	end;

	function xdr_latency (
		constant stdr  : natural;
		constant param : natural; 
		constant tCP   : natural :=  250;
		constant tDDR  : natural := 1000);
		return integer is
		variable msg : line;
	begin
		for i in latency_db'range loop
			if latency_db(i).stdr = stdr then
				if latency_db(i).param = param then
					return (latency_db(i).value*tDDR)/(4*tCP);
				end if;
			end if;
		end loop;
		return 0;
	end;

	function to_xdrlatency (
		period : natural;
		timing : natural)
		return natural is
	begin
		if (timing/period)*period < timing then
			return (timing+period)/period;
		else
			return timing/period;
		end if;
	end;

	function to_xdrlatency (
		constant period : natural;
		constant mark   : natural;
		constant param  : natural)
		return natural is
	begin
		return to_xdrlatency(period, xdr_timing(mark, param));
	end;

	function xdr_lattab (
		constant stdr : natural;
		constant rgtr : natural;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is
		constant query_size : natural := xdr_query_size(stdr, rgtr);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(stdr, rgtr);
		variable lattab : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := (query_data(i).lat*tDDR)/(4*tCP);
		end loop;
		return lattab;
	end;

	function xdr_schtab (
		constant stdr : natural;
		constant rtgr : natural;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is

		constant lat : integer := xdr_latency(stdr, rtgr);
		constant tab : natural_vector := xdr_latrgtr(stdr, CL, tDDR, 4*tDDR);
		variable val : natural_vector(tab'range);

	begin
		for i in tab'range loop
			val(i) := ((tab(i)+lat)*tDDR)/(4*tCP);
		end loop;
		return val;
	end;

	function xdr_schtab (
		constant stdr   : natural;
		constant tabid : cwltabs_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is

		type latid_vector is array (cwltabs_ids) of laty_ids;
		constant tab2laty : latid_vector := (WWNT => WWNL, DQSZT => DQSZL, DQST => DQSL, DQSZXT => DQSZXL, DQZT => DQZL, DQZXT => DQZXL);

		constant cltab  : natural_vector(0 to  xdr_query_size(stdr, CL)-1)  := xdr_lattab(stdr, CL);
		constant cwltab : natural_vector(0 to  xdr_query_size(stdr, CWL)-1) := xdr_lattab(stdr, CWL);
		variable clval  : natural_vector(cltab'range);
		variable cwlval : natural_vector(cwltab'range);
		variable latx   : integer := 0;

	constant STRT   : natural := 1;
	constant RWNT   : natural := 2;
	constant WWNT   : natural := 3;
	constant DQSZT  : natural := 4;
	constant DQST   : natural := 5;
	constant DQSZXT : natural := 6;
	constant DQZT   : natural := 7;
	constant DQZXT  : natural := 8;

	begin
		case tabid is
		when STRT =>
		when RWNT =>
		when WWNT =>
		when DQZXT =>
			latx := lat;
			lat  := xdr_latency(stdr, DQZXL);
			for i in cwltab'range loop
				aux := ((cwltab(i)+lat )*tDDR) mod (4*tCP);
				cwlval(i) := (latx*tDDR+aux+4*tCP-1) / (4*tCP);
			end loop;
		when DQSZXT =>
			latx := lat;
			lat  := xdr_latency(stdr, DQSZXL);
			for i in cwltab'range loop
				aux := ((cwltab(i)+lat )*tDDR) mod (4*tCP);
				cwlval(i) := (latx*tDDR+aux+4*tCP-1) / (4*tCP);
			end loop;
		when others =>
			for i in cwltab'range loop
				cwlval(i) := ((cwltab(i)+lat)*tDDR)/(4*tCP);
			end loop;
		end case;
		return cwlval;
	end;

end package body;
