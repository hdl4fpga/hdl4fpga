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
use hdl4fpga.sdram_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx3s is

	--------------------------------------
	--     Set your profile here        --
	constant io_link      : io_comms     := io_usb;
	constant sdram_speed  : sdram_speeds := sdram225MHz; 
	constant video_gear   : natural      := 2;
	constant video_mode   : video_modes  := mode600p24bpp;
	-- constant video_mode   : video_modes  := mode720p24bpp;
	-- constant video_mode   : video_modes  := mode900p24bpp;
	-- constant video_mode   : video_modes  := mode1080p24bpp30;
	-- constant video_mode   : video_modes  := mode1080p24bpp;
	-- constant video_mode   : video_modes  := mode1440p24bpp30;
	constant baudrate     : natural      := 3000000;
	--------------------------------------

	constant video_params  : video_record := videoparam(
		video_modes'VAL(setif(debug,
			video_modes'POS(modedebug),
			-- video_modes'POS(video_mode),
			video_modes'POS(video_mode))), clk25mhz_freq);

	constant sdram_params : sdramparams_record := sdramparams(
		sdram_speeds'VAL(setif(debug,
			sdram_speeds'POS(sdram133MHz),
			-- sdram_speeds'POS(sdram225MHz),
			sdram_speeds'POS(sdram_speed))), clk25mhz_freq);
	
	constant sdram_tcp : real := 
		real(sdram_params.pll.clki_div*sdram_params.pll.clkop_div)/
		(real(sdram_params.pll.clkfb_div*sdram_params.pll.clkos_div)*clk25mhz_freq);

	constant bank_size   : natural := sdram_ba'length;
	constant addr_size   : natural := sdram_a'length;
	constant word_size   : natural := sdram_d'length;
	constant byte_size   : natural := sdram_d'length/sdram_dqm'length;
	constant coln_size   : natural := 9;
	constant gear        : natural := 1;
	constant usb_oversampling : natural := 3;

	signal ctlr_clk      : std_logic;
	signal sdrsys_rst    : std_logic;

	signal ctlrphy_rst   : std_logic;
	signal ctlrphy_cke   : std_logic;
	signal ctlrphy_cs    : std_logic;
	signal ctlrphy_ras   : std_logic;
	signal ctlrphy_cas   : std_logic;
	signal ctlrphy_we    : std_logic;
	signal ctlrphy_b     : std_logic_vector(sdram_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(sdram_a'length-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(gear*word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(gear-1 downto 0);
	signal sdrphy_sti    : std_logic_vector(gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal sdram_dqs     : std_logic_vector(word_size/byte_size-1 downto 0);

	signal video_clk     : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_pixel   : std_logic_vector(0 to setif(
		video_params.pixel=rgb565, 16, setif(
		video_params.pixel=rgb888, 24, 0))-1);
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);
	signal videoio_clk   : std_logic;

	constant mem_size    : natural := 8*(1024*8);
	signal so_frm        : std_logic := '0';
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal sio_clk       : std_logic;

	constant serdebug    : boolean := false;
	signal ser_clk       : std_logic;
	signal ser_frm       : std_logic;
	signal ser_irdy      : std_logic;
	signal ser_data      : std_logic_vector(0 to setif(io_link=io_ipoe, 2,1)-1);
	-- signal ser_data      : std_logic_vector(0 to 8-1);

begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		io_link      => io_link,
		clkio_freq   => 12.0e6*real(usb_oversampling),
		clkref_freq  => clk25mhz_freq,
		default_gear => video_gear,
		video_params => video_params)
	port map (
		clk_rst     => right,
		clk_ref     => clk_25mhz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_eclk  => video_eclk,
		video_lck   => video_lck);

	sdrampll_e  : entity hdl4fpga.ecp5_sdrampll
	generic map (
		gear         => gear,
		clkref_freq  => clk25mhz_freq,
		sdram_params => sdram_params)
	port map (
		clk_ref  => clk_25mhz,
		ctlr_rst => sdrsys_rst,
		sclk     => ctlr_clk);

	process (ctlr_clk)
	begin
		if debug then
			sdram_dqs <= (others => ctlr_clk);
		else
			case sdram_speed is
			when sdram133MHz =>
				sdram_dqs <= (others => ctlr_clk);
			when others =>
				sdram_dqs <= (others => not ctlr_clk);
			end case;
		end if;
	end process;

	hdlc_g : if io_link=io_hdlc generate
		constant uart_freq : real := 
			real(video_params.pll.clkfb_div*video_params.pll.clkos_div)*clk25mhz_freq/
			real(video_params.pll.clki_div*video_params.pll.clkos3_div);
		signal uart_clk : std_logic;
	begin

		nodebug_g : if not debug generate
			uart_clk <= videoio_clk;
			sio_clk  <= videoio_clk;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
			sio_clk  <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;
		led(7) <= video_lck;

		hdlc_e : entity hdl4fpga.hdlc_link
		generic map (
			uart_freq => uart_freq,
			baudrate  => baudrate,
			mem_size  => mem_size)
		port map (
			sio_clk   => uart_clk,
			si_frm    => si_frm,
			si_irdy   => si_irdy,
			si_trdy   => si_trdy,
			si_end    => si_end,
			si_data   => si_data,
	
			so_frm    => so_frm,
			so_irdy   => so_irdy,
			so_trdy   => so_trdy,
			so_data   => so_data,
			uart_frm  => video_lck,
			uart_sin  => ftdi_txd,
			uart_sout => ftdi_rxd);

		ftdi_txden <= '1';
	end generate;

	usb_g : if io_link=io_usb generate
		signal tp : std_logic_vector(1 to 32);
		signal usb_cken : std_logic;
		signal fltr_en : std_logic;
		signal fltr_bs : std_logic;
		signal fltr_d  : std_logic;

	begin

		usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
		usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
		usb_fpga_dp    <= 'Z'; -- when up='0' else '0';
		usb_fpga_dn    <= 'Z'; -- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';

		sio_clk  <= videoio_clk;

		led(7) <= tp(4);

		usb_e : entity hdl4fpga.sio_dayusb
		generic map (
			usb_oversampling => usb_oversampling)
		port map (
			tp        => tp,
			usb_clk   => videoio_clk,
			usb_cken  => usb_cken,
			usb_dp    => usb_fpga_dp,
			usb_dn    => usb_fpga_dn,

			sio_clk   => sio_clk,
			si_frm    => si_frm,
			si_irdy   => si_irdy,
			si_trdy   => si_trdy,
			si_end    => si_end,
			si_data   => si_data,
	
			so_frm    => so_frm,
			so_irdy   => so_irdy,
			so_trdy   => so_trdy,
			so_data   => so_data);

		usbfltrsof_e : entity hdl4fpga.usbfltr_sof
		port map (
			usb_clk  => sio_clk,
			usb_cken => usb_cken,
			phy_en   => tp(1),
			phy_bs   => tp(2),
			phy_d    => tp(3),
			fltr_en  => fltr_en,
			fltr_bs  => fltr_bs,
			fltr_d   => fltr_d);

		ser_clk     <= videoio_clk;
		ser_frm     <= fltr_en;
		ser_irdy    <= not fltr_bs;
		ser_data(0) <= fltr_d;
		-- ser_frm     <= tp(1);
		-- ser_irdy    <= tp(2);
		-- ser_data(0) <= tp(3);
		-- ser_frm  <= tp(4);
		-- ser_irdy <= '1';
		-- ser_data <= tp(5 to 12);
	end generate;

	ipoe_g : if io_link=io_ipoe generate
		constant hdplx : std_logic := '1';
		signal video_pixel   : std_logic_vector(0 to setif(
		video_params.pixel=rgb565, 16, setif(
		video_params.pixel=rgb888, 32, 0))-1);
		-- https://www.waveshare.com/LAN8720-ETH-Board.htm
		-- Starts up 10Mb half duplex

		signal mii_clk : std_logic;
		signal tp      : std_logic_vector(1 to 32);
		signal mii_clk10 : std_logic;
	begin

		rmii_nintclk <= 'Z';
		rmii_crsdv   <= 'Z';
		rmii_rx0     <= 'Z';
		rmii_rx1     <= 'Z';

		clk10Mb_p : process (rmii_nintclk)
			variable cntr : unsigned (0 to 4-1);
		begin
			if rising_edge(rmii_nintclk) then
				if cntr < (10/2-1) then
					cntr := cntr + 1 ;
				else
					mii_clk10 <= not setif(mii_clk10/='0','1');
					cntr := (others => '0');
				end if;
			end if;
		end process;

		mii_clk <= mii_clk10 when not debug else rmii_nintclk;

		process (clk_25mhz)
		begin
			if rising_edge(clk_25mhz) then
				led <= tp(1 to 8);
			end if;
		end process;

		rmii_e : entity hdl4fpga.link_mii
		generic map (
			rmii          => true,
			default_mac   => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"),
			n             => 2)
		port map (
			tp            => tp,
			si_frm        => si_frm,
			si_irdy       => si_irdy,
			si_trdy       => si_trdy,
			si_end        => si_end,
			si_data       => si_data,
	
			so_frm        => so_frm,
			so_irdy       => so_irdy,
			so_trdy       => so_trdy,
			so_data       => so_data,
			dhcp_btn      => fire1,
			hdplx         => hdplx,
			mii_txc       => mii_clk,
			mii_txen      => rmii_tx_en,
			mii_txd(0)    => rmii_tx0,
			mii_txd(1)    => rmii_tx1,

			mii_rxc       => mii_clk,
			mii_rxdv      => rmii_crsdv,
			mii_rxd(0)    => rmii_rx0,
			mii_rxd(1)    => rmii_rx1);

		-- displaytp_e : entity hdl4fpga.display_tp
		-- generic map (
			-- timing_id    => video_params.timing,
			-- video_gear   => 2,
			-- num_of_cols  => 1,
			-- field_widths => (0 to 6-1 => 15),
			-- labels       => 
				-- "dev_gtn(0)" & NUL &
				-- "dev_gtn(1)" & NUL &
				-- "dev_csc"    & NUL &
				-- "dev_req(0)" & NUL &
				-- "dev_req(1)" & NUL &
				-- "miitx_frm"  & NUL &
				-- "miitx_end"  & NUL &
				-- "ethtx_frm"  & NUL &
				-- "ethtx_irdy" & NUL &
				-- "ethtx_trdy" & NUL &
				-- "arptx_frm"  & NUL &
				-- "arptx_irdy" & NUL &
				-- "arptx_trdy" & NUL)
		-- port map (
			-- sweep_clk   => video_clk,
			-- tp          => tp(1 to 13),
			-- video_clk   => video_clk,
			-- video_shift_clk => video_shift_clk,
			-- dvid_crgb   => dvid_crgb,
			-- video_pixel => video_pixel);

		sio_clk   <= mii_clk;
		wifi_en   <= '0';
		rmii_mdio <= '0';
		rmii_mdc  <= '0';

	end generate;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug,
		profile      => 0,

		sdram_tcp    => sdram_tcp,
		phy_latencies => ecp5g1_latencies,
		mark         => MT48LC256MA27E ,
		gear         => gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_params.timing,
		video_gear   => video_gear,
		red_length   => setif(video_params.pixel=rgb565, 5, setif(video_params.pixel=rgb888, 8, 0)),
		green_length => setif(video_params.pixel=rgb565, 6, setif(video_params.pixel=rgb888, 8, 0)),
		blue_length  => setif(video_params.pixel=rgb565, 5, setif(video_params.pixel=rgb888, 8, 0)),
		fifo_size    => mem_size)

	port map (
		sin_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_clk     => sio_clk,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_shift_clk => video_shift_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clk     => ctlr_clk,
		ctlr_rst     => sdrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_params.cl,

		ctlrphy_rst  => ctlrphy_rst,
		ctlrphy_cke  => ctlrphy_cke,
		ctlrphy_cs   => ctlrphy_cs,
		ctlrphy_ras  => ctlrphy_ras,
		ctlrphy_cas  => ctlrphy_cas,
		ctlrphy_we   => ctlrphy_we,
		ctlrphy_b    => ctlrphy_b,
		ctlrphy_a    => ctlrphy_a,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	latsti_e : entity hdl4fpga.latency
	generic map (
		n => gear,
		d => (0 to gear-1 => 0))
	port map (
		clk => ctlr_clk,
		di  => ctlrphy_sto,
		do  => sdrphy_sti);

	sdrphy_e : entity hdl4fpga.ecp5_sdrphy
	generic map (
		gear       => gear,
		bank_size  => sdram_ba'length,
		addr_size  => sdram_a'length,
		word_size  => word_size,
		byte_size  => byte_size,
		wr_fifo    => false,
		rd_fifo    => false,
		bypass     => false)
	port map (
		sclk       => ctlr_clk,
		rst        => sdrsys_rst,

		sys_cs(0)  => ctlrphy_cs,
		sys_cke(0) => ctlrphy_cke,
		sys_ras(0) => ctlrphy_ras,
		sys_cas(0) => ctlrphy_cas,
		sys_we(0)  => ctlrphy_we,
		sys_b      => ctlrphy_b,
		sys_a      => ctlrphy_a,
		sys_dmi    => ctlrphy_dmo,
		sys_dqi    => ctlrphy_dqo,
		sys_dqt    => ctlrphy_dqt,
		sys_dqo    => ctlrphy_dqi,
		sys_sto    => ctlrphy_sti,
		sys_sti    => sdrphy_sti,

		sdram_clk  => sdram_clk,
		sdram_cke  => sdram_cke,
		sdram_cs   => sdram_csn,
		sdram_ras  => sdram_rasn,
		sdram_cas  => sdram_casn,
		sdram_we   => sdram_wen,
		sdram_b    => sdram_ba,
		sdram_a    => sdram_a,
		sdram_dqs  => sdram_dqs,

		sdram_dm   => sdram_dqm,
		sdram_dq   => sdram_d);

	-- VGA --
	---------

	no_serdebug_g : if not serdebug generate
		hdmibrd_g : if video_gear=2 generate 
			signal crgb : std_logic_vector(dvid_crgb'range);
		begin
			reg_e : entity hdl4fpga.latency
			generic map (
				n => dvid_crgb'length,
				d => (dvid_crgb'range => 1))
			port map (
				clk => video_shift_clk,
				di  => dvid_crgb,
				do  => crgb);
	
			gbx_g : entity hdl4fpga.ecp5_ogbx
			generic map (
				mem_mode  => false,
				lfbt_frst => false,
				interlace => true,
				size      => gpdi_d'length,
				gear      => video_gear)
			port map (
				sclk      => video_shift_clk,
				eclk      => video_eclk,
				d         => crgb,
				q         => gpdi_d);

		end generate;

		hdmiext_g : if video_gear=7 or video_gear=4 generate 
			signal crgb : std_logic_vector(dvid_crgb'range);
		begin
			reg_e : entity hdl4fpga.latency
			generic map (
				n => dvid_crgb'length,
				d => (dvid_crgb'range => 1))
			port map (
				clk => video_shift_clk,
				di  => dvid_crgb,
				do  => crgb);

			hdmi_ext_g : entity hdl4fpga.ecp5_ogbx
		   	generic map (
				mem_mode  => false,
				lfbt_frst => false,
				interlace => true,
				size      => gpdi_d'length,
				gear      => video_gear)
		   	port map (
				eclk      => video_eclk,
				sclk      => video_shift_clk,
				d         => crgb,
				q         => gp(9 to 13-1));

			wifi_en   <= '0';
		end generate;
	end generate;

	ser_debug_g : if serdebug generate
		signal video_hzsync : std_logic;
		signal video_vtsync : std_logic;
		signal dvid_crgb    : std_logic_vector(4*2-1 downto 0);
	begin
		ser_debug_e : entity hdl4fpga.ser_debug
		generic map (
			timing_id       => video_params.timing)
		port map (
			ser_clk         => ser_clk, 
			ser_frm         => ser_frm, 
			ser_irdy        => ser_irdy, 
			ser_data        => ser_data, 
			
			video_clk       => video_clk,
			video_shift_clk => video_shift_clk,
			video_hzsync    => video_hzsync,
			video_vtsync    => video_vtsync,
			video_pixel     => video_pixel,
			dvid_crgb       => dvid_crgb);

		ddr_g : for i in gpdi_d'range generate
			signal q : std_logic;
		begin
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
				rst  => '0',
				d0   => dvid_crgb(2*i),
				d1   => dvid_crgb(2*i+1),
				q    => gpdi_d(i));
		end generate;

	end generate;

	-- SDRAM-clk-divided-by-2 monitor
	tp_p : process (ctlr_clk)
		variable q0 : std_logic;
		variable q1 : std_logic;
	begin
		if rising_edge(ctlr_clk) then
			gp(27) <= q0;
			gn(27) <= q1;
			q0 := not q0;
			q1 := not q1;
		end if;
	end process;
end;