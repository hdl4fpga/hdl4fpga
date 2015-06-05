use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr_init is
	generic (
		timers : ddrtid_vector := (TMR_RST => 100_000, TMR_RRDY => 250_000, TMR_CKE => 14, TMR_MRD => 17, TMR_DLL => 200, TMR_ZQINIT => 20, TMR_REF => 25, TMR_MOD => 100, TMR_WLC => 20);
		addr_size : natural := 13;
		bank_size : natural := 3);
	port (
		xdr_mr_addr  : out std_logic_vector;
		xdr_mr_data  : in std_logic_vector;
		xdr_refi_rdy : in  std_logic;
		xdr_refi_req : out std_logic;
		xdr_init_clk : in  std_logic;
		xdr_init_wlc : in  std_logic;
		xdr_init_req : in  std_logic;
		xdr_init_rdy : out std_logic;
		xdr_init_rst : out std_logic;
		xdr_init_cke : out std_logic;
		xdr_init_odt : out std_logic := '0';
		xdr_init_cs  : out std_logic;
		xdr_init_ras : out std_logic;
		xdr_init_cas : out std_logic;
		xdr_init_we  : out std_logic;
		xdr_init_a   : out std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '1');
		xdr_init_b   : out std_logic_vector(BANK_SIZE-1 downto 0) := (others => '1'));

	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_init : entity is "compact";

end;

architecture ddr3 of xdr_init is

	subtype s_code is std_logic_vector(0 to 4-1);

	constant sc_rst  : s_code := "0000";
	constant sc_cke  : s_code := "0001";
	constant sc_lmr2 : s_code := "0011";
	constant sc_lmr3 : s_code := "0010";
	constant sc_lmr1 : s_code := "0110";
	constant sc_lmr0 : s_code := "0111";
	constant sc_zqi  : s_code := "0101";
	constant sc_wls  : s_code := "0100";
	constant sc_wlc  : s_code := "1100";
	constant sc_wlf  : s_code := "1101";
	constant sc_ref  : s_code := "1000";

	type s_row is record
		state   : s_code;
		state_n : s_code;
		mask    : std_logic_vector(0 to 0);
		input   : std_logic_vector(0 to 0);
		rst     : std_logic;
		cke     : std_logic;
		cmd     : ddr_cmd;
		mr      : ddr_mr;
		tid     : ddr_tid;
	end record;

	type s_table is array (natural range <>) of s_row;

	constant pgm : s_table := (
		(sc_rst,  sc_cke,  "0", "0", '0', '0', ddr_nop, mrx, TMR_RST),
		(sc_cke,  sc_lmr2, "0", "0", '1', '0', ddr_nop, mrx, TMR_RRDY),
		(sc_lmr2, sc_lmr3, "0", "0", '1', '1', ddr_lmr, mr2, TMR_MRD),
		(sc_lmr3, sc_lmr1, "0", "0", '1', '1', ddr_lmr, mr3, TMR_MRD),
		(sc_lmr1, sc_lmr0, "0", "0", '1', '1', ddr_lmr, mr1, TMR_MRD),
		(sc_lmr0, sc_zqi,  "0", "0", '1', '1', ddr_lmr, mr0, TMR_MOD),
		(sc_zqi,  sc_wls,  "0", "0", '1', '1', ddr_zqc, mrz, TMR_ZQINIT),
		(sc_wls,  sc_wlf,  "0", "0", '1', '1', ddr_lmr, mrz, TMR_MRD),
		(sc_wlc,  sc_wlc,  "1", "0", '1', '1', ddr_nop, mrz, TMR_WLC),
		(sc_wlc,  sc_wlf,  "1", "1", '1', '1', ddr_nop, mrz, TMR_WLC),
		(sc_wlf,  sc_ref,  "0", "0", '1', '1', ddr_lmr, mrz, TMR_MRD),
		(sc_ref,  sc_ref,  "0", "0", '1', '1', ddr_nop, mrz, TMR_REF));

	signal xdr_init_pc : s_code;
	signal xdr_timer_id : ddr_tid;
	signal xdr_timer_rdy : std_logic;
	signal xdr_timer_req : std_logic;

	signal input : std_logic_vector(0 to 0);
begin

	input(0) <= xdr_init_wlc;

	process (xdr_init_clk)
		variable row : s_row;
	begin
		if rising_edge(xdr_init_clk) then
			if xdr_init_req='0' then
				for i in pgm'range loop
					if pgm(i).state=xdr_init_pc then
						if ((pgm(i).input xor input) and pgm(i).mask)=(input'range => '0') then
							 row := pgm(i);
						end if;
					end if;
				end loop;
				if xdr_timer_rdy='1' then
					xdr_init_pc  <= row.state_n;
					xdr_init_rst <= row.rst;
					xdr_init_cke <= row.cke;
					xdr_init_cs  <= row.cmd.cs;
					xdr_init_ras <= row.cmd.ras;
					xdr_init_cas <= row.cmd.cas;
					xdr_init_we  <= row.cmd.we;
				else
					xdr_timer_id <= row.tid;
				end if;
				xdr_init_b  <= std_logic_vector(unsigned(resize(unsigned(row.mr), xdr_init_b'length)));
				xdr_mr_addr <= row.mr;
			else
				xdr_init_pc  <= pgm(0).state;
				xdr_timer_id <= pgm(0).tid;
				xdr_init_rst <= pgm(0).rst;
				xdr_init_cke <= pgm(0).cke;
				xdr_init_cs  <= pgm(0).cmd.cs;
				xdr_init_ras <= pgm(0).cmd.ras;
				xdr_init_cas <= pgm(0).cmd.cas;
				xdr_init_we  <= pgm(0).cmd.we;
				xdr_mr_addr  <= pgm(0).mr;
				xdr_init_b   <= std_logic_vector(unsigned(resize(unsigned(pgm(0).mr), xdr_init_b'length)));
			end if;
		end if;
	end process;
	xdr_init_a <= std_logic_vector(unsigned(resize(unsigned(xdr_mr_data), xdr_init_a'length)));


	xdr_timer_req <=
	'1' when xdr_timer_req='1' else
	'1' when xdr_timer_rdy='1' else
	'0';

	timer_e : entity hdl4fpga.xdr_timer
	generic map (
		timers => timers)
	port map (
		sys_clk => xdr_init_clk,
		tmr_id  => xdr_timer_id,
		sys_req => xdr_timer_req,
		sys_rdy => xdr_timer_rdy);
end;
