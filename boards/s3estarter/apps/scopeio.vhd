--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.profiles.all;
use hdl4fpga.app_profiles.all;

library unisim;
use unisim.vcomponents.all;

architecture scopeio of s3estarter is

	constant baudrate : natural := 115200;
	constant io_link  : io_comms := io_none;

	signal sys_rst        : std_logic;
	signal sys_clk    : std_logic;
	signal video_clk    : std_logic;
	signal video_vton : std_logic;

	constant sample_size : natural := 14;

	constant inputs  : natural := 2;

	signal samples   : std_logic_vector(inputs*sample_size-1 downto 0);
	signal spi_clk   : std_logic;
	signal spiclk_rd : std_logic;
	signal spiclk_fd : std_logic;
	signal sckamp_rd : std_logic;
	signal sckamp_fd : std_logic;
	signal amp_spi   : std_logic;
	signal amp_sdi   : std_logic;
	signal amp_rdy   : std_logic;
	signal adc_spi   : std_logic;
	signal ampcs     : std_logic;
	signal spi_rst   : std_logic;
	signal dac_sdi   : std_logic;
	signal input_ena : std_logic;
	signal video_pixel   : std_logic_vector(24-1 downto 0);

	alias  sio_clk   is e_tx_clk;
	signal si_frm    : std_logic;
	signal si_irdy   : std_logic;
	signal si_data   : std_logic_vector(0 to setif(io_link=io_ipoe,e_rxd'length,8)-1);

	constant max_delay   : natural := 2**14;
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	signal hz_slider : std_logic_vector(hzoffset_bits-1 downto 0);
	signal hz_scale  : std_logic_vector(4-1 downto 0);
	signal hz_dv     : std_logic;

	signal so_frm    : std_logic;
	signal so_irdy   : std_logic;
	signal so_trdy   : std_logic;
	signal so_end    : std_logic;
	signal so_data   : std_logic_vector(0 to setif(io_link=io_ipoe,e_txd'length,8)-1);

	type dcm_params is record
		dcm_mul : natural;
		dcm_div : natural;
	end record;

	type video_params is record
		id     : video_modes;
		cm     : dcm_params;
		timing : videotiming_ids;
	end record;

	type videoparams_vector is array (natural range <>) of video_params;
	constant video_tab : videoparams_vector := (
		(id => modedebug,      timing => pclk_debug,               cm => (dcm_mul =>  4, dcm_div => 2)),
		(id => mode480p24bpp,  timing => pclk25_00m640x480at60,    cm => (dcm_mul =>  2, dcm_div => 4)),
		(id => mode600p24bpp,  timing => pclk40_00m800x600at60,    cm => (dcm_mul =>  4, dcm_div => 5)),
		(id => mode720p24bpp,  timing => pclk75_00m1280x720at60,   cm => (dcm_mul =>  3, dcm_div => 2)),
		(id => mode1080p24bpp, timing => pclk150_00m1920x1080at60, cm => (dcm_mul =>  3, dcm_div => 1)));

	function videoparam (
		constant id  : video_modes)
		return video_params is
		constant tab : videoparams_vector := video_tab;
	begin
		for i in tab'range loop
			if id=tab(i).id then
				return tab(i);
			end if;
		end loop;

		assert false 
		report ">>>videoparam<<< : video id not available"
		severity failure;

		return tab(tab'left);
	end;

	constant video_mode : video_modes := mode1080p24bpp;

	constant vt_step : string := "0.000152587890625";  -- 2.5V/ 2.0**14 real'image() does not work on Xilinx ISE
	constant layout : string := compact(
			"{                             " &   
			"   inputs          : " & natural'image(inputs) & ',' &
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
			"       horizontal : {         " &
			"           scales : [         " &
							natural'image(     2**(0+0)*5**(0+0)) & "," & -- [0]
							natural'image(     2**(0+0)*5**(0+0)) & "," & -- [1]
							natural'image(2**((-1)+2+0)*5**(0+0)) & "," & -- [2]
							natural'image(2**((-1)+1+0)*5**(0+1)) & "," & -- [3]
							natural'image(2**((-1)+0+1)*5**(1+0)) & "," & -- [4]
							natural'image(2**((-1)+1+1)*5**(1+0)) & "," & -- [5]
							natural'image(2**((-1)+2+1)*5**(0+1)) & "," & -- [6]
							natural'image(2**((-1)+0+1)*5**(1+1)) & "," & -- [7]
							natural'image(2**((-1)+0+2)*5**(2+0)) & "," & -- [8]
							natural'image(2**((-1)+1+2)*5**(2+0)) & "," & -- [9]
							natural'image(2**((-1)+2+2)*5**(0+2)) & "," & -- [10]
							natural'image(2**((-1)+0+2)*5**(1+2)) & "," & -- [11]
							natural'image(2**((-1)+0+3)*5**(3+0)) & "," & -- [12]
							natural'image(2**((-1)+1+3)*5**(3+0)) & "," & -- [13]
							natural'image(2**((-1)+2+3)*5**(0+3)) & "," & -- [14]
							natural'image(2**((-1)+0+3)*5**(1+3)) & "," & -- [15]
			"               length : 16],  " &
			"           unit   : 25.0e-6, " &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}," &
			"       vertical : {           " &
			"           unit   : 5.0e-3, " &
			"           width  : " & natural'image(6*8) & ','  &
			"           color  : 0xff_00_00_00," &
			"           background-color : 0xff_00_ff_ff}}," &
			"   textbox : {                " &
			"       width      : " & natural'image(33*8) & ','&
			"       color      : 0xff_ff_00_ff," &
			"       background-color : 0xff_00_00_00}," &
			"   main : {                   " &
			"       top        :  5,       " & 
			"       left       :  1,       " & 
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
			"   { text  : VINA,        " &
			"     step  : " & vt_step & ","  &
			"     color : 0xff_00_ff_ff},  " &
			"   { text  : VINB,        " &
			"     step  : " & vt_step & ","  &
			"     color : 0xff_ff_ff_ff}]}");

	constant sdram : string := compact(
		"{" &
		"   gear      : 2," &
		"   bank_size : " & natural'image(sd_ba'length) & "," &
		"   addr_size : " & natural'image(sd_a'length)  & "," &
		"   coln_size : 9," &
		"   word_size : " & natural'image(sd_dq'length)  & "," &
		"   byte_size : " & natural'image(sd_dq'length/sd_dm'length) & "," &
		"}");

	type sdramparams_record is record
		id  : sdram_speeds;
		cm : dcm_params;
		cl  : std_logic_vector(0 to 3-1);
	end record;

	type sdramparams_vector is array (natural range <>) of sdramparams_record;
	constant sdram_tab : sdramparams_vector := (
		(id => sdram133MHz, cm => (dcm_mul =>  8, dcm_div => 3), cl => "010"),
		(id => sdram166MHz, cm => (dcm_mul => 10, dcm_div => 3), cl => "110"),
		(id => sdram170MHz, cm => (dcm_mul => 17, dcm_div => 5), cl => "110"),
		(id => sdram200MHz, cm => (dcm_mul =>  4, dcm_div => 1), cl => "011"));

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
	constant sdram_tcp    : real := real(sdram_params.cm.dcm_div)*clk50hmz_per/real(sdram_params.cm.dcm_mul);

	constant gear         : natural := hdo(sdram)**".gear";
	constant bank_size    : natural := hdo(sdram)**".bank_size";
	constant addr_size    : natural := hdo(sdram)**".addr_size";
	constant coln_size    : natural := hdo(sdram)**".coln_size";
	constant word_size    : natural := hdo(sdram)**".word_size";
	constant byte_size    : natural := hdo(sdram)**".byte_size";

	signal sdrsys_rst    : std_logic;

	signal ctlrphy_rst    : std_logic;
	signal ctlrphy_cke    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_cs     : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_ras    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_cas    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_we     : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_odt    : std_logic_vector((gear+1)/2-1 downto 0);
	signal ctlrphy_b      : std_logic_vector((gear+1)/2*sd_ba'length-1 downto 0);
	signal ctlrphy_a      : std_logic_vector((gear+1)/2*sd_a'length-1 downto 0);
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
	signal sd_clk       : std_logic_vector(0 downto 0);
	signal ddr_odt       : std_logic_vector(0 to 0);
	signal sdram_cke     : std_logic_vector(0 to 0);
	signal sdram_cs      : std_logic_vector(0 to 0);
	signal ddr_lp_ck     : std_logic;
	signal st_dqs_open   : std_logic;

	alias ctlr_clk is ddr_clk0;
begin

	clkin_ibufg : ibufg
	port map (
		I => clk_50mhz,
		O => sys_clk);

	process(sys_clk)
	begin
		if rising_edge(sys_clk) then
			sys_rst <= btn_north;
		end if;
	end process;

	videodcm_b : if not debug generate
		signal dcm_clkfb : std_logic;
		signal dcm_clk0  : std_logic;
	begin
	
		bug_i : bufg
		port map (
			I => dcm_clk0,
			O => dcm_clkfb);
	
		-- dcm_i : dcm
		-- generic map(
			-- clk_feedback   => "1x",
			-- clkdv_divide   => 2.0,
			-- clkfx_divide   => videoparam(video_mode).cm.dcm_div,
			-- clkfx_multiply => videoparam(video_mode).cm.dcm_mul,
			-- clkin_divide_by_2 => false,
			-- clkin_period   => clk50hmz_per*1.0e9,
			-- clkout_phase_shift => "none",
			-- deskew_adjust  => "system_synchronous",
			-- dfs_frequency_mode => "LOW",
			-- duty_cycle_correction => true,
			-- factory_jf   => x"c080",
			-- phase_shift  => 0,
			-- startup_wait => false)
		-- port map (
			-- rst      => '0',
			-- dssen    => '0',
			-- psclk    => '0',
			-- psen     => '0',
			-- psincdec => '0',
			-- clkfb    => dcm_clkfb,
			-- clkin    => sys_clk,
			-- clkfx    => video_clk,
			-- clkfx180 => open,
			-- clk0     => dcm_clk0,
			-- locked   => open,
			-- psdone   => open,
			-- status   => open);
		-- video_clk <= sys_clk;

	end generate;

	sdrdcm_b : block
		signal dfs_lckd  : std_logic;
		signal dfs_clkfb : std_logic;
		
		signal dcm_rst   : std_logic;
		signal dcm_clkin : std_logic;
		signal dcm_clkfb : std_logic;
		signal dcm_clk0  : std_logic;
		signal dcm_clk90 : std_logic;
		signal dcm_lckd  : std_logic;

	begin

		dcmdfs_i : dcm_sp
		generic map(
			clk_feedback   => "NONE",
			clkin_period   => clk50hmz_per*1.0e9,
			clkdv_divide   => 2.0,
			clkin_divide_by_2 => FALSE,
			clkfx_divide   => sdram_params.cm.dcm_div,
			clkfx_multiply => sdram_params.cm.dcm_mul,
			clkout_phase_shift => "NONE",
			deskew_adjust  => "SYSTEM_SYNCHRONOUS",
			dfs_frequency_mode => "HIGH",
			duty_cycle_correction => TRUE,
			factory_jf     => X"C080",
			phase_shift    => 0,
			startup_wait   => FALSE)
		port map (
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
	
			rst      => sys_rst,
			clkin    => sys_clk,
			clkfb    => '0',
			clk0     => dfs_clkfb,
			clkfx    => dcm_clkin,
			locked   => dfs_lckd);
	
		dcmdll_i : dcm_sp
		generic map(
			clk_feedback   => "1X",
			clkin_period   => (clk50hmz_per*real(sdram_params.cm.dcm_div))/real( sdram_params.cm.dcm_mul)*1.0e9,
			clkdv_divide   => 2.0,
			clkin_divide_by_2 => FALSE,
			clkfx_divide   => 1,
			clkfx_multiply => 2,
			clkout_phase_shift => "NONE",
			deskew_adjust => "SYSTEM_SYNCHRONOUS",
			dfs_frequency_mode => "HIGH",
			duty_cycle_correction => TRUE,
			factory_jf    => x"C080",
			phase_shift   => 0,
			startup_wait  => FALSE)
		port map (
			dssen    => '0',
			psclk    => '0',
			psen     => '0',
			psincdec => '0',
	
			rst      => '0',
			clkin    => dcm_clkin,
			clkfb    => ddr_clk0,
			clk0     => dcm_clk0,
			clk90    => dcm_clk90,
			locked   => dcm_lckd);
		video_clk <= ddr_clk0;

		clk0_bufg_i : bufg
		port map (
			i => dcm_clk0,
			o => ddr_clk0);
	
		clk90_bufg_i : bufg
		port map (
			i => dcm_clk90,
			o => ddr_clk90);
	
		sdrsys_rst <= not dcm_lckd;

	end block;

	spi_b: block
		signal spiclk_n : std_logic;
	begin

		spidcm_e : entity hdl4fpga.dfs2dfs
		generic map (
			dcm_per  => 20.0,
			dfs1_mul => 32,
			dfs1_div => 25,
			dfs2_mul => 17,
			dfs2_div => 25)
		port map(
			dcm_rst  => '0',
			dcm_clk  => sys_clk,
			dfs_clk  => spi_clk,
			dcm_lck  => spi_rst);
		spiclk_n <= not sys_clk;
--		spi_clk <= sys_clk;
--		spi_rst <= not dfs_rst;


		spiclk_rd <= '0' when spi_rst='0' else sckamp_rd when amp_spi='1' else '0' ;
		spiclk_fd <= '0' when spi_rst='0' else sckamp_fd when amp_spi='1' else '1' ;
		spi_mosi  <= amp_sdi when amp_spi='1' else dac_sdi;

		adcclkab_e : oddr2
		port map (
			c0 => spi_clk,
			c1 => spiclk_n,
			ce => '1',
			d0 => spiclk_rd,
			d1 => spiclk_fd,
			q  => spi_sck);

		ampclkr_p : process (spi_rst, spi_clk)
			variable cntr : unsigned(0 to 4-1);
		begin
			if spi_rst='0' then
				cntr := (others => '0');
				sckamp_rd <= cntr(0);
				adc_spi <= '1';
			elsif rising_edge(spi_clk) then
				cntr := cntr + 1;
				sckamp_rd <= cntr(0);
				amp_cs <= ampcs;
			end if;
		end process;

		ampclkf_p : process (spi_rst, spi_clk)
		begin
			if spi_rst='0' then
				sckamp_fd <= '0';
			elsif falling_edge(spi_clk) then
				sckamp_fd <= sckamp_rd;
			end if;
		end process;

		ampp2sr_p : process (spi_rst, sckamp_fd)
		begin
			if spi_rst='0' then
				ampcs <= '1';
			elsif falling_edge(sckamp_fd) then
				ampcs <= not amp_rdy or not amp_spi;
			end if;
		end process;

		amp_p : process (spi_rst, sckamp_fd)
			variable cntr : unsigned(0 to 4);
			variable val  : unsigned(0 to 8-1);
		begin
			if spi_rst='0' then
				amp_spi <= '1';
				amp_rdy <= '0';
				amp_sdi <= '0';
				cntr    := to_unsigned(val'length-2,cntr'length);
				val     := B"0001_0001";
			elsif falling_edge(sckamp_fd) then
				if ampcs='0' then
					if cntr(0)='0' then
						cntr := cntr - 1;
						val  := val rol 1;
					end if;
				end if;
				amp_sdi <= val(0);
				amp_rdy <= not cntr(0);
				amp_spi <= not cntr(0) or not ampcs;
			end if;
		end process;

		adcdac_p : process (amp_spi, spi_clk)
			constant p2p        : natural := 2*1550;
			constant cycle      : natural := 34;
			variable cntr       : unsigned(0 to 6) := (others => '0');
			variable adin       : unsigned(32-1 downto 0);
			variable aux        : unsigned(samples'range);
			variable dac_shr    : unsigned(0 to 30-1);
			variable adcdac_sel : std_logic;
			variable dac_data   : unsigned(0 to 12-1);
			variable dac_chan   : unsigned(0 to 2-1);
		begin
			if amp_spi='1' then
				cntr       := to_unsigned(cycle-2, cntr'length);
				adcdac_sel := '0';
				dac_sdi    <= '0';
				dac_cs     <= '1';
			elsif rising_edge(spi_clk) then
				if cntr(0)='1' then
					if adcdac_sel ='0' then
						samples <= std_logic_vector(
							adin(1*16+sample_size-1 downto 1*16) &
							adin(0*16+sample_size-1 downto 0*16));
						input_ena <= not amp_spi;
						ad_conv   <= '0';
					else
						if to_integer(dac_data)=(2048+p2p/2) then
							dac_data := to_unsigned(2048-p2p/2, dac_data'length);
						else
							dac_data := dac_data + 1;
						end if;
						ad_conv <= not amp_spi;
					end if;

					if hz_scale=(hz_scale'range=> '0') then
						adcdac_sel := '0';
						ad_conv    <= '1';
					else 
						adcdac_sel := not adcdac_sel;
					end if;

					dac_shr := (1 to 10 => '-') & "001100" & dac_chan & dac_data;
					cntr    := to_unsigned(cycle-2, cntr'length);
				else
					input_ena <= '0';
					ad_conv   <= '0';
					dac_shr   := dac_shr sll 1;
					cntr      := cntr - 1;
				end if;
				adin    := adin sll 1;
				adin(0) := spi_miso;

				dac_cs  <= not adcdac_sel or amp_spi;
				dac_sdi <= dac_shr(0);
			end if;
		end process;
	end block;

	ipoe_b : if io_link=io_ipoe generate
		alias  mii_clk    is e_tx_clk;
		signal txen       : std_logic;
		signal txd        : std_logic_vector(e_txd'range);
		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_data : std_logic_vector(e_rxd'range);

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
					if sw0='1' then
						dhcpcd_req <= not dhcpcd_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
						if sw0='0' then
							state := s_request;
						end if;
					end if;
				end case;
			end if;
		end process;

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to e_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to e_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			process (e_rx_clk)
			begin
				if rising_edge(e_rx_clk) then
					rxc_rxbus <= e_rx_dv & e_rxd;
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
				src_clk  => e_rx_clk,
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
					miirx_data <= txc_rxbus(1 to e_rxd'length);
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
				e_txen <= txen;
				e_txd  <= txd;
			end if;
		end process;

	end generate;

	stactlr_g : if io_link=io_none generate
		signal tp : std_logic_vector(1 to 32);
		signal miilnk_frm  : std_logic := '0';
		signal miilnk_irdy : std_logic := '0';
		signal miilnk_trdy : std_logic := '1';
		signal miilnk_data : std_logic_vector(si_data'range);
		signal left        : std_logic;
		signal right       : std_logic;
		signal up          : std_logic;
		signal down        : std_logic;

		signal rot         : std_logic_vector(0 to 2-1);
		signal derot       : std_logic_vector(0 to 2-1);
		signal rot_left    : std_logic;
		signal rot_right   : std_logic;
	begin

		e_txen <= 'Z';
		e_txd  <= (others => 'Z');
		rot <= (not rot_a, not rot_b);
		debounce_g : for i in rot'range  generate
			process (sio_clk)
				constant rebounds0 : natural := 6;
				constant rebounds1 : integer := -1;
				type states is (s_pressed, s_released);
				variable state : states;
				variable cntr  : integer range -1 to max(rebounds0, rebounds1);
				variable edge  : std_logic;
			begin
				if rising_edge(sio_clk) then
					case state is
					when s_pressed =>
						derot(i) <= '1';
						if rot(i)='0' then
							if cntr < 0 then
								cntr := 0;
								derot(i) <= '0';
								state := s_released;
							elsif (video_vton and not edge)='1' or debug then
								cntr := cntr - 1;
							end if;
						elsif cntr < rebounds0 then
							if (video_vton and not edge)='1' or debug then
								cntr := cntr + 1;
							end if;
						end if;
					when s_released =>
						derot(i) <= '0';
						if rot(i)='1' then
							if cntr >= rebounds1 then
								cntr := rebounds0;
								derot(i) <= '1';
								state := s_pressed;
							elsif (video_vton and not edge)='1' or debug then
								cntr := cntr + 1;
							end if;
						elsif cntr >= 0 then
							if (video_vton and not edge)='1' or debug then
								cntr := cntr - 1;
							end if;
						end if;
					end case;
					edge := video_vton;
				end if;
			end process;
		end generate;

		process (sio_clk)
			type states is (s_dtnt, s_left01, s_left11, s_left10, s_right10, s_right11, s_right01);
			--                    0       1         2         3         4         5           6          7 
			variable state : states;
			variable edge  : std_logic;
			variable lf : std_logic;
			variable rt : std_logic;
		begin
			if rising_edge(sio_clk) then
				lf := '0';
				rt := '0';
				case state is
				when s_dtnt =>
					case derot is
					when "01" =>
						state := s_left01;
					when "10" =>
						state := s_right10;
					when "11" =>
					when others =>
					end case;
				when s_left01 =>
					case derot is
					when "00" =>
						state := s_dtnt;
					when "10" =>
						lf := '1';
						state := s_dtnt;
					when "11" => 
						state := s_left11;
					when others =>
					end case;
				when s_left11 =>
					case derot is
					when "00" =>
						lf := '1';
						state := s_dtnt;
					when "10" =>
						state := s_left10;
					when "11" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_left10 =>
					case derot is
					when "00" =>
						lf := '1';
						state := s_dtnt;
					when "10" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_right10 =>
					case derot is
					when "00" =>
						state := s_dtnt;
					when "01" =>
						rt := '1';
						state := s_dtnt;
					when "11" => 
						state := s_right11;
					when others =>
					end case;
				when s_right11 =>
					case derot is
					when "00" =>
						rt := '1';
						state := s_dtnt;
					when "01" =>
						state := s_right01;
					when "11" =>
					when others =>
						state := s_dtnt;
					end case;
				when s_right01 =>
					case derot is
					when "00" =>
						rt := '1';
						state := s_dtnt;
					when "01" =>
					when others =>
						state := s_dtnt;
					end case;
				when others =>
				end case;

				if lf='1' then
					rot_left <= '1';
				elsif (video_vton and not edge)='1' then
					rot_left <= '0';
				end if;

				if rt='1' then
					rot_right <= '1';
				elsif (video_vton and not edge)='1' then
					rot_right <= '0';
				end if;

				edge := video_vton;
			end if;
		end process;

		led <= tp(1 to 8);
		-- led <= rot_left & b"000_000" & rot_right;
   		up    <= btn_north or rot_right;
   		down  <= btn_south or rot_left;
   		-- up    <= btn_north;
   		-- down  <= btn_south;
   		left  <= btn_west;
   		right <= btn_east or rot_center;
		stactlr_e : entity hdl4fpga.scopeio_stactlr
		generic map (
			layout => layout)
		port map (
			tp => tp,
			left    => left,
			up      => up,
			down    => down,
			right   => right,
			video_vton => video_vton,
			sio_clk => sio_clk,
			si_frm  => miilnk_frm,
			si_irdy => miilnk_irdy,
			si_trdy => miilnk_trdy,
			si_data => miilnk_data,
			so_frm  => si_frm,
			so_irdy => si_irdy,
			so_data => si_data);
	end generate;

	scopeio_e : entity hdl4fpga.scopeio
	generic map (
		debug     => debug,
		profile   => 1,
		sdram_tcp => sdram_tcp,
		mark      => MT46V256M6T,
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
		input_clk   => spi_clk,
		input_data  => samples,

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
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti,
		video_clk   => video_clk,
		video_pixel => video_pixel,
		video_hsync => vga_hsync,
		video_vsync => vga_vsync,
		video_vton  => video_vton);

	-- vga_hsync <= '0';
	-- vga_vsync <= '0';
	vga_red   <= video_pixel(3*8-1);
	vga_green <= video_pixel(2*8-1);
	vga_blue  <= video_pixel(1*8-1);

	ctlrphy_wlreq <= to_stdulogic(to_bit(ctlrphy_wlrdy));
	ctlrphy_rlreq <= to_stdulogic(to_bit(ctlrphy_rlrdy));

	sdrphy_e : entity hdl4fpga.xc_sdrphy
	generic map (
		-- dqs_delay   => (0 to 0 => 0 ns),
		-- dqi_delay   => (0 to 0 => 0 ns),
		device      => xc3s,
		bank_size   => sd_ba'length,
		addr_size   => sd_a'length,
		gear        => gear,
		word_size   => word_size,
		byte_size   => byte_size,
		loopback    => false,
		bypass      => true,
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

		sdram_clk     => sd_clk,
		sdram_cke     => sdram_cke,
		sdram_cs      => sdram_cs,
		sdram_odt     => ddr_odt,
		sdram_ras     => sd_ras,
		sdram_cas     => sd_cas,
		sdram_we      => sd_we,
		sdram_b       => sd_ba,
		sdram_a       => sd_a,

		sdram_dm      => sd_dm,
		sdram_dq      => sd_dq,
		sdram_dqs     => sd_dqs);

	sdram_clk_i : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => sd_clk(0),
		o  => sd_ck_p,
		ob => sd_ck_n);

	sd_cke <= sdram_cke(0);
	sd_cs  <= sdram_cs(0);

	-- Ethernet Transceiver --
	--------------------------

	e_txen <= 'Z';
	e_mdc  <= '0';
	e_mdio <= 'Z';
	e_txd_4 <= '0';

	amp_shdn <= '0';
	dac_clr <= '1';
	sf_ce0 <= '1';
	fpga_init_b <= '0';
	spi_ss_b <= '0';

	-- led0 <= '1';
	-- led1 <= '1';
	-- led2 <= '1';
	-- led3 <= '1';
	-- led4 <= '1';
	-- led5 <= '1';
	-- led6 <= '1';
	-- led7 <= '1';

	rs232_dte_txd <= 'Z';
	rs232_dce_txd <= 'Z';
end;
