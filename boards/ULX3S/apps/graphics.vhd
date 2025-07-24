-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of ulx3s is

	--------------------------------------
	--     Set your profile here        --
	constant settings : string := "{"   &
		"io_link: io_usb,"              &
		"video:{"                       &
			"dcm:"     & string'(hdl4fpga.ecp5_profiles.video_dcm(".'25mhz'.'40mhz'", 36.0e6))  & ',' &
			"videoio_freq:" & "36.0e6," &
			"gear:"    & "2,"           &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")      & ',' &
			"pixel:{"                   &
				"R:8,"                  &
				"G:8,"                  &
				"B:8}},"                &
		"sdram:{"                       &
			"dcm:"     & string'(hdl4fpga.ecp5_profiles.sdram_dcm(".'25mhz'.'133mhz'"))         & ',' &
			"cl:"      & "'010'}}";

	constant io_link      : string := settings**".io_link";
	constant baudrate     : natural      := 3000000;
	--------------------------------------

	constant byte_size   : natural := sdram_d'length/sdram_dqm'length;
	constant phy_data    : string  := hdo(phy_db)**".ecp5g1";
	constant sdram_gear  : natural := hdo(phy_data)**".orgz.gear";
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
	signal ctlrphy_dmo   : std_logic_vector(sdram_gear*sdram_dqm'length-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(sdram_gear*sdram_dqm'length-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(sdram_gear*sdram_dqm'length-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(sdram_gear-1 downto 0);
	signal sdrphy_sti    : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(sdram_gear*sdram_dqm'length-1 downto 0);
	signal sdram_dqs     : std_logic_vector(sdram_dqm'length-1 downto 0);

	signal video_clk     : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_pixel   : std_logic_vector(0 to settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1);
	signal dvid_crgb     : std_logic_vector(4*settings**".video.gear"-1 downto 0);
	signal videoio_clk   : std_logic;

	constant mem_size    : natural := 8*(1024*8);
	signal sio_clk       : std_logic;
	signal so_frm        : std_logic := '0';
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		settings     => settings**".video")
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
		settings => "{" & 
			"dcm:"  & string'(settings**".sdram.dcm")      & ',' &
			"gear:" & string'(hdo(phy_data)**".orgz.gear") & '}')
	port map (
		clk_ref  => clk_25mhz,
		ctlr_rst => sdrsys_rst,
		sclk     => ctlr_clk);

	process (ctlr_clk)
	begin
		if debug then
			sdram_dqs <= (others => ctlr_clk);
		else
			if string'(settings**".sdram.dcm")="133mhz" then
				sdram_dqs <= (others => ctlr_clk);
			else
				sdram_dqs <= (others => not ctlr_clk);
			end if;
		end if;
	end process;

	hdlc_g : if io_link="io_hdlc" generate
		constant uart_freq : real := 30.0e6;
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

		hdlc_e : entity hdl4fpga.link_hdlc
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

	usb_g : if io_link="io_usb" generate
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

		usb_e : entity hdl4fpga.sio_dayusb
		generic map (
			usb_oversampling => usb_oversampling)
		port map (
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
	end generate;

	ipoe_g : if io_link="io_ipoe" generate
		constant hdplx : std_logic := '1';
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

		sio_clk   <= mii_clk;
		wifi_en   <= '0';
		rmii_mdio <= '0';
		rmii_mdc  <= '0';

	end generate;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug,
		profile      => 0,

		sdram_tcp    => 1.0/sdram_freq(settings**".dcm"),
		phy_data     => hdo(phy_db)**".ecp5g1",
		sdram_data   => hdo(sdram_db)**".MT48LC16M16MA2-7E",

		video_settings => settings**".video",
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
		ctlr_cl      => settings**".sdram.cl",

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

	-- latsti_e : entity hdl4fpga.latency
	-- generic map (
	-- 	n => sdram_gear,
	-- 	d => (0 to sdram_gear-1 => 0))
	-- port map (
	-- 	clk => ctlr_clk,
	-- 	di  => ctlrphy_sto,
	-- 	do  => sdrphy_sti);

	-- sdrphy_e : entity hdl4fpga.ecp5_sdrphy
	-- generic map (
	-- 	gear       => sdram_gear,
	-- 	bank_size  => sdram_ba'length,
	-- 	addr_size  => sdram_a'length,
	-- 	word_size  => sdram_d'length,
	-- 	byte_size  => byte_size,
	-- 	wr_fifo    => false,
	-- 	rd_fifo    => false,
	-- 	bypass     => false)
	-- port map (
	-- 	sclk       => ctlr_clk,
	-- 	rst        => sdrsys_rst,

	-- 	sys_cs(0)  => ctlrphy_cs,
	-- 	sys_cke(0) => ctlrphy_cke,
	-- 	sys_ras(0) => ctlrphy_ras,
	-- 	sys_cas(0) => ctlrphy_cas,
	-- 	sys_we(0)  => ctlrphy_we,
	-- 	sys_b      => ctlrphy_b,
	-- 	sys_a      => ctlrphy_a,
	-- 	sys_dmi    => ctlrphy_dmo,
	-- 	sys_dqi    => ctlrphy_dqo,
	-- 	sys_dqt    => ctlrphy_dqt,
	-- 	sys_dqo    => ctlrphy_dqi,
	-- 	sys_sto    => ctlrphy_sti,
	-- 	sys_sti    => sdrphy_sti,

	-- 	sdram_clk  => sdram_clk,
	-- 	sdram_cke  => sdram_cke,
	-- 	sdram_cs   => sdram_csn,
	-- 	sdram_ras  => sdram_rasn,
	-- 	sdram_cas  => sdram_casn,
	-- 	sdram_we   => sdram_wen,
	-- 	sdram_b    => sdram_ba,
	-- 	sdram_a    => sdram_a,
	-- 	sdram_dqs  => sdram_dqs,

	-- 	sdram_dm   => sdram_dqm,
	-- 	sdram_dq   => sdram_d);

	-- -- VGA --
	-- ---------

	-- no_serdebug_g : if false generate
	-- 	hdmibrd_g : if settings**".video.gear"=2 generate 
	-- 		signal crgb : std_logic_vector(dvid_crgb'range);
	-- 	begin
	-- 		reg_e : entity hdl4fpga.latency
	-- 		generic map (
	-- 			n => dvid_crgb'length,
	-- 			d => (dvid_crgb'range => 1))
	-- 		port map (
	-- 			clk => video_shift_clk,
	-- 			di  => dvid_crgb,
	-- 			do  => crgb);
	
	-- 		gbx_g : entity hdl4fpga.ecp5_ogbx
	-- 		generic map (
	-- 			mem_mode  => false,
	-- 			lfbt_frst => false,
	-- 			interlace => true,
	-- 			size      => gpdi_d'length,
	-- 			gear      => settings**".video.gear")
	-- 		port map (
	-- 			sclk      => video_shift_clk,
	-- 			eclk      => video_eclk,
	-- 			d         => crgb,
	-- 			q         => gpdi_d);

	-- 	end generate;

	-- 	hdmiext_g : if settings**".video.gear"=7 or settings**".video.gear"=4 generate 
	-- 		signal crgb : std_logic_vector(dvid_crgb'range);
	-- 	begin
	-- 		reg_e : entity hdl4fpga.latency
	-- 		generic map (
	-- 			n => dvid_crgb'length,
	-- 			d => (dvid_crgb'range => 1))
	-- 		port map (
	-- 			clk => video_shift_clk,
	-- 			di  => dvid_crgb,
	-- 			do  => crgb);

	-- 		hdmi_ext_g : entity hdl4fpga.ecp5_ogbx
	-- 	   	generic map (
	-- 			mem_mode  => false,
	-- 			lfbt_frst => false,
	-- 			interlace => true,
	-- 			size      => gpdi_d'length,
	-- 			gear      => settings**".video.gear")
	-- 	   	port map (
	-- 			eclk      => video_eclk,
	-- 			sclk      => video_shift_clk,
	-- 			d         => crgb,
	-- 			q         => gp(13-1 downto 9));

	-- 		wifi_en   <= '0';
	-- 	end generate;
	-- end generate;

	-- -- SDRAM-clk-divided-by-2 monitor
	-- tp_p : process (ctlr_clk)
	-- 	variable q0 : std_logic;
	-- 	variable q1 : std_logic;
	-- begin
	-- 	if rising_edge(ctlr_clk) then
	-- 		gp(27) <= q0;
	-- 		gn(27) <= q1;
	-- 		q0 := not q0;
	-- 		q1 := not q1;
	-- 	end if;
	-- end process;

end;
