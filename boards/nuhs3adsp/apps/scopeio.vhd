library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.hdo.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

architecture scopeio of nuhs3adsp is

	constant io_link  : io_comms := io_ipoe;
	constant sys_per  : real := 50.0;

	signal sys_clk    : std_logic;
	signal sysclk_n   : std_logic;
	signal video_clk    : std_logic;
	signal videoclk_n   : std_logic;
	signal video_hsync  : std_logic;
	signal video_vsync  : std_logic;
	signal video_vton    : std_logic;
	signal video_pixel    : std_logic_vector(0 to 3*8-1);
	signal video_blank  : std_logic;

	constant inputs : natural := 2;
	constant vt_step   : string := "1.220703125e-4"; --2.0V/2.0**14; -- real'image() does not work on Xilinx ISE
	alias  input_sample is adc_da;
	signal samples_doa : std_logic_vector(input_sample'length-1 downto 0);
	signal samples_dib : std_logic_vector(input_sample'length-1 downto 0);
	signal input_samples     : std_logic_vector(inputs*input_sample'length-1 downto 0);
	signal adc_clk     : std_logic;
	signal adcclk_n    : std_logic;

	signal input_clk   : std_logic;

	constant baudrate : natural := 115200;

	signal uart_rxc  : std_logic;
	signal uart_sin  : std_logic;
	signal uart_ena  : std_logic;
	signal uart_rxdv : std_logic;
	signal uart_rxd  : std_logic_vector(8-1 downto 0);

	alias  sio_clk   is mii_txc;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(mii_rxd'range);

	signal so_frm    : std_logic;
	signal so_irdy   : std_logic;
	signal so_trdy   : std_logic;
	signal so_end    : std_logic;
	signal so_data   : std_logic_vector(mii_txd'range);

	type display_param is record
		timing_id : videotiming_ids;
		dcm_mul   : natural;
		dcm_div   : natural;
	end record;

	type display_modes is (
		mode1080p);

	type displayparam_vector is array (display_modes) of display_param;
	constant display_tab : displayparam_vector := (
		mode1080p   => (timing_id => pclk150_00m1920x1080at60, dcm_mul => 15, dcm_div => 2));

	constant video_mode : display_modes := mode1080p;

	constant layout : string := compact(
			"{                             " &   
			"   inputs          : " & natural'image(inputs) & ',' &
			"   max_delay       : " & natural'image(2**14)  & ',' &
			"   min_storage     : 256,     " & -- samples, storage size will be equal or larger than this
			"   num_of_segments :   4,     " &
			"   display : {                " &
			"       width  : 1920,         " &
			"       height : 1080},        " &
			"   grid : {                   " &
			"       unit   : 32,           " &
			"       width  : " & natural'image(50*32+1) & ',' &
			"       height : " & natural'image( 8*32+1) & ',' &
			"       color  : 0xff_ff_00_ff, " &
			"       background-color : 0xff_00_00_00}," &
			"   axis : {                   " &
			"       fontsize   : 8,        " &
			"       horizontal : {         " &
			"           unit   : 250.0e-9, " &
			"           height : 8,        " &
			"           inside : false,    " &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}," &
			"       vertical : {           " &
			"           unit   : 5.0e-3, " &
			"           width  : " & natural'image(6*8) & ','  &
			"           rotate : ccw0,     " &
			"           inside : false,    " &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}}," &
			"   textbox : {                " &
			"       font_width : 8,        " &
			"       width      : " & natural'image(33*8) & ','&
			"       inside     : false,    " &
			"       color      : 0xff_ff_00_ff," &
			"       background-color : 0xff_00_00_00}," &
			"   main : {                   " &
			"       top        :  5,       " & 
			"       left       :  2,       " & 
			"       right      :  0,       " & 
			"       bottom     :  0,       " & 
			"       vertical   :  1,       " & 
			"       horizontal :  1,       " &
			"       background-color : 0xff_00_00_00}," &
			"   segment : {                " &
			"       top        : 1,        " &
			"       left       : 1,        " &
			"       right      : 1,        " &
			"       bottom     : 1,        " &
			"       vertical   : 0,        " &
			"       horizontal : 1,        " &
			"       background-color : 0xff_ff_ff_ff}," &
			"  vt : [                      " &
			"   { text  : J3,        " &
			"     step  : " & vt_step & ","  &
			"     color : 0xff_00_ff_ff},  " &
			"   { text  : J4,        " &
			"     step  : " & vt_step & ","  &
			"     color : 0xff_ff_ff_ff}]}");

	constant sdram : string := compact(
		"{" &
		"   gear      : 2," &
		"   bank_size : " & natural'image(ddr_ba'length) & "," &
		"   addr_size : " & natural'image(ddr_a'length)  & "," &
		"   coln_size : 9," &
		"   word_size : " & natural'image(ddr_dq'length)  & "," &
		"   byte_size : " & natural'image(ddr_dq'length/ddr_dm'length) & "," &
		"}");

	type dcm_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type sdramparams_record is record
		id  : sdram_speeds;
		dcm : dcm_params;
		cl  : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram133MHz, dcm => (dcm_mul => 20, dcm_div => 3), cl => "010"),
		(id => sdram145MHz, dcm => (dcm_mul => 29, dcm_div => 4), cl => "110"),
		(id => sdram150MHz, dcm => (dcm_mul => 15, dcm_div => 2), cl => "110"),
		(id => sdram166MHz, dcm => (dcm_mul => 25, dcm_div => 3), cl => "110"),
		(id => sdram200MHz, dcm => (dcm_mul => 10, dcm_div => 1), cl => "011"));

	function sdramparams (
		constant id  : sdram_speeds)
		return sdramparams_record is
		constant tab : sdramparams_vector := sdram_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>sdramparams<<< : sdram speed not enabled"
		severity failure;

		return tab(tab'left);
	end;

	constant sdram_speed  : sdram_speeds := sdram166MHz;
	constant sdram_params : sdramparams_record := sdramparams(sdram_speed);
	constant sdram_tcp    : real := real(sdram_params.dcm.dcm_div)*clk_per/real(sdram_params.dcm.dcm_mul);


	constant gear         : natural := hdo(sdram)**".gear";
	constant bank_size    : natural := hdo(sdram)**".bank_size";
	constant addr_size    : natural := hdo(sdram)**".addr_size";
	constant coln_size    : natural := hdo(sdram)**".coln_size";
	constant word_size    : natural := hdo(sdram)**".word_size";
	constant byte_size    : natural := hdo(sdram)**".byte_size";

	signal ctlr_clk      : std_logic;
	signal sdrsys_rst    : std_logic;

	signal ctlrphy_rst    : std_logic;
	signal ctlrphy_cke    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_cs     : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_ras    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_cas    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_we     : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_odt    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_b      : std_logic_vector((gear+1)/2*ddr_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector((gear+1)/2*ddr_a'length-1 downto 0);
	signal ctlrphy_dqst   : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dqsi   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqso   : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dmi    : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo    : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqt    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dqi    : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqo    : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqv    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_sto    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_sti    : std_logic_vector(gear*word_size/byte_size-1 downto 0);

	signal ctlrphy_wlreq  : std_logic;
	signal ctlrphy_wlrdy  : std_logic;
	signal ctlrphy_rlreq  : std_logic;
	signal ctlrphy_rlrdy  : std_logic;

	signal ddr_clk0       : std_logic;
	signal ddr_clk90      : std_logic;
	signal ddr_clk       : std_logic_vector(0 downto 0);
	signal ddr_odt       : std_logic_vector(0 to 0);
	signal sdram_cke     : std_logic_vector(0 to 0);
	signal sdram_cs      : std_logic_vector(0 to 0);
	signal ddr_lp_ck     : std_logic;
	signal st_dqs_open   : std_logic;

begin

	clkin_ibufg : ibufg
	port map (
		I => clk,
		O => sys_clk);

	adcdfs_i : dcm_sp
	generic map(
		clk_feedback  => "NONE",
		clkin_period  => sys_per*1.0e9,
		clkdv_divide  => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => 32,
		clkfx_divide  => 5,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',

		rst      => '0',
		clkin    => sys_clk,
		clkfb    => '0',
		clkfx    => adc_clk);
	adcclk_n  <= not adc_clk;
	input_clk <= not adc_clkout;

	videodfs_i : dcm_sp
	generic map(
		clk_feedback  => "NONE",
		clkin_period  => sys_per*1.0e9,
		clkdv_divide  => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => display_tab(video_mode).dcm_mul,
		clkfx_divide  => display_tab(video_mode).dcm_div,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',

		rst      => '0',
		clkin    => sys_clk,
		clkfb    => '0',
		clkfx    => video_clk);

	miidfs_e : dcm_sp
	generic map(
		clk_feedback  => "NONE",
		clkin_period  => sys_per*1.0e9,
		clkdv_divide  => 2.0,
		clkin_divide_by_2 => FALSE,
		clkfx_multiply => 5,
		clkfx_divide  => 4,
		clkout_phase_shift => "NONE",
		deskew_adjust => "SYSTEM_SYNCHRONOUS",
		dfs_frequency_mode => "HIGH",
		duty_cycle_correction => TRUE,
		factory_jf   => X"C080",
		phase_shift  => 0,
		startup_wait => FALSE)
	port map (
		dssen    => '0',
		psclk    => '0',
		psen     => '0',
		psincdec => '0',

		rst      => '0',
		clkin    => sys_clk,
		clkfb    => '0',
		clkfx    => mii_refclk);

	process (input_clk)
		variable adc_dab : std_logic_vector(input_samples'range);
	begin
		if rising_edge(input_clk) then
			input_samples <= adc_dab xor ((1 => '1', 2 to input_sample'length => '0') & ((1 => '1', 2 to adc_db'length => '0')));
			-- input_samples <= std_logic_vector(to_signed(2**13-1, input_sample'length) & to_signed(2**13, input_sample'length));
			adc_dab := adc_da & adc_db;
		end if;
	end process;

	process (mii_rxc)
		constant max_count : natural := (25*10**6+16*baudrate/2)/(16*baudrate);
		variable cntr      : unsigned(0 to unsigned_num_bits(max_count-1)-1) := (others => '0');
	begin
		if rising_edge(mii_rxc) then
			if cntr >= max_count-1 then
				uart_ena <= '1';
				cntr := (others => '0');
			else
				uart_ena <= '0';
				cntr := cntr + 1;
			end if;
		end if;
	end process;

	uart_sin <= rs232_rd;
	uart_rxc <= mii_rxc;

	ipoe_b : if io_link=io_ipoe generate
		alias  mii_clk    is mii_txc;
		signal txen       : std_logic;
		signal txd        : std_logic_vector(mii_txd'range);
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		dhcp_p : process(mii_clk)
			type states is (s_request, s_wait);
			variable state : states;
		begin
			if rising_edge(mii_clk) then
				case state is
				when s_request =>
					if sw1='0' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if sw1='1' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					rxc_rxbus <= mii_rxdv & mii_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true)
			port map (
				src_clk  => mii_rxc,
				src_data => rxc_rxbus,
				dst_clk  => mii_clk,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (mii_clk)
			begin
				if rising_edge(mii_clk) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_rxd'length);
				end if;
			end process;
		end block;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => debug,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			mii_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => miirx_irdy,
			miirx_trdy => open,
			miirx_data => miirx_data,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data,

			si_frm     => so_frm,
			si_irdy    => so_irdy,
			si_trdy    => so_trdy,
			si_end     => so_end,
			si_data    => so_data,

			so_clk     => sio_clk,
			so_frm     => si_frm,
			so_irdy    => si_irdy,
			so_data    => si_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => mii_clk,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => txd);

		txen <= miitx_frm and not miitx_end;
		process (mii_clk)
		begin
			if rising_edge(mii_clk) then
				mii_txen <= txen;
				mii_txd  <= txd;
			end if;
		end process;

	end generate;

	scopeio_e : entity hdl4fpga.scopeiosdr
	generic map (
		debug => debug,
		profile   => 0,
		sdram_tcp => sdram_tcp,
		mark      => MT48LC256MA27E ,
		timing_id => pclk150_00m1920x1080at60,
		sdram     => sdram,
		layout    => layout)
	port map (
		-- tp => tp,
		sio_clk     => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_frm      => so_frm,
		so_irdy     => so_irdy,
		so_trdy     => so_trdy,
		so_end      => so_end,
		so_data     => so_data,
		input_clk   => input_clk,
		input_data  => input_samples,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => sdrsys_rst,
		ctlr_bl      => "001",
		ctlr_cl      => sdram_params.cl,

		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => video_hsync,
		video_vsync => video_vsync,
		video_vton  => video_vton,
		video_blank => video_blank);

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	ctlrphy_rlreq <= to_stdulogic(to_bit(ctlrphy_rlrdy));

	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		-- dqs_delay   => (0 to 0 => 0 ns),
		-- dqi_delay   => (0 to 0 => 0 ns),
		device      => xc3s,
		bank_size   => ddr_ba'length,
		addr_size   => ddr_a'length,
		gear        => gear,
		word_size   => word_size,
		byte_size   => byte_size,
		bypass      => true,
		loopback    => true,
		rd_fifo     => true,
		rd_align    => true)
	port map (
		rst         => sdrsys_rst,
		iod_clk     => ddr_clk0,
		clk         => ddr_clk0,
		clk_shift   => ddr_clk90,

		phy_wlreq   => ctlrphy_wlreq,
		phy_wlrdy   => ctlrphy_wlrdy,
		phy_rlreq   => ctlrphy_rlreq,
		phy_rlrdy   => ctlrphy_rlrdy,
		sys_cke     => ctlrphy_cke,
		sys_cs      => ctlrphy_cs,
		sys_ras     => ctlrphy_ras,
		sys_cas     => ctlrphy_cas,
		sys_we      => ctlrphy_we,
		sys_b       => ctlrphy_b,
		sys_a       => ctlrphy_a,
		sys_dqsi    => ctlrphy_dqso,
		sys_dqst    => ctlrphy_dqst,
		sys_dqso    => ctlrphy_dqsi,
		sys_dmi     => ctlrphy_dmo,
		sys_dmo     => ctlrphy_dmi,
		sys_dqi     => ctlrphy_dqo,
		sys_dqt     => ctlrphy_dqt,
		sys_dqo     => ctlrphy_dqi,
		sys_odt     => ctlrphy_odt,
		sys_dqv     => ctlrphy_dqv,
		sys_sti     => ctlrphy_sto,
		sys_sto     => ctlrphy_sti,

		sdram_sto(0)  => ddr_st_dqs,
		sdram_sto(1)  => st_dqs_open,
		sdram_sti(0)  => ddr_st_lp_dqs,
		sdram_sti(1)  => ddr_st_lp_dqs,
		sdram_clk     => ddr_clk,
		sdram_cke     => sdram_cke,
		sdram_cs      => sdram_cs,
		sdram_odt     => ddr_odt,
		sdram_ras     => ddr_ras,
		sdram_cas     => ddr_cas,
		sdram_we      => ddr_we,
		sdram_b       => ddr_ba,
		sdram_a       => ddr_a,

		sdram_dm      => ddr_dm,
		sdram_dq      => ddr_dq,
		sdram_dqs     => ddr_dqs);

	process (video_clk)
		variable video_rgb1   : std_logic_vector(video_pixel'range);
		variable video_hsync1 : std_logic;
		variable video_vsync1 : std_logic;
		variable video_blank1 : std_logic;
	begin
		if rising_edge(video_clk) then
			red        <= multiplex(video_rgb1, std_logic_vector(to_unsigned(0,2)), 8);
			green      <= multiplex(video_rgb1, std_logic_vector(to_unsigned(1,2)), 8);
			blue       <= multiplex(video_rgb1, std_logic_vector(to_unsigned(2,2)), 8);
			blankn     <= not video_blank1;
			hsync      <= video_hsync1;
			vsync      <= video_vsync1;
			sync       <= not video_hsync1 and not video_vsync1;
			video_rgb1   := video_pixel;
			video_hsync1 := video_hsync;
			video_vsync1 := video_vsync;
			video_blank1 := video_blank;
		end if;
	end process;
	psave <= '1';

	adcclkab_e : oddr2
	port map (
		c0 => adc_clk,
		c1 => adcclk_n,
		ce => '1',
		d0 => '1',
		d1 => '0',
		q  => adc_clkab);

	videoclk_n <= not video_clk;
	videodac_i: oddr2
	port map (
		c0   => video_clk,
		c1  => videoclk_n,
		ce  => '1',
		d0  => '0',
		d1  => '1',
		q   => clk_videodac);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';
	led7  <= '0';

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_rstn <= '1';
	mii_mdc  <= '0';
	mii_mdio <= 'Z';
	-- mii_txen <= '0';
	-- mii_txd  <= (others => '0');

	-- LCD --
	---------

	lcd_e    <= 'Z';
	lcd_rs   <= 'Z';
	lcd_rw   <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR --
	---------

	ddr_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => 'Z',
		o  => ddr_ckp,
		ob => ddr_ckn);


	ddr_st_dqs <= 'Z';
	ddr_cke    <= 'Z';
	ddr_cs     <= 'Z';
	ddr_ras    <= 'Z';
	ddr_cas    <= 'Z';
	ddr_we     <= 'Z';
	ddr_ba     <= (others => 'Z');
	ddr_a      <= (others => 'Z');
	ddr_dm     <= (others => 'Z');
	ddr_dqs    <= (others => 'Z');
	ddr_dq     <= (others => 'Z');

end;
