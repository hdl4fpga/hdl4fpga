library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.jso.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;

architecture scopeio of nuhs3adsp is

	constant io_link    : io_comms := io_ipoe;
	constant sys_per  : real := 50.0;
	signal sys_clk    : std_logic;
	signal vga_clk    : std_logic;
	signal vga_hsync  : std_logic;
	signal vga_vsync  : std_logic;
	signal vga_rgb    : std_logic_vector(0 to 3*8-1);
	signal vga_blank  : std_logic;

	constant inputs : natural := 2;
	alias  input_sample is adc_da;
	signal samples_doa : std_logic_vector(input_sample'length-1 downto 0);
	signal samples_dib : std_logic_vector(input_sample'length-1 downto 0);
	signal samples     : std_logic_vector(inputs*input_sample'length-1 downto 0);
	signal adc_clk     : std_logic;

	signal input_clk : std_logic;

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
		mode480p,
		mode600p, 
		mode600px16,
		mode1080p);

	type displayparam_vector is array (display_modes) of display_param;
	constant display_tab : displayparam_vector := (
		mode480p    => (timing_id => pclk25_00m640x480at60,    dcm_mul => 5, dcm_div => 4),
		mode600p    => (timing_id => pclk40_00m800x600at60,    dcm_mul => 2, dcm_div => 1),
		mode600px16 => (timing_id => pclk40_00m800x600at60,    dcm_mul => 2, dcm_div => 1),
		mode1080p   => (timing_id => pclk140_00m1920x1080at60, dcm_mul => 7, dcm_div => 1));

	constant video_mode : display_modes := mode1080p;

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
	input_clk <= not adc_clk;

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
		clkfx    => vga_clk);

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
		variable ff : std_logic_vector(samples'range);
	begin
		if rising_edge(input_clk) then
			samples <= ff;
			ff     := (input_sample xor (1 => '1', 2 to input_sample'length => '0')) & (adc_db xor (1 => '1', 2 to adc_db'length => '0'));
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

	ipoe_e : if io_link=io_ipoe generate
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
				check_dov  => true,
				gray_code  => false)
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

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		videotiming_id   => display_tab(video_mode).timing_id,
        layout           =>
            "{                             " &   
            "   inputs  :                  " & natural'image(inputs) & ',' &
            "   num_of_segments : 3,       " &
            "   display : {                " &
            "       width  : 1920,         " &
            "       height : 1080},        " &
            "   grid : {                   " &
            "       unit   : 32,           " &
            "       width  :               " & natural'image(50*32+1) & ',' &
            "       height :               " & natural'image( 8*32+1) & ',' &
            "       color  : 0xff_ff_00_00, " &
            "       background-color : 0xff_00_00_00}," &
            "   axis : {                   " &
            "       fontsize   : 8,        " &
            "       horizontal : {         " &
            "           unit   : 250.0e-9, " &
            "           height : 8,        " &
            "           inside : false,    " &
            "           color  : 0xff_ff_ff_ff," &
            "           background-color : 0xff_00_00_ff}," &
            "       vertical : {           " &
            "           unit   : 2.0e-3, " &
            "           width  :           " & natural'image(6*8) & ','  &
            "           rotate : ccw0,     " &
            "           inside : false,    " &
            "           color  : 0xff_ff_ff_ff," &
            "           background-color : 0xff_00_00_ff}}," &
            "   textbox : {                " &
            "       font_width :  8,       " &
            "       width      :           " & natural'image(33*8) & ','&
            "       inside     : false,    " &
            "       color      : 0xff_ff_ff_ff," &
            "       background-color : 0xff_00_00_00}," &
            "   main : {                   " &
            "       top        :  5,       " & 
            "       left       :  1,       " & 
            "       right      :  0,       " & 
            "       bottom     :  0,       " & 
            "       horizontal :  1,       " &
            "       vertical   :  1,       " & 
            "       background-color : 0xff_00_00_00}," &
            "   segment : {                " &
            "       top        : 1,        " &
            "       left       : 1,        " &
            "       right      : 1,        " &
            "       bottom     : 1,        " &
            "       horizontal : 1,        " &
            "       vertical   : 0,        " &
            "       background-color : 0xff_00_00_00}," &
            "  vt : [                      " &
            "   { label : channel1,        " &
            "     step  : '" & real'image(1.0/2.0**14) & "'," &
            "     color : 0xff_ff_ff_00},  " & -- vt(6)
            "   { label : channel2,          " &
            "     step  : '" & real'image(1.0/2.0**14) & "'," &
            "     color : 0xff_00_ff_ff}]}")   -- vt(7)
	port map (
		sio_clk     => sio_clk,
		si_frm      => si_frm,
		si_irdy     => si_irdy,
		si_data     => si_data,
		so_data     => so_data,
		input_clk   => input_clk,
		input_data  => samples,
		video_clk   => vga_clk,
		video_pixel => vga_rgb,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_blank => vga_blank);

	process (vga_clk)
		variable vga_rgb1   : std_logic_vector(vga_rgb'range);
		variable vga_hsync1 : std_logic;
		variable vga_vsync1 : std_logic;
		variable vga_blank1 : std_logic;
	begin
		if rising_edge(vga_clk) then
			red        <= multiplex(vga_rgb1, std_logic_vector(to_unsigned(0,2)), 8);
			green      <= multiplex(vga_rgb1, std_logic_vector(to_unsigned(1,2)), 8);
			blue       <= multiplex(vga_rgb1, std_logic_vector(to_unsigned(2,2)), 8);
			blankn     <= not vga_blank1;
			hsync      <= vga_hsync1;
			vsync      <= vga_vsync1;
			sync       <= not vga_hsync1 and not vga_vsync1;
			vga_rgb1   := vga_rgb;
            vga_hsync1 := vga_hsync;
            vga_vsync1 := vga_vsync;
            vga_blank1 := vga_blank;
		end if;
	end process;
	psave <= '1';

	adcclkab_e : oddr
	generic map (
		ddr_clk_edge => "SAME_EDGE")
	port map (
		c  => clk,
		ce => '1',
		d1 => '1',
		d2 => '0',
		q  => adc_clkab);

	videodac_i: oddr
	generic map (
		ddr_clk_edge => "SAME_EDGE")
	port map (
		c   => vga_clk,
		ce  => '1',
		d1  => '0',
		d2  => '1',
		q   => clk_videodac);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
--	led18 <= '0';
	led16 <= '0';
	led15 <= '0';
	led13 <= '0';
	led11 <= '0';
	led9  <= '0';
	led8  <= '0';

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
