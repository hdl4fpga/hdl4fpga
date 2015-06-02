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
		timers : timer_vector := (TMR_RST => 100_000, TMR_RRDY => 250_000, TMR_CKE => 14, TMR_MRD => 17, TMR_DLL => 200, TMR_ZQINIT => 20, TMR_REF => 25, TMR_MOD => 100);
		addr_size : natural := 13;
		bank_size : natural := 3);
	port (
		xdr_mr_addr : in std_logic_vector;
		xdr_mr_data : in std_logic_vector;
		xdr_refi_rdy : in  std_logic;
		xdr_refi_req : out std_logic;
		xdr_init_clk : in  std_logic;
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

	constant xdrinitout_size : natural := 2;

	constant xdrinitods_size : natural := 1;
	constant cnfgreg_size : natural := 
		xdrinitods_size +
		xdr_init_rtt'length +
		xdr_init_pl'length +
		xdr_init_cwl'length +
		xdr_init_drtt'length +
		xdr_init_wr'length +
		xdr_init_bl'length +
		xdr_init_cl'length;

	subtype  dst_cmd is natural range dst_b'high+4 downto dst_b'high+1;
	constant dst_cs  : natural := dst_b'high+4;
	constant dst_ras : natural := dst_b'high+3;
	constant dst_cas : natural := dst_b'high+2;
	constant dst_we  : natural := dst_b'high+1;
	subtype  dst_o   is natural range dst_cs+xdrinitout_size downto dst_ras+1;

	type ccmds is (CFG_ZQC, CFG_MRS);

	type mr_array is array (natural range <>) of ddr3_mr;

	signal src : src_word;

	signal xdr_timer_req : std_logic;
	signal xdr_timer_rdy : std_logic;
	signal xdr_timer_id  : TMR_IDs;
	signal xdr_timer_ref : std_logic;

	attribute fsm_encoding : string;
	attribute fsm_encoding of xdr_init : entity is "compact";

end;

architecture ddr3 of xdr_init is

	subtype state_cod is std_logic_vector(0 to 3);
	constant sid_reset : state_cod;

	type is record
		state   : state_id
		state_n : state_id;
		cmd     : ddr3_cmd;
		mr      : ddr3_mr;
		tmr     : ddr3_id;
	end record;

	constant pgm : ddr3ccmd_vector := (
		(ddr3_nop, mrx, TMR_RRDY),
		(ddr3_nop, mrx, TMR_CKE),
		(ddr3_lmr, mr2, TMR_MRD),
		(ddr3_lmr, mr3, TMR_MRD),
		(ddr3_lmr, mr1, TMR_MRD),
		(ddr3_lmr, mr0, TMR_MOD),
		(ddr3_zqc, mrz, TMR_ZQINIT));

	signal xdr_init_pc : unsigned(0 to unsigned_num_bits(pgm'length-1));

begin


	process (xdr_init_clk)
	begin
		if rising_edge(xdr_init_clk) then
			if xdr_init_req='0' then
				if xdr_timer_rdy='1' then
					if xdr_init_pc(0)='0' then
						xdr_init_pc <= xdr_init_pc - 1;
						dst <= build(xdr_init_pc, src).dst;
					else
						dst <= (others => '1');
					end if;
				else
					dst <= (others => '1');
				end if;
			else
				dst <= (others => '1');
				xdr_init_pc <= to_unsigned(pgm'length-1, xdr_init_pc'length);
			end if;

			if xdr_init_req='0' then
				if xdr_timer_rdy='0' then
					if xdr_init_pc(0)='0' then
						xdr_timer_id <= build(xdr_init_pc, src).id;
					else
						xdr_timer_id <= TMR_REF;
					end if;
				end if;
			else
				xdr_timer_id <= TMR_RST;
			end if;

			if xdr_init_req='0' then
				if xdr_timer_rdy='1' then
					if xdr_init_pc(0)='1' then
						xdr_timer_ref <= '1';
					end if;
				end if;
			else
				xdr_timer_ref <= '0';
			end if;

			if xdr_init_req='0' then
				if xdr_timer_rdy='1' then
					case xdr_timer_id is
					when TMR_RST =>
						xdr_init_rst <= '0';
						xdr_init_cke <= '0';
					when TMR_RRDY =>
						xdr_init_rst <= '1';
						xdr_init_cke <= '0';
					when others =>
						xdr_init_rst <= '1';
						xdr_init_cke <= '1';
					end case;
					xdr_init_rdy <= xdr_init_pc(0);
				end if;
			else
				xdr_init_rst <= '0';
				xdr_init_cke <= '0';
				xdr_init_rdy <= '0';
			end if;

			if xdr_init_req='0' then
				if xdr_refi_rdy='1' then
					xdr_refi_req <= '0';
				elsif xdr_timer_ref='1' then
					if xdr_timer_req='1' then
						xdr_refi_req  <= '1';
					end if;
				end if;
			else
				xdr_refi_req <= '0';
			end if;
		end if;
	end process;

	xdr_timer_req <= xdr_timer_rdy or xdr_init_req;

	xdr_init_a   <= dst(dst_a);
	xdr_init_b   <= dst(dst_b);
	xdr_init_cs  <= dst(dst_cs);
	xdr_init_ras <= dst(dst_ras);
	xdr_init_cas <= dst(dst_cas);
	xdr_init_we  <= dst(dst_we);

	timer_e : entity hdl4fpga.xdr_timer
	generic map (
		timers => timers)
	port map (
		sys_clk => xdr_init_clk,
		tmr_id  => xdr_timer_id,
		sys_req => xdr_timer_req,
		sys_rdy => xdr_timer_rdy);
end;
