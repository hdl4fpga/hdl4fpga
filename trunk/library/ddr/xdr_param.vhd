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
	type tmng_ids is (tWR, tRP, tRCD, tRFC, tMRD, tREFI);
	type latr_ids is (CL, BL, WRL, CWL);
	type cfgt_ids is (cPreRST, cPstRST);

	function lkup_lat (
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

		cPreRST => natural(t200u/tCP),
--		c200u => natural(2000.0/tCP),
		cDLL  => hdl4fpga.std.assign_if(std=3, 512, 220),
		cPstRST => natural(hdl4fpga.std.assign_if(std=2,t400n,t500u)/tCP),
--		c500u => natural(3000.0),
		cxpr  => natural(txpr/tCP),
		cREF  => natural(floor(tREFI/tCP)),
		std   => std)

	type cnftmng_record is record
		std   : positive;
		param : cfgt_ids;
		value : time;
	end record;

	type cnftmng_tab is array (natural range <>) of cnftmng_record;

	constant cnftmng_db : cnftmng_tab := 
		cnftmng_record'(
	type timing_record is record
		mark  : mark_ids;
		std   : positive;
		param : tmng_ids;
		value : time;
	end record;

	type timing_tab is array (natural range <>) of timing_record;

	constant timing_db : timing_tab(0 to 6-1) := 
		timing_record'(mark => M6T, std => 1, param => tWR,   value => 15 ns) &
		timing_record'(mark => M6T, std => 1, param => tRP,   value => 15 ns) &
		timing_record'(mark => M6T, std => 1, param => tRCD,  value => 15 ns) &
		timing_record'(mark => M6T, std => 1, param => tRFC,  value => 72 ns) &
		timing_record'(mark => M6T, std => 1, param => tMRD,  value => 12 ns) &
		timing_record'(mark => M6T, std => 1, param => tREFI, value =>  7 us);

	type latency_record is record
		std  : positive;
		reg  : latr_ids;
		lat  : positive;
		code : std_logic_vector(0 to 2);
	end record;

	type latency_tab is array (natural range <>) of latency_record;

	constant latency_db : latency_tab(0 to 40-1) :=

		-- DDR1 standard --
		-------------------

		-- CL register --

		latency_record'(std => 1, reg => CL,  lat =>  4, code => "010") &
		latency_record'(std => 1, reg => CL,  lat =>  5, code => "110") &
		latency_record'(std => 1, reg => CL,  lat =>  6, code => "011") &

		-- BL register --

		latency_record'(std => 1, reg => BL,  lat =>  2, code => "001") &
		latency_record'(std => 1, reg => BL,  lat =>  4, code => "010") &
		latency_record'(std => 1, reg => BL,  lat =>  8, code => "011") &

		-- DDR2 standard --
		-------------------

		-- CL register --

		latency_record'(std => 2, reg => CL,  lat =>  3, code => "011") &
		latency_record'(std => 2, reg => CL,  lat =>  4, code => "100") &
		latency_record'(std => 2, reg => CL,  lat =>  5, code => "101") &
		latency_record'(std => 2, reg => CL,  lat =>  6, code => "110") &
		latency_record'(std => 2, reg => CL,  lat =>  7, code => "111") &

		-- BL register --

		latency_record'(std => 2, reg => BL,  lat =>  4, code => "010") &
		latency_record'(std => 2, reg => BL,  lat =>  8, code => "011") &

		-- WRL register --

		latency_record'(std => 2, reg => WRL, lat =>  2, code => "001") &
		latency_record'(std => 2, reg => WRL, lat =>  3, code => "010") &
		latency_record'(std => 2, reg => WRL, lat =>  4, code => "011") &
		latency_record'(std => 2, reg => WRL, lat =>  5, code => "100") &
		latency_record'(std => 2, reg => WRL, lat =>  6, code => "101") &
		latency_record'(std => 2, reg => WRL, lat =>  7, code => "110") &
		latency_record'(std => 2, reg => WRL, lat =>  8, code => "111") &

		-- DDR3 standard --
		-------------------

		-- CL register --

		latency_record'(std => 3, reg => CL,  lat =>  5, code => "001") &
		latency_record'(std => 3, reg => CL,  lat =>  6, code => "010") &
		latency_record'(std => 3, reg => CL,  lat =>  7, code => "011") &
		latency_record'(std => 3, reg => CL,  lat =>  8, code => "100") &
		latency_record'(std => 3, reg => CL,  lat =>  9, code => "101") &
		latency_record'(std => 3, reg => CL,  lat => 10, code => "110") &
		latency_record'(std => 3, reg => CL,  lat => 11, code => "111") &

		-- BL register --

		latency_record'(std => 3, reg => BL,  lat =>  4, code => "000") &
		latency_record'(std => 3, reg => BL,  lat =>  8, code => "001") &
		latency_record'(std => 3, reg => BL,  lat => 16, code => "010") &

		-- WRL register --

		latency_record'(std => 3, reg => WRL, lat =>  5, code => "001") &
		latency_record'(std => 3, reg => WRL, lat =>  6, code => "010") &
		latency_record'(std => 3, reg => WRL, lat =>  7, code => "011") &
		latency_record'(std => 3, reg => WRL, lat =>  8, code => "100") &
		latency_record'(std => 3, reg => WRL, lat => 10, code => "101") &
		latency_record'(std => 3, reg => WRL, lat => 12, code => "110") &

		-- CWL register --

		latency_record'(std => 3, reg => CWL, lat =>  5, code => "000") &
		latency_record'(std => 3, reg => CWL, lat =>  6, code => "001") &
		latency_record'(std => 3, reg => CWL, lat =>  7, code => "010") &
		latency_record'(std => 3, reg => CWL, lat =>  8, code => "011");

	function lkup_lat (
		constant std : positive;
		constant reg : latr_ids;
		constant lat : positive)	-- DDR1 CL must be multiplied by 2 before looking up
		return std_logic_vector is
	begin
		for i in latency_db'range loop
			if latency_db(i).std = std then
				if latency_db(i).reg = reg then
					if latency_db(i).lat = lat then
						return latency_db(i).code;
					end if;
				end if;
			end if;
		end loop;

		report "Invalid DDR Latency"
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

		report "Invalid DDR Latency"
		severity FAILURE;
		return 0 ns;
	end;

end package body;
