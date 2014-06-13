library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package xdr_param is
	component xdr_cfg is
		generic (
			lat_size : natural := 5;
			trp  : natural := 10;
			tmrd : natural := 11;
		    trfc : natural := 13;
		    tmod : natural := 13;

			a    : natural := 13;
			ba   : natural := 2);
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

	function casdb (
		constant cl  : real;
		constant std : positive range 1 to 3)
		return std_logic_vector;

	function bldb (
		constant bl  : natural;
		constant std : positive)
		return std_logic_vector;

	function wrdb (
		constant wr  : natural;
		constant std : positive)
		return std_logic_vector;

	function cwldb (
		constant cwl : natural;
		constant std : positive)
		return std_logic_vector;

end package;

package body xdr_param is

	type lat_reg is (CL, BL, WR, CWL);
	type lat_record is record
		std   : positive;
		reg   : lat_reg;
		lat   : positive;
		code  : std_logic_vector(0 to 2);
	end record;

	type lattab is array (natural range <>) of lat_record;

	constant casdb : lattab := (
		std => 1, lat_reg => CL, lat =>  4, code => "010",
		std => 1, lat_reg => CL, lat =>  5, code => "110",
		std => 1, lat_reg => CL, lat =>  6, code => "011",

		std => 2, lat_reg => CL, lat =>  3, code => "011",
		std => 2, lat_reg => CL, lat =>  4, code => "100",
		std => 2, lat_reg => CL, lat =>  5, code => "101",
		std => 2, lat_reg => CL, lat =>  6, code => "110",
		std => 2, lat_reg => CL, lat =>  7, code => "111",

		std => 3, lat_reg => CL, lat =>  5, code => "001",
		std => 3, lat_reg => CL, lat =>  6, code => "010",
		std => 3, lat_reg => CL, lat =>  7, code => "011",
		std => 3, lat_reg => CL, lat =>  8, code => "100",
		std => 3, lat_reg => CL, lat =>  9, code => "101",
		std => 3, lat_reg => CL, lat => 10, code => "110",
		std => 3, lat_reg => CL, lat => 11, code => "111");

	--
	-- DDR1 CL must be multiplied by 2 before calling casdb
	--

	function lkup_lat (
		constant std : positive;
		constant reg : lat_reg;
		constant lat : positive);
		return std_logic_vector is
	begin
		for i in castab'range loop
			if castab(i).std = std then
				if castab(i).reg = reg then
					if castab(i).lat = lat then
						return castab(i).code;
					end if;
				end if;
			end if;
		end loop;

		report "Invalid DDR CL"
		severity FAILURE;
	end;

	function bldb (
		constant bl  : natural;
		constant std : natural)
		return std_logic_vector is
		type bltab is array (natural range <>) of std_logic_vector(0 to 2);

		constant bl1db : bltab(0 to 2) := ("001", "010", "011");
		constant bl2db : bltab(2 to 3) := ("010", "011");
		constant bl3db : bltab(0 to 2) := ("000", "001", "010");
	begin
		case std is
		when 1 =>
			for i in bl1db'range loop
				if bl=2**(i+1) then
					return bl1db(i);
				end if;
			end loop;

		when 2 =>
			for i in bl2db'range loop
				if bl=2**i then
					return bl2db(i);
				end if;
			end loop;

		when 3 =>
			for i in bl3db'range loop
				if bl=2**(i+1) then
					return bl3db(i);
				end if;
			end loop;

		when others =>
			report "Invalid DDR version"
			severity FAILURE;

			return (0 to 2 => '-');
		end case;

		report "Invalid Burst Length"
		severity FAILURE;
		return (0 to 2 => '-');
	end;

	function wrdb (
		constant wr  : natural;
		constant std : positive range 2 to 3)
		return std_logic_vector is
		type wrtab is array (natural range <>) of std_logic_vector(0 to 2);

		constant wr2db  : wrtab(0 to 7-1) := ("001", "010", "011", "100", "101", "110", "111");
		constant wr2idx : hdl4fpga.std.natural_vector(wr2db'range) := (2, 3, 4, 5, 6, 7, 8);

		constant wr3db  : wrtab(0 to 6-1) := ("001", "010", "011", "100", "101", "110");
		constant wr3idx : hdl4fpga.std.natural_vector(wr3db'range) := (5, 6, 7, 8, 10, 12);

	begin
		case std is
		when 2 =>
			for i in wr2db'range loop
				if wr = wr2idx(i) then
					return wr2db(i);
				end if;
			end loop;

			report "Invalid DDR2 Write Recovery"
			severity FAILURE;

		when 3 =>
			for i in wr3db'range loop
				if wr = wr3idx(i) then
					return wr3db(i);
				end if;
			end loop;

			report "Invalid DDR3 Write Recovery"
			severity FAILURE;
		end case;

		return (0 to 2 => '-');
	end;

	function cwldb (
		constant cwl : natural;
		constant std : positive range 1 to 3)
		return std_logic_vector is
		type cwltab is array (natural range <>) of std_logic_vector(0 to 2);

		constant cwl3db  : cwltab(0 to 4-1) := ("000", "001", "010", "011");
		constant cwl3idx : hdl4fpga.std.natural_vector(cwl3db'range) := (5, 6, 7, 8);

	begin
		case std is
		when 3 =>
			for i in cwl3db'range loop
				if cwl = cwl3idx(i) then
					return cwl3db(i);
				end if;
			end loop;

			report "Invalid CAS Write Latency"
			severity FAILURE;
			return (0 to 2 => '-');

		when others =>
			report "Invalid DDR version"
			severity WARNING;

			return (0 to 2 => '-');
		end case;
	end;

end package;
