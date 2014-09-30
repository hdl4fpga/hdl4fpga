library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr is
	generic (
		strobe : string := "NONE_LOOPBACK";
		mark : tmrk_ids := M6T;
		tCP  : time := 6.0 ns;

		bank_size : natural :=  2;
		addr_size : natural := 13;

		sclk_phases : natural := 4;
		sclk_edges  : natural := 2;
		data_phases : natural := 2;
		data_edges  : natural := 2;
		dqso_phases : natural := 2;

		line_size : natural := 16;
		word_size : natural := 16;
		byte_size : natural :=  8);

	port (
		sys_bl  : in std_logic_vector(2 downto 0);
		sys_cl  : in std_logic_vector(2 downto 0);
		sys_cwl : in std_logic_vector(2 downto 0);
		sys_wr  : in std_logic_vector(2 downto 0);

		sys_rst  : in std_logic := '-';
		sys_clks : in std_logic_vector;
		sys_cfg_rdy : out std_logic;

		sys_cmd_req : in  std_logic := '-';
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic := '0';
		sys_b  : in  std_logic_vector(bank_size-1 downto 0) := (others => '-');
		sys_a  : in  std_logic_vector(addr_size-1 downto 0) := (others => '-');
		sys_di_rdy : out std_logic;
		sys_do_rdy : out std_logic_vector((word_size/byte_size)-1 downto 0);
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic;
		sys_dm  : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0) := (others => '0');
		sys_di  : in  std_logic_vector(data_phases*line_size-1 downto 0) := (others => '-');
		sys_do  : out std_logic_vector(data_phases*line_size-1 downto 0);
		sys_ref : out std_logic;

		xdr_wclks : in std_logic_vector;
		xdr_rst : out std_logic;
		xdr_cke : out std_logic;
		xdr_cs  : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_b   : out std_logic_vector(bank_size-1 downto 0);
		xdr_a   : out std_logic_vector(addr_size-1 downto 0);
		xdr_odt : out std_logic;
    xdr_dmi : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0) := (others => '-');
    xdr_dmt : out std_logic_vector(data_phases*line_size/byte_size-1 downto 0) := (others => '-');
		xdr_dmo : out std_logic_vector(data_phases*line_size/byte_size-1 downto 0) := (others => '-');
		xdr_dqsi : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		xdr_dqso : out std_logic_vector((word_size/byte_size)*dqso_phases*line_size/byte_size-1 downto 0) := (others => '-');

		xdr_dqi : in  std_logic_vector(data_phases*line_size-1 downto 0) := (others => '-');
		xdr_dqo : out std_logic_vector(data_phases*line_size-1 downto 0) := (others => '-');

		xdr_dqst : out std_logic_vector(data_phases*(line_size*byte_size)/word_size-1 downto 0);
		xdr_dqt : out std_logic_vector(data_phases*(word_size/byte_size)-1 downto 0);
		xdr_sti : in  std_logic_vector(data_phases/(word_size/byte_size)-1 downto 0) := (others => '-');
		xdr_sto : out std_logic_vector((line_size/word_size)*2*data_phases-1 downto 0) := (others => '-'));

	constant std : natural := xdr_std(mark);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr is
	subtype byte is std_logic_vector(0 to byte_size-1);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_init_rdy : std_logic;
	signal xdr_init_ras : std_logic;
	signal xdr_init_cas : std_logic;
	signal xdr_init_we  : std_logic;
	signal xdr_init_a   : std_logic_vector(addr_size-1 downto 0);
	signal xdr_init_b   : std_logic_vector(bank_size-1 downto 0);

	signal xdrphy_odt : std_logic;
	signal xdrphy_cke : std_logic;
	signal xdrphy_ras : std_logic;
	signal xdrphy_cas : std_logic;
	signal xdrphy_we  : std_logic;
	signal xdrphy_a   : std_logic_vector(addr_size-1 downto 0);
	signal xdrphy_b   : std_logic_vector(bank_size-1 downto 0);

	signal xdr_init_req : std_logic;

	signal dll_timer_rdy : std_logic;

	signal xdr_pgm_cmd : std_logic_vector(0 to 2);

	signal xdr_mpu_rst : std_logic;
	signal xdr_mpu_rdy : std_logic;
	signal xdr_mpu_req : std_logic;
	signal xdr_mpu_ref : std_logic;
	signal xdr_mpu_ras : std_logic;
	signal xdr_mpu_cas : std_logic;
	signal xdr_mpu_we  : std_logic;
	signal xdr_mpu_wri : std_logic;
	signal xdr_mpu_rea : std_logic;
	signal xdr_mpu_rwin : std_logic;
	signal xdr_mpu_wwin : std_logic;

	signal xdr_sch_rwn : std_logic_vector(0 to (line_size/word_size)*2*data_phases-1);
	signal xdr_sch_wwn : std_logic_vector(xdr_sch_rwn'range);
	signal xdr_sch_st : std_logic_vector(xdr_sch_rwn'range);
	signal xdr_sch_dqz : std_logic_vector(xdr_sch_rwn'range);
	signal xdr_sch_dqsz : std_logic_vector(xdr_sch_rwn'range);
	signal xdr_sch_dqs : std_logic_vector(xdr_sch_rwn'range);

	signal xdr_win_dqs : std_logic_vector(xdr_dqsi'range);
	signal xdr_win_dq  : std_logic_vector(xdr_dqsi'range);
	signal xdr_wr_fifo_rst : std_logic;
	signal xdr_wr_fifo_req : std_logic;
	signal xdr_wr_fifo_ena : std_logic_vector(data_phases-1 downto 0);
	signal xdr_wr_dm : std_logic_vector(sys_dm'range);
	signal xdr_wr_dq : std_logic_vector(sys_di'range);

	signal xdr_cwl : std_logic_vector(sys_cwl'range);

	signal rst : std_logic;

begin

	process (sys_clks(0), sys_rst)
	begin
		if sys_rst='1' then
			rst <= '1';
		elsif rising_edge(sys_clks(0)) then
			rst <= sys_rst;
		end if;
	end process;

	xdr_cs <= '0';

	xdr_cwl <= sys_cl when std=2 else sys_cwl;

	xdr_init_du : entity hdl4fpga.xdr_init
	generic map (
		timers => (
			TMR_RST  => to_xdrlatency(tCP, mark, tPreRST),
			TMR_RRDY => to_xdrlatency(tCP, mark, tPstRST),
			TMR_CKE  => to_xdrlatency(tCP, mark, tXPR),
			TMR_ZQINIT => xdr_latency(std, cDLL),
			TRM_REF  => to_xdrlatency(tCP, mark, tREFI)),
		addr_size => addr_size,
		bank_size => bank_size),
	port map (
		xdr_init_bl  => sys_bl,
		xdr_init_cl  => sys_cl,
		xdr_init_wr  => sys_wr,
		xdr_init_cwl => sys_cwl,
		xdr_init_pl  => sys_pl,
		xdr_init_dqsn => sys_dqsn,

		xdr_init_clk => sys_clks(0),
		xdr_init_req => xdr_init_req,
		xdr_init_rdy => xdr_init_rdy,
		xdr_init_ras => xdr_init_ras,
		xdr_init_cas => xdr_init_cas,
		xdr_init_we  => xdr_init_we,
		xdr_init_a   => xdr_init_a,
		xdr_init_b   => xdr_init_b,
		xdr_refi_req => xdr_refi_req,
		xdr_refi_rdy => xdr_refi_rdy);

	xdrphy_cke <= xdrphy_cke;
	xdrphy_odt <= dll_timer_rdy;
	xdrphy_ras <= xdr_mpu_ras when xdr_init_rdy='1' else xdr_init_ras;
	xdrphy_cas <= xdr_mpu_cas when xdr_init_rdy='1' else xdr_init_cas;
	xdrphy_we  <= xdr_mpu_we  when xdr_init_rdy='1' else xdr_init_we;
	xdrphy_a   <= sys_a when xdr_init_rdy='1' else xdr_init_a;
	xdrphy_b   <= sys_b when xdr_init_rdy='1' else xdr_init_b;

	process (sys_clks(0))
		variable q : std_logic;
	begin
		if rising_edge(sys_clks(0)) then
--			xdr_mpu_rst <= not (xdr_init_rdy and dll_timer_rdy);
			xdr_mpu_rst <= q;
			q := not (xdr_init_rdy and dll_timer_rdy);
			sys_cfg_rdy <= xdr_init_rdy and dll_timer_rdy;
		end if;
	end process;

	xdr_pgm_e : entity hdl4fpga.xdr_pgm
	port map (
		xdr_pgm_rst => xdr_mpu_rst,
		xdr_pgm_clk => sys_clks(0),
		sys_pgm_ref => sys_ref,
		xdr_pgm_cmd => xdr_pgm_cmd,
		xdr_pgm_cas => sys_cas,
		xdr_pgm_pre => sys_pre,
		xdr_pgm_ref => xdr_mpu_ref,
		xdr_pgm_start => xdr_mpu_req,
		xdr_pgm_rdy => sys_cmd_rdy,
		xdr_pgm_req => xdr_mpu_rdy,
		xdr_pgm_rw  => sys_rw);

	xdr_mpu_req <= sys_cmd_req;
	sys_di_rdy  <= xdr_wr_fifo_req;
	du : entity hdl4fpga.xdr_mpu
	generic map (
		lRCD => to_xdrlatency(tCP, M6T, tRCD, word_size, byte_size),
		lRFC => to_xdrlatency(tCP, M6T, tRFC, word_size, byte_size),
		lWR  => to_xdrlatency(tCP, M6T, tWR,  word_size, byte_size),
		lRP  => to_xdrlatency(tCP, M6T, tRP,  word_size, byte_size),
		bl_cod => xdr_latcod(std, BL),
		bl_tab => xdr_lattab(std, BL),
		cl_cod => xdr_latcod(std, CL),
		cl_tab => xdr_lattab(std, CL),
		cwl_cod => xdr_latcod(std, xdr_selcwl(std)),
		cwl_tab => xdr_lattab(std, xdr_selcwl(std)))
	port map (
		xdr_mpu_bl  => sys_bl,
		xdr_mpu_cl  => sys_cl,
		xdr_mpu_cwl => xdr_cwl,

		xdr_mpu_rst => xdr_mpu_rst,
		xdr_mpu_clk => sys_clks(0),
		xdr_mpu_cmd => xdr_pgm_cmd,
		xdr_mpu_rdy => xdr_mpu_rdy,
		xdr_mpu_act => sys_act,
		xdr_mpu_cas => xdr_mpu_cas,
		xdr_mpu_ras => xdr_mpu_ras,
		xdr_mpu_we  => xdr_mpu_we,

		xdr_mpu_rea => xdr_mpu_rea,
		xdr_mpu_wri => xdr_mpu_wri,
		xdr_mpu_rwin => xdr_mpu_rwin,
		xdr_mpu_wwin => xdr_mpu_wwin);

	xdr_sch_e : entity hdl4fpga.xdr_sch
	generic map (
		sclk_phases => sclk_phases,
		sclk_edges => sclk_edges,

		data_phases => data_phases,
		data_edges  => data_edges,
		line_size   => line_size,
		byte_size   => byte_size,

		CL_COD    => xdr_latcod(std, CL),
		CWL_COD   => xdr_latcod(std, CWL),

		STRL_TAB  => xdr_lattab(std, STRT, sclk_phases),
		RWNL_tab  => xdr_lattab(std, RWNT, sclk_phases),
		DQSZL_TAB => xdr_lattab(std, DQSZT, sclk_phases),
		DQSOL_TAB => xdr_lattab(std, DQST, sclk_phases),
		DQZL_TAB  => xdr_lattab(std, DQZT, sclk_phases),
		WWNL_TAB  => xdr_lattab(std, WWNT, sclk_phases),

		STRX_LAT  => xdr_latency(std, STRXL, 4/sclk_phases),
		RWNX_LAT  => xdr_latency(std, RWNXL, 4/sclk_phases),
		DQSZX_LAT => xdr_latency(std, DQSZXL, 4/sclk_phases),
		DQSX_LAT  => xdr_latency(std, DQSXL, 4/sclk_phases),
		DQZX_LAT  => xdr_latency(std, DQZXL, 4/sclk_phases),
		WWNX_LAT  => xdr_latency(std, WWNXL, 4/sclk_phases),
		WID_LAT   => xdr_latency(std, WIDL,  4/sclk_phases))
	port map (
		sys_cl   => sys_cl,
		sys_cwl  => xdr_cwl,
		sys_clks => sys_clks,
		sys_rea  => xdr_mpu_rwin,
		sys_wri  => xdr_mpu_wwin,

		xdr_rwn => xdr_sch_rwn,
		xdr_st  => xdr_sto,

		xdr_dqsz => xdr_sch_dqsz,
		xdr_dqs  => xdr_sch_dqs,
		xdr_dqz  => xdr_sch_dqz,
		xdr_wwn  => xdr_sch_wwn);

	xdr_dqo <= xdr_combclks(xdr_sch_dqs, sclk_phases, dqso_phases);

	xdr_win_dqs <= (others => xdr_sch_rwn(0));
	xdr_win_dq  <= (others => xdr_sch_rwn(0));
	rdfifo_i : entity hdl4fpga.xdr_rdfifo
	generic map (
--		dqsi_phases => dqsi_phases,
--		dqsi_edges  => dqsi_edges,
		data_phases => data_phases,
		data_edges  => data_edges,

		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size,
		data_delay => std)
	port map (
		sys_clk => sys_clks(0),
		sys_rdy => sys_do_rdy,
		sys_rea => xdr_mpu_rea,
		sys_do  => sys_do,
		xdr_win_dq  => xdr_win_dq,
		xdr_win_dqs => xdr_win_dqs,
		xdr_dqsi => xdr_dqsi,
		xdr_dqi  => xdr_dqi);
		
	wrfifo_i : entity hdl4fpga.xdr_wrfifo
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,

		line_size => line_size,
		word_size => word_size,
		byte_size => byte_size)
	port map (
		sys_clk => sys_clks(0),
		sys_dqi => sys_di,
		sys_req => xdr_wr_fifo_req,
		sys_dmi => sys_dm,
		xdr_clks => xdr_wclks,
		xdr_dmo  => xdr_dmo,
		xdr_enas => xdr_wr_fifo_ena, 
		xdr_dqo  => xdr_dqo);
end;
