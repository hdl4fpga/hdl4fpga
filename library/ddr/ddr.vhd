library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ddr is
	generic (
		std : positive := 3;
		tCP : real := 6.0;
		tWR : real := 15.0;
		tRP : real := 15.0;
		tRCD : real := 15.0;
		tRFC : real := 72.0;
		tMRD : real := 12.0;
		tREF : real := 7.8e3;
		cl  : real := 5.0;
		bl  : natural := 8;
		wr  : natural := 10;
		cwl : natural := 7;

		bank_bits  : natural := 2;
		addr_bits  : natural := 13;
		data_bytes : natural := 2;
		byte_bits  : natural := 8);
	port (
		sys_rst   : in  std_logic;
		sys_clk0  : in  std_logic;
		sys_clk90 : in  std_logic;

		sys_ini : out std_logic;
		sys_cmd_req : in  std_logic;
		sys_cmd_rdy : out  std_logic;
		sys_rw  : in  std_logic;
		sys_a   : in  std_logic_vector(addr_bits-1 downto 0);
		sys_di_rdy : out std_logic;
		sys_do_rdy : out std_logic;
		sys_ba  : in  std_logic_vector(bank_bits-1 downto 0);
		sys_act : out std_logic;
		sys_cas : out std_logic;
		sys_pre : out std_logic;
		sys_di  : in  std_logic_vector(0 to 2*data_bytes*byte_bits-1);
		sys_do  : out std_logic_vector(0 to 2*data_bytes*byte_bits-1);
		sys_ref : out std_logic;

		ddr_rst : out std_logic;
		ddr_cke : out std_logic;
		ddr_cs  : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_st_lp_dqs : in std_logic;
		ddr_lp_dqs : out std_logic;
		ddr_we  : out std_logic;
		ddr_ba  : out std_logic_vector(bank_bits-1 downto 0);
		ddr_a   : out std_logic_vector(addr_bits-1 downto 0);
		ddr_dm  : out std_logic_vector(0 to data_bytes-1);
		ddr_dqs : inout std_logic_vector(0 to data_bytes-1);
		ddr_dq  : inout std_logic_vector(0 to data_bytes*byte_bits-1));

	constant t200u : real := 200.0e3;
	constant t500u : real := 500.0e3;
	constant t400n : real := 400.0;
	constant txpr  : real := 120.0;
	constant data_bits : natural := data_bytes*byte_bits;
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;

architecture mix of ddr is
	constant debug : boolean := false;
	subtype byte is std_logic_vector(0 to byte_bits-1);
	type byte_vector is array (natural range <>) of byte;

	signal ddr_init_rdy : std_logic;
	signal ddr_init_ras : std_logic;
	signal ddr_init_cas : std_logic;
	signal ddr_init_we  : std_logic;
	signal ddr_init_a   : std_logic_vector(addr_bits-1 downto 0);
	signal ddr_init_b   : std_logic_vector(bank_bits-1 downto 0);
	signal ddr_init_cke : std_logic;
	signal ddr_init_cfg : std_logic;
	signal ddr_init_dll : std_logic;

	signal ddr_timer_sel  : std_logic;
	signal dll_timer_rdy  : std_logic;
	signal ddr_timer_rst  : std_logic;
	signal ddr_timer_ref  : std_logic;

	signal ddr_acc_rst : std_logic;
	signal ddr_acc_req : std_logic;
	signal ddr_acc_ref  : std_logic;
	signal ddr_acc_ras : std_logic;
	signal ddr_acc_cas : std_logic;
	signal ddr_acc_we  : std_logic;
	signal ddr_acc_rwin : std_logic;
	signal ddr_acc_drr : std_logic;
	signal ddr_acc_drf : std_logic;
	signal ddr_acc_rea : std_logic;
	signal ddr_acc_dqz : std_logic_vector(ddr_dqs'range);
	signal ddr_acc_dqsz : std_logic_vector(ddr_dqs'range);
	signal ddr_acc_dqs : std_logic_vector(ddr_dqs'range);
	signal ddr_pgm_cmd : std_logic_vector(0 to 2);
	signal ddr_mpu_rdy : std_logic;
	signal ddr_wr_fifo_rst  : std_logic;
	signal ddr_wr_fifo_req  : std_logic;
	signal ddr_wr_fifo_ena_n : std_logic_vector(ddr_dqs'range);
	signal ddr_wr_fifo_ena_p : std_logic_vector(ddr_dqs'range);
	signal ddr_wr_fifo_do  : std_logic_vector(sys_di'range);
	signal ddr_io_dso  : std_logic_vector(ddr_dqs'reverse_range);

	signal ddr_io_dqi : std_logic_vector(ddr_dq'range);
	signal ddr_acc_wri : std_logic;

	signal rst : std_logic;
	alias  ddr_dql : std_logic_vector(0 to data_bits-1) is ddr_wr_fifo_do(0 to data_bits-1);
	alias  ddr_dqh : std_logic_vector(0 to data_bits-1) is ddr_wr_fifo_do(data_bits to 2*data_bits-1);

	alias  clk0   is sys_clk0;
	alias  clk90  is sys_clk90;
	signal clk180 : std_logic;
	signal clk270 : std_logic;

	function casdb (
		constant cl  : real;
		constant std : natural)
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

		when others =>
			report "Invalid DDR version"
			severity FAILURE;

			return (0 to 2 => '-');
		end case;
	end;

	function bldb (
		constant bl  : natural;
		constant std : natural)
		return std_logic_vector is
		type bltab is array (natural range <>) of std_logic_vector(0 to 2);

		constant bl1db : bltab(0 to 2) := ("001", "010", "011");
		constant bl2db : bltab(1 to 2) := ("010", "011");
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
				if bl=2**(i+1) then
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
		constant std : natural)
		return std_logic_vector is
		type wrtab is array (natural range <>) of std_logic_vector(0 to 2);

		constant wr3db  : wrtab(0 to 6-1) := ("001", "010", "011", "100", "101", "110");
		constant wr3idx : hdl4fpga.std.natural_vector(wr3db'range) := (5, 6, 7, 8, 10, 12);

	begin
		case std is
		when 3 =>
			for i in wr3db'range loop
				if wr = wr3idx(i) then
					return wr3db(i);
				end if;
			end loop;

		when others =>
			report "Invalid DDR version"
			severity FAILURE;

			return (0 to 2 => '-');
		end case;

		report "Invalid Write Recovery"
		severity FAILURE;
		return (0 to 2 => '-');
	end;

	function cwldb (
		constant cwl : natural;
		constant std : natural)
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

		when others =>
			report "Invalid DDR version"
			severity FAILURE;

			return (0 to 2 => '-');
		end case;

		report "Invalid CAS Write Latency"
		severity FAILURE;
		return (0 to 2 => '-');
	end;

begin

	clk180 <= not sys_clk0;
	clk270 <= not sys_clk90;

	process (clk0)
	begin
		if rising_edge(clk0) then
			rst <= sys_rst;
		end if;
	end process;

	ddr_cs  <= '0';
	ddr_io_ba_e : entity hdl4fpga.ddr_io_ba
	generic map (
		bank_bits => bank_bits,
		addr_bits => addr_bits)
	port map (
		sys_clk => clk0,
		sys_ini => dll_timer_rdy,
		sys_cke => ddr_init_cke,
		sys_ras => ddr_acc_ras,
		sys_cas => ddr_acc_cas,
		sys_we  => ddr_acc_we,
		sys_a   => sys_a,
		sys_b   => sys_ba,
		
		sys_ini_ras => ddr_init_ras,
		sys_ini_cas => ddr_init_cas,
		sys_ini_we  => ddr_init_we,
		sys_ini_a   => ddr_init_a,
		sys_ini_b   => ddr_init_b,
	
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_cke => ddr_cke,
		ddr_we  => ddr_we,
		ddr_a   => ddr_a,
		ddr_b   => ddr_ba);

	ddr_timer_du : entity hdl4fpga.ddr_timer
	generic map (
--		c200u => natural(t200u/tCP),
		c200u => natural(2000.0/tCP),
		cDLL  => hdl4fpga.std.assign_if(std=3, 512, 200),
--		c500u => natural(hdl4fpga.std.assign_if(std=2,t400n,t500u)/tCP),
		c500u => natural(hdl4fpga.std.assign_if(std=2,t400n, 3000.0 )/tCP),
		cxpr  => natural(txpr/tCP),
		cREF  => natural(tREF/tCP),
		std   => std)
	port map (
		ddr_timer_clk => clk0,
		ddr_timer_rst => rst,
		ddr_init_rst  => ddr_rst,
		ddr_init_cke  => ddr_init_cke,
		ddr_init_cfg  => ddr_init_cfg,
		dll_timer_req => ddr_init_dll,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => ddr_init_rdy,
		ref_timer_rdy => ddr_acc_ref);

	ddr1_init_g : if std=1 generate
		ddr_init_du : entity hdl4fpga.ddr_init(ddr1)
		generic map (
			a    => addr_bits,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => natural(ceil(tMRD/tCp)),
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
			ddr_init_bl  => "011",
			ddr_init_cl  => casdb(cl, std),
			ddr_init_clk => clk0,
			ddr_init_req => ddr_init_cfg,
			ddr_init_rdy => ddr_init_rdy,
			ddr_init_dll => ddr_init_dll,
			ddr_init_ras => ddr_init_ras,
			ddr_init_cas => ddr_init_cas,
			ddr_init_we  => ddr_init_we,
			ddr_init_a   => ddr_init_a,
			ddr_init_b   => ddr_init_b);
	end generate;

	ddr2_init_g : if std=2 generate
		ddr_init_du : entity hdl4fpga.ddr_init(ddr2)
		generic map (
			lat_length => 9,
			a    => addr_bits,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => 2,
			tRFC => natural(ceil(127.50/tCp)))
		port map (
			ddr_init_cl  => casdb(cl, std),
			ddr_init_bl  => bldb(bl,std),
			ddr_init_wr  => wrdb(wr,std),
			ddr_init_clk => clk0,
			ddr_init_req => ddr_init_cfg,
			ddr_init_rdy => ddr_init_rdy,
			ddr_init_dll => ddr_init_dll,
			ddr_init_ras => ddr_init_ras,
			ddr_init_cas => ddr_init_cas,
			ddr_init_we  => ddr_init_we,
			ddr_init_a   => ddr_init_a,
			ddr_init_b   => ddr_init_b);
	end generate;

	ddr3_init_g : if std=3 generate
		signal ba3 : std_logic_vector(2 downto 0);
	begin
		ddr_init_b <= ba3(1 downto 0);
		ddr_init_du : entity hdl4fpga.ddr_init(ddr3)
		generic map (
			lat_length => 9,
			a    => addr_bits,
			ba   => 3,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => 4,
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
--			ddr_init_bl  => "011",
			ddr_init_bl  => "000",
--			ddr_init_bl  => bldb(bl,std),
			ddr_init_cl  => casdb(cl, std),
			ddr_init_wr  => wrdb(wr,std),
			ddr_init_cwl => cwldb(cwl,std),
			ddr_init_clk => clk0,
			ddr_init_req => ddr_init_cfg,
			ddr_init_rdy => ddr_init_rdy,
			ddr_init_dll => ddr_init_dll,
			ddr_init_ras => ddr_init_ras,
			ddr_init_cas => ddr_init_cas,
			ddr_init_we  => ddr_init_we,
			ddr_init_a   => ddr_init_a,
			ddr_init_b   => ba3);
	end generate;

	process (clk0)
	begin
		if rising_edge(clk0) then
			ddr_acc_rst   <= not (ddr_init_rdy and dll_timer_rdy);
			sys_ini       <= ddr_init_rdy and dll_timer_rdy;
		end if;
	end process;

	ddr_acc_req <= sys_cmd_req;
	sys_di_rdy  <= ddr_wr_fifo_req;
	ddr_mpu_e : entity hdl4fpga.ddr_mpu
	generic map (
		tRCD => natural(ceil(tRCD/tCp)),
		tWR  => natural(ceil(tWR/tCp)),
		tRP  => natural(ceil(tRP/tCp)),
		tRFC => natural(ceil(tRFC/tCp)),
		ddr_mpu_bl => bldb(bl,std),
		ddr_mpu_cwl => cwldb(cwl, std),
		ddr_mpu_cl => casdb(cl, std))
	port map (
		ddr_mpu_rst   => ddr_acc_rst,
		ddr_mpu_clk   => clk0,
		ddr_mpu_clk90 => clk90,
		ddr_mpu_cmd   => ddr_pgm_cmd,
		ddr_mpu_rdy   => ddr_mpu_rdy,
		ddr_mpu_act   => sys_act,
		ddr_mpu_cas   => ddr_acc_cas,
		ddr_mpu_ras   => ddr_acc_ras,
		ddr_mpu_we    => ddr_acc_we,

		ddr_mpu_rea   => ddr_acc_rea,
		ddr_mpu_wbl   => ddr_wr_fifo_req,
		ddr_mpu_wri   => ddr_acc_wri,

		ddr_mpu_rwin  => ddr_acc_rwin,
		ddr_mpu_drr   => ddr_acc_drr,
		ddr_mpu_drf   => ddr_acc_drf,

		ddr_mpu_dwr   => ddr_wr_fifo_ena_p,  
		ddr_mpu_dwf   => ddr_wr_fifo_ena_n,  
		ddr_mpu_dqs   => ddr_acc_dqs,
		ddr_mpu_dqsz  => ddr_acc_dqsz,
		ddr_mpu_dqz   => ddr_acc_dqz);

	ddr_pgm_e : entity hdl4fpga.ddr_pgm
	port map (
		ddr_pgm_rst => ddr_acc_rst,
		ddr_pgm_clk => clk0,
		sys_pgm_ref => sys_ref,
		ddr_pgm_cmd => ddr_pgm_cmd,
		ddr_pgm_cas => sys_cas,
		ddr_pgm_pre => sys_pre,
		ddr_pgm_ref => ddr_acc_ref,
		ddr_pgm_start => ddr_acc_req,
		ddr_pgm_rdy => sys_cmd_rdy,
		ddr_pgm_req => ddr_mpu_rdy,
		ddr_pgm_rw  => sys_rw);

	ddr_rd_fifo_e : entity hdl4fpga.ddr_rd_fifo
	port map (
		sys_clk => clk0,
		sys_do  => sys_do,
		sys_rdy => sys_do_rdy,
		sys_rea => ddr_acc_rea,
		ddr_win_dq  => ddr_acc_rwin,
		ddr_win_dqs => ddr_st_lp_dqs,
		ddr_dqs => ddr_io_dso,
		ddr_dqi  => ddr_io_dqi);
		
	ddr_wr_fifo_rst <= not ddr_acc_wri;
	ddr_wr_fifo_e : entity hdl4fpga.ddr_wr_fifo
	port map (
		sys_clk => clk0,
		sys_di  => sys_di,
		sys_req => ddr_wr_fifo_req,
		sys_rst => ddr_wr_fifo_rst,
		ddr_ena_p => ddr_wr_fifo_ena_n, 
		ddr_ena_n => ddr_wr_fifo_ena_p, 
		ddr_clk_p => clk270,
		ddr_clk_n => clk90,
		ddr_do  => ddr_wr_fifo_do);
		
	ddr_io_du : entity hdl4fpga.ddr_io_dq
	generic map (
		data_bytes => data_bytes,
		byte_bits  => byte_bits)
	port map (
		ddr_io_clk => clk90,
		ddr_io_dql => ddr_dql,
		ddr_io_dqh => ddr_dqh,
		ddr_io_dqz => ddr_acc_dqz,
		ddr_io_dq  => ddr_dq,
		ddr_io_dqi => ddr_io_dqi);

	ddr_io_dqs_e : entity hdl4fpga.ddr_io_dqs
	generic map (
		data_bytes => 2)
	port map (
		ddr_io_clk => clk0,
		ddr_io_ena => ddr_acc_dqs,
		ddr_io_dqz => ddr_acc_dqsz,
		ddr_io_dqs => ddr_dqs,
		ddr_io_dso => ddr_io_dso);
	
	lp_dqs : block
		constant cas : std_logic_vector(0 to 2) := casdb(cl, std);
		signal rclk : std_logic;
		signal fclk : std_logic;
	begin
		rclk <= 
		   clk0 when cas(0)='0' else
		   clk180;
			
		fclk <= 
		   clk180 when cas(0)='0' else
		   clk0;

		oddr_du : fddrrse
		port map (
			c0 => rclk,
			c1 => fclk,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => ddr_acc_drr,
			d1 => ddr_acc_drf,
			q  => ddr_lp_dqs);
	end block;

--	ddr_io_dm_e : entity hdl4fpga.ddr_io_dm
--	generic map (
--		n => 2)
--	port map (
--		ddr_io_clk => clk90,
--		ddr_io_drw => ddr_acc_drw,
--		ddr_io_dml => "00",
--		ddr_io_dmh => "00",
--		ddr_io_dm  => open); ---ddr_dm);
		ddr_dm <= (others => '0');
end;
