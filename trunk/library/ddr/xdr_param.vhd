use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

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

	impure function xdr_cnfglat (
		constant stdr : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking it up
		return std_logic_vector;

	impure function xdr_timing (
		constant mark  : tmrk_ids;
		constant param : tmng_ids) 
		return natural;

	impure function xdr_latency (
		constant stdr   : natural;
		constant param : laty_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000;
		constant roundon : boolean := false)
		return integer;

	function xdr_query_size (
		constant stdr : natural;
		constant reg : latr_ids)
		return natural;

	function xdr_query_data (
		constant stdr : natural;
		constant reg : latr_ids)
		return cnfglat_tab;

	impure function xdr_stdr (
		mark : tmrk_ids) 
		return natural;

	impure function to_xdrlatency (
		period : natural;
		timing : natural)
		return natural;

	impure function to_xdrlatency (
		constant period : natural;
		constant mark   : tmrk_ids;
		constant param  : tmng_ids)
		return natural;

	impure function xdr_lattab (
		constant stdr : natural;
		constant reg : latr_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector;

	impure function xdr_lattab (
		constant stdr : natural;
		constant tabid : cltabs_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector;

	impure function xdr_lattab (
		constant stdr : natural;
		constant tabid : cwltabs_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector;

	function xdr_latcod (
		constant stdr : natural;
		constant reg : latr_ids)
		return std_logic_vector;

	impure function xdr_rotval (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector;

	impure function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector;

	impure function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural_vector;
		constant lat_wid : natural := 1)
		return std_logic_vector;

	function xdr_selcwl (
		constant stdr : natural)
		return latr_ids;

	function xdr_combclks (
		constant iclks : std_logic_vector;
		constant iclks_phases : natural;
		constant oclks_phases : natural)
		return std_logic_vector;

	type field_desc is record
		dbase : natural;
		sbase : natural;
		size  : natural;
	end record;

	type fielddesc_vector is array (natural range <>) of field_desc;

	type ddr3_ccmd is record
		cmd  : std_logic_vector( 3 downto 0);
		bank : std_logic_vector( 2 downto 0);
		addr : natural_vector(13 downto 0);
	end record;

	type ddr3_mrID is (mr0, mr1, mr2, mr3);

	type ddr3_mr is record
		tab : natural_vector(13 downto 0);
	end record;

	type ddr3mr_vector is array (natural range <>) of ddr3_mr;

	type ddr3_cmd is record
		id : std_logic_vector(3 downto 0);
	end record;

	type TMR_IDs is (TMR_RST, TMR_RRDY, TMR_CKE, TMR_MRD, TMR_MOD, TMR_DLL, TMR_ZQINIT, TMR_REF);
	type DDR_CCNAME is (DDR_CNOP, DDR_CZQC, DDR_CLMR, DDR_CRST, DDR_CRRDY);
	type timer_vector is array (TMR_IDs) of natural;

	type ddr3ccmd_vector is array(DDR_CCNAME) of ddr3_cmd;
	constant ddr3_cnop  : ddr3_cmd := (id => "0111");
	constant ddr3_czqc  : ddr3_cmd := (id => "0110");
	constant ddr3_clmr  : ddr3_cmd := (id => "0000");

	function mov (
		constant desc : field_desc)
		return natural_vector;

	function mov (
		constant desc : fielddesc_vector)
		return natural_vector;

	function set (
		constant desc : ddr3_cmd)
		return natural_vector;

	function set (
		constant desc : field_desc)
		return natural_vector;

	function set (
		constant desc : fielddesc_vector)
		return natural_vector;

	function clr (
		constant desc : field_desc)
		return natural_vector;

	function clr (
		constant desc : fielddesc_vector)
		return natural_vector;

	function "or" (
		constant arg1 : ddr3_mr;
		constant arg2 : natural_vector) 
		return ddr3_mr;

	function "or" (
		constant arg1 : natural_vector;
		constant arg2 : natural_vector) 
		return ddr3_mr;

	function "+" (
		constant cmd : ddr3_cmd;
		constant mr  : ddr3_mrID)
		return ddr3_ccmd;

	function ddr_ccmd (
		constant cmd : ddr3_cmd)
		return ddr3_ccmd;

	function "+" (
		constant cmd : ddr3_cmd;
		constant dat : std_logic_vector) 
		return ddr3_ccmd;

end package;

library hdl4fpga;
use hdl4fpga.std.all;

package body xdr_param is

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

	type latency_tab is array (positive range <>) of latency_record;

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
		latency_record'(stdr => 3, param => DQSZL, value =>  -8) &
		latency_record'(stdr => 3, param => DQZL,  value =>  -4) &
		latency_record'(stdr => 3, param => WWNL,  value =>  0) &
		latency_record'(stdr => 3, param => STRXL, value =>   2) &
		latency_record'(stdr => 3, param => RWNXL, value => 4*0) &
		latency_record'(stdr => 3, param => DQSXL, value =>   2) &
		latency_record'(stdr => 3, param => DQSZXL, value =>  6) &
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

	type timing_tab is array (positive range <>) of timing_record;

	constant timing_db : timing_tab := 
		timing_record'(mark => M6T,  param => tPreRST, value => 200000000) &
		timing_record'(mark => M6T,  param => tWR,   value => 15000) &
		timing_record'(mark => M6T,  param => tRP,   value => 15000) &
		timing_record'(mark => M6T,  param => tRCD,  value => 15000) &
		timing_record'(mark => M6T,  param => tRFC,  value => 72000) &
		timing_record'(mark => M6T,  param => tMRD,  value => 12000) &
		timing_record'(mark => M6T,  param => tREFI, value => 7000000) &
		timing_record'(mark => M15E, param => tREFI, value => 7000000) &
--		timing_record'(mark => M15E, param => tPreRST, value => 200000000) &
--		timing_record'(mark => M15E, param => tPstRST, value => 500000000) &
		timing_record'(mark => M15E, param => tPreRST, value => 2000000) &
		timing_record'(mark => M15E, param => tPstRST, value => 2000000) &
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

	impure function xdr_cnfglat (
		constant stdr : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking up
		return std_logic_vector is
		variable msg : line;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).reg = reg then
					if cnfglat_db(i).lat = lat then
						return cnfglat_db(i).code;
					end if;
				end if;
			end if;
		end loop;

		write (msg, string'("///////////////////" & CR));
		write (msg, string'("*** XDR_CNFGLAT ***" & CR));
		write (msg, string'("///////////////////" & CR));

		write (msg, string'("DDR" & CR));
		write (msg, stdr);
		write (msg, latr_ids'image(reg));
		write (msg, string'(" : "));
		write (msg, lat);
		write (msg, string'(CR & "//////////////////" & CR));
		writeline(output, msg);

		assert false
		severity FAILURE;
		return "XXX";
	end;

	impure function xdr_timing (
		constant mark  : tmrk_ids;
		constant param : tmng_ids) 
		return natural is
		variable msg : line;
	begin
		for i in timing_db'range loop
			if timing_db(i).mark = mark then
				if timing_db(i).param = param then
					return timing_db(i).value;
				end if;
			end if;
		end loop;

		write (msg, string'("//////////////////" & CR));
		write (msg, string'("*** XDR_TIMING ***" & CR));
		write (msg, string'("//////////////////" & CR));

		write (msg, tmrk_ids'image(mark));
		write (msg, string'(" : "));
		write (msg, tmng_ids'image(param));
		write (msg, string'(CR & "//////////////////" & CR));
		writeline(output, msg);

		assert false
		severity FAILURE;
		return 0;
	end;

	impure function xdr_latency (
		constant stdr   : natural;
		constant param : laty_ids; 
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000;
		constant roundon : boolean := false)
		return integer is
		variable msg : line;
	begin
		for i in latency_db'range loop
			if latency_db(i).stdr = stdr then
				if latency_db(i).param = param then
					if roundon then
						if (latency_db(i).value*tDDR) mod (4*tCP) = 0  then
							return (latency_db(i).value*tDDR)/(4*tCP);
						else
							return (latency_db(i).value*tDDR)/(4*tCP)+1;
						end if;
					else
						return (latency_db(i).value*tDDR)/(4*tCP);
					end if;
				end if;
			end if;
		end loop;

		write (msg, string'("///////////////////" & CR));
		write (msg, string'("*** XDR_LATENCY ***" & CR));
		write (msg, string'("///////////////////" & CR));

		write (msg, string'("DDR"));
		write (msg, stdr);
		write (msg, string'(":"));
		write (msg, laty_ids'image(param));
		write (msg, string'(CR & "//////////////////" & CR));
		writeline(output, msg);

		assert false
		severity FAILURE;
		return 0;
	end;

	impure function xdr_stdr (
		mark : tmrk_ids) 
		return natural is
		variable msg : line;
	begin
		for i in tmark_db'range loop
			if tmark_db(i).mark = mark then
				return tmark_db(i).stdr;
			end if;
		end loop;

		write (msg, string'("////////////////" & CR));
		write (msg, string'("*** XDR_STDR ***" & CR));
		write (msg, string'("////////////////" & CR));

		write (msg, string'("-> "));
		write (msg, tmrk_ids'image(mark));
		write (msg, string'(CR & "//////////////////" & CR));
		writeline(output, msg);

		assert false
		severity FAILURE;
		return 0;
	end;

	impure function to_xdrlatency (
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

	impure function to_xdrlatency (
		constant period : natural;
		constant mark   : tmrk_ids;
		constant param  : tmng_ids)
		return natural is
	begin
		return to_xdrlatency(period, xdr_timing(mark, param));
	end;

	function xdr_query_size (
		constant stdr : natural;
		constant reg : latr_ids)
		return natural is
		variable val : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).reg = reg then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function xdr_query_data (
		constant stdr : natural;
		constant reg : latr_ids)
		return cnfglat_tab is
		constant query_size : natural := xdr_query_size(stdr, reg);
		variable query_data : cnfglat_tab (1 to query_size);
		variable query_row  : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).reg = reg then
					query_row := query_row + 1;
					query_data(query_row) := cnfglat_db(i);
				end if;
			end if;
		end loop;
		return query_data;
	end;

	impure function xdr_lattab (
		constant stdr : natural;
		constant reg : latr_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is
		constant query_size : natural := xdr_query_size(stdr, reg);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(stdr, reg);
		variable lattab : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := (query_data(i).lat*tDDR)/(4*tCP);
		end loop;
		return lattab;
	end;

	impure function xdr_lattab (
		constant stdr : natural;
		constant tabid : cltabs_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is

		type latid_vector is array (cltabs_ids) of laty_ids;
		constant tab2laty : latid_vector := (STRT => STRL, RWNT => RWNL);

		constant lat : integer := xdr_latency(stdr, tab2laty(tabid));
		constant tab : natural_vector := xdr_lattab(stdr, CL, tDDR, 4*tDDR);
		variable val : natural_vector(tab'range);

	begin
		for i in tab'range loop
			val(i) := ((tab(i)+lat)*tDDR)/(4*tCP);
		end loop;
		return val;
	end;

	impure function xdr_lattab (
		constant stdr   : natural;
		constant tabid : cwltabs_ids;
		constant tCP  : natural :=  250;
		constant tDDR : natural := 1000)
		return natural_vector is

		type latid_vector is array (cwltabs_ids) of laty_ids;
		constant tab2laty : latid_vector := (WWNT => WWNL, DQSZT => DQSZL, DQST => DQSL, DQSZXT => DQSZXL, DQZT => DQZL, DQZXT => DQZXL);

		variable lat    : integer := xdr_latency(stdr, tab2laty(tabid));
		constant cltab  : natural_vector := xdr_lattab(stdr, CL);
		variable clval  : natural_vector(cltab'range);
		variable aux : natural;
		constant cwltab : natural_vector := xdr_lattab(stdr, CWL);
		variable cwlval : natural_vector(cwltab'range);
		variable latx   : integer := 0;

		variable mesg : line;
	begin
		if stdr = 2 then
			for i in cltab'range loop
				clval(i) := ((cltab(i)+lat-4)*tDDR)/(4*tCP);
			end loop;
			return clval;
		else
			case tabid is
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
		end if;
	end;

	function xdr_latcod (
		constant stdr : natural;
		constant reg : latr_ids)
		return std_logic_vector is
		constant query_size : natural := xdr_query_size(stdr, reg);
		constant query_data : cnfglat_tab(0 to query_size-1) := xdr_query_data(stdr, reg);
		variable latcode : std_logic_vector(0 to code_size*query_size-1);
	begin
		for i in query_data'reverse_range loop
			latcode := latcode srl code_size;
			latcode(code_t'range) := query_data(i).code;
		end loop;
		return latcode;
	end;

	impure function xdr_rotval (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return std_logic_vector is

		subtype word is std_logic_vector(unsigned_num_bits(line_size/word_size-1)-1 downto 0);
		type word_vector is array(natural range <>) of word;
		
		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		constant algn : natural := unsigned_num_bits(word_size-1);
		
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
		
		constant lc   : latword_vector := to_latwordvector(lat_cod);
		
		variable sel_sch : word_vector(lc'range);
		variable val : std_logic_vector(unsigned_num_bits(line_size-1)-1 downto 0) := (others => '0');
		variable disp : natural;
		variable msg : line;

	begin

		setup_l : for i in 0 to lat_tab'length-1 loop
	--        sel_sch(i) := to_unsigned((line_size/word_size-(lat_tab(i) mod (line_size/word_size)) mod (line_size/word_size)), word'length);
			sel_sch(i) := to_unsigned(lat_tab(i) mod (line_size/word_size), word'length);
	--		write (msg, sel_sch(i));
	--		write (msg, lat_tab(i));
	--		writeline (output, msg);
		end loop;
	--	report "termine"
	--	severity FAILURE;
		
		val(word'range) := select_lat(lat_val, lc, sel_sch);
		val := std_logic_vector'(unsigned(val) sll algn);
		return val;
	end;

	impure function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural_vector;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to data_phases*line_size/word_size-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

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
		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable pha : natural;
		variable aux : std_logic;

		variable j_quo : natural;
		variable j_mod : natural;
		variable l_quo : natural;
		variable l_mod : natural;
		variable msg : line;
	begin
		sel_sch := (others => (others => '-'));

--		for i in 0 to lat_tab'length-1 loop
--			write (msg, lat_ext(i));
--			writeline (output, msg);
--		end loop;
--		report "xdr_task"
--		severity failure;

		setup_l : for i in 0 to lat_tab'length-1 loop
			disp := lat_tab(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  /  word'length;
			for j in word'range loop
				aux := '0';
				j_quo := ((lat_ext(i)-j+word'length-1)/word'length+lat_wid-1)/lat_wid;
				j_mod := (lat_wid-(lat_ext(i)-j+word'length-1)/word'length) mod lat_wid;
				l_mod := 0;
				l_quo := 0;
				for l in 0 to j_quo loop

					pha   := (j+disp_mod)/word'length+l*lat_wid-l_quo;
					aux   := aux or lat_sch(disp_quo+pha);

					if j_quo /= 0 then
						l_quo := j_mod  /  j_quo;
						l_mod := j_mod mod j_quo;
						l_quo := l_quo + (l*l_mod) / j_quo;
						l_mod := (l*l_mod) mod j_quo;
					end if;
				end loop;
				sel_sch(i)((disp+j) mod word'length) := aux;
			end loop;
		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

	impure function xdr_task (
		constant data_phases : natural;
		constant data_edges : natural;
		constant line_size : natural;
		constant word_size : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to data_phases*line_size/word_size-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable pha : natural;
		variable aux : std_logic;

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
		constant i : natural := 2;
		variable j_quo : natural;
		variable j_mod : natural;
		variable l_quo : natural;
		variable l_mod : natural;
		variable msg : line;
	begin
		sel_sch := (others => (others => '-'));

--		write (msg, string'("LAT_WID -> "));
--		write (msg, LAT_WID);
--		write (msg, string'(" LAT_EXT -> "));
--		write (msg, LAT_EXT);
--		writeline (output, msg);

		setup_l : for i in 0 to lat_tab'length-1 loop
			disp := lat_tab(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  /  word'length;
			for j in word'range loop
				aux := '0';
				j_quo := ((lat_ext-j+word'length-1)/word'length+lat_wid-1)/lat_wid;
				j_mod := (lat_wid-(lat_ext-j+word'length-1)/word'length) mod lat_wid;
				l_mod := 0;
				l_quo := 0;
				for l in 0 to j_quo loop

					pha   := (j+disp_mod)/word'length+l*lat_wid-l_quo;
					aux   := aux or lat_sch(disp_quo+pha);

					if j_quo /= 0 then
						l_quo := j_mod  /  j_quo;
						l_mod := j_mod mod j_quo;
						l_quo := l_quo + (l*l_mod) / j_quo;
						l_mod := (l*l_mod) mod j_quo;
					end if;

--					write (msg, string'(" j_mod -> "));
--					write (msg, j_mod);
--					write (msg, string'(" j_quo -> "));
--					write (msg, j_quo);
--					write (msg, string'(" l_mod -> "));
--					write (msg, l_mod);
--					write (msg, string'(" l_quo -> "));
--					write (msg, l_quo);
--					write (msg, string'(" j -> "));
--					write (msg, j);
--					write (msg, string'(" l -> "));
--					write (msg, l);
--					write (msg, string'(" pha -> "));
--					write (msg, pha);
--					writeline (output, msg);

				end loop;
				sel_sch(i)((disp+j) mod word'length) := aux;
			end loop;

--			writeline (output, msg);

		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

	function xdr_selcwl (
		constant stdr : natural)
		return latr_ids is
	begin
		if stdr = 2 then
			return CL;
		else
			return CWL;
		end if;
	end;

	function xdr_combclks (
		constant iclks : std_logic_vector;
		constant iclks_phases : natural;
		constant oclks_phases : natural)
		return std_logic_vector is
		variable aux : std_logic_vector(0 to iclks'length-1) := iclks;
		variable val : std_logic_vector(0 to iclks'length/(iclks_phases/oclks_phases)-1);
	begin
		for i in val'range loop
			val(i) := aux(i*(iclks_phases/oclks_phases));
		end loop;
		return val;
	end;

	-- DDR init

	function mov (
		constant desc : field_desc)
		return natural_vector is
		variable tab : natural_vector(13 downto 0) := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			tab(desc.dbase+j) := desc.sbase+j;
		end loop;
		return tab;
	end function;

	function max (
		constant desc : fielddesc_vector)
		return natural is
		variable val : natural := 0;
	begin
		for i in desc'range loop
			if desc(i).dbase > val then
				val := desc(i).dbase;
			end if;
		end loop;
		return val;
	end;

	function min (
		constant desc : fielddesc_vector)
		return natural is
		variable val : natural := 0;
	begin
		for i in desc'range loop
			if desc(i).dbase < val then
				val := desc(i).dbase;
			end if;
		end loop;
		return val;
	end;

	function mov (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
		variable aux : natural_vector(val'range) := (others => 0);
	begin
		for i in desc'range loop
			aux := mov(desc(i));
			for j in aux'range loop
				if aux(i) /= 0 then
					val(j) := aux(j);
				end if;
			end loop;
		end loop;
		return val;
	end function;

	function set (
		constant desc : ddr3_cmd)
		return natural_vector is
		variable val : natural_vector(desc.id'range) := (others => 0);
		variable aux : std_logic_vector(desc.id'range);
	begin
		aux := desc.id;
		for i in aux'range loop
			if aux(i) = '0' then
				val(i) := 1;
			elsif aux(i) = '1' then
				val(i) := 2;
			end if;
		end loop;
		return val;
	end;

	function set (
		constant desc : field_desc)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			val(desc.dbase+j) := 2;
		end loop;
		return val;
	end;

	function set (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
		variable aux : natural_vector(val'range) := (others => 0);
	begin
		for i in desc'range loop
			aux := set(desc(i));
			for j in aux'range loop
				if aux(i) /= 0 then
					val(j) := aux(j);
				end if;
			end loop;
		end loop;
		return val;
	end;

	function clr (
		constant desc : field_desc)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			val(desc.dbase+j) := 1;
		end loop;
		return val;
	end;

	function clr (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : natural_vector(13 downto 0) := (others => 0);
		variable aux : natural_vector(val'range) := (others => 0);
	begin
		for i in desc'range loop
			aux := clr(desc(i));
			for j in aux'range loop
				if aux(i) /= 0 then
					val(j) := aux(j);
				end if;
			end loop;
		end loop;
		return val;
	end;

	function "or" (
		constant arg1 : ddr3_mr;
		constant arg2 : natural_vector) 
		return ddr3_mr is
		variable val : ddr3_mr;
	begin
		val := arg1;
		for i in arg2'range loop
			if arg2(i) /= 0 then
				val.tab(i) := arg2(i);
			end if;
		end loop;
		return val;
	end;

	function "or" (
		constant arg1 : natural_vector;
		constant arg2 : natural_vector) 
		return ddr3_mr is
		variable val : ddr3_mr;
	begin
		val.tab := (val.tab'range => 0);
		val := val or arg1;
		val := val or arg2;
		return val;
	end;

	function "+" (
		constant cmd : ddr3_cmd;
		constant mr  : ddr3_mrID) 
		return ddr3_ccmd is
		variable val : ddr3_ccmd;
	begin
		val.cmd  := std_logic_vector(resize(unsigned(cmd.id), cmd.id'length));
		val.bank := std_logic_vector(unsigned'(to_unsigned(ddr3_mrID'pos(mr), val.bank'length)));
		val.addr := (val.addr'range => 0);
		return val;
	end;

	function ddr_ccmd (
		constant cmd : ddr3_cmd)
		return ddr3_ccmd is
	begin
		return (cmd => cmd.id, addr => (others => 0), bank => (others => '-'));
	end;

	function "+" (
		constant cmd : ddr3_cmd;
		constant dat : std_logic_vector) 
		return ddr3_ccmd is
		variable val : ddr3_ccmd;
	begin
		val.addr := (val.addr'range => 0);
		val.cmd  := std_logic_vector(resize(unsigned(cmd.id), cmd.id'length));
		val.bank := (others => '1');
		for i in dat'range loop
			if val.addr'low <= i and i <= val.addr'high then
				val.addr(i) := 1;
				if dat(i) = '1' then
					val.addr(i) := 2;
				end if;
			end if;
		end loop;
		return val;
	end;

end package body;
