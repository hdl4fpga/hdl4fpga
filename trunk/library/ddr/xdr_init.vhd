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

	constant xdrinitout_size : natural := 2;

	constant xdrinitods_size : natural := 1;
	constant cnfgreg_size : natural := 
		xdrinitods_size +
		xdr_init_pl'length +
		xdr_init_cwl'length +
		xdr_init_rtt'length +
		xdr_init_wr'length +
		xdr_init_bl'length +
		xdr_init_cl'length;

	subtype  dst_a   is natural range xdr_init_a'length-1 downto 0;
	subtype  dst_b   is natural range dst_a'high+xdr_init_b'length downto dst_a'high+1;
	subtype  dst_cmd is natural range dst_b'high+3 downto dst_b'high+1;
	constant dst_ras : natural := dst_b'high+3;
	constant dst_cas : natural := dst_b'high+2;
	constant dst_we  : natural := dst_b'high+1;
	subtype  dst_o   is natural range dst_ras+xdrinitout_size downto dst_ras+1;

	subtype src_word is std_logic_vector(2+cnfgreg_size downto 1);
	subtype dst_word is std_logic_vector(dst_a'high downto 0);
	subtype dst_wtab is natural_vector(dst_word'range);

	type ccmds is (CFG_NOP, CFG_AUTO);

	type field_desc is record
		dbase : natural;
		sbase : natural;
		size  : natural;
	end record;

	type cmd_desc is record
		cmd : std_logic_vector(dst_cmd);
	end record;

	constant cnop : cmd_desc := (cmd => "111");
	constant clmr : cmd_desc := (cmd => "000");
	constant cqcl : cmd_desc := (cmd => "110");

	type mr_desc is record
		id : std_logic_vector(xdr_init_b'range);
	end record;

	type fielddesc_vector is array (natural range <>) of field_desc;

	type mr_array is array (natural range <>) of dst_tab;

	signal src : src_word;

	function mov (
		constant desc : field_desc)
		return natural_vector is
		variable tab : dst_wtab := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			tab(desc.dbase+j) := desc.sbase+j;
		end loop;
		return tab;
	end function;

	function mov (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
		variable aux : dst_wtab := (others => 0);
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
		constant desc : cmd_desc)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
		variable aux : std_logic_vector(dst_cmd);
	begin
		aux := desc.cmd;
		for i in aux'range loop
			if aux(i) = '0' then
				val(i) := cnfgreg_size+1;
			elsif aux(i) = '1' then
				val(i) := cnfgreg_size+2;
			end if;
		end loop;
		return val;
	end;

	function set (
		constant desc : mr_desc)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
		variable aux : std_logic_vector(dst_b);
	begin
		aux := desc.id;
		for i in aux'range loop
			if aux(i) = '0' then
				val(i) := cnfgreg_size+1;
			elsif aux(i) = '1' then
				val(i) := cnfgreg_size+2;
			end if;
		end loop;
		return val;
	end;

	function set (
		constant desc : field_desc)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			val(desc.dbase+j) := 2;
		end loop;
		return val;
	end;

	function set (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
		variable aux : dst_wtab := (others => 0);
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
		variable val : dst_wtab := (others => 0);
	begin
		for j in 0 to desc.size-1 loop
			val(desc.dbase+j) := 1;
		end loop;
		return val;
	end;

	function clr (
		constant desc : fielddesc_vector)
		return natural_vector is
		variable val : dst_wtab := (others => 0);
		variable aux : dst_wtab := (others => 0);
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

	constant lat_size : natural := signed_num_bits(lMRD-2);
	type ccmd_record is record 
		cmd : std_logic_vector(2 downto 0);
		lat : signed(0 to lat_size-1);
	end record;

	type ccmd_table is array (ccmds) of ccmd_record;
	constant ccmd_db : ccmd_table := (
		CFG_NOP  => (cnop.cmd, to_signed(lMRD-2, lat_size)),
		CFG_AUTO => (clmr.cmd, to_signed(lMRD-2, lat_size)));

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

	function "or" (
		constant arg1 : natural_vector;
		constant arg2 : natural_vector) 
		return natural_vector is
		variable val : natural_vector(arg1'range);
	begin
		val := arg2;
		for i in arg1'range loop
			if arg1(i) /= '0' then
				val(i) := arg1(i);
			end if;
		end loop;
		return val;
	end;

	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_init : entity is "compact";

end;

architecture ddr3 of xdr_init is

	signal dst : dst_word;

	signal lat_timer : signed(0 to lat_size-1);

	constant ddl_rdy : field_desc := (dbase => dst_o'low+0, sbase => 1, size => 1);
	constant end_rdy : field_desc := (dbase => dst_o'low+1, sbase => 1, size => 1);

	-- DDR3 Mode Register 0 --
	--------------------------

	constant bl : field_desc := (dbase =>  0, sbase => 1, size => 3);
	constant bt : field_desc := (dbase =>  3, sbase => 1, size => 1);
	constant cl : field_desc := (dbase =>  4, sbase => 1, size => 3);
	constant tm : field_desc := (dbase =>  7, sbase => 1, size => 1);
	constant rdll : field_desc := (dbase =>  8, sbase => 1, size => 1);
	constant wr : field_desc := (dbase =>  9, sbase => 1, size => 3);
	constant pd : field_desc := (dbase => 12, sbase => 1, size => 1);

	-- DDR3 Mode Register 1 --
	--------------------------

	constant edll : field_desc := (dbase => 0, sbase => 1, size => 1);
	constant ods  : fielddesc_vector := (
		(dbase => 1, sbase => 1, size => 1),
	   	(dbase => 5, sbase => 1, size => 1));
	constant rtt  : fielddesc_vector := (
		(dbase => 2, sbase => 1, size => 1),
		(dbase => 6, sbase => 1, size => 1),
		(dbase => 9, sbase => 1, size => 1));
	constant al   : field_desc := (dbase =>  3, sbase => 1, size => 2);
	constant wl   : field_desc := (dbase =>  7, sbase => 0, size => 1);
	constant dqs  : field_desc := (dbase => 10, sbase => 0, size => 1);
	constant tdqs : field_desc := (dbase => 11, sbase => 0, size => 1);
	constant qoff : field_desc := (dbase => 12, sbase => 0, size => 1);

	-- DDR3 Mode Register 2 --
	--------------------------

	constant cwl : field_desc := (dbase => 3, sbase => 0, size => 3);
	constant asr : field_desc := (dbase => 6, sbase => 0, size => 1);
	constant srt : field_desc := (dbase => 7, sbase => 0, size => 1);
	constant rttw : field_desc := (dbase => 9, sbase => 0, size => 2);

	-- DDR3 Mode Register 3 --
	--------------------------

	constant rf  : field_desc := (dbase => 0, sbase => 0, size => 2);

	constant mr_file : mr_vector := ( 
		(clr(rttw) or mov(cwl)),
		(clr(edll) or mov(ods) or mov(rtt) or mov(al) or set(wl)   or mov(tdqs)),
		(mov(bl)   or set(bt)  or mov(cl)  or clr(tm) or set(edll) or mov(wr) or mov(pd)));

	type labelIds is (lbl_mr2, lbl_mr3, lbl_mr0, lbl_mr1);

	type insctn is record
		id   : labelIds;
		data : natural_vector(dst_cmd'high downto 0);
	end record;

	function "&" (
		constant arg1 : cmd_desc;
		constant arg2 : std_logic_vector) 
		return natural_vector is
		variable val : natural_vector(arg1'range);
		variable aux : natural_vector;
	begin
		aux := rm_file(to_integer(unsigned(arg2)));
		return val;
	end;

	type insttn_vector is array (natural range <>) of insttn;

	constant pgm : insttn_vector :+ (
		issmr2, clmr & mr1,
		issmr2, clmr & mr2,
		issmr2, clmr & mr2,
		issmr2, clmr & mr4,

	constant clmr : cmd_desc := (cmd => "000");
	signal xdr_init_pc : signed(0 to 4);

begin

	src <=
		"10" &
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
						aux := compile_pgm(xdr_init_pc, src);
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
