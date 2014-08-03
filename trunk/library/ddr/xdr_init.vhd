library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_init is
	generic (
		tMRD : natural := 11;
		ADDR_SIZE : natural := 13);
		BANK_SIZE : natural := 3);
	port (
		xdr_init_ods : in  std_logic := '0';
		xdr_init_rtt : in  std_logic_vector(1 downto 0) := "01";
		xdr_init_bl  : in  std_logic_vector(0 to 2);
		xdr_init_cl  : in  std_logic_vector(0 to 2);
		xdr_init_wr  : in  std_logic_vector(0 to 2) := (others => '-');
		xdr_init_cwl : in  std_logic_vector(0 to 2) := (others => '-');
		xdr_init_pl  : in  std_logic_vector(0 to 2) := (others => '-');
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

	constant cnop  : std_logic_vector(0 to 2) := "111";
	constant cauto : std_logic_vector(0 to 2) := "001";
	constant cpre  : std_logic_vector(0 to 2) := "010";
	constant clmr  : std_logic_vector(0 to 2) := "000";
	constant cqcl  : std_logic_vector(0 to 2) := "110";

	type ccmd is (CFG_NOP, CFG_AUTO
	type field_desc record is
		dbase : natural;
		sbase : natural;
		size  : natural;
	end record;

	type fielddesc_vector is array of (natural range <>) of field_desc;

	type inst_param record is
		cmd  : std_logic_vector(0 to 2);
		dest : std_logic_vector(xdr_init_b'range);
		desc : field_desc;
	end record;

	type issue record is
		class : natural;
		param : inst_param;
	end;

	type code array (natural range <>) of issue;

	function mov (
		constant dest : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  = clmr;
		param.dest = dest;
		param.desc = desc;
		return param;
	end function;

	function set (
		constant dest : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  = clmr;
		param.dest = dest;
		param.desc = desc;
		param.desc.src = 1*xdr_init_a'length;
	end;

	function clr (
		constant dest : std_logic_vector;
		constant desc : field_desc)
		return inst_param is
		variable param : inst_param;
	begin
		param.cmd  = clmr;
		param.dest = dest;
		param.desc = desc;
		param.desc.src = 0*xdr_init_a'length;
	end;

	type xdr_code is record
		xdr_cmd : std_logic_vector(0 to 2);
		xdr_lat : signed(0 to lat_length-1);
	end record;

	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_init : entity is "compact";
end;

library hdl4fpga.all;

architecture ddr3 of xdr_init is
	function unsigned_num_bits (arg: natural) return natural;

		lb_lmr2, lb_lmr3, lb_lmr1, lb_lmr0,
		lb_zqcl, lb_end); 

	type xdr_init_insr is record
		lbl  : xdr_labels;
		code : xdr_code;
	end record;

	type xdr_state_code is array (xdr_labels) of xdr_init_insr;

	signal lat_timer : signed(0 to unsigned_numbits(tMRD-2));
	signal xdr_init_pc : xdr_labels;

	constant xdr_init_pgm : xdr_state_code := (
		(lb_lmr3, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_lmr1, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_lmr0, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_zqcl, (cmd_lmr, to_signed (tmrd-2, lat_length))),
		(lb_end, (cmd_zqcl, to_signed (tmrd-2, lat_length))),
		(lb_end,  (cmd_nop, (1 to lat_length => '1'))));

	-- DDR3 Mode Register 0 --
	--------------------------

	constant mr0 : std_logic_vector(2 to 0) := "000";

	constant bl : field_desc := (dbase =>  0, sbase => 0, size => 3);
	constant bt : field_desc := (dbase =>  3, sbase => 0, size => 1);
	constant cl : field_desc := (dbase =>  4, sbase => 0, size => 3);
	constant tm : field_desc := (dbase =>  7, sbase => 0, size => 1);
	constant wr : field_desc := (dbase =>  9, sbase => 0, size => 3);
	constant pd : field_desc := (dbase => 12, sbase => 0, size => 1);

	-- DDR3 Mode Register 1 --
	--------------------------

	constant mr1 : std_logic_vector(2 to 0) := "001";

	constant dll  : fill_desc := (dbase => 0, sbase => 0, size => 1);
	constant ods  : filldesc_vector := (
		(dbase => 1, sbase => 0, size => 1),
	   	(dbase => 5, sbase => 0, size => 1));
	constant rt   : filldesc_vector := (
		(dbase => 2, sbase => 0, size => 1),
		(dbase => 6, sbase => 0, size => 1),
		(dbase => 9, sbase => 0, size => 1));
	constant al   : fill_desc := (dbase =>  3, sbase => 0, size => 2);
	constant wr   : fill_desc := (dbase =>  7, sbase => 0, size => 7);
	constant dqs  : fill_desc := (dbase => 10, sbase => 0, size => 1);
	constant tdqs : fill_desc := (dbase => 11, sbase => 0, size => 1);
	constant qoff : fill_desc := (dbase => 12, sbase => 0, size => 1);

	-- DDR3 Mode Register 2 --
	--------------------------

	constant mr2 : std_logic_vector(2 to 0) := "011";

	constant cwl : fill_desc := (dbase => 3, sbase => 0, size => 3);
	constant asr : fill_desc := (dbase => 6, sbase => 0, size => 1);
	constant srt : fill_desc := (dbase => 7, sbase => 0, size => 1);
	constant rtt : fill_desc := (dbase => 9, sbase => 0, size => 2);

	-- DDR3 Mode Register 3 --
	--------------------------

	constant mr3 : std_logic_vector(2 to 0) := "010";

	constant rf  : fill_desc := (dbase => 0, sbase => 0, size => 2);

	constant init_pgm :  init_code := ( 
		(issmr0, mov(mr0, bl)),
		(issmr0, set(mr0, bt)),
		(issmr0, mov(mr0, cl)),
		(issmr0, clr(mr0, tm)),
		(issmr0, set(mr0, dll)),
		(issmr0, mov(mr0, wr)),
		(issmr0, set(mr0, pd)));

	constant xdrinitods_size : natural := 1;
	constant cnfgreg_size : natural := 
		xdrinitods_size +
		xdr_init_pl'length +
		xdr_init_cwl'length +
		xdr_init_rtt'length +
		xdr_init_wr'length +
		xdr_init_bl'length +
		xdr_init_cl'length;

	signal src : std_logic_vector(cnfgreg_size-1 downto 0);

	function compile_pgm(
		constant class : natural)
		return std_logic_vector is
		variable val : std_logic_vector(xdr_init_a'range);
	begin
		for i in pgm'range loop
			if init_code(i).class = class then
				for j in 0 to init_code(i).inst.param.desc.size loop
					val(j+pgm(i).inst.param.desc.dbase) := src(j+pgm(i).inst.param.desc.sbase);
				end loop;
			end if;
		end loop;
		return val;
	end;

begin
	src <=
		xdr_init_ods & xdr_init_pl & xdr_init_cwl &
		xdr_init_rtt & xdr_init_wr & xdr_init_bl  &
		xdr_init_cl;

	process (xdr_init_clk)
	begin
		if rising_edge(xdr_init_clk) then
			if xdr_init_req='1' then
				if lat_timer(0)='1' then
					lat_timer <= xdr_init_pgm(xdr_init_pc).code.xdr_lat;

					dst <= compile_pgm (xdr_init_pc);
					xdr_init_pc <= xdr_init_pgm(xdr_init_pc).lbl;
					if xdr_init_pc=lb_end then
						xdr_init_rdy <= '1';
					else
						xdr_init_rdy <= '0';
					end if;

					if xdr_labels'pos(xdr_init_pc) > xdr_labels'pos(lb_lmr0) then
						xdr_init_dll <= '1';
					else
						xdr_init_dll <= '0';
					end if;
				else
					lat_timer    <= lat_timer - 1;
					dst <= "U0" & "111" & (xdr_init_b'range => '1') & (xdr_init_a'range => '1');
				end if;
			else
				xdr_init_pc  <= lb_lmr2;
				lat_timer    <= (others => '1');
				dst <= "00" & "111" & (xdr_init_b'range => '1') & (xdr_init_a'range => '1');
			end if;
		end if;
	end process;
end;
