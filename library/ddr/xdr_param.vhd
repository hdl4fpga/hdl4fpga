use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

package xdr_param is
	component xdr_cfg is
		generic (
			cRP  : natural := 10;
			cMRD : natural := 11;
		    cRFC : natural := 13;
		    cMOD : natural := 13;

			a  : natural := 13;
			ba : natural := 2);
		port (
			xdr_cfg_ods : in  std_logic := '0';
			xdr_cfg_rtt : in  std_logic_vector(1 downto 0) := "01";
			xdr_cfg_bl  : in  std_logic_vector(0 to 2);
			xdr_cfg_cl  : in  std_logic_vector(0 to 2);
			xdr_cfg_wr  : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_cwl : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_pl  : in  std_logic_vector(0 to 2) := (others => '0');
			xdr_cfg_dqsn : in std_logic := '0';

			xdr_cfg_clk : in  std_logic;
			xdr_cfg_req : in  std_logic;
			xdr_cfg_rdy : out std_logic := '1';
			xdr_cfg_dll : out std_logic := '1';
			xdr_cfg_odt : out std_logic := '0';
			xdr_cfg_ras : out std_logic := '1';
			xdr_cfg_cas : out std_logic := '1';
			xdr_cfg_we  : out std_logic := '1';
			xdr_cfg_a   : out std_logic_vector( a-1 downto 0) := (others => '1');
			xdr_cfg_b   : out std_logic_vector(ba-1 downto 0) := (others => '1'));
	end component;

	type tmrk_ids is (ANY, M6T, M107);
	type tmng_ids is (ANY, tPreRST, tPstRST, tXPR, tWR, tRP, tRCD, tRFC, tMRD, tREFI);
	type latr_ids is (ANY, CL, BL, WRL, CWL, RSTL, RWL, DQSZL, DQSL, DQZL, WWL);
	type laty_ids is (ANY, cDLL);

	type cnfglat_record is record
		std  : positive;
		reg  : latr_ids;
		lat  : integer;
		code : std_logic_vector(0 to 2);
	end record;
	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	function xdr_cnfglat (
		constant std : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking it up
		return std_logic_vector;

	function xdr_timing (
		mark  : tmrk_ids;
		param : tmng_ids) 
		return time;

	function xdr_latency (
		std : natural;
		param : laty_ids) 
		return natural;

	function xdr_query_size (
		constant std : natural;
		constant reg : latr_ids)
		return natural;

	function xdr_query_data (
		constant std : natural;
		constant reg : latr_ids)
		return cnfglat_tab;

	function xdr_std (
		mark : tmrk_ids) 
		return natural;

	function to_xdrlatency (
		period : time;
		timing : time)
		return natural;

	function to_xdrlatency (
		constant period : time;
		constant mark   : tmrk_ids;
		constant param  : tmng_ids;
		constant word_size : natural := 1;
		constant byte_size : natural := 1;
		constant data_edges : natural := 1)
		return natural;

	function xdr_lattab (
		constant std : natural;
		constant reg : latr_ids;
		constant word_size : natural := 1;
		constant byte_size : natural := 1;
		constant data_edges : natural := 1)
		return natural_vector;

	function xdr_latcod (
		constant std : natural;
		constant reg : latr_ids)
		return std_logic_vector;

	function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant word_size : natural;
		constant byte_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0)
		return std_logic_vector;

end package;

library hdl4fpga;
use hdl4fpga.std.all;

package body xdr_param is

	type tmark_record is record
		mark : tmrk_ids;
		std  : natural;
	end record;

	type tmark_tab is array (natural range <>) of tmark_record;

	constant tmark_db : tmark_tab (1 to 2) :=
		tmark_record'(mark => M6T,  std => 1) &
		tmark_record'(mark => M107, std => 3);

	type latency_record is record
		std   : positive;
		param : laty_ids;
		value : natural;
	end record;

	type latency_tab is array (natural range <>) of latency_record;

	constant latency_db : latency_tab (1 to 3) := 
		latency_record'(std => 1, param => cDLL, value => 200) &
		latency_record'(std => 2, param => cDLL, value => 200) &
		latency_record'(std => 3, param => cDLL, value => 500);

	type timing_record is record
		mark  : tmrk_ids;
		param : tmng_ids;
		value : time;
	end record;

	type timing_tab is array (natural range <>) of timing_record;

	constant timing_db : timing_tab(1 to 10) := 
		timing_record'(mark => M6T,  param => tPreRST, value => 200 us) &
		timing_record'(mark => M6T,  param => tWR,   value => 15 ns) &
		timing_record'(mark => M6T,  param => tRP,   value => 15 ns) &
		timing_record'(mark => M6T,  param => tRCD,  value => 15 ns) &
		timing_record'(mark => M6T,  param => tRFC,  value => 72 ns) &
		timing_record'(mark => M6T,  param => tMRD,  value => 12 ns) &
		timing_record'(mark => M107, param => tREFI, value =>  7 us) &
		timing_record'(mark => M107, param => tPreRST, value => 200 us) &
		timing_record'(mark => M107, param => tPstRST, value => 500 us) &
		timing_record'(mark => M6T,  param => tREFI, value =>  7 us);

	constant cnfglat_db : cnfglat_tab :=

		-- DDR1 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 1, reg => CL,  lat =>  4*2, code => "010") &
		cnfglat_record'(std => 1, reg => CL,  lat =>  2*5, code => "110") &
		cnfglat_record'(std => 1, reg => CL,  lat =>  4*3, code => "011") &

		-- BL register --

		cnfglat_record'(std => 1, reg => BL,  lat =>  2*2, code => "001") &
		cnfglat_record'(std => 1, reg => BL,  lat =>  2*4, code => "010") &
		cnfglat_record'(std => 1, reg => BL,  lat =>  2*8, code => "011") &

		-- CWL register --

		cnfglat_record'(std => 1, reg => CWL, lat =>  4*1, code => "---") &

		-- RSTL, RWL, DQSZ, DQSZL, DQSL, WWL latency --

		cnfglat_record'(std => 1, reg => RSTL,  lat => 4*0, code => "---") &
		cnfglat_record'(std => 1, reg => RWL,   lat => 4*0, code => "---") &
		cnfglat_record'(std => 1, reg => DQSZL, lat => 4*2, code => "---") &
		cnfglat_record'(std => 1, reg => DQSL,  lat =>   2, code => "---") &
		cnfglat_record'(std => 1, reg => DQZL,  lat =>   1, code => "---") &
		cnfglat_record'(std => 1, reg => WWL,   lat =>   1, code => "---") &

		cnfglat_record'(std => 1, reg => RSTXL, lat =>   2, code => "---") &
		cnfglat_record'(std => 1, reg => RWXL,  lat => 4*0, code => "---") &
		cnfglat_record'(std => 1, reg => DQSZXL, lat =>  2, code => "---") &
		cnfglat_record'(std => 1, reg => DQSXL, lat =>   2, code => "---") &
		cnfglat_record'(std => 1, reg => DQZXL, lat =>   1, code => "---") &
		cnfglat_record'(std => 1, reg => WWXL,  lat =>   1, code => "---") &

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 2, reg => CL,  lat =>  2*3, code => "011") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  2*4, code => "100") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  2*5, code => "101") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  2*6, code => "110") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  2*7, code => "111") &

		-- BL register --

		cnfglat_record'(std => 2, reg => BL,  lat =>  4, code => "010") &
		cnfglat_record'(std => 2, reg => BL,  lat =>  8, code => "011") &

		-- WRL register --

		cnfglat_record'(std => 2, reg => WRL, lat =>  2*2, code => "001") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*3, code => "010") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*4, code => "011") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*5, code => "100") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*6, code => "101") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*7, code => "110") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  2*8, code => "111") &

		-- CWL register --

		cnfglat_record'(std => 2, reg => CWL, lat =>  2*1, code => "---") &

		-- RSTL, RWL, DQSZ, DQSZL, DQSL, WWL latency --

		cnfglat_record'(std => 2, reg => RSTL,  lat =>   -3, code => "---") &
		cnfglat_record'(std => 2, reg => RWL,   lat =>    8, code => "---") &
		cnfglat_record'(std => 2, reg => DQSZL, lat =>   -8, code => "---") &
		cnfglat_record'(std => 2, reg => DQSL,  lat =>   -2, code => "---") &
		cnfglat_record'(std => 2, reg => DQZL,  lat =>   -7, code => "---") &
		cnfglat_record'(std => 2, reg => WWL,   lat =>   -3, code => "---") &

		cnfglat_record'(std => 2, reg => RSTXL, lat =>   4, code => "---") &
		cnfglat_record'(std => 2, reg => RWXL,  lat =>   4, code => "---") &
		cnfglat_record'(std => 2, reg => DQSZXL, lat =>  8,  code => "---") &
		cnfglat_record'(std => 2, reg => DQSXL, lat =>   4, code => "---") &
		cnfglat_record'(std => 2, reg => DQZXL, lat =>   4, code => "---") &
		cnfglat_record'(std => 2, reg => WWXL,  lat =>   4, code => "---") &

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 3, reg => CL,  lat =>  2*5, code => "001") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  2*6, code => "010") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  2*7, code => "011") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  2*8, code => "100") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  2*9, code => "101") &
		cnfglat_record'(std => 3, reg => CL,  lat => 2*10, code => "110") &
		cnfglat_record'(std => 3, reg => CL,  lat => 2*11, code => "111") &

		-- BL register --

		cnfglat_record'(std => 3, reg => BL,  lat =>  4, code => "000") &
		cnfglat_record'(std => 3, reg => BL,  lat =>  8, code => "001") &
		cnfglat_record'(std => 3, reg => BL,  lat => 16, code => "010") &

		-- WRL register --

		cnfglat_record'(std => 3, reg => WRL, lat =>  2*5, code => "001") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  2*6, code => "010") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  2*7, code => "011") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  2*8, code => "100") &
		cnfglat_record'(std => 3, reg => WRL, lat => 2*10, code => "101") &
		cnfglat_record'(std => 3, reg => WRL, lat => 2*12, code => "110") &

		-- CWL register --

		cnfglat_record'(std => 3, reg => CWL, lat =>  2*5, code => "000") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  2*6, code => "001") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  2*7, code => "010") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  2*8, code => "011") &

		-- RSTL, RWL, DQSZ, DQSZL, DQSL, WWL latency --

		cnfglat_record'(std => 3, reg => RSTL,  lat =>  4*0, code => "---") &
		cnfglat_record'(std => 3, reg => RWL,   lat =>  4*2, code => "---") &
		cnfglat_record'(std => 3, reg => DQSZL, lat =>   -2, code => "---") &
		cnfglat_record'(std => 3, reg => DQSL,  lat =>    0, code => "---") &
		cnfglat_record'(std => 3, reg => DQZL,  lat =>    1, code => "---") &
		cnfglat_record'(std => 3, reg => WWL,   lat =>   -3, code => "---") &

		cnfglat_record'(std => 1, reg => RSTXL, lat =>   2, code => "---") &
		cnfglat_record'(std => 1, reg => RWXL,  lat => 4*0, code => "---") &
		cnfglat_record'(std => 1, reg => DQSZXL, lat => 4*2, code => "---") &
		cnfglat_record'(std => 1, reg => DQSXL, lat =>   2, code => "---") &
		cnfglat_record'(std => 1, reg => DQZXL, lat =>   1, code => "---") &
		cnfglat_record'(std => 1, reg => WWXL,  lat =>   1, code => "---");


	function xdr_cnfglat (
		constant std : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking up
		return std_logic_vector is
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).std = std then
				if cnfglat_db(i).reg = reg then
					if cnfglat_db(i).lat = lat then
						return cnfglat_db(i).code;
					end if;
				end if;
			end if;
		end loop;

		report "xdr_cnfglat: Invalid DDR configuration latency"
		severity WARNING;
		return "XXX";
	end;

	function xdr_timing (
		mark  : tmrk_ids;
		param : tmng_ids) 
		return time is
		variable msg : line;
	begin
		for i in timing_db'range loop
			if timing_db(i).mark = mark then
				if timing_db(i).param = param then
					return timing_db(i).value;
				end if;
			end if;
		end loop;

		write (msg, string'("-> "));
		write (msg, tmrk_ids'pos(mark));
		write (msg, string'(" <-> "));
		write (msg, tmng_ids'pos(param));
		report msg.all;
		report "xdr_timing: Invalid DDR timing"
		severity WARNING;
		return 0 ns;
	end;

	function xdr_latency (
		std : natural;
		param : laty_ids) 
		return natural is
	begin
		for i in latency_db'range loop
			if latency_db(i).std = std then
				if latency_db(i).param = param then
					return latency_db(i).value;
				end if;
			end if;
		end loop;

		report "xdr_latency: Invalid DDR latency"
		severity WARNING;
		return 0;
	end;

	function xdr_std (
		mark : tmrk_ids) 
		return natural is
	begin
		for i in tmark_db'range loop
			if tmark_db(i).mark = mark then
				return latency_db(i).value;
			end if;
		end loop;

		report "xdr_std: Invalid DDR latency"
		severity WARNING;
		return 0;
	end;

	function to_xdrlatency (
		period : time;
		timing : time)
		return natural is
	begin
		return (timing+period)/period;
	end;

	function to_xdrlatency (
		constant period : time;
		constant mark   : tmrk_ids;
		constant param  : tmng_ids;
		constant word_size : natural := 1;
		constant byte_size : natural := 1;
		constant data_edges : natural := 1)
		return natural is
	begin
		return to_xdrlatency(period, xdr_timing(mark, param));
	end;

	function xdr_query_size (
		constant std : natural;
		constant reg : latr_ids)
		return natural is
		variable val : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).std = std then
				if cnfglat_db(i).reg = reg then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function xdr_query_data (
		constant std : natural;
		constant reg : latr_ids)
		return cnfglat_tab is
		constant query_size : natural := xdr_query_size(std, reg);
		variable query_data : cnfglat_tab (1 to query_size);
		variable query_row  : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).std = std then
				if cnfglat_db(i).reg = reg then
					query_row := query_row + 1;
					query_data(query_row) := cnfglat_db(i);
				end if;
			end if;
		end loop;
		return query_data;
	end;

	function xdr_lattab (
		constant std : natural;
		constant reg : latr_ids;
		constant word_size : natural := 1;
		constant byte_size : natural := 1;
		constant data_edges : natural := 1)
		return natural_vector is
		constant query_size : natural := xdr_query_size(std, reg);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(std, reg);
		variable lattab : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := (byte_size*(data_edges*((query_data(i).lat+1)/2)))/word_size;
		end loop;
		return lattab;
	end;

	function xdr_latcod (
		constant std : natural;
		constant reg : latr_ids)
		return std_logic_vector is
		constant query_size : natural := xdr_query_size(std, reg);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(std, reg);
		variable latcode : std_logic_vector(0 to cnfglat_db(1).code'length*query_size-1);
	begin
		for i in query_data'reverse_range loop
			latcode := latcode srl cnfglat_db(1).code'length;
			latcode(cnfglat_db(1).code'range) := query_data(i).code;
		end loop;
		return latcode;
	end;

	function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant word_size : natural;
		constant byte_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to word_size/byte_size*data_phases-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable pha : natural;
		variable aux : std_logic;
		variable sel_sch : word_vector(lat_cod'range);

		constant word_byte : natural := word_size/byte_size;
		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : std_logic_vector(0 to arg'length-1) := arg;
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			for i in val'range loop
				val(i) := aux(latword'range);
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		function select_lat (
			constant lat_val  : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length -1 loop
				if lat_val = lat_cod(i) then
					for j in word'range loop
						val(j) := lat_sch(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;

	begin
		sel_sch := (others => (others => '-'));
		setup_l : for i in 0 to lat_tab'length-1 loop
			disp := lat_tab(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  / word'length;
			for j in word'range loop
				aux := '0';
				for l in 0 to (lat_ext+word'length-1-j)/word'length loop
					pha := (j+disp_mod+l*word'length)/word_byte;
					aux := aux or lat_sch(disp_quo*word'length+pha);
				end loop;
				sel_sch(i)((disp+j) mod word'length) := aux;
			end loop;
		end loop;
		return select_lat(lat_val, to_latwordvector(lat_cod), sel_sch);
	end;

end package body;
