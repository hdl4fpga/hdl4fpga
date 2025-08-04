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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdrampkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of orangecrab is

	constant settings : string := "{"                                                               &
		"io_link: io_usb,"                                                                          &
		"video:{"                                                                                   &
			"dcm:"          & string'(hdl4fpga.ecp5_profiles.video_dcm(".'48mhz'.'40mhz'", 36.0e6)) & ',' &
			"videoio_freq:" & "36.0e6"                                                              & ',' &
			"gear:"         & "4"                                                                   & ',' &
			"timings:"      & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'")     & ',' &
			"pixel:{"                                                                               &
				"R:8"                                                                               & ',' &
				"G:8"                                                                               & ',' &
				"B:8}}"                                                                             & ',' &
		"sdram:{"                                                                                   &
			"dcm:"       & string'(hdl4fpga.ecp5_profiles.sdram_dcm(".'48mhz'.'400mhz'"))           & ',' &
			"chip_data:" & string'(hdo(sdram_db)**".MT41K256M16-125")                               & ',' &
			"phy_data:"  & string'(hdo(phy_db)**".orangecrab_ecp5g4")                               & ',' &
			"cwl:"       & "'001'"                                                                  & ',' &                             
			"cl:"        & "'0010'}}";

	constant io_link      : string  := settings**".io_link";
	constant baudrate     : natural := 115200;
	-- Set your UART pinout here         --
	alias uart_rxd : std_logic is gpio(0); -- input  data received by the FPGA
	alias uart_txd : std_logic is gpio(1); -- output data sent by the FPGA

	signal sys_rst       : std_logic;

	constant mem_size    : natural := 8*(1024*8);
	signal sio_clk       : std_logic;
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal video_clk     : std_logic;
	signal videoio_clk   : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_phyrst  : std_logic;
	constant video_gear  : natural := 4; --video_params.gear;
	signal video_pixel   : std_logic_vector(settings**".video.pixel.R=8"+settings**".video.pixel.G=8"+settings**".video.pixel.B=8"-1 downto 0);
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);

	constant sdram_gear  : natural := hdo(settings)**".sdram.phy_data.orgz.gear";
	constant ba_latency : natural := 1;
	constant byte_size   : natural := ddram_dq'length/ddram_dqs'length;

	signal ctlr_rst      : std_logic;
	signal ctlr_sclk     : std_logic;
	signal ctlr_eclk     : std_logic;
	signal sdrphy_rst    : std_logic;
	signal ms_pause      : std_logic;
	signal ddrdel        : std_logic;
	signal sdrphy_locked : std_logic;


	signal ctlrphy_frm   : std_logic;
	signal ctlrphy_trdy  : std_logic;
	signal ctlrphy_ini   : std_logic;
	signal ctlrphy_rw    : std_logic;
	signal ctlrphy_wlreq : std_logic;
	signal ctlrphy_wlrdy : std_logic;
	signal ctlrphy_rlreq : std_logic;
	signal ctlrphy_rlrdy : std_logic;

	signal ctlrphy_rst   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cke   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cs    : std_logic_vector(0 to 2-1);
	signal ctlrphy_ras   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cas   : std_logic_vector(0 to 2-1);
	signal ctlrphy_we    : std_logic_vector(0 to 2-1);
	signal ctlrphy_odt   : std_logic_vector(0 to 2-1);
	signal ctlrphy_cmd   : std_logic_vector(0 to 3-1);
	signal ctlrphy_b     : std_logic_vector(sdram_gear/2*ddram_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(sdram_gear/2*ddram_a'length-1 downto 0);
	signal ctlrphy_dqst  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqso  : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(sdram_gear*ddram_dm'length-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(sdram_gear*ddram_dq'length-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(sdram_gear*ddram_dq'length-1 downto 0);
	signal ctlrphy_dqv   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(sdram_gear*ddram_dm'length-1 downto 0);

	signal sdr_b         : std_logic_vector(ddram_ba'range);
	signal sdr_a         : std_logic_vector(ddram_a'length-1 downto 0);


	signal tp            : std_logic_vector(1 to 32);
	signal tp_phy        : std_logic_vector(1 to 32);

begin

	sys_rst <= not rst_n;
	videodcm_e : entity hdl4fpga.ecp5_videodcm
	generic map (
		settings     => settings**".video")
	port map (
		clk         => clk_48mhz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_eclk  => video_eclk,
		video_lck   => video_lck);

	sdramdcm_e  : entity hdl4fpga.ecp5_sdramdcm
	generic map (
		settings => "{" & 
			"dcm:"  & string'(settings**".sdram.dcm")      & ',' &
			"gear:" & string'(hdo(settings)**".sdram.phy_data.orgz.gear") & '}')
	port map (
		ctlr_rst     => ctlr_rst,
		clk          => clk_48MHz,
		sclk         => ctlr_sclk,
		eclk         => ctlr_eclk,
		phy_rst      => sdrphy_rst,
		phy_mspause  => ms_pause,
		phy_ddrdel   => ddrdel);

	hdlc_g : if io_link="io_hdlc" generate
		constant uart_freq : real := clk48MHz_freq;
		signal uart_clk : std_logic;
	begin
		nodebug_g : if not debug generate
			uart_clk <= clk_48MHz;
			sio_clk  <= clk_48MHz;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
			sio_clk  <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;

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
			uart_sin  => uart_rxd,
			uart_sout => uart_txd);

	end generate;

	usb_g : if io_link="io_usb" generate
		constant usb_oversampling : natural := 3;
		signal usb_cken : std_logic;
	begin

		usb_pullup <= '1'; -- D+ pullup for USB1.1 device mode
		usb_d_p    <= 'Z'; -- when up='0' else '0';
		usb_d_n    <= 'Z'; -- when up='0' else '0';

		sio_clk  <= videoio_clk;

		usb_e : entity hdl4fpga.sio_dayusb
		generic map (
			usb_oversampling => usb_oversampling)
		port map (
			usb_clk   => videoio_clk,
			usb_cken  => usb_cken,
			usb_dp    => usb_d_p,
			usb_dn    => usb_d_n,

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

		rgb_led0_r <= usb_d_p;
		rgb_led0_g <= usb_d_n;
	end generate;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		debug        => debug, -- true,
		profile      => 2,
		burst_length => 8,
		sdram_freq   => sdram_freq(settings**".sdram.dcm")/2.0,
		settings     => settings,
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

		ctlr_clk     => ctlr_sclk,
		ctlr_rst     => ctlr_rst,
		ctlr_bl      => "00",
		ctlr_cl      => settings**".sdram.cl",
		ctlr_cwl     => settings**".sdram.cwl",
		ctlr_rtt     => "001",
		ctlr_cmd     => ctlrphy_cmd,
		ctlr_inirdy  => tp(1),

		ctlrphy_wlreq => ctlrphy_wlreq,
		ctlrphy_wlrdy => ctlrphy_wlrdy,
		ctlrphy_rlreq => ctlrphy_rlreq,
		ctlrphy_rlrdy => ctlrphy_rlrdy,

		ctlrphy_irdy => ctlrphy_frm,
		ctlrphy_trdy => ctlrphy_trdy,
		ctlrphy_ini  => ctlrphy_ini,
		ctlrphy_rw   => ctlrphy_rw,

		ctlrphy_rst  => ctlrphy_rst(0),
		ctlrphy_cke  => ctlrphy_cke(0),
		ctlrphy_cs   => ctlrphy_cs(0),
		ctlrphy_ras  => ctlrphy_ras(0),
		ctlrphy_cas  => ctlrphy_cas(0),
		ctlrphy_we   => ctlrphy_we(0),
		ctlrphy_odt  => ctlrphy_odt(0),
		ctlrphy_b    => sdr_b,
		ctlrphy_a    => sdr_a,
		ctlrphy_dqst => ctlrphy_dqst,
		ctlrphy_dqso => ctlrphy_dqso,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_dqv  => ctlrphy_dqv,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	cgear_g : for i in 1 to sdram_gear/2-1 generate
		ctlrphy_rst(i) <= ctlrphy_rst(0);
		ctlrphy_cke(i) <= ctlrphy_cke(0);
		ctlrphy_cs(i)  <= ctlrphy_cs(0);
		ctlrphy_ras(i) <= '1';
		ctlrphy_cas(i) <= '1';
		ctlrphy_we(i)  <= '1';
		ctlrphy_odt(i) <= ctlrphy_odt(0);
	end generate;

	process (clk_48MHz)
	begin
		if rising_edge(clk_48MHz) then
			-- rgb_led <= (others => '1');
			rgb_led0_b <= not sdrphy_locked;
		end if;
	end process;

	process (sdr_b)
	begin
		for i in sdr_b'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_b(j*sdr_b'length+i) <= sdr_b(i);
			end loop;
		end loop;
	end process;

	process (sdr_a)
	begin
		for i in sdr_a'range loop
			for j in 0 to sdram_gear/2-1 loop
				ctlrphy_a(j*sdr_a'length+i) <= sdr_a(i);
			end loop;
		end loop;
	end process;

	tp_b : block
		signal tp_dv : std_logic;
	begin
		process (ctlr_sclk)
			variable q : std_logic;
			variable q1 : std_logic := '0';
		begin
			if rising_edge(ctlr_sclk) then
				if ctlrphy_sti(0)='1' then
					if q='0' then
						q1 := not q1;
					end if;
				end if;
				q := ctlrphy_sti(0);
			tp_dv <= q1;
			end if;
		end process;
		
	end block;

	sdrphy_e : entity hdl4fpga.ecp5_sdrphy
	generic map (
		debug        => debug,
		bank_size    => ddram_ba'length,
		addr_size    => ddram_a'length,
		word_size    => ddram_dq'length,
		byte_size    => byte_size,
		gear         => sdram_gear,
		ba_latency   => ba_latency,
		rd_fifo      => false,
		wr_fifo      => true,
		bypass       => false,
		taps       => natural(ceil((1.0/sdram_freq(settings**".sdram.dcm")-25.0e-12)/25.0e-12))) -- FPGA-TN-02035-1-3-ECP5-ECP5-5G-HighSpeed-IO-Interface/3.11. Input/Output DELAY page 13
	port map (
		-- tpin       => btn(1),

		rst          => sdrphy_rst,
		sclk         => ctlr_sclk,
		eclk         => ctlr_eclk,
		ms_pause     => ms_pause,
		ddrdel       => ddrdel,

		phy_frm      => ctlrphy_frm,
		phy_trdy     => ctlrphy_trdy,
		phy_cmd      => ctlrphy_cmd,
		phy_rw       => ctlrphy_rw,
		phy_ini      => ctlrphy_ini,
		phy_locked   => sdrphy_locked,
		phy_wlreq    => ctlrphy_wlreq,
		phy_wlrdy    => ctlrphy_wlrdy,

		phy_rlreq    => ctlrphy_rlreq,
		phy_rlrdy    => ctlrphy_rlrdy,

		sys_rst      => ctlrphy_rst,
		sys_cs       => ctlrphy_cs,
		sys_cke      => ctlrphy_cke,
		sys_ras      => ctlrphy_ras,
		sys_cas      => ctlrphy_cas,
		sys_we       => ctlrphy_we,
		sys_odt      => ctlrphy_odt,
		sys_b        => ctlrphy_b,
		sys_a        => ctlrphy_a,
		sys_dqsi     => ctlrphy_dqso,
		sys_dqst     => ctlrphy_dqst,
		sys_dmi      => ctlrphy_dmo,
		sys_dqv      => ctlrphy_dqv,
		sys_dqi      => ctlrphy_dqo,
		sys_dqt      => ctlrphy_dqt,
		sys_dqo      => ctlrphy_dqi,
		sys_sti      => ctlrphy_sto,
		sys_sto      => ctlrphy_sti,

		sdram_rst    => ddram_reset_n,
		sdram_clk    => ddram_clk,
		sdram_cke    => ddram_cke,
		sdram_cs     => ddram_cs_n,
		sdram_ras    => ddram_ras_n,
		sdram_cas    => ddram_cas_n,
		sdram_we     => ddram_we_n,
		sdram_odt    => ddram_odt,
		sdram_b      => ddram_ba,
		sdram_a      => ddram_a,

		sdram_dm     => open,
		sdram_dq     => ddram_dq,
		sdram_dqs    => ddram_dqs,
		tp         => tp_phy);
	ddram_dm <= (others => '0');

	-- VGA --
	---------

	-- hdmi0_g : entity hdl4fpga.ecp5_ogbx
   	-- generic map (
		-- mem_mode  => false,
		-- lfbt_frst => false,
		-- interlace => true,
		-- size      => gpdi_d'length,
		-- gear      => video_gear)
   	-- port map (
		-- rst       => video_phyrst,
		-- eclk      => video_eclk,
		-- sclk      => video_shift_clk,
		-- d         => dvid_crgb,
		-- q         => gpdi_d);

	-- SDRAM-clk-divided-by-4 monitor
	process (ctlr_sclk)
		variable q : std_logic;
	begin
		if rising_edge(ctlr_sclk) then
			gpio(5) <= q;
			q := not q;
		end if;
	end process;

	tp(2) <= not (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= not (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

end;
