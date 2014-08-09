use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_init is
	generic (
		lMRD : natural := 11;
		ADDR_SIZE : natural := 13;
		BANK_SIZE : natural := 3);
	port (
		xdr_init_ods : in  std_logic := '0';
		xdr_init_rtt : in  std_logic_vector(1 downto 0) := "01";
		xdr_init_bl  : in  std_logic_vector(0 to 2);
		xdr_init_cl  : in  std_logic_vector(0 to 2);
		xdr_init_wr  : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_init_cwl : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_init_pl  : in  std_logic_vector(0 to 2) := (others => '0');
		xdr_init_dqsn : in std_logic := '0';

		xdr_init_clk : in  std_logic;
		xdr_init_req : in  std_logic;
		xdr_init_rdy : out std_logic := '1';
		xdr_init_dll : out std_logic := '1';
		xdr_init_odt : out std_logic := '0';
		xdr_init_ras : out std_logic := '1';
		xdr_init_cas : out std_logic := '1';
		xdr_init_we  : out std_logic := '1';
		xdr_init_a   : out std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '1');
		xdr_init_b   : out std_logic_vector(BANK_SIZE-1 downto 0) := (others => '1'));

	constant cnop : std_logic_vector(0 to 2) := "111";
	constant clmr : std_logic_vector(0 to 2) := "000";
	constant cqcl : std_logic_vector(0 to 2) := "110";

	constant xdrinitods_size : natural := 1;
	constant cnfgreg_size : natural := 
		xdrinitods_size +
		xdr_init_pl'length +
		xdr_init_cwl'length +
		xdr_init_rtt'length +
		xdr_init_wr'length +
		xdr_init_bl'length +
		xdr_init_cl'length;

	type ccmds is (CFG_NOP, CFG_AUTO);

	type field_desc is record
		dbase : natural;
		sbase : natural;
		size  : natural;
	end record;

	type fielddesc_vector is array (natural range <>) of field_desc;

	type inst_param is record
		cmd  : std_logic_vector(0 to 2);
		mr   : std_logic_vector(xdr_init_b'range);
		desc : field_desc;
	end record;

	type issue is record
		setid : natural;
		param : inst_param;
	end record;

	type code is array (natural range <>) of issue;

	function mov (
		constant mr   : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  := clmr;
		param.mr   := mr;
		param.desc := desc;
		return param;
	end function;

	function set (
		constant mr : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  := clmr;
		param.mr   := mr;
		param.desc := desc;
		param.desc.sbase := 1*xdr_init_a'length+cnfgreg_size;
		return param;
	end;

	function clr (
		constant mr : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  := clmr;
		param.mr   := mr;
		param.desc := desc;
		param.desc.sbase := 0*xdr_init_a'length+cnfgreg_size;
		return param;
	end;

	constant lat_size : natural := signed_num_bits(lMRD-2);
	type ccmd_record is record 
		cmd : std_logic_vector(2 downto 0);
		lat : signed(0 to lat_size-1);
	end record;

	type ccmd_table is array (ccmds) of ccmd_record;
	constant ccmd_db : ccmd_table := (
		CFG_NOP  => (cnop, to_signed(lMRD-2, lat_size)),
		CFG_AUTO => (clmr, to_signed(lMRD-2, lat_size)));

	function lat_lookup (
		constant cmd : std_logic_vector)
		return signed is
	begin
		for i in ccmd_db'range loop
			if ccmd_db(i).cmd = cmd then
				return ccmd_db(i).lat;
			end if;
		end loop;
		return (1 to lat_size => '1');
	end;

	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_init : entity is "compact";

end;

architecture ddr3 of xdr_init is

	signal lat_timer : signed(0 to lat_size-1);

	constant allbits  : field_desc := (dbase =>  0, sbase => 0, size => xdr_init_a'length);

	-- DDR3 Mode Register 0 --
	--------------------------

	constant mr0 : std_logic_vector(2 downto 0) := "000";

	constant bl : field_desc := (dbase =>  0, sbase => 0, size => 3);
	constant bt : field_desc := (dbase =>  3, sbase => 0, size => 1);
	constant cl : field_desc := (dbase =>  4, sbase => 0, size => 3);
	constant tm : field_desc := (dbase =>  7, sbase => 0, size => 1);
	constant rdll : field_desc := (dbase =>  8, sbase => 0, size => 1);
	constant wr : field_desc := (dbase =>  9, sbase => 0, size => 3);
	constant pd : field_desc := (dbase => 12, sbase => 0, size => 1);

	-- DDR3 Mode Register 1 --
	--------------------------

	constant mr1 : std_logic_vector(2 downto 0) := "001";

	--constant dll  : field_desc := (dbase => 0, sbase => 0, size => 1);
	constant ods  : fielddesc_vector := (
		(dbase => 1, sbase => 0, size => 1),
	   	(dbase => 5, sbase => 0, size => 1));
	constant rt   : fielddesc_vector := (
		(dbase => 2, sbase => 0, size => 1),
		(dbase => 6, sbase => 0, size => 1),
		(dbase => 9, sbase => 0, size => 1));
	constant al   : field_desc := (dbase =>  3, sbase => 0, size => 2);
	constant edll : field_desc := (dbase =>  8, sbase => 0, size => 1);
--	constant wr   : field_desc := (dbase =>  7, sbase => 0, size => 7);
	constant dqs  : field_desc := (dbase => 10, sbase => 0, size => 1);
	constant tdqs : field_desc := (dbase => 11, sbase => 0, size => 1);
	constant qoff : field_desc := (dbase => 12, sbase => 0, size => 1);

	-- DDR3 Mode Register 2 --
	--------------------------

	constant mr2 : std_logic_vector(2 downto 0) := "011";

	constant cwl : field_desc := (dbase => 3, sbase => 0, size => 3);
	constant asr : field_desc := (dbase => 6, sbase => 0, size => 1);
	constant srt : field_desc := (dbase => 7, sbase => 0, size => 1);
	constant rtt : field_desc := (dbase => 9, sbase => 0, size => 2);

	-- DDR3 Mode Register 3 --
	--------------------------

	constant mr3 : std_logic_vector(2 downto 0) := "010";

	constant rf  : field_desc := (dbase => 0, sbase => 0, size => 2);

	type setIDs is (issmr0, issmr1);

	constant init_pgm : code := ( 
		(setIDs'POS(issmr0), mov(mr0, bl)),
		(setIDs'POS(issmr0), set(mr0, bt)),
		(setIDs'POS(issmr0), mov(mr0, cl)),
		(setIDs'POS(issmr0), clr(mr0, tm)),
		(setIDs'POS(issmr0), set(mr0, dll)),
		(setIDs'POS(issmr0), mov(mr0, wr)),
		(setIDs'POS(issmr0), mov(mr0, pd)),

		(setIDs'POS(issmr1), set(mr1, dqs)),
		(setIDs'POS(issmr1), set(mr1, al))
	);

	signal src : std_logic_vector(2*xdr_init_a'length+cnfgreg_size-1 downto 0);

	signal xdr_init_pc : signed(0 to 4);

	impure function compile_pgm(
		constant setid : signed)
		return std_logic_vector is
		variable val : std_logic_vector(xdr_init_a'length-1 downto 0);
		variable mr  : std_logic_vector(init_pgm(0).param.mr'range);
		variable cmd : std_logic_vector(init_pgm(0).param.cmd'range);
		variable msg : line;
	begin
		for i in init_pgm'range loop
			if to_signed(setIds'POS(setIds'high)-init_pgm(i).setid, xdr_init_pc'length) = setid then
				for j in 0 to init_pgm(i).param.desc.size-1 loop
					val(init_pgm(i).param.desc.dbase+j) := src(init_pgm(i).param.desc.sbase+j);
				end loop;
				 mr  := init_pgm(i).param.mr;
				 cmd := init_pgm(i).param.cmd;
			end if;
		end loop;
		return cmd & mr & val;
	end;

	subtype  dst_a   is natural range xdr_init_a'length-1 downto 0;
	subtype  dst_b   is natural range xdr_init_b'length+xdr_init_a'length-1 downto xdr_init_a'length;
	subtype  dst_cmd is natural range xdr_init_b'length+xdr_init_a'length+3-1 downto xdr_init_b'length+xdr_init_a'length;
	constant dst_ras : natural := xdr_init_b'length+xdr_init_a'length+2;
	constant dst_cas : natural := xdr_init_b'length+xdr_init_a'length+1;
	constant dst_we  : natural := xdr_init_b'length+xdr_init_a'length+0;

	signal dst : std_logic_vector(dst_ras downto 0);
begin

	src <=
		(xdr_init_a'range => '1') &
		(xdr_init_a'range => '0') &
		xdr_init_ods & 
		xdr_init_pl  & 
		xdr_init_cwl &
		xdr_init_rtt & 
		xdr_init_wr  & 
		xdr_init_bl  &
		xdr_init_cl;

	process (xdr_init_clk)
		variable aux : std_logic_vector(dst'range);
	begin
		if rising_edge(xdr_init_clk) then
			if xdr_init_req='1' then
				if lat_timer(0)='1' then
					if xdr_init_pc(0)='0' then
						aux := compile_pgm(xdr_init_pc);
						dst <= aux;
						lat_timer <= lat_lookup(aux(dst_cmd));
						xdr_init_pc <= xdr_init_pc - 1;
					else
						dst <= (others => '1');
						lat_timer <= (others => '1');
					end if;
				else
					dst <= (others => '1');
					lat_timer <= lat_timer-1;
				end if;
			else
				dst <= (others => '1');
				lat_timer <= (others => '1');
				xdr_init_pc <= to_signed(setIds'POS(setIds'high), xdr_init_pc'length);
			end if;
		end if;
	end process;

	xdr_init_a   <= dst(dst_a);
	xdr_init_b   <= dst(dst_b);
	xdr_init_ras <= dst(dst_ras);
	xdr_init_cas <= dst(dst_cas);
	xdr_init_we  <= dst(dst_we);

end;
