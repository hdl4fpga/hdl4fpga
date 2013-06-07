library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

architecture scope of nuhs3dsp is
	constant bank_size : natural := 2;
	constant addr_size : natural := 13;
	constant col_size  : natural := 6;
	constant data_size : natural := 16;

	signal sys_rst : std_logic;

	signal vga_hsync : std_logic;
	signal vga_vsync : std_logic;
	signal vga_blank : std_logic;
	signal vga_red   : std_logic_vector(red'range);
	signal vga_green : std_logic_vector(green'range);
	signal vga_blue  : std_logic_vector(blue'range);

	signal video_clk  : std_logic;
	signal video_don : std_logic;
	signal video_frm : std_logic;
	signal video_ena : std_logic;
	signal video_hsync : std_logic;
	signal video_vsync : std_logic;
	signal video_blank : std_logic;

	signal cga_clk : std_logic;
	signal vga_row : std_logic_vector(9-1 downto 0);
	signal cga_row : std_logic_vector(9-1 downto 4);
	signal cga_col : std_logic_vector(4-1 downto 0);
	signal cga_ptr : std_logic_vector(9-1 downto 0);
	signal cga_we  : std_logic;
	signal cga_dot : std_logic;
	signal cga_don : std_logic;
	signal cga_code : byte;

	signal video_red   : std_logic_vector(red'range);
	signal video_green : std_logic_vector(green'range);
	signal video_blue  : std_logic_vector(blue'range);

	signal ddrs_clk0   : std_logic;
	signal ddrs_clk90  : std_logic;
	signal ddrs_clk180 : std_logic;

	signal ddr_lp_clk : std_logic;

	signal ddrs_ini : std_logic;
	signal ddrs_ref_req : std_logic;
	signal ddrs_cmd_req : std_logic;
	signal ddrs_cmd_rdy : std_logic;
	signal ddrs_ba : std_logic_vector(0 to 2-1);
	signal ddrs_a  : std_logic_vector(0 to 13-1);
	signal ddrs_act : std_logic;
	signal ddrs_cas : std_logic;
	signal ddrs_pre : std_logic;
	signal ddrs_rw  : std_logic;

	signal ddrs_di_rdy : std_logic;
	signal ddrs_di : std_logic_vector(0 to 32-1);
	signal ddrs_do_rdy : std_logic;
	signal ddrs_do : std_logic_vector(0 to 32-1);

	signal dataio_rst : std_logic;
	signal input_rdy : std_logic;
	signal input_req : std_logic := '0';
	signal input_dat : std_logic_vector(0 to 15);
	signal input_clk : std_logic;
	
	signal win_rowid  : std_logic_vector(2-1 downto 0);
	signal win_rowpag : std_logic_vector(5-1 downto 0);
    signal win_rowoff : std_logic_vector(7-1 downto 0);
    signal win_colid  : std_logic_vector(2-1 downto 0);
    signal win_colpag : std_logic_vector(2-1 downto 0);
    signal win_coloff : std_logic_vector(13-1 downto 0);

    signal chann_dat : std_logic_vector(32-1 downto 0);

	signal grid_dot : std_logic;
	signal plot_dot : std_logic_vector(0 to 2-1);

	signal miitx_req  : std_logic;
	signal miitx_rdy  : std_logic;
	signal miitx_addr : std_logic_vector(8-1 downto 0);
	signal miitx_data : std_logic_vector(2*data_size-1 downto 0);

	signal trdy : std_logic := '0';
	signal treq : std_logic := '0';
	signal txen : std_logic;
	signal txd  : nibble;
	signal rxdv : std_logic;
	signal rxd  : nibble;
	signal rpkt : std_logic;
	signal pkt_cntr : std_logic_vector(15 downto 0) := x"0000";
	signal tpkt_cntr : byte := x"00";
	signal a0 : std_logic;
	signal tp : nibble_vector(7 downto 0) := (others => "0000");

	impure function cas_code (
		tCLK : real;
		multiply : natural;
		divide   : natural)
		return std_logic_vector is
		constant tDDR : real := (real(divide)*tCLK)/(real(multiply));
	begin

		if tDDR < 6.0 then
			return "011";
		elsif tDDR < 7.5 then
			return "110";
		else 
			return "010";
		end if;
	end;

	-------------------------------------------------------------------------
	-- Frequency   -- 133 Mhz -- 166 Mhz -- 180 Mhz -- 193 Mhz -- 200 Mhz  --
	-- Multiply by --  20     --  25     --   9     --  29     --  10      --
	-- Divide by   --   3     --   3     --   1     --   3     --   1      --
	-------------------------------------------------------------------------

	constant ddr_multiply : natural := 25;
	constant ddr_divide   : natural := 3;
	constant cas : std_logic_vector(0 to 2) := cas_code(
		tCLK => 50.0,
		multiply => ddr_multiply,
		divide   => ddr_divide);
begin

	input_clk <= adc_clkout;
	process (input_clk)
		variable sample : signed(adc_db'range);
	begin
		if falling_edge(input_clk) then
			input_dat <= std_logic_vector(resize(sample, input_dat'length));
			if ddrs_ini='0' then
				input_req <= '0';
			elsif input_rdy='0' then
				input_req <= '1';
			end if;
			sample := signed(adc_db);
			sample(sample'left) := not sample(sample'left);
--			sample := shift_right(sample, 6);
		end if;
	end process;

--	process (input_clk)
--		constant n : natural := 15;
--		variable r : unsigned(0 to n);
--	begin
--		if rising_edge(input_clk) then
--			input_dat <= std_logic_vector(resize(signed(r(0 to n)), input_dat'length));
--			r := r + 1;
--			if ddrs_ini='0' then
--				input_req <= '0';
--				r := to_unsigned(61, r'length);
--			elsif input_rdy='0' then
--				input_req <= '1';
--			end if;
--		end if;
--	end process;

	video_vga_e : entity hdl4fpga.video_vga
	generic map (
		n => 12)
	port map (
		clk   => video_clk,
		hsync => video_hsync,
		vsync => video_vsync,
		frm   => video_frm,
		don   => video_don);
	video_blank <= video_don and video_frm;
		
	win_stym_e : entity hdl4fpga.win_sytm
	port map (
		win_clk => video_clk,
		win_frm => video_frm,
		win_don => video_don,
		win_rowid  => win_rowid ,
		win_rowpag => win_rowpag,
		win_rowoff => win_rowoff,
		win_colid  => win_colid,
		win_colpag => win_colpag,
		win_coloff => win_coloff);

	win_ena_b : block
		signal scope_win : std_logic;
		signal cga_win : std_logic;
		signal grid_don : std_logic;
		signal plot_dot1 : std_logic_vector(plot_dot'range);
		signal grid_dot1 : std_logic;
		signal plot_start  : std_logic;
		signal plot_end  : std_logic;
	begin
		scope_win <= setif(win_rowid&win_colid = "1111");
		cga_win   <= cga_dot and setif(win_rowid&win_colid="1101");

		align_e : entity hdl4fpga.align
		generic map (
			n => 10,
			d => (
				0 to 2 => 4+10,		-- hsync, vsync, blank
				3 to 3 => 2+10,		-- scope_win -> plot_end
				4 to 5 => 1,		-- plot
				6 to 6 => 1+10,		-- grid
			    7 to 7 => 1,		-- plot_end -> grid_don
			    8 to 8 => 3,		-- grid_don -> plot_start
			    9 to 9 => 3))		-- cga_dot -> cga_dot
		port map (
			clk   => video_clk,

			di(0) => video_hsync,
			di(1) => video_vsync,
			di(2) => video_blank,

			di(3) => scope_win,

			di(4) => plot_dot(0),
			di(5) => plot_dot(1),
			di(6) => grid_dot,
			di(7) => plot_end,
			di(8) => grid_don,
			di(9) => cga_win,

			do(0) => vga_hsync,
			do(1) => vga_vsync,
			do(2) => vga_blank,

			do(3) => plot_end,

			do(4) => plot_dot1(0),
			do(5) => plot_dot1(1),
			do(6) => grid_dot1,
			do(7) => grid_don,
			do(8) => plot_start,
			do(9) => cga_don);

		vga_red   <= (others => (plot_start and plot_end and plot_dot1(1)) or cga_don);
		vga_green <= (others => (plot_start and plot_end and plot_dot1(0)) or cga_don);
		vga_blue  <= (others => (grid_don and grid_dot1) or cga_don);
		
	end block;

	vga_iob_e : entity hdl4fpga.vga_iob
	port map (
		sys_clk   => video_clk,
		sys_hsync => vga_hsync,
		sys_vsync => vga_vsync,
		sys_sync  => '1',
		sys_psave => '1',
		sys_blank => vga_blank,
		sys_red   => vga_red,
		sys_green => vga_green,
		sys_blue  => vga_blue,

		vga_clk => clk_videodac,
		vga_hsync => hsync,
		vga_vsync => vsync,
		dac_blank => blank,
		dac_sync  => sync,
		dac_psave => psave,

		dac_red   => red,
		dac_green => green,
		dac_blue  => blue);

	video_ena <= setif(win_rowid="11");

	dataio_rst <= not ddrs_ini;
	dataio_e : entity hdl4fpga.dataio 
	generic map (
		bank_size => bank_size,
		addr_size => addr_size,
		col_size  => col_size, 
		data_size => data_size)
	port map (
		sys_rst   => dataio_rst,

		input_req => input_req,
		input_rdy => input_rdy,
		input_clk => input_clk,
		input_dat => input_dat,

		video_clk => video_clk,
		video_ena => video_ena,
		video_row => win_rowpag(3 downto 0),
		video_col => win_coloff,
		video_do  => chann_dat,

		ddrs_clk => ddrs_clk0,
		ddrs_ref_req => ddrs_ref_req,
		ddrs_cmd_req => ddrs_cmd_req,
		ddrs_cmd_rdy => ddrs_cmd_rdy,
		ddrs_ba => ddrs_ba,
		ddrs_a  => ddrs_a,
		ddrs_rw  => ddrs_rw,
		ddrs_act => ddrs_act,
		ddrs_cas => ddrs_cas,
		ddrs_pre => ddrs_pre,

		ddrs_di_rdy => ddrs_di_rdy,
		ddrs_di => ddrs_di,
		ddrs_do_rdy => ddrs_do_rdy,
		ddrs_do => ddrs_do,
		tp => tp(6 downto 0),

		mii_txc => mii_txc,
		mii_a0 => a0,
		miitx_req => miitx_req,
		miitx_rdy => miitx_rdy,
		miitx_addr => miitx_addr,
		miitx_data => miitx_data);

	process (ddrs_clk0)
		variable trdy_edge : std_logic_vector(0 to 1);
	begin
		if rising_edge(ddrs_clk0) then
			mii_rst   <= ddrs_ini; 
--			if input_rdy='0' then
--				miitx_rdy <= '0';
--			els
			if miitx_rdy/='0' then
				miitx_rdy <= not miitx_req;
			elsif trdy='1' then
				if trdy_edge(0)='0' then
					miitx_rdy <= miitx_req;
				end if;
			end if;
			trdy_edge := not trdy_edge(0) & not trdy;
		end if;
	end process;

	process (mii_txc)
		variable rpkt_edge : std_logic_vector(0 to 1);
	begin
		if rising_edge(mii_txc) then
			if treq='0' then
				if rpkt='1' then
					if rpkt_edge(0)='0' then
						treq <= '1';
					end if;
				end if;
			elsif trdy='1' then
				treq <= '0';
			end if;
			rpkt_edge := not rpkt_edge(1) & not rpkt;
		end if;
	end process;

	miitx_udp_e : entity hdl4fpga.miitx_udp
	port map (
		sys_addr => miitx_addr,
		sys_data => miitx_data,
		mii_txc  => mii_txc,
		mii_treq => treq,
		mii_trdy => trdy,
		mii_txen => txen,
		mii_txd  => txd);

	process (mii_txc)
		variable edge : std_logic;
	begin
		if rising_edge(mii_txc) then
			if txen='1' then
				if edge='0' then
					tpkt_cntr <= byte(unsigned(tpkt_cntr) + 1);
				end if;
			end if;
			edge := txen;
		end if;
	end process;

	process (mii_rxc)
		variable edge : std_logic;
	begin
		if rising_edge(mii_rxc) then
			if rpkt='1' then
				if edge='0' then
					pkt_cntr <= std_logic_vector(unsigned(pkt_cntr) + 1);
				end if;
			end if;
			edge := rpkt;
		end if;
	end process;

	process (video_clk)
		variable nibble_ptr : unsigned(3-1 downto 0);
	begin
		if rising_edge(cga_clk) then
			nibble_ptr := nibble_ptr + 1;
			cga_code <= to_ascii(tp(to_integer(nibble_ptr)));
			cga_ptr <= (3 to 5 => '0',others => '1');
			cga_ptr(2 downto 0) <= std_logic_vector(nibble_ptr);
		end if;
	end process;

	cga_clk <= mii_rxc;
	vga_row <= win_rowpag(4-1 downto 0) & win_rowoff(6-1 downto 1);
	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom => psf1cp850x8x16,
		height => 16,
		width  => 8,
		row_reverse => true,
		col_reverse => true)
	port map (
		sys_clk => cga_clk,
		sys_row => cga_ptr(cga_row'range),
		sys_col => cga_ptr(cga_col'range),
		sys_we  => hd_t_clock,
		sys_code => cga_code,
		vga_clk => video_clk,
		vga_row => vga_row,
		vga_col => win_coloff(8-1 downto 1),
		vga_dot => cga_dot);

	miirx_udp_e : entity hdl4fpga.miirx_mac
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		mii_txc  => open,
		mii_txen => rpkt,
		mii_txd  => open);


	mii_iob_e : entity hdl4fpga.mii_iob
	port map (
		mii_rxc  => mii_rxc,

		iob_rxdv => mii_rxdv,
		iob_rxd  => mii_rxd,

		mii_rxdv => rxdv,
		mii_rxd  => rxd,


		mii_txc  => mii_txc,
		mii_txen => txen,
		mii_txd  => txd,

		iob_txen => mii_txen,
		iob_txd  => mii_txd);

	scope_e : entity hdl4fpga.scope
	generic map (
		num_chann => 2)
	port map (
		video_clk => video_clk,

		chann_row => win_rowoff,
		chann_col => win_coloff,
		chann_seg => win_rowpag(3 downto 0),
		chann_dat => chann_dat,
		grid_dot  => grid_dot,
		plot_dot  => plot_dot);

	usm: block
		signal xtal_ibufg : std_logic;
		signal rst    : std_logic_vector(0 to 32);
		signal clk0   : std_logic;
		signal clk90  : std_logic;
		signal locked : std_logic; 

		signal miixc_lckd : std_logic;
		signal video_lckd : std_logic;
		signal ddrs_lckd  : std_logic;
		signal adc_lckd   : std_logic;

	begin

		clkin_ibufg : ibufg
		port map (
			I => xtal,
			O => xtal_ibufg);

		video_dcm : entity hdl4fpga.dfs
		generic map (
			dcm_per => 50.0,
			dfs_mul => 15,
			dfs_div => 2)
		port map(
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => video_clk,
			dcm_lck => video_lckd);

		mii_dfs_e : entity hdl4fpga.dfs
		generic map (
			dcm_per => 50.0,
			dfs_mul => 5,
			dfs_div => 4)
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => mii_refclk,
			dcm_lck => miixc_lckd);

		ddr_dcm	: entity hdl4fpga.dfsdcm
		generic map (
			dcm_per => 50.0,
			dfs_mul => ddr_multiply,
			dfs_div => ddr_divide)
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfsdcm_clk0  => clk0,
			dfsdcm_clk90 => clk90,
			dcm_lck => ddrs_lckd);

		isdbt_dcm: entity hdl4fpga.dcmisdbt
		port map (
			dcm_rst => rst(0),
			dcm_clk => xtal_ibufg,
			dfs_clk => adc_clkab,
			dcm_lck => adc_lckd);

		locked <= adc_lckd and ddrs_lckd and miixc_lckd and video_lckd;
		ddr_rst_p : process (xtal_ibufg,sw1)
		begin
			if sw1='0' then
				rst <= (others => '1');
			elsif rising_edge(xtal_ibufg) then
				rst <= rst(1 to rst'right) & '0';
			end if;
		end process;

		ddrs_clk0   <= clk0;
		ddrs_clk90  <= clk90;
		ddrs_clk180 <= not clk0;
		sys_rst <= not locked;
	end block;

	ddr_e : entity hdl4fpga.ddr
	generic map (
		tCP => (50.0*real(ddr_divide))/real(ddr_multiply),
		tWR => 15.0,
		tRP => 15.0,
		tRCD => 15.0,
		tRFC => 72.0,
		tMRD => 12.0,
		cas  => cas,

		bank_bits => bank_size,
		addr_bits => addr_size,
		data_bytes => 2,
		byte_bits => 8)

	port map (
		sys_rst   => sys_rst,
		sys_clk0  => ddrs_clk0,
		sys_clk90 => ddrs_clk90,

		sys_ini => ddrs_ini,
		sys_cmd_req => ddrs_cmd_req,
		sys_cmd_rdy => ddrs_cmd_rdy,
		sys_rw  => ddrs_rw,
		sys_ba  => ddrs_ba,
		sys_a   => ddrs_a,
		sys_act => ddrs_act,
		sys_cas => ddrs_cas,
		sys_pre => ddrs_pre,
		sys_di_rdy => ddrs_di_rdy,
		sys_di  => ddrs_di,
		sys_do_rdy => ddrs_do_rdy,
		sys_do  => ddrs_do,
		sys_ref => ddrs_ref_req,

		ddr_st_lp_dqs => ddr_st_lp_dqs,
		ddr_lp_dqs => ddr_lp_dqs,
		ddr_cke => ddr_cke,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_ba  => ddr_ba,
		ddr_a   => ddr_a,
		ddr_dm  => ddr_dm,
		ddr_dqs => ddr_dqs,
		ddr_dq  => ddr_dq);

	-- I/O buffers --
	-----------------

	-- Differential buffers --
	--------------------------

	diff_clk_b : block
		signal diff_clk : std_logic;
	begin
		oddr_mdq : oddr2
		port map (
			r  => '0',
			s  => '0',
			c0 => ddrs_clk180,
			c1 => ddrs_clk0,
			ce => '1',
			d0 => '1',
			d1 => '0',
			q  => diff_clk);

		ddr_ck_obufds : obufds
		generic map (
			iostandard => "DIFF_SSTL2_I")
		port map (
			i  => diff_clk,
			o  => ddr_ckp,
			ob => ddr_ckn);
	end block;

	ddr_lp_ck_obufds : ibufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => ddr_lp_ckp,
		ib => ddr_lp_ckn,
		o  => ddr_lp_clk);

	hd_t_data <= 'Z';

	-- LEDs DAC --
	--------------
		
	led18 <= treq;
	led16 <= '0';
	led15 <= a0;
	led13 <= '0';
	led11 <= '0';
	led9  <= miitx_req;
	led8  <= miitx_rdy;
	led7  <= not sys_rst;

	-- RS232 Transceiver --
	-----------------------

	rs232_rts <= '0';
	rs232_td  <= '0';
	rs232_dtr <= '0';

	-- Ethernet Transceiver --
	--------------------------

	mii_mdc  <= '0';
	mii_mdio <= 'Z';


	-- LCD --
	---------

	lcd_e <= 'Z';
	lcd_rs <= 'Z';
	lcd_rw <= 'Z';
	lcd_data <= (others => 'Z');
	lcd_backlight <= 'Z';

	-- DDR RAM --
	-------------

	ddr_ckp <= 'Z';
	ddr_ckn <= 'Z';
	ddr_lp_dqs <= 'Z'; 
	ddr_cke <= 'Z';  
	ddr_cs  <= 'Z';  
	ddr_ras <= 'Z';
	ddr_cas <= 'Z';
	ddr_cas <= 'Z';
	ddr_we  <= 'Z';
	ddr_a   <= (others => 'Z');
	ddr_ba  <= (others => 'Z');
	ddr_dm  <= (others => 'Z');
	ddr_dqs <= (others => 'Z');
	ddr_dq  <= (others => 'Z');

end;
