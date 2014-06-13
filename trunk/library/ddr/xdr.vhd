library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity xdr is
	generic (
		strobe : string := "EXTERNAL";
		std   : positive;

		tCP   : time := 6.0 ns;

		tWR   : time := 0;
		tRP   : time := 0;
		tRCD  : time := 0;
		tRFC  : time := 0;
		tMRD  : time := 0;
		tREFI : time := 0;

		cl  : natural := 0;
		bl  : natural := 0;
		wr  : natural := 0;
		cwl : natural := 0;

		bank_bits   : natural :=  2;
		addr_bits   : natural := 13;
		byte_size   : natural :=  8;
		data_phases : natural :=  1;
		data_bytes  : natural :=  2);
	port (
		sys_rst   : in std_logic;
		sys_clk   : in std_logic := '-';
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;

		sys_ini : out std_logic;
		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out std_logic;
		sys_rw : in  std_logic;
		sys_a  : in  std_logic_vector(addr_bits-1 downto 0);
		sys_di_rdy : out std_logic;
		sys_do_rdy : out std_logic;
		sys_ba  : in  std_logic_vector(bank_bits-1 downto 0);
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

	constant t200u : real := 200.0e3;
	constant t500u : real := 500.0e3;
	constant t400n : real := 400.0;
	constant txpr  : real := 120.0;
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
	signal xdr_cfg_cke : std_logic;
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
	signal xdr_wr_clk : std_logic_vector(data_phases*data_edges-1 downto 0);

	constant cas : std_logic_vector(0 to 2) := lkup_lat(std, CL, cl); 
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
	xdr_io_ba_e : entity hdl4fpga.xdr_io_ba
	generic map (
		bank_bits => bank_bits,
		addr_bits => addr_bits)
	port map (
		sys_clk => sys_clk0,
		sys_rst => rst,
		sys_ini => dll_timer_rdy,
		sys_cke => xdr_cfg_cke,
		sys_ras => xdr_mpu_ras,
		sys_cas => xdr_mpu_cas,
		sys_we  => xdr_mpu_we,
		sys_odt => dll_timer_rdy,
		sys_a   => sys_a,
		sys_b   => sys_ba,
		sys_ini_ras => xdr_cfg_ras,
		sys_ini_cas => xdr_cfg_cas,
		sys_ini_we  => xdr_cfg_we,
		sys_ini_a   => xdr_cfg_a,
		sys_ini_b   => xdr_cfg_b,

		xdr_odt => xdr_odt,
		xdr_ras => xdr_ras,
		xdr_cas => xdr_cas,
		xdr_cke => xdr_cke,
		xdr_we  => xdr_we,
		xdr_a   => xdr_a,
		xdr_b   => xdr_ba);

	xdr_timer_e : entity hdl4fpga.xdr_timer
	generic map (
		c200u => natural(t200u/tCP),
--		c200u => natural(2000.0/tCP),
		cDLL  => hdl4fpga.std.assign_if(std=3, 512, 220),
		c500u => natural(hdl4fpga.std.assign_if(std=2,t400n,t500u)/tCP),
--		c500u => natural(3000.0),
		cxpr  => natural(txpr/tCP),
		cREF  => natural(floor(tREFI/tCP)),
		std   => std)
	port map (
		xdr_timer_clk => sys_clk,
		xdr_timer_rst => rst,
		xdr_cfg_rst  => xdr_rst,
		xdr_cfg_cke  => xdr_cfg_cke,
		xdr_cfg_req  => xdr_cfg_req,
		dll_timer_req => xdr_cfg_dll,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => xdr_cfg_rdy,
		ref_timer_rdy => xdr_mpu_ref);

	xdr_cfg_du : xdr_cfg
	generic map (
		a    => addr_bits,
		cRP  => (tRP +tCP)/tCP,
		cMRD => (tMRD+tCP)/tCP,
		cRFC => (tRFC+tCP)/tCP)
	port map (
		xdr_cfg_cl  => lkup_lat(std, CL,  cl),
		xdr_cfg_bl  => lkup_lat(std, BL,  bl),
		xdr_cfg_wr  => lkup_lat(std, WR,  wr),
		xdr_cfg_cwl => lkup_lat(std, CWL, cwl),

		xdr_cfg_clk => sys_clk,
		xdr_cfg_req => xdr_cfg_req,
		xdr_cfg_rdy => xdr_cfg_rdy,
		xdr_cfg_dll => xdr_cfg_dll,
		xdr_cfg_ras => xdr_cfg_ras,
		xdr_cfg_cas => xdr_cfg_cas,
		xdr_cfg_we  => xdr_cfg_we,
		xdr_cfg_a   => xdr_cfg_a,
		xdr_cfg_b   => xdr_cfg_b);

	process (sys_clk)
		variable q : std_logic;
	begin
		if rising_edge(sys_clk) then
--			xdr_mpu_rst <= not (xdr_cfg_rdy and dll_timer_rdy);
			xdr_mpu_rst <= q;
			q := not (xdr_cfg_rdy and dll_timer_rdy);
			sys_ini     <= xdr_cfg_rdy and dll_timer_rdy;
		end if;
	end process;

	xdr_mpu_req <= sys_cmd_req;
	sys_di_rdy  <= xdr_wr_fifo_req;
	xdr_mpu_e : entity hdl4fpga.xdr_mpu
	generic map (
		std  => std,
		tRCD => natural(ceil(tRCD/tCP)),
		tWR  => natural(ceil(tWR/tCP)),
		tRP  => natural(ceil(tRP/tCP)),
		tRFC => natural(ceil(tRFC/tCP)),
		data_phases => data_phases,
		data_bytes => data_bytes,
		data_edges => data_edges,
		xdr_mpu_bl => bldb(bl,std),
		xdr_mpu_cwl => cwldb(cwl, std),
		xdr_mpu_cl => casdb(cl, std))
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

--	xdr_clks_e : entity hdl4fpga.xdr_clks
--	generic map (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		data_bytes  => data_bytes)
--	port map (
--		sys_clk  => clk0,
--		xdr_dqsi => xdr_dqsi,
--		phs_clk  => 
--		phs_dqs  => );

	xdr_win_dqs <= xdr_st_lp_dqs;
	xdr_rd_fifo_e : entity hdl4fpga.xdr_rd_fifo
	generic map (
		data_delay => 2, --std,
		data_phases => data_phases,
		data_bytes => data_bytes,
		byte_size  => byte_size)
	port map (
		sys_clk => clk0,
		sys_do  => sys_do,
		sys_rdy => sys_do_rdy,
		sys_rea => xdr_mpu_rea,

		xdr_win_dq  => xdr_mpu_rwin,
		xdr_win_dqs => xdr_win_dqs,
		xdr_dqsi => xdr_rd_dqsi,
		xdr_dqi  => xdr_dqi);
		
	xdr_wr_fifo_e : entity hdl4fpga.xdr_wr_fifo
	generic map (
		std => std,
		data_phases => data_phases,
		data_bytes => data_bytes,
		byte_size  => byte_size)
	port map (
		sys_clk => clk0,
		sys_di  => sys_di,
		sys_req => xdr_wr_fifo_req,
		sys_dm  => sys_dm,

		xdr_clk => xdr_wr_clk,
		xdr_dm  => xdr_wr_dm,
		xdr_ena => xdr_wr_fifo_ena, 
		xdr_dq  => xdr_wr_dq);
		
	xdr_io_dq_e : entity hdl4fpga.xdr_io_dq
	generic map (
		data_phases => assign_if(data_phases > 2,unsigned_num_bits(data_phases),0),
		data_edges => data_edges,
		data_bytes => data_bytes,
		byte_size  => byte_size)
	port map (
		xdr_io_clk => clk90,
		xdr_io_dq  => xdr_wr_dq,
		xdr_mpu_dqz => xdr_mpu_dqz,
		xdr_io_dqz => xdr_io_dqz,
		xdr_io_dqo => xdr_dqo);
	xdr_dqz <= xdr_io_dqz;

	xdr_io_dqs_e : entity hdl4fpga.xdr_io_dqs
	generic map (
		std => std,
		data_phases => data_phases,
		data_edges  => data_edges,
		data_bytes  => data_bytes)
	port map (
		xdr_io_clk => clk0,
		xdr_io_ena => xdr_mpu_dqs,
		xdr_mpu_dqsz => xdr_mpu_dqsz,
		xdr_io_dqsz => xdr_io_dqsz,
		xdr_io_dqso => xdr_dqso);
	xdr_dqsz <= xdr_io_dqsz;
	
	xdr_mpu_dmx <= xdr_wr_fifo_ena;
--	xdr_io_dm_e : entity hdl4fpga.xdr_io_dm
--	generic map (
--		strobe => strobe,
--		xdr_phases => assign_if(data_phases > 2,unsigned_num_bits(data_phases),0),
--		data_edges => data_edges,
--		data_bytes => data_bytes)
--	port map (
--		sys_dmi
--		sys_dmo
--		xdr_io_clk => xdr_clk,
--		xdr_mpu_st => xdr_mpu_dr,
--		xdr_mpu_dm => xdr_wr_dm,
--		xdr_mpu_dmx => xdr_mpu_dmx,
--		xdr_io_dmo => xdr_dm);

	xdr_st_g : if strobe="EXTERNAL" generate
		signal st_dqs : std_logic;
	begin
		xdr_st_hlf <= setif(std=1 and cas(0)='1');
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
