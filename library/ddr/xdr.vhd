library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

entity xdr is
	generic (
		bank_bits   : natural :=  2;
		addr_bits   : natural := 13;
		byte_size   : natural :=  8;
		data_phases : natural :=  1;
		data_bytes  : natural :=  2;

		mark : tmrk_ids := M6T;
		tCP  : time := 6.0 ns;
		strobe : string := "EXTERNAL_LOOPBACK";

		vCL  : natural;
		vBL  : natural;
		vWR  : natural;
		vCWL : natural);

	port (
		sys_rst   : in std_logic;
		sys_clk   : in std_logic := '-';
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;

		sys_cfg_rdy : out std_logic;
		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic;
		sys_b  : in  std_logic_vector(bank_bits-1 downto 0);
		sys_a  : in  std_logic_vector(addr_bits-1 downto 0);
		sys_di_rdy : out std_logic;
		sys_do_rdy : out std_logic;
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic;
		sys_dm  : in  std_logic_vector(2*data_bytes-1 downto 0) := (others => '0');
		sys_di  : in  std_logic_vector(2*data_bytes*byte_size-1 downto 0);
		sys_do  : out std_logic_vector(2*data_bytes*byte_size-1 downto 0);
		sys_ref : out std_logic;

		xdr_rst : out std_logic;
		xdr_cke : out std_logic;
		xdr_cs  : out std_logic;
		xdr_ras : out std_logic;
		xdr_cas : out std_logic;
		xdr_we  : out std_logic;
		xdr_ba  : out std_logic_vector(bank_bits-1 downto 0);
		xdr_a   : out std_logic_vector(addr_bits-1 downto 0);
		xdr_dm  : out std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		xdr_dqsz : out std_logic_vector(data_bytes-1 downto 0);
		xdr_dqsi : in  std_logic_vector(data_bytes-1 downto 0);
		xdr_dqso : out std_logic_vector(data_bytes-1 downto 0);
		xdr_dqz : out std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqi : in  std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_dqo : out std_logic_vector(data_bytes*byte_size-1 downto 0);
		xdr_odt : out std_logic;

		xdr_st_dqs : out std_logic_vector(data_bytes-1 downto 0) := (others => '-');
		xdr_st_lp_dqs : in std_logic_vector(data_bytes-1 downto 0));

	constant r : natural := 0;
	constant f : natural := 1;
	constant data_edges : natural := sys_dm'length/xdr_dqsi'length;

	constant std : natural := xdr_std(mark);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr is
	constant debug : boolean := false;
	subtype byte is std_logic_vector(0 to byte_size-1);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_cfg_rdy : std_logic;
	signal xdr_cfg_ras : std_logic;
	signal xdr_cfg_cas : std_logic;
	signal xdr_cfg_we  : std_logic;
	signal xdr_cfg_a   : std_logic_vector(addr_bits-1 downto 0);
	signal xdr_cfg_b   : std_logic_vector(bank_bits-1 downto 0);

	signal xdrphy_cke : std_logic;
	signal xdrphy_ras : std_logic;
	signal xdrphy_cas : std_logic;
	signal xdrphy_we  : std_logic;
	signal xdrphy_a   : std_logic_vector(addr_bits-1 downto 0);
	signal xdrphy_b   : std_logic_vector(bank_bits-1 downto 0);

	signal xdr_cfg_req : std_logic;
	signal xdr_cfg_dll : std_logic;

	signal dll_timer_rdy : std_logic;

	signal xdr_mpu_rst : std_logic;
	signal xdr_mpu_req : std_logic;
	signal xdr_mpu_ref : std_logic;
	signal xdr_mpu_ras : std_logic;
	signal xdr_mpu_cas : std_logic;
	signal xdr_mpu_we  : std_logic;
	signal xdr_mpu_rwin : std_logic;
	signal xdr_mpu_dr  : std_logic_vector(data_phases*data_edges-1 downto 0);
	signal xdr_mpu_rea : std_logic;
	signal xdr_mpu_dqz : std_logic_vector(xdr_dqsi'range);
	signal xdr_mpu_dqsz : std_logic_vector(xdr_dqsi'range);
	signal xdr_mpu_dqs : std_logic_vector(xdr_dqsi'range);
	signal xdr_win_dqs : std_logic_vector(xdr_dqsi'range);
	signal xdr_pgm_cmd : std_logic_vector(0 to 2);
	signal xdr_mpu_rdy : std_logic;
	signal xdr_rd_dqsi : std_logic_vector(data_phases*data_edges*data_bytes-1 downto 0);
	signal xdr_wr_fifo_rst : std_logic;
	signal xdr_wr_fifo_req : std_logic;
	signal xdr_wr_fifo_ena : std_logic_vector(data_phases*data_edges*data_bytes-1 downto 0);
	signal xdr_wr_dm : std_logic_vector(sys_dm'range);
	signal xdr_wr_dq : std_logic_vector(sys_di'range);

	signal xdr_mpu_dmx : std_logic_vector(sys_dm'range);
	signal xdr_stw_sto : std_logic;
	signal xdr_io_dqz : std_logic_vector(xdr_dqz'range);
	signal xdr_io_dqsz : std_logic_vector(xdr_dqsi'range);
	signal xdr_st_hlf : std_logic;

	signal rst : std_logic;

	signal clk0 : std_logic;
	signal clk90 : std_logic;
	signal xdr_wr_clk : std_logic_vector(data_phases-1 downto 0);

begin

	clk0  <= sys_clk0;
	clk90 <= sys_clk90;

	process (clk0, sys_rst)
	begin
		if sys_rst='1' then
			rst <= '1';
		elsif rising_edge(clk0) then
			rst <= sys_rst;
		end if;
	end process;

	xdr_cs <= '0';

	xdr_timer_e : entity hdl4fpga.xdr_timer
	generic map (
		cPreRST => to_xdrlatency(tCP, mark, tPreRST),
		cDLL => xdrlatency(std, cDLL),
		cPstRST => to_xdrlatency(tCP, mark, tPstRST),
		cxpr => to_xdrlatency(tCP, mark, tXPR),
		cREF => to_xdrlatency(tCP, mark, tREFI),
		std  => std)
	port map (
		sys_timer_clk => sys_clk,
		sys_timer_rst => rst,
		sys_cfg_rst  => xdr_rst,
		sys_cfg_req  => xdr_cfg_req,
		xdr_cke => xdrphy_cke,
		dll_timer_req => xdr_cfg_dll,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => xdr_cfg_rdy,
		ref_timer_rdy => xdr_mpu_ref);

	xdr_cfg_du : xdr_cfg
	generic map (
		a    => addr_bits,
		cRP  => to_xdrlatency(tCP, mark, tRP),
		cMRD => to_xdrlatency(tCP, mark, tMRD),
		cRFC => to_xdrlatency(tCP, mark, tRFC))
	port map (
		xdr_cfg_cl  => xdr_cnfglat(std, CL,  vCL),
		xdr_cfg_bl  => xdr_cnfglat(std, BL,  vBL),
		xdr_cfg_wr  => xdr_cnfglat(std, WRL, vWR),
		xdr_cfg_cwl => xdr_cnfglat(std, CWL, vCWL),

		xdr_cfg_clk => sys_clk,
		xdr_cfg_req => xdr_cfg_req,
		xdr_cfg_rdy => xdr_cfg_rdy,
		xdr_cfg_dll => xdr_cfg_dll,
		xdr_cfg_ras => xdr_cfg_ras,
		xdr_cfg_cas => xdr_cfg_cas,
		xdr_cfg_we  => xdr_cfg_we,
		xdr_cfg_a   => xdr_cfg_a,
		xdr_cfg_b   => xdr_cfg_b);

--		sys_cke => xdrphy_cke,
--		sys_odt => dll_timer_rdy,

	xdrphy_ras <= xdr_mpu_ras when dll_timer_rdy='1' else xdr_cfg_ras;
	xdrphy_cas <= xdr_mpu_cas when dll_timer_rdy='1' else xdr_cfg_cas;
	xdrphy_we  <= xdr_mpu_we  when dll_timer_rdy='1' else xdr_cfg_we;
	xdrphy_a <= sys_a when dll_timer_rdy='1' else xdr_cfg_a;
	xdrphy_b <= sys_b when dll_timer_rdy='1' else xdr_cfg_b;

	process (sys_clk)
		variable q : std_logic;
	begin
		if rising_edge(sys_clk) then
--			xdr_mpu_rst <= not (xdr_cfg_rdy and dll_timer_rdy);
			xdr_mpu_rst <= q;
			q := not (xdr_cfg_rdy and dll_timer_rdy);
			sys_cfg_rdy <= xdr_cfg_rdy and dll_timer_rdy;
		end if;
	end process;

	xdr_mpu_req <= sys_cmd_req;
	sys_di_rdy  <= xdr_wr_fifo_req;
	xdr_mpu_e : entity hdl4fpga.xdr_mpu
	generic map (
		std  => std,
		data_phases => data_phases,
		data_bytes  => data_bytes,
		data_edges  => data_edges,

		tRCD => to_xdrlatency(tCP, mark, tRCD),
		tWR  => to_xdrlatency(tCP, mark, tWR),
		tRP  => to_xdrlatency(tCP, mark, tRP),
		tRFC => to_xdrlatency(tCP, mark, tRFC),

		xdr_mpu_bl  => xdr_cnfglat(std, BL,  vBL),
		xdr_mpu_cwl => xdr_cnfglat(std, CWL, vCWL),
		xdr_mpu_cl  => xdr_cnfglat(std, CL,  vCL))
	port map (
		xdr_mpu_rst => xdr_mpu_rst,
		xdr_mpu_clk => clk0,
		xdr_mpu_clk90 => clk90,
		xdr_mpu_cmd => xdr_pgm_cmd,
		xdr_mpu_rdy => xdr_mpu_rdy,
		xdr_mpu_act => sys_act,
		xdr_mpu_cas => xdr_mpu_cas,
		xdr_mpu_ras => xdr_mpu_ras,
		xdr_mpu_we  => xdr_mpu_we,

		xdr_mpu_rea => xdr_mpu_rea,
		xdr_mpu_wbl => xdr_wr_fifo_req,
		xdr_mpu_wri => open,

		xdr_mpu_rwin => xdr_mpu_rwin,
		xdr_mpu_dr => xdr_mpu_dr,

		xdr_mpu_dw => xdr_wr_fifo_ena,
		xdr_mpu_dqs => xdr_mpu_dqs,
		xdr_mpu_dqsz => xdr_mpu_dqsz,
		xdr_mpu_dqz => xdr_mpu_dqz);

	xdr_pgm_e : entity hdl4fpga.xdr_pgm
	port map (
		xdr_pgm_rst => xdr_mpu_rst,
		xdr_pgm_clk => sys_clk,
		sys_pgm_ref => sys_ref,
		xdr_pgm_cmd => xdr_pgm_cmd,
		xdr_pgm_cas => sys_cas,
		xdr_pgm_pre => sys_pre,
		xdr_pgm_ref => xdr_mpu_ref,
		xdr_pgm_start => xdr_mpu_req,
		xdr_pgm_rdy => sys_cmd_rdy,
		xdr_pgm_req => xdr_mpu_rdy,
		xdr_pgm_rw  => sys_rw);

	xdr_win_dqs <= xdr_st_lp_dqs;
	xdr_rd_fifo_g : for i in 0 to 3 generate
		byte_g : entity hdl4fpga.xdr_rd_fifo
		generic map (
			data_delay => std,
			data_edges => data_edges,
			data_phases => data_phases,
			word_size  => byte_size)
		port map (
			sys_clk => clk0,
			sys_rdy => sys_do_rdy,
			sys_rea => xdr_mpu_rea,
			sys_do  => sys_do,
			xdr_win_dq  => xdr_mpu_rwin,
			xdr_win_dqs => xdr_win_dqs(i),
			xdr_dqsi => xdr_rd_dqsi(i),
			xdr_dqi  => xdr_dqi);
	end generate;
			
	xdr_wr_fifo_e : entity hdl4fpga.xdr_wr_fifo
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		byte_size => byte_size,
		word_size => byte_size)
	port map (
		sys_clk => clk0,
		sys_di  => sys_di,
		sys_req => xdr_wr_fifo_req,
		sys_dm  => sys_dm,
		xdr_clks => xdr_wr_clk,
		xdr_dmo  => xdr_wr_dm,
		xdr_enas => xdr_wr_fifo_ena, 
		xdr_dqo  => xdr_wr_dq);
		
	xdr_st_g : if strobe="EXTERNAL_LOOPBACK" generate
		signal st_dqs : std_logic;
	begin
--		xdr_st_hlf <= setif(std=1 and cas(0)='1');
		xdr_st_e : entity hdl4fpga.xdr_stw
		port map (
			xdr_st_hlf => xdr_st_hlf,
			xdr_st_clk => sys_clk0,
			xdr_st_drr => xdr_mpu_dr(r),
			xdr_st_drf => xdr_mpu_dr(f),
			xdr_st_dqs => st_dqs);
		xdr_st_dqs <= (others => st_dqs);
	end generate;
end;
