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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;

library ecp3;
use ecp3.components.all;

architecture graphics of ecp3versa is

	--------------------------------------
	-- Set of profiles                  --
	type apps is (
	--	Interface_SdramSpeed_PixelFormat--

		mii_400MHz_480p24bpp,
		mii_425MHz_480p24bpp,
		mii_450MHz_480p24bpp,
		mii_475MHz_480p24bpp,
		mii_500MHz_480p24bpp);
	--------------------------------------

	---------------------------------------------
	-- Set your profile here                   --
	constant app : apps := mii_400MHz_480p24bpp;
	---------------------------------------------

	constant sys_freq    : real    := 100.0e6;

	constant sclk_phases : natural := 1;
	constant sclk_edges  : natural := 1;
	constant cmmd_gear   : natural := 2;
	constant data_edges  : natural := 1;
	constant data_gear   : natural := 4;

	constant bank_size   : natural := ddr3_ba'length;
	constant addr_size   : natural := ddr3_a'length;
	constant coln_size   : natural := 10;
	constant word_size   : natural := ddr3_dq'length;
	constant byte_size   : natural := ddr3_dq'length/ddr3_dqs'length;

	signal sys_rst       : std_logic;

	signal ddrsys_rst    : std_logic;
	signal ddrphy_rst    : std_logic;
	signal physys_clk    : std_logic;

	signal ctlr_lck      : std_logic;

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
	signal ctlrphy_ba    : std_logic_vector(cmmd_gear*ddr3_ba'length-1 downto 0);
	signal ctlrphy_a     : std_logic_vector(cmmd_gear*ddr3_a'length-1 downto 0);
	signal ctlrphy_dsi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dst   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dso   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmi   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dmo   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(data_gear*word_size-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
	signal ddr_ba        : std_logic_vector(ddr3_ba'length-1 downto 0);
	signal ddr_a         : std_logic_vector(ddr3_a'length-1 downto 0);

	type pll_params is record
		clkok_div  : natural;
		clkop_div  : natural;
		clkfb_div  : natural;
		clki_div   : natural;
	end record;

	type video_modes is (
		mode480p24,
		mode600p16,
		mode600p24,
		mode900p24,
		modedebug);

	type pixel_types is (
		rgb565,
		rgb888);

	type video_params is record
		pll   : pll_params;
		mode  : videotiming_ids;
		pixel : pixel_types;
	end record;

	type videoparams_vector is array (video_modes) of video_params;
	constant v_r : natural := 5; -- video ratio
	constant video_tab : videoparams_vector := (
		modedebug  => (pll => (clkok_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1), pixel => rgb888, mode => pclk_debug),
		mode480p24 => (pll => (clkok_div => 5, clkop_div => 25,  clkfb_div => 1, clki_div => 1), pixel => rgb888, mode => pclk25_00m640x480at60),
		mode600p16 => (pll => (clkok_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1), pixel => rgb565, mode => pclk40_00m800x600at60),
		mode600p24 => (pll => (clkok_div => 2, clkop_div => 16,  clkfb_div => 1, clki_div => 1), pixel => rgb888, mode => pclk40_00m800x600at60),
		mode900p24 => (pll => (clkok_div => 2, clkop_div => 22,  clkfb_div => 1, clki_div => 1), pixel => rgb888, mode => pclk108_00m1600x900at60)); -- 30 Hz

	signal video_clk      : std_logic := '0';
	signal videoio_clk    : std_logic := '0';
	signal video_lck      : std_logic := '0';
	signal video_shft_clk : std_logic := '0';
	signal dvid_crgb      : std_logic_vector(8-1 downto 0);

	type ddram_speed is (
		ddram400MHz,
		ddram425MHz,
		ddram450MHz,
		ddram475MHz,
		ddram500MHz);

	type ddram_params is record
		pll : pll_params;
		cl  : std_logic_vector(0 to 3-1);
		cwl : std_logic_vector(0 to 3-1);
	end record;

	type ddramparams_vector is array (ddram_speed) of ddram_params;
	constant ddram_tab : ddramparams_vector := (
		ddram400MHz => (pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  4, clki_div => 1), cl => "010", cwl => "000"),
		ddram425MHz => (pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 17, clki_div => 4), cl => "011", cwl => "001"),
		ddram450MHz => (pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  9, clki_div => 2), cl => "011", cwl => "001"),
		ddram475MHz => (pll => (clkok_div => 2, clkop_div => 1, clkfb_div => 19, clki_div => 4), cl => "011", cwl => "001"),
		ddram500MHz => (pll => (clkok_div => 2, clkop_div => 1, clkfb_div =>  5, clki_div => 1), cl => "011", cwl => "001"));

	constant mem_size : natural := 8*(1024*8);
	signal so_frm     : std_logic;
	signal so_irdy    : std_logic;
	signal so_trdy    : std_logic;
	signal so_data    : std_logic_vector(0 to 8-1);
	signal si_frm     : std_logic;
	signal si_irdy    : std_logic;
	signal si_trdy    : std_logic;
	signal si_end     : std_logic;
	signal si_data    : std_logic_vector(0 to 8-1);

	signal uart_clk    : std_logic;

	type io_iface is (
		io_hdlc,
		io_ipoe);

	type app_record is record
		iface : io_iface;
		mode  : video_modes;
		speed : ddram_speed;
	end record;

	type app_vector is array (apps) of app_record;
	constant app_tab : app_vector := (
		mii_400MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => ddram400MHz),
		mii_425MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => ddram425MHz),
		mii_450MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => ddram450MHz),
		mii_475MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => ddram475MHz),
		mii_500MHz_480p24bpp  => (iface => io_ipoe, mode => mode480p24, speed => ddram500MHz));

	constant nodebug_videomode : video_modes := app_tab(app).mode;
	constant video_mode   : video_modes := video_modes'VAL(setif(debug,
		video_modes'POS(modedebug),
		video_modes'POS(nodebug_videomode)));

    signal video_pixel    : std_logic_vector(0 to setif(
		video_tab(app_tab(app).mode).pixel=rgb565, 16, setif(
		video_tab(app_tab(app).mode).pixel=rgb888, 32, 0))-1);

	constant ddram_mode : ddram_speed := ddram_speed'VAL(setif(not debug,
		ddram_speed'POS(app_tab(app).speed),
		ddram_speed'POS(ddram400Mhz)));

	constant ddr_tcp : real := 
		real(ddram_tab(ddram_mode).pll.clki_div)/
		(real(ddram_tab(ddram_mode).pll.clkok_div*ddram_tab(ddram_mode).pll.clkfb_div)*sys_freq);

	constant io_link : io_iface := app_tab(app).iface;

	constant hdplx   : std_logic := setif(debug, '0', '1');

	signal tp : std_logic_vector(1 to 32);
	signal ddr_sclk   : std_logic;
	signal ddr_sclk2x : std_logic;
	signal ddr_eclk   : std_logic;

		signal  sio_clk    : std_logic;
	alias ctlr_clk   : std_logic is ddr_sclk;
begin

	sys_rst <= '0';
	videopll_b : block

		attribute FREQUENCY_PIN_CLKOS  : string;
		attribute FREQUENCY_PIN_CLKOK  : string;
		attribute FREQUENCY_PIN_CLKI   : string;
		attribute FREQUENCY_PIN_CLKOP  : string;

		constant video_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkok_div*1e6));

		constant video_shift_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkok_div*1e6));

		constant videoio_freq  : real :=
			(real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq)/
			(real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkok_div*1e6));

		attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(video_shift_freq, 10);
		attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa(video_freq,       10);
		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(videoio_freq,     10);
		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/1.0e6,   10);

		signal clkfb : std_logic;

	begin
		pll_i : ehxpllf
        generic map (
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL   => "RISING", 
			CLKOS_BYPASS     => "DISABLED", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL   => "RISING", 
			CLKOP_BYPASS     => "DISABLED", 
			CLKOK_INPUT      => "CLKOP",
			CLKOK_BYPASS     => "DISABLED", 
			DELAY_PWD        => "DISABLED",
			DELAY_VAL        => 0, 
			DUTY             => 8,
			PHASE_DELAY_CNTL => "DYNAMIC",
			PHASEADJ         => "0.0", 

--			CLKOS_DIV        => video_tab(video_mode).pll.clkos_div,
			CLKOK_DIV       => video_tab(video_mode).pll.clkok_div,
			CLKOP_DIV        => video_tab(video_mode).pll.clkop_div,
			CLKFB_DIV        => video_tab(video_mode).pll.clkfb_div,
			CLKI_DIV         => video_tab(video_mode).pll.clki_div)
        port map (
			rst       => '0',
			rstk             => '0',
			drpai3 => '0',  drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3 => '0',  dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3             => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			wrdel            => '0',
			clki      => clk,
			CLKFB     => clkfb,
			CLKOS     => open, --video_shft_clk,
			CLKOP     => open, --video_clk,
			CLKOK     => open, --videoio_clk,
			LOCK      => video_lck,
			CLKINTFB  => open);

	end block;

	ctlrpll_b : block

		attribute FREQUENCY_PIN_CLKI  : string;
		attribute FREQUENCY_PIN_FIN   : string;
		attribute FREQUENCY_PIN_CLKOS : string;
		attribute FREQUENCY_PIN_CLKOP : string;
		attribute FREQUENCY_PIN_CLKOK : string; 

		constant ddram_mhz : real := 1.0e-6/ddr_tcp;

		attribute FREQUENCY_PIN_CLKI  of pll_i : label is ftoa(sys_freq/1.0e6, 10);
		attribute FREQUENCY_PIN_FIN   of pll_i : label is ftoa(ddram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOP of pll_i : label is ftoa(ddram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOS of pll_i : label is ftoa(ddram_mhz, 10);
		attribute FREQUENCY_PIN_CLKOK of pll_i : label is ftoa(ddram_mhz/2.0, 10);

		attribute hgroup : string;
		attribute pbbox  : string;
		
		attribute pbbox  of phase_ff_0_i : label is "1,1";
		attribute hgroup of phase_ff_0_i : label is "clk_phase0";
		
		signal clkfb      : std_logic;
		signal lock       : std_logic;

		signal dtct_req   : std_logic;
		signal dtct_rdy   : std_logic;
		signal step_req   : std_logic;
		signal step_rdy   : std_logic;

		signal eclk_smp   : std_logic;
		signal eclk_rpha  : std_logic_vector(4-1 downto 0) := (others => '0');
		signal phase_ff_q : std_logic;
		signal rpha       : std_logic_vector(4-1 downto 0) := (others => '0');
		signal dfpa3      : std_logic;

	begin

		assert false
		report real'image(ddram_mhz)
		severity NOTE;

		dfpa3 <= not rpha(3);
		pll_i : ehxpllf
		generic map (
			CLKOS_TRIM_DELAY => 0,
			CLKOS_TRIM_POL   => "RISING", 
			CLKOS_BYPASS     => "DISABLED", 
			CLKOP_TRIM_DELAY => 0,
			CLKOP_TRIM_POL   => "RISING", 
			CLKOP_BYPASS     => "DISABLED", 
			CLKOK_INPUT      => "CLKOP",
			CLKOK_BYPASS     => "DISABLED", 
			DELAY_PWD        => "DISABLED",
			DELAY_VAL        => 0, 
			DUTY             => 8,
			PHASE_DELAY_CNTL => "DYNAMIC",
			PHASEADJ         => "0.0", 
			CLKOK_DIV        => ddram_tab(ddram_mode).pll.clkok_div,
			CLKOP_DIV        => ddram_tab(ddram_mode).pll.clkop_div,
			CLKFB_DIV        => ddram_tab(ddram_mode).pll.clkfb_div,
			CLKI_DIV         => ddram_tab(ddram_mode).pll.clki_div,

			FEEDBK_PATH      => "INTERNAL")
		port map (
			rst              => '0', 
			rstk             => '0',
			clki             => clk,
			drpai3           => rpha(3),
			drpai2           => rpha(2), 
			drpai1           => rpha(1), 
			drpai0           => rpha(0), 
			dfpai3           => dfpa3,
			dfpai2           => rpha(2), 
			dfpai1           => rpha(1), 
			dfpai0           => rpha(0), 
			fda3             => '0',
			fda2             => '0',
			fda1             => '0',
			fda0             => '0', 
			wrdel            => '0',
			clkintfb         => clkfb,
			clkfb            => clkfb,
			clkop            => ddr_sclk2x, 
			clkos            => ddr_eclk,
			clkok            => ddr_sclk,
			clkok2           => open,
			lock             => lock);
		
		process (clk, step_rdy)
			type states is (s_request, s_ready);
			variable state : states;
		begin
			if rising_edge(clk) then
				if lock='0' then
					dtct_req <= to_stdulogic(to_bit(dtct_rdy));
					ctlr_lck <= '0';
					state := s_request;
				else
					case state is
					when s_request =>
						dtct_req <= not to_stdulogic(to_bit(dtct_rdy));
						ctlr_lck <= '0';
						state := s_ready;
					when s_ready =>
						if (dtct_req xor to_stdulogic(to_bit(dtct_rdy)))='0' then
							ctlr_lck <= '1';
						end if;
					end case;
				end if;
			end if;
		end process;

		process (clk)
			variable cntr : unsigned(0 to 4-1);
		begin
			if rising_edge(clk) then
				if (to_bit(step_rdy) xor to_bit(step_req))='0' then
					cntr := (others => '0');
				elsif cntr(0)='0' then
					cntr := cntr + 1;
				else
					step_rdy <= step_req;
				end if;
			end if;
		end process;

		phadctor_e : entity hdl4fpga.phadctor
		generic map (
			taps      => 2**eclk_rpha'length-1)
		port map (
			clk       => clk,
			dtct_req  => dtct_req,
			dtct_rdy  => dtct_rdy,
			step_req  => step_req,
			step_rdy  => step_rdy,
			edge      => '0',
			input     => phase_ff_q,
			phase     => eclk_rpha);
		rpha <= not eclk_rpha;

		eclk_smp <= transport ddr_eclk after 0 ns;
		phase_ff_0_i : entity hdl4fpga.ff
		port map (
			clk => ddr_sclk,
			d   => eclk_smp,
			q   => phase_ff_q);
		
	end block;

	hdlc_g : if io_link=io_hdlc generate

--		block
--		port (
--			sio_clk : buffer std_logic);
--		port map (
--			sio_clk => sio_clk);
--		begin
--		end block;

		constant uart_xtal : real := 
			real(video_tab(video_mode).pll.clkfb_div*video_tab(video_mode).pll.clkop_div)*sys_freq/
			real(video_tab(video_mode).pll.clki_div*video_tab(video_mode).pll.clkok_div);

		constant baudrate : natural := setif(
			uart_xtal >= 32.0e6, 3000000, setif(
			uart_xtal >= 25.0e6, 2000000,
                                 115200));

		signal uart_rxdv  : std_logic;
		signal uart_rxd   : std_logic_vector(0 to 8-1);
		signal uarttx_frm : std_logic;
		signal uart_idle  : std_logic;
		signal uart_txen  : std_logic;
		signal uart_txd   : std_logic_vector(uart_rxd'range);

		signal tp         : std_logic_vector(1 to 32);

		signal ftdi_txd   : std_logic;
		signal ftdi_txen  : std_logic;
		signal ftdi_rxd   : std_logic;

		signal dummy_txd  : std_logic_vector(uart_rxd'range);
	begin

		process (uart_clk)
			variable q0 : std_logic := '0';
			variable q1 : std_logic := '0';
		begin
			if rising_edge(uart_clk) then
				led(6) <= q1;
				led(7) <= q0;
				if tp(1)='1' then
					if tp(2)='1' then
						q1 := not q1;
					end if;
				end if;
				if uart_rxdv='1' then
					q0 := not q0;
				end if;
			end if;
		end process;

		process (dummy_txd ,uart_clk)
			variable q : std_logic := '0';
			variable e : std_logic := '1';
		begin
			if rising_edge(uart_clk) then
				led(5) <= q;
				if (so_frm and not e)='1' then
					q := not q;
				end if;
				led(4) <= so_frm;
				e := so_frm;
			end if;
		end process;

		ftdi_txen <= '1';
		nodebug_g : if not debug generate
			uart_clk <= videoio_clk;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;

		assert FALSE
			report "BAUDRATE : " & " " & integer'image(baudrate)
			severity NOTE;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_irdy => uart_rxdv,
			uart_data => uart_rxd);

		uarttx_e : entity hdl4fpga.uart_tx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_xtal)
		port map (
			uart_txc  => uart_clk,
			uart_frm  => video_lck,
			uart_irdy => uart_txen,
			uart_trdy => uart_idle,
			uart_data => uart_txd,
			uart_sout => ftdi_rxd);

		siodaahdlc_e : entity hdl4fpga.sio_dayhdlc
		generic map (
			mem_size    => mem_size)
		port map (
			uart_clk    => uart_clk,
			uartrx_irdy => uart_rxdv,
			uartrx_data => uart_rxd,
			uarttx_frm  => uarttx_frm,
			uarttx_trdy => uart_idle,
			uarttx_data => uart_txd,
			uarttx_irdy => uart_txen,
			sio_clk     => sio_clk,
			so_frm      => so_frm,
			so_irdy     => so_irdy,
			so_trdy     => so_trdy,
			so_data     => so_data,

			si_frm      => si_frm,
			si_irdy     => si_irdy,
			si_trdy     => si_trdy,
			si_end      => si_end,
			si_data     => si_data,
			tp          => tp);

	end generate;


	ipoe_b : block

		port (
			sio_clk : buffer std_logic);
		port map (
			sio_clk => sio_clk);

		alias  mii_rxc    : std_logic is phy1_rxc;
		alias  mii_rxdv   : std_logic is phy1_rx_dv;
		alias  mii_rxd    : std_logic_vector(phy1_rx_d'range) is phy1_rx_d;

		alias mii_txc    : std_logic is phy1_gtxclk;
		signal mii_txd    : std_logic_vector(phy1_tx_d'range);
		signal mii_txen   : std_logic;
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

		signal mii_txcrxd : std_logic_vector(mii_rxd'range);

	begin

		sio_clk <= phy1_rxc;
		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_txcrxd'length);
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
				dst_clk  => mii_txc,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_txcrxd'length);
				end if;
			end process;
		end block;

		dhcp_p : process(mii_txc)
		begin
			if rising_edge(mii_txc) then
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
			--		dhcpcd_req <= dhcpcd_rdy xor not sw1;
				end if;
			end if;
		end process;

		udpdaisy_e : entity hdl4fpga.sio_dayudp
		generic map (
			debug         => false,
			my_mac        => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"))
		port map (
			tp         => open,

			sio_clk    => sio_clk,
			dhcpcd_req => dhcpcd_req,
			dhcpcd_rdy => dhcpcd_rdy,
			miirx_frm  => miirx_frm,
			miirx_irdy => '1', --miirx_irdy,
			miirx_trdy => open,
			miirx_data => miirx_data,

			miitx_frm  => miitx_frm,
			miitx_irdy => miitx_irdy,
			miitx_trdy => miitx_trdy,
			miitx_end  => miitx_end,
			miitx_data => miitx_data,

			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_end     => si_end,
			si_data    => si_data,

			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data);

		desser_e: entity hdl4fpga.desser
		port map (
			desser_clk => mii_txc,

			des_frm    => miitx_frm,
			des_irdy   => miitx_irdy,
			des_trdy   => miitx_trdy,
			des_data   => miitx_data,

			ser_irdy   => open,
			ser_data   => mii_txd);

		mii_txen <= miitx_frm and not miitx_end;
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				phy1_tx_en <= mii_txen;
				phy1_tx_d  <= mii_txd;
			end if;
		end process;

	end block;

	grahics_e : entity hdl4fpga.demo_graphics
	generic map (
		debug        => debug,
		profile      => 2,

		ddr_tcp      => natural(2.0*ddr_tcp*1.0e12),
		fpga         => LatticeECP3,
		mark         => A4G12,
		sclk_phases  => sclk_phases,
		sclk_edges   => sclk_edges,
		burst_length => 8,
		data_phases  => data_gear,
		data_edges   => data_edges,
		data_gear    => data_gear,
		cmmd_gear    => cmmd_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,

		timing_id    => video_tab(video_mode).mode,
		red_length   => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		green_length => setif(video_tab(video_mode).pixel=rgb565, 6, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		blue_length  => setif(video_tab(video_mode).pixel=rgb565, 5, setif(video_tab(video_mode).pixel=rgb888, 8, 0)),
		fifo_size    => mem_size)
	port map (
		sio_clk      => sio_clk,
		sin_frm      => so_frm,
		sin_irdy     => so_irdy,
		sin_trdy     => so_trdy,
		sin_data     => so_data,
		sout_frm     => si_frm,
		sout_irdy    => si_irdy,
		sout_trdy    => si_trdy,
		sout_end     => si_end,
		sout_data    => si_data,

		video_clk    => video_clk,
		video_shift_clk => video_shft_clk,
		video_pixel  => video_pixel,
		dvid_crgb    => dvid_crgb,

		ctlr_clks(0) => ctlr_clk,
		ctlr_rst     => ddrsys_rst,
		ctlr_bl      => "000",
		ctlr_cl      => ddram_tab(ddram_mode).cl,
		ctlr_cwl     => ddram_tab(ddram_mode).cwl,
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
		ctlrphy_b    => ddr_ba,
		ctlrphy_a    => ddr_a,
		ctlrphy_dsi  => ctlrphy_dsi,
		ctlrphy_dst  => ctlrphy_dst,
		ctlrphy_dso  => ctlrphy_dso,
		ctlrphy_dmi  => ctlrphy_dmi,
		ctlrphy_dmt  => ctlrphy_dmt,
		ctlrphy_dmo  => ctlrphy_dmo,
		ctlrphy_dqi  => ctlrphy_dqi,
		ctlrphy_dqt  => ctlrphy_dqt,
		ctlrphy_dqo  => ctlrphy_dqo,
		ctlrphy_sto  => ctlrphy_sto,
		ctlrphy_sti  => ctlrphy_sti);

	tp(2) <= not (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= not (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

	process (clk)
	begin
		if rising_edge(clk) then
			led(0) <= tp(1);
		end if;
	end process;

	process (ddr_ba)
	begin
		for i in ddr_ba'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_ba(i*cmmd_gear+j) <= ddr_ba(i);
			end loop;
		end loop;
	end process;

	process (ddr_a)
	begin
		for i in ddr_a'range loop
			for j in 0 to cmmd_gear-1 loop
				ctlrphy_a(i*cmmd_gear+j) <= ddr_a(i);
			end loop;
		end loop;
	end process;

	ctlrphy_rst(1) <= ctlrphy_rst(0);
	ctlrphy_cke(1) <= ctlrphy_cke(0);
	ctlrphy_cs(1)  <= ctlrphy_cs(0);
	ctlrphy_ras(1) <= '1';
	ctlrphy_cas(1) <= '1';
	ctlrphy_we(1)  <= '1';
	ctlrphy_odt(1) <= ctlrphy_odt(0);

	ddrphy_rst <= not ctlr_lck;
	process (ctlr_lck, ctlr_clk)
	begin
		if ctlr_lck='0' then
			ddrsys_rst <= '1';
		elsif rising_edge(ctlr_clk) then
			ddrsys_rst <= '0';
		end if;
	end process;
	
	ddrphy_e : entity hdl4fpga.ecp3_ddrphy
	generic map (
		taps          => natural(floor(ddr_tcp/26.0e-12)),
		cmmd_gear     => cmmd_gear,
		data_gear     => data_gear,
		bank_size     => ddr3_ba'length,
		addr_size     => ddr3_a'length,
		word_size     => word_size,
		byte_size     => byte_size)
	port map (
		rst           => ddrphy_rst,
		sclk          => ddr_sclk,
		sclk2x        => ddr_sclk2x,
		eclk          => ddr_eclk,
		phy_frm       => ctlrphy_frm,
		phy_trdy      => ctlrphy_trdy,
		phy_cmd       => ctlrphy_cmd,
		phy_rw        => ctlrphy_rw,
		phy_ini       => ctlrphy_ini,

		phy_wlreq     => ctlrphy_wlreq,
		phy_wlrdy     => ctlrphy_wlrdy,

		phy_rlreq     => ctlrphy_rlreq,
		phy_rlrdy     => ctlrphy_rlrdy,

		phy_rst       => ctlrphy_rst,
		phy_cs        => ctlrphy_cs,
		phy_cke       => ctlrphy_cke,
		phy_ras       => ctlrphy_ras,
		phy_cas       => ctlrphy_cas,
		phy_we        => ctlrphy_we,
		phy_odt       => ctlrphy_odt,
		phy_b         => ctlrphy_ba,
		phy_a         => ctlrphy_a,
		phy_dqsi      => ctlrphy_dso,
		phy_dqst      => ctlrphy_dst,
		phy_dqso      => ctlrphy_dsi,
		phy_dmi       => ctlrphy_dmo,
		phy_dmt       => ctlrphy_dmt,
		phy_dmo       => ctlrphy_dmi,
		phy_dqi       => ctlrphy_dqo,
		phy_dqt       => ctlrphy_dqt,
		phy_dqo       => ctlrphy_dqi,
		phy_sti       => ctlrphy_sto,
		phy_sto       => ctlrphy_sti,

		ddr_rst       => ddr3_rst,
		ddr_ck        => ddr3_clk,
		ddr_cke       => ddr3_cke,
		ddr_cs        => ddr3_cs,
		ddr_ras       => ddr3_ras,
		ddr_cas       => ddr3_cas,
		ddr_we        => ddr3_we,
		ddr_odt       => ddr3_odt,
		ddr_b         => ddr3_ba,
		ddr_a         => ddr3_a,

		ddr_dm        => ddr3_dm,
		ddr_dq        => ddr3_dq,
		ddr_dqs       => ddr3_dqs);

	-- VGA --
	---------

	phy1_gtxclk_i : oddrxd1
	port map (
		sclk => phy1_125clk,
		da   => '0',
		db   => '1',
		q    => phy1_gtxclk);

end;