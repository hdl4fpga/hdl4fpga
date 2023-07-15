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
use hdl4fpga.sdram_param.all;

package sdram_db is
	type sdram_chips is (
		MT46V256M6T,
		MT41J1G15E,
		MT47H512M3,
		MT41K2G125,
		MT41K4G107,
		MT41K8G125,
		AS4CD3LC12,
		MT48LC256MA27E);

	type sdrmark_vector is array (sdram_chips) of sdram_standards;

	constant sdrmark_tab : sdrmark_vector := (
		MT48LC256MA27E => sdr,
		MT46V256M6T    => ddr,
		MT47H512M3     => ddr2,
		MT41J1G15E     => ddr3,
		MT41K2G125     => ddr3,
		MT41K4G107     => ddr3,
		MT41K8G125     => ddr3,
		AS4CD3LC12     => ddr3);

	type timing_record is record
		mark  : sdram_chips;
		param : sdram_parameters;
		value : real;
	end record;

	type timing_vector is array (natural range <>) of timing_record;

	constant timing_tab : timing_vector := (
		(mark => MT48LC256MA27E, param => tPreRST, value => 100.0e-6),
		(mark => MT48LC256MA27E, param => tWR,     value =>  14.0e-9+11.0e-9),
		(mark => MT48LC256MA27E, param => tRP,     value =>  15.0e-9),
		(mark => MT48LC256MA27E, param => tRCD,    value =>  15.0e-9),
		(mark => MT48LC256MA27E, param => tRFC,    value =>  66.0e-9),
		(mark => MT48LC256MA27E, param => tMRD,    value =>  15.0e-9),
		(mark => MT48LC256MA27E, param => tREFI,   value =>  64.0e-3/8192.0), -- real/natural Serious Lattice diamond bug

		(mark => MT46V256M6T,    param => tPreRST, value => 200.0e-6),
		(mark => MT46V256M6T,    param => tWR,     value =>  15.0e-9),
		(mark => MT46V256M6T,    param => tRP,     value =>  15.0e-9),
		(mark => MT46V256M6T,    param => tRCD,    value =>  15.0e-9),
		(mark => MT46V256M6T,    param => tRFC,    value =>  72.0e-9),
		(mark => MT46V256M6T,    param => tMRD,    value =>  12.0e-9),
		(mark => MT46V256M6T,    param => tREFI,   value =>  64.0e-3/8192.0),

		(mark => MT47H512M3,     param => tPreRST, value => 200.0e-6),
		(mark => MT47H512M3,     param => tXPR,    value => 400.0e-6),
		(mark => MT47H512M3,     param => tWR,     value =>  15.0e-9),
		(mark => MT47H512M3,     param => tRP,     value =>  15.0e-9),
		(mark => MT47H512M3,     param => tRCD,    value =>  15.0e-9),
		(mark => MT47H512M3,     param => tRFC,    value => 130.0e-9),
		(mark => MT47H512M3,     param => tRPA,    value =>  15.0e-9),
		(mark => MT47H512M3,     param => tREFI,   value =>  64.0e-3/8192.0),

		(mark => MT41J1G15E,     param => tPreRST, value => 200.00e-6),
		(mark => MT41J1G15E,     param => tPstRST, value => 500.00e-6),
		(mark => MT41J1G15E,     param => tWR,     value =>  15.00e-9),
		(mark => MT41J1G15E,     param => tRCD,    value =>  13.91e-9),
		(mark => MT41J1G15E,     param => tRP,     value =>  13.91e-9),
		(mark => MT41J1G15E,     param => tMRD,    value =>  15.00e-9),
		(mark => MT41J1G15E,     param => tRFC,    value => 110.00e-9),
		(mark => MT41J1G15E,     param => tXPR,    value => 110.00e-9 + 10.0e-9),  -- tMin : tRFC + 10 ns
		(mark => MT41J1G15E,     param => tREFI,   value =>  64.00e-3/8192.0),

		(mark => MT41K2G125,     param => tPreRST, value => 200.00e-6),
		(mark => MT41K2G125,     param => tPstRST, value => 500.00e-6),
		(mark => MT41K2G125,     param => tWR,     value =>  15.00e-9),
		(mark => MT41K2G125,     param => tRCD,    value =>  13.75e-9),
		(mark => MT41K2G125,     param => tRP,     value =>  13.75e-9),
		(mark => MT41K2G125,     param => tMRD,    value =>  15.00e-9),
		(mark => MT41K2G125,     param => tRFC,    value => 360.00e-9),
		(mark => MT41K2G125,     param => tXPR,    value => 360.00e-9 + 10.0e-9),  -- tMin : tRFC + 10 ns
		(mark => MT41K2G125,     param => tREFI,   value =>  64.00e-3/8192.0),

		(mark => MT41K4G107,     param => tPreRST, value => 200.00e-6),
		(mark => MT41K4G107,     param => tPstRST, value => 500.00e-6),
		(mark => MT41K4G107,     param => tWR,     value =>  15.00e-9),
		(mark => MT41K4G107,     param => tRCD,    value =>  13.91e-9),
		(mark => MT41K4G107,     param => tRP,     value =>  13.91e-9),
		(mark => MT41K4G107,     param => tMRD,    value =>  20.00e-9),
		(mark => MT41K4G107,     param => tRFC,    value => 260.00e-9),
		(mark => MT41K4G107,     param => tXPR,    value => 260.00e-9 + 10.0e-9),  -- tMin : tRFC + 10 ns
		(mark => MT41K4G107,     param => tREFI,   value =>  64.00e-3/8192.0),

		(mark => MT41K8G125,     param => tPreRST, value => 200.00e-6),
		(mark => MT41K8G125,     param => tPstRST, value => 500.00e-6),
		(mark => MT41K8G125,     param => tWR,     value =>  15.00e-9),
		(mark => MT41K8G125,     param => tRCD,    value =>  13.75e-9),
		(mark => MT41K8G125,     param => tRP,     value =>  13.75e-9),
		(mark => MT41K8G125,     param => tMRD,    value =>  20.00e-9),
		(mark => MT41K8G125,     param => tRFC,    value => 350.00e-9),
		(mark => MT41K8G125,     param => tXPR,    value => 350.00e-9 + 10.0e-9),  -- tMin : tRFC + 10 ns
		(mark => MT41K8G125,     param => tREFI,   value =>  64.00e-3/8192.0),

		(mark => AS4CD3LC12,     param => tPreRST, value => 200.00e-6),
		(mark => AS4CD3LC12,     param => tPstRST, value => 500.00e-6),
		(mark => AS4CD3LC12,     param => tWR,     value =>  15.00e-9),
		(mark => AS4CD3LC12,     param => tRCD,    value =>  13.75e-9),
		(mark => AS4CD3LC12,     param => tRP,     value =>  13.75e-9),
		(mark => AS4CD3LC12,     param => tMRD,    value =>  15.00e-9),
		(mark => AS4CD3LC12,     param => tRFC,    value => 260.00e-9),
		(mark => AS4CD3LC12,     param => tXPR,    value => 260.00e-9 + 10.0e-9),  -- tMin : tRFC + 10 ns
		(mark => AS4CD3LC12,     param => tREFI,   value =>  64.00e-3/8192.0));

	type latency_vector     is array (device_latencies) of integer;
	constant sdram_latency_tab : sdram_latency_vector := (
		(stdr => ddr,  param => cDLL,   value => 200),

		(stdr => ddr2, param => cDLL,   value => 200),
		(stdr => ddr2, param => MRD,    value =>   2),

		(stdr => ddr3, param => cDLL,   value => 500),
		(stdr => ddr3, param => ZQINIT, value => 500),
		(stdr => ddr3, param => MRD,    value =>   4),
		(stdr => ddr3, param => MODu,   value =>  12),
		(stdr => ddr3, param => XPR,    value =>   5));

	constant xc3sg2_latencies : latency_vector := (
		STRL   => -2,
		DQSL   => -2,
		DQSZL  => -2,
		DQZL   => -2,
		WWNL   => -2,
		STRXL  =>  0,
		DQSZXL =>  4,
		DQSXL  =>  0,
		DQZXL  =>  0,
		WWNXL  =>  0,
		WIDL   =>  2);

	constant xc5vg4_latencies : latency_vector := (
		STRL   =>  9,
		DQSL   =>  2,
		DQSZL  =>  2,
		DQZL   => -1,
		WWNL   => -3,
		STRXL  =>  0,
		DQSZXL =>  1,
		DQSXL  =>  0,
		DQZXL  =>  0,
		WWNXL  =>  0,
		WIDL   =>  4);

	constant xc7vg4_latencies : latency_vector := (
		STRL   =>  9,
		DQSL   =>  1,
		DQSZL  =>  1,
		DQZL   => -1,
		WWNL   => -1,
		STRXL  =>  0,
		DQSZXL =>  2,
		DQSXL  =>  2,
		DQZXL  =>  0,
		WWNXL  =>  0,
		WIDL   =>  4);

	constant ecp3g4_latencies : latency_vector := (
		STRL   => 0,
		DQSL   => 0,
		DQSZL  => 0,
		DQZL   => 2,
		WWNL   => 2,
		STRXL  => 0,
		DQSZXL => 2,
		DQSXL  => 2,
		DQZXL  => 0,
		WWNXL  => 2,
		WIDL   => 4);

	constant ecp5g1_latencies : latency_vector := (
		STRL   => 1,
		DQSL   => 0,
		DQSZL  => 0,
		DQZL   => 0,
		WWNL   => 0,
		STRXL  => 0,
		DQSZXL => 0,
		DQSXL  => 0,
		DQZXL  => 0,
		WWNXL  => 0,
		WIDL   => 1);

	constant ecp5g4_latencies : latency_vector := (
		STRL   =>  0,
		DQSL   =>  4*1-2+2, -- ulx4ld
		DQSZL  =>  4*1+0+2,
		DQZL   =>  4*1+0+2,
		WWNL   =>  4*1-4+2,
		-- DQSL   =>  4*1-2+0, -- orangecrab
		-- DQSZL  =>  4*1+0+0,
		-- DQZL   =>  4*1+0+0,
		-- WWNL   =>  4*1-4+0,
		STRXL  =>  0,
		DQSZXL =>  2,
		DQSXL  =>  2,
		DQZXL  =>  0,
		WWNXL  =>  2,
		WIDL   =>  4);

	function sdrmark_standard (
		constant mark : sdram_chips)
		return sdram_standards;

	function sdram_timing (
		constant mark  : sdram_chips;
		constant param : sdram_parameters)
		return real;

	function sdram_latency (
		constant stdr : sdram_standards;
		constant param : sdram_latencies)
		return natural;

	function sdram_schtab (
		constant stdr      : sdram_standards;
		constant latencies : latency_vector;
		constant tabid     : device_latencies)
		return natural_vector;

	function sdram_schtab (
		constant latency   : integer;
		constant latencies : natural_vector)
		return natural_vector;

	function to_sdrlatency (
		constant period : real;
		constant mark   : sdram_chips;
		constant param  : sdram_parameters)
		return natural;

end package;

package body sdram_db is

	function sdrmark_standard (
		constant mark : sdram_chips)
		return sdram_standards is
	begin
		return sdrmark_tab(mark);
	end;

	function sdram_timing (
		constant mark  : sdram_chips;
		constant param : sdram_parameters)
		return real is
	begin
		for i in timing_tab'range loop
			if timing_tab(i).mark = mark then
				if timing_tab(i).param = param then
					return timing_tab(i).value;
				end if;
			end if;
		end loop;

		assert false
		report ">>>sdram_timing<<<"       & " : " & 
			sdram_chips'image(mark)       & " : " &
			sdram_parameters'image(param) & " : " &
			"not found, returning 0.0"
		severity warning;

		return 0.0;
	end;

	function sdram_latency (
		constant stdr : sdram_standards;
		constant param : sdram_latencies)
		return natural is
	begin
		for i in sdram_latency_tab'range loop
			if sdram_latency_tab(i).stdr = stdr then
				if sdram_latency_tab(i).param = param then
					return sdram_latency_tab(i).value;
				end if;
			end if;
		end loop;

		assert false
		report ">>> sdram_latency <<<"   & " : " & 
			sdram_standards'image(stdr)  & " : " &
			sdram_latencies'image(param) & " : " &
			"not found, returning 0"
		severity warning;

		return 0;
	end;

	function to_sdrlatency (
		constant period : real;
		constant mark   : sdram_chips;
		constant param  : sdram_parameters)
		return natural is
		variable retval : natural;
	begin
		retval := natural(ceil(sdram_timing(mark, param)/period));

		assert false
		report "AC parameter of "         &
			sdram_chips'image(mark)       & " named " &
			sdram_parameters'image(param) & " is    " &
			natural'image(retval)
		severity note;

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