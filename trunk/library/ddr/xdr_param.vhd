library ieee;
use ieee.std_logic_1164.all;

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

	type mark_ids is (M6T, M107);
	type tmng_ids is (tPreRST, tPstRST, tXPR, tWR, tRP, tRCD, tRFC, tMRD, tREFI);
	type latr_ids is (CL, BL, WRL, CWL);
	type laty_ids is (cDLL);

	function lkup_cnfglat (
		constant std : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking it up
		return std_logic_vector;

	function lkup_tmng (
		mark  : mark_ids;
		param : tmng_ids) 
		return time;

end package;

library hdl4fpga;
use hdl4fpga.std.all;

package body xdr_param is

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
		mark  : mark_ids;
		std   : positive;
		param : tmng_ids;
		value : time;
	end record;

	type timing_tab is array (natural range <>) of timing_record;

	constant timing_db : timing_tab(1 to 10) := 
		timing_record'(mark => M6T,  std => 1, param => tPreRST, value => 200 us) &
		timing_record'(mark => M6T,  std => 1, param => tWR,   value => 15 ns) &
		timing_record'(mark => M6T,  std => 1, param => tRP,   value => 15 ns) &
		timing_record'(mark => M6T,  std => 1, param => tRCD,  value => 15 ns) &
		timing_record'(mark => M6T,  std => 1, param => tRFC,  value => 72 ns) &
		timing_record'(mark => M6T,  std => 1, param => tMRD,  value => 12 ns) &
		timing_record'(mark => M107, std => 3, param => tREFI, value =>  7 us) &
		timing_record'(mark => M107, std => 3, param => tPreRST, value => 200 us) &
		timing_record'(mark => M107, std => 3, param => tPstRST, value => 500 us) &
		timing_record'(mark => M6T,  std => 3, param => tREFI, value =>  7 us);

	type cnfglat_record is record
		std  : positive;
		reg  : latr_ids;
		lat  : positive;
		code : std_logic_vector(0 to 2);
	end record;

	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	constant cnfglat_db : cnfglat_tab(1 to 40) :=

		-- DDR1 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 1, reg => CL,  lat =>  4, code => "010") &
		cnfglat_record'(std => 1, reg => CL,  lat =>  5, code => "110") &
		cnfglat_record'(std => 1, reg => CL,  lat =>  6, code => "011") &

		-- BL register --

		cnfglat_record'(std => 1, reg => BL,  lat =>  2, code => "001") &
		cnfglat_record'(std => 1, reg => BL,  lat =>  4, code => "010") &
		cnfglat_record'(std => 1, reg => BL,  lat =>  8, code => "011") &

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 2, reg => CL,  lat =>  3, code => "011") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  4, code => "100") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  5, code => "101") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  6, code => "110") &
		cnfglat_record'(std => 2, reg => CL,  lat =>  7, code => "111") &

		-- BL register --

		cnfglat_record'(std => 2, reg => BL,  lat =>  4, code => "010") &
		cnfglat_record'(std => 2, reg => BL,  lat =>  8, code => "011") &

		-- WRL register --

		cnfglat_record'(std => 2, reg => WRL, lat =>  2, code => "001") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  3, code => "010") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  4, code => "011") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  5, code => "100") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  6, code => "101") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  7, code => "110") &
		cnfglat_record'(std => 2, reg => WRL, lat =>  8, code => "111") &

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(std => 3, reg => CL,  lat =>  5, code => "001") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  6, code => "010") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  7, code => "011") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  8, code => "100") &
		cnfglat_record'(std => 3, reg => CL,  lat =>  9, code => "101") &
		cnfglat_record'(std => 3, reg => CL,  lat => 10, code => "110") &
		cnfglat_record'(std => 3, reg => CL,  lat => 11, code => "111") &

		-- BL register --

		cnfglat_record'(std => 3, reg => BL,  lat =>  4, code => "000") &
		cnfglat_record'(std => 3, reg => BL,  lat =>  8, code => "001") &
		cnfglat_record'(std => 3, reg => BL,  lat => 16, code => "010") &

		-- WRL register --

		cnfglat_record'(std => 3, reg => WRL, lat =>  5, code => "001") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  6, code => "010") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  7, code => "011") &
		cnfglat_record'(std => 3, reg => WRL, lat =>  8, code => "100") &
		cnfglat_record'(std => 3, reg => WRL, lat => 10, code => "101") &
		cnfglat_record'(std => 3, reg => WRL, lat => 12, code => "110") &

		-- CWL register --

		cnfglat_record'(std => 3, reg => CWL, lat =>  5, code => "000") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  6, code => "001") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  7, code => "010") &
		cnfglat_record'(std => 3, reg => CWL, lat =>  8, code => "011");

	function lkup_cnfglat (
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

		report "Invalid DDR configuration latency"
		severity FAILURE;
		return "XXX";
	end;

	function lkup_tmng (
		mark  : mark_ids;
		param : tmng_ids) 
		return time is
	begin
		for i in timing_db'range loop
			if timing_db(i).mark = mark then
				if timing_db(i).param = param then
					return timing_db(i).value;
				end if;
			end if;
		end loop;

		report "Invalid DDR timing"
		severity FAILURE;
		return 0 ns;
	end;

	function lkup_lat (
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

		report "Invalid DDR latency"
		severity FAILURE;
		return 0;
	end;

end package body;
