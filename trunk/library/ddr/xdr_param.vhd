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
	type latr_ids is (ANY, CL, BL, WRL, CWL);
	type cltabs_ids  is (STRT,  RWNT);
	type cwltabs_ids is (WWNT, DQSZT, DQST,  DQZT);
	type laty_ids is (ANY, cDLL, STRL, RWNL, DQSZL, DQSL, DQZL, WWNL,
		STRXL, RWNXL, DQSZXL, DQSXL, DQZXL, WWNXL, WIDL);

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
		constant mark  : tmrk_ids;
		constant param : tmng_ids) 
		return time;

	function xdr_latency (
		constant std   : natural;
		constant param : laty_ids;
		constant unit  : natural := 1)
		return integer;

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

	impure function xdr_lattab (
		constant std : natural;
		constant reg : latr_ids;
		constant phs : natural := 1)
		return natural_vector;

	impure function xdr_lattab (
		constant std : natural;
		constant tabid : cltabs_ids;
		constant phs : natural := 1)
		return natural_vector;

	impure function xdr_lattab (
		constant std : natural;
		constant tabid : cwltabs_ids;
		constant phs : natural := 1)
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
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
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
		value : integer;
	end record;

	type latency_tab is array (positive range <>) of latency_record;

	constant latency_db : latency_tab  := 
		latency_record'(std => 1, param => cDLL, value =>  200) &
		latency_record'(std => 1, param => STRL, value =>  4*0) &
		latency_record'(std => 1, param => RWNL, value =>  4*0) &
		latency_record'(std => 1, param => DQSZL, value => 4*2) &
		latency_record'(std => 1, param => DQSL, value =>    2) &
		latency_record'(std => 1, param => DQZL, value =>    1) &
		latency_record'(std => 1, param => WWNL, value =>    1) &
		latency_record'(std => 1, param => STRXL, value =>   2) &
		latency_record'(std => 1, param => RWNXL, value => 4*0) &
		latency_record'(std => 1, param => DQSZXL, value =>  2) &
		latency_record'(std => 1, param => DQSXL, value =>   2) &
		latency_record'(std => 1, param => DQZXL, value =>   1) &
		latency_record'(std => 1, param => WWNXL, value =>   1) &
		latency_record'(std => 1, param => WIDL,  value =>   4) &

		latency_record'(std => 2, param => cDLL, value =>  200) &
		latency_record'(std => 2, param => STRL,  value =>  -3) &
		latency_record'(std => 2, param => RWNL,  value =>   8) &
		latency_record'(std => 2, param => DQSZL, value =>  -8) &
		latency_record'(std => 2, param => DQSL,  value =>  -2) &
		latency_record'(std => 2, param => DQZL,  value =>  -7) &
		latency_record'(std => 2, param => WWNL,  value =>  -3) &
		latency_record'(std => 2, param => STRXL, value =>   4) &
		latency_record'(std => 2, param => RWNXL, value =>   4) &
		latency_record'(std => 2, param => DQSZXL, value =>  8) &
		latency_record'(std => 2, param => DQSXL, value =>   4) &
		latency_record'(std => 2, param => DQZXL, value =>   4) &
		latency_record'(std => 2, param => WWNXL, value =>   4) &
		latency_record'(std => 2, param => WIDL,  value =>   8) &

		latency_record'(std => 3, param => cDLL, value =>  500) &
		latency_record'(std => 3, param => STRL,  value => 4*0) &
		latency_record'(std => 3, param => RWNL,  value => 4*2) &
		latency_record'(std => 3, param => DQSZL, value =>  -2) &
		latency_record'(std => 3, param => DQSL,  value =>   0) &
		latency_record'(std => 3, param => DQZL,  value =>   1) &
		latency_record'(std => 3, param => WWNL,  value =>  -3) &
		latency_record'(std => 3, param => STRXL, value =>   2) &
		latency_record'(std => 3, param => RWNXL, value => 4*0) &
		latency_record'(std => 3, param => DQSZXL, value => 4*2) &
		latency_record'(std => 3, param => DQSXL, value =>   2) &
		latency_record'(std => 3, param => DQZXL, value =>   1) &
		latency_record'(std => 3, param => WWNXL, value =>   1) &
		latency_record'(std => 3, param => WIDL,  value =>   8);

	type timing_record is record
		mark  : tmrk_ids;
		param : tmng_ids;
		value : time;
	end record;

	type timing_tab is array (positive range <>) of timing_record;

	constant timing_db : timing_tab := 
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

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 2, reg => CL,  lat =>  4*3, code => "011") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  4*4, code => "100") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  4*5, code => "101") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  4*6, code => "110") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  4*7, code => "111") &

		-- BL register --

		cnfglat_record'(std => 2, reg => BL,  lat =>  4, code => "010") &
		cnfglat_record'(std => 2, reg => BL,  lat =>  8, code => "011") &

		-- CWL register --

		cnfglat_record'(std => 2, reg => WRL, lat =>  4*2, code => "001") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*3, code => "010") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*4, code => "011") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*5, code => "100") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*6, code => "101") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*7, code => "110") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4*8, code => "111") &

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 3, reg => CL, lat =>  4*5, code => "001") &
		cnfglat_record'(std => 3, reg => CL, lat =>  4*6, code => "010") &
		cnfglat_record'(std => 3, reg => CL, lat =>  4*7, code => "011") &
		cnfglat_record'(std => 3, reg => CL, lat =>  4*8, code => "100") &
		cnfglat_record'(std => 3, reg => CL, lat =>  4*9, code => "101") &
		cnfglat_record'(std => 3, reg => CL, lat => 4*10, code => "110") &
		cnfglat_record'(std => 3, reg => CL, lat => 4*11, code => "111") &

		-- BL register --

		cnfglat_record'(std => 3, reg => BL, lat =>  4, code => "000") &
		cnfglat_record'(std => 3, reg => BL, lat =>  8, code => "001") &
		cnfglat_record'(std => 3, reg => BL, lat => 16, code => "010") &

		-- WRL register --

		cnfglat_record'(std => 3, reg => WRL, lat =>  4*5, code => "001") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  4*6, code => "010") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  4*7, code => "011") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  4*8, code => "100") &
		cnfglat_record'(std => 3, reg => WRL, lat => 4*10, code => "101") &
		cnfglat_record'(std => 3, reg => WRL, lat => 4*12, code => "110") &

		-- CWL register --

		cnfglat_record'(std => 3, reg => CWL, lat =>  4*5, code => "000") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  4*6, code => "001") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  4*7, code => "010") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  4*8, code => "011");

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
		constant std   : natural;
		constant param : laty_ids; 
		constant unit : natural := 1) 
		return integer is
	begin
		for i in latency_db'range loop
			if latency_db(i).std = std then
				if latency_db(i).param = param then
					return latency_db(i).value/unit;
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

	impure function xdr_lattab (
		constant std : natural;
		constant reg : latr_ids;
		constant phs : natural := 1)
		return natural_vector is
		constant query_size : natural := xdr_query_size(std, reg);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(std, reg);
		variable lattab : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := (query_data(i).lat*phs)/4;
		end loop;
		return lattab;
	end;

	impure function xdr_lattab (
		constant std : natural;
		constant tabid : cltabs_ids;
		constant phs : natural := 1)
		return natural_vector is
		type latid_vector is array (cltabs_ids) of laty_ids;
		constant tab2laty : latid_vector := 
			(STRT => STRL, RWNT => RWNL);
		constant tab : natural_vector := xdr_lattab(std, CL, phs);
		constant lat : integer := xdr_latency(std, tab2laty(tabid));
		variable val : natural_vector(tab'range);
		variable msg : line;
	begin
		write (msg, string'("lat : "));
		write (msg, lat);
		for i in tab'range loop
			write (msg, string'(", tab : "));
			write (msg, tab(i));
			val(i) := tab(i)+lat;
		end loop;
		writeline(output, msg);
		return val;
	end;

	impure function xdr_lattab (
		constant std : natural;
		constant tabid : cwltabs_ids;
		constant phs : natural := 1)
		return natural_vector is
		type latid_vector is array (cwltabs_ids) of laty_ids;
		constant tab2laty : latid_vector := (WWNT => WWNL, DQSZT => DQSZL, DQST => DQSL, DQZT => DQZL);
		constant tab : natural_vector := xdr_lattab(std, CWL, phs);
		constant lat : integer := xdr_latency(std, tab2laty(tabid), 1);
		variable val : natural_vector(tab'range);
		variable msg : line;
	begin
		write (msg, string'("lat : "));
		write (msg, lat);
		for i in tab'range loop
			write (msg, string'(", tab : "));
			write (msg, tab(i));
		writeline(output, msg);
			val(i) := tab(i)+lat;
		end loop;
		return val;
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
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
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
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length-1 loop
				if lat_val = lat_cod(i) then
					for j in word'range loop
						val(j) := lat_sch(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;
		constant lat_cod1 : latword_vector := to_latwordvector(lat_cod);
		variable sel_sch : word_vector(lat_cod1'range);
	begin
		sel_sch := (others => (others => '-'));
		setup_l : for i in 0 to lat_tab'length-1 loop
			disp := lat_tab(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  /  word'length;
			for j in word'range loop
				aux := '0';
				for l in 0 to ((lat_ext+lat_wid-1)/lat_wid+word'length-1-j)/word'length loop
					pha := (j+disp_mod+(l*word'length+(lat_ext+lat_wid-1)/lat_wid))/word_byte;
					aux := aux or lat_sch(disp_quo*word'length+pha);
				end loop;
				sel_sch(i)((disp+j) mod word'length) := aux;
			end loop;
		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

end package body;
