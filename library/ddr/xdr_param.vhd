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

	type lat_reg is (CL, BL, WRL, CWL);

	function lookup_lat (
		constant std : positive;
		constant reg : lat_reg;
		constant lat : positive);	-- DDR1 CL must be multiplied by 2 before looking up
		return std_logic_vector;

end package;

package body xdr_param is

	type lat_record is record
		std   : positive;
		reg   : lat_reg;
		lat   : positive;
		code  : std_logic_vector(0 to 2);
	end record;

	type lattab is array (natural range <>) of lat_record;

	constant casdb : lattab := (

		-- DDR1 standard --
		-------------------

		-- CL register --

		std => 1, lat_reg => CL,  lat =>  4, code => "010",
		std => 1, lat_reg => CL,  lat =>  5, code => "110",
		std => 1, lat_reg => CL,  lat =>  6, code => "011",

		-- BL register --

		std => 1, lat_reg => BL,  lat =>  2, code => "001",
		std => 1, lat_reg => BL,  lat =>  4, code => "010",
		std => 1, lat_reg => BL,  lat =>  8, code => "011",

		-- DDR2 standard --
		-------------------

		-- CL register --

		std => 2, lat_reg => CL,  lat =>  3, code => "011",
		std => 2, lat_reg => CL,  lat =>  4, code => "100",
		std => 2, lat_reg => CL,  lat =>  5, code => "101",
		std => 2, lat_reg => CL,  lat =>  6, code => "110",
		std => 2, lat_reg => CL,  lat =>  7, code => "111",

		-- BL register --

		std => 2, lat_reg => BL,  lat =>  4, code => "010",
		std => 2, lat_reg => BL,  lat =>  8, code => "011",

		-- WRL register --

		std => 2, lat_reg => WRL, lat =>  2, code => "001",
		std => 2, lat_reg => WRL, lat =>  3, code => "010",
		std => 2, lat_reg => WRL, lat =>  4, code => "011",
		std => 2, lat_reg => WRL, lat =>  5, code => "100",
		std => 2, lat_reg => WRL, lat =>  6, code => "101",
		std => 2, lat_reg => WRL, lat =>  7, code => "110",
		std => 2, lat_reg => WRL, lat =>  8, code => "111",

		-- DDR3 standard --
		-------------------

		-- CL register --

		std => 3, lat_reg => CL,  lat =>  5, code => "001",
		std => 3, lat_reg => CL,  lat =>  6, code => "010",
		std => 3, lat_reg => CL,  lat =>  7, code => "011",
		std => 3, lat_reg => CL,  lat =>  8, code => "100",
		std => 3, lat_reg => CL,  lat =>  9, code => "101",
		std => 3, lat_reg => CL,  lat => 10, code => "110",
		std => 3, lat_reg => CL,  lat => 11, code => "111",

		-- BL register --

		std => 3, lat_reg => BL,  lat =>  4, code => "000",
		std => 3, lat_reg => BL,  lat =>  8, code => "001",
		std => 3, lat_reg => BL,  lat => 16, code => "010",

		-- WRL register --

		std => 3, lat_reg => WRL, lat =>  5, code => "001",
		std => 3, lat_reg => WRL, lat =>  6, code => "010",
		std => 3, lat_reg => WRL, lat =>  7, code => "011",
		std => 3, lat_reg => WRL, lat =>  8, code => "100",
		std => 3, lat_reg => WRL, lat => 10, code => "101",
		std => 3, lat_reg => WRL, lat => 12, code => "110",

		-- CWL register --

		std => 3, lat_reg => CWL, lat =>  5, code => "000",
		std => 3, lat_reg => CWL, lat =>  6, code => "001",
		std => 3, lat_reg => CWL, lat =>  7, code => "010",
		std => 3, lat_reg => CWL, lat =>  8, code => "011");

	function lookup_lat (
		constant std : positive;
		constant reg : lat_reg;
		constant lat : positive);	-- DDR1 CL must be multiplied by 2 before looking up
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

		report "Invalid DDR Latency"
		severity FAILURE;
	end;

end package;
