library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity xdr_cfg is
	generic (
		strobe : string := "EXTERNAL";
		std  : positive range 1 to 3 := 3;

		tCP  : real := 6.0;
		tWR  : real := 15.0;
		tRP  : real := 15.0;
		tRCD : real := 15.0;
		tRFC : real := 72.0;
		tMRD : real := 12.0;
		tREFI : real := 7.0e3;

		cl  : real    := 7.0;
		bl  : natural := 8;
		wr  : natural := 8;
		cwl : natural := 7;

		bank_bits  : natural :=  2;
		addr_bits  : natural := 13;
		data_phases : natural := 1;
		data_bytes : natural :=  2;
		byte_bits  : natural :=  8);
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
		sys_di  : in  std_logic_vector(2*data_bytes*byte_bits-1 downto 0);
		sys_do  : out std_logic_vector(2*data_bytes*byte_bits-1 downto 0);
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
		xdr_dqsi : in std_logic_vector(data_bytes-1 downto 0);
		xdr_dqso : out std_logic_vector(data_bytes-1 downto 0);
		xdr_dqz : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		xdr_dqi : in std_logic_vector(data_bytes*byte_bits-1 downto 0);
		xdr_dqo : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
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
	subtype byte is std_logic_vector(0 to byte_bits-1);
	type byte_vector is array (natural range <>) of byte;

	signal xdr_init_rdy : std_logic;
	signal xdr_init_ras : std_logic;
	signal xdr_init_cas : std_logic;
	signal xdr_init_we  : std_logic;
	signal xdr_init_a   : std_logic_vector(addr_bits-1 downto 0);
	signal xdr_init_b   : std_logic_vector(bank_bits-1 downto 0);
	signal xdr_init_cke : std_logic;
	signal xdr_init_cfg : std_logic;
	signal xdr_init_dll : std_logic;

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
	constant cas : std_logic_vector(0 to 2) := casdb(cl, std); 
begin

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
		xdr_init_rst  => xdr_rst,
		xdr_init_cke  => xdr_init_cke,
		xdr_init_cfg  => xdr_init_cfg,
		dll_timer_req => xdr_init_dll,
		dll_timer_rdy => dll_timer_rdy,
		ref_timer_req => xdr_init_rdy,
		ref_timer_rdy => xdr_mpu_ref);

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
	ddr1_init_g : if std=1 generate
		xdr_init_du : entity hdl4fpga.xdr_init(ddr1)
		generic map (
			a    => addr_bits,
			tRP  => natural(ceil(tRP/tCp)),
			tMRD => natural(ceil(tMRD/tCp)),
			tRFC => natural(ceil(tRFC/tCp)))
		port map (
			xdr_init_cl  => casdb (cl, std),
			xdr_init_bl  => bldb  (bl, std),

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

	process (sys_clk)
		variable q : std_logic;
	begin
		if rising_edge(sys_clk) then
--			xdr_mpu_rst <= not (xdr_init_rdy and dll_timer_rdy);
			xdr_mpu_rst <= q;
			q := not (xdr_init_rdy and dll_timer_rdy);
			sys_ini     <= xdr_init_rdy and dll_timer_rdy;
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
		byte_bits  => byte_bits)
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
		byte_bits  => byte_bits)
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
		byte_bits  => byte_bits)
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
