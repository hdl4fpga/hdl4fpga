library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package xdr_param is
	component xdr_cfg is
		generic (
			lat_length : natural := 5;
			a    : natural := 13;
			trp  : natural := 10;
			tmrd : natural := 11;
		    trfc : natural := 13;
		    tmod : natural := 13;
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

end package;

package body xdr_param is

	function casdb (
		constant cl  : real;
		constant std : positive range 1 to 3)
		return std_logic_vector is

		type castab is array (natural range <>) of std_logic_vector(0 to 2);

		constant cas1db : castab(0 to 3-1)  := ("010", "110", "011");
		constant cas2db : castab(3 to 8-1)  := ("011", "100", "101", "110", "111");
		constant cas3db : castab(5 to 12-1) := ("001", "010", "011", "100", "101", "110", "111");

		constant frac : real := cl-floor(cl);
	begin

		case std is
		when 1 =>
			assert 2.0 <= cl and cl <= 3.0
			report "Invalid DDR1 cas latency"
			severity FAILURE;

			if cl = 2.0 then
				return cas1db(0);
			elsif cl = 2.5 then
				return cas1db(1);
			else
				return cas1db(2);
			end if;

		when 2 =>
			assert 3.0 <= cl and cl <= 7.0
			report "Invalid DDR2 cas latency"
			severity FAILURE;
			
			return cas2db(natural(floor(cl)));

		when 3 =>
			assert 5.0 <= cl and cl <= 11.0
			report "Invalid DDR3 cas latency"
			severity FAILURE;
			
			return cas3db(natural(floor(cl)));
		end case;
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
		xdr_init_du : entity hdl4fpga.xdr_init(ddr1)
			a    => addr_bits,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => natural(ceil(tMRD/tCp)),
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
			xdr_init_cl  => casdb (cl, std),
			xdr_init_bl  => bldb  (bl, std),

	ddr2_init_g : if std=2 generate
		xdr_init_du : entity hdl4fpga.xdr_init(ddr2)
		generic map (
			lat_length => 9,

			a => addr_bits,

			tRP  => natural(ceil(tRP/tCP)),
			tMRD => 2,
			tMOD => natural(ceil(12.0/tCP))+2,
			tRFC => natural(ceil(tRFC/tCP)))
		port map (
			xdr_init_cl  => casdb (cl, std),
			xdr_init_bl  => bldb  (bl, std),
			xdr_init_wr  => wrdb  (wr, std),

			xdr_init_clk => sys_clk,
			xdr_init_req => xdr_init_cfg,
			xdr_init_rdy => xdr_init_rdy,
			xdr_init_dll => xdr_init_dll,
			xdr_init_ras => xdr_init_ras,
			xdr_init_cas => xdr_init_cas,
			xdr_init_we  => xdr_init_we,
			xdr_init_a   => xdr_init_a,
			xdr_init_b   => xdr_init_b);
	end generate;

	ddr3_init_g : if std=3 generate
		signal ba3 : std_logic_vector(2 downto 0);
	begin
		xdr_init_b <= ba3(1 downto 0);
		xdr_init_du : entity hdl4fpga.xdr_init(ddr3)
		generic map (
			lat_length => 9,
			a    => addr_bits,
			ba   => 3,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => 4,
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
			xdr_init_cl  => casdb (cl,  std),
			xdr_init_bl  => bldb  (bl,  std),
			xdr_init_wr  => wrdb  (wr,  std),
			xdr_init_cwl => cwldb (cwl, std),

			xdr_init_clk => sys_clk,
			xdr_init_req => xdr_init_cfg,
			xdr_init_rdy => xdr_init_rdy,
			xdr_init_dll => xdr_init_dll,
			xdr_init_ras => xdr_init_ras,
			xdr_init_cas => xdr_init_cas,
			xdr_init_we  => xdr_init_we,
			xdr_init_a   => xdr_init_a,
			xdr_init_b   => ba3);
	end generate;

end package;
