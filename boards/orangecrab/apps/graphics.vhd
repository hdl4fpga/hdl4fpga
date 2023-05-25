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
use hdl4fpga.base.all;
use hdl4fpga.sdram_db.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture graphics of orangecrab is

	---------------------------------------
	-- Set your profile here             --
	constant sdram_speed  : sdram_speeds := sdram300MHz;
	constant video_mode   : video_modes  := mode600p24bpp;
	constant io_link      : io_comms     := io_hdlc;
	constant baudrate     : natural      := 3e6; --setif(debug, 3e6, 115200);
	-- Set your UART pinout here         --
	alias uart_rxd : std_logic is gpio(0); -- input  data received by the FPGA
	alias uart_txd : std_logic is gpio(1); -- output data sent by the FPGA
	---------------------------------------

	constant video_params  : video_record := videoparam(
		video_modes'VAL(setif(debug,
			video_modes'POS(modedebug),
			video_modes'POS(video_mode))), clk48MHz_freq);

	constant sdram_params : sdramparams_record := sdramparams(
		sdram_speeds'VAL(setif(debug,
			sdram_speeds'POS(sdram300Mhz),
			sdram_speeds'POS(sdram_speed))), clk48MHz_freq);
	
	constant sdram_tcp : real := 1.0/sdram_freq(sdram_params, clk48MHz_freq);

	constant bank_size   : natural := ddram_ba'length;
	constant addr_size   : natural := ddram_a'length;
	constant word_size   : natural := ddram_dq'length;
	constant byte_size   : natural := ddram_dq'length/ddram_dqs'length;
	constant coln_size   : natural := 10;
	constant sdram_gear  : natural := 4;

	signal sys_rst       : std_logic;

	signal ctlr_rst      : std_logic;

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
	signal ctlrphy_dmo   : std_logic_vector(sdram_gear*word_size/byte_size-1 downto 0);
	signal ctlrphy_dqt   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_dqi   : std_logic_vector(sdram_gear*word_size-1 downto 0);
	signal ctlrphy_dqo   : std_logic_vector(sdram_gear*word_size-1 downto 0);
	signal ctlrphy_dqv   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sto   : std_logic_vector(sdram_gear-1 downto 0);
	signal ctlrphy_sti   : std_logic_vector(sdram_gear*word_size/byte_size-1 downto 0);

	signal sdr_b         : std_logic_vector(ddram_ba'range);
	signal sdr_a         : std_logic_vector(ddram_a'length-1 downto 0);

	signal video_clk     : std_logic;
	signal videoio_clk   : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_phyrst  : std_logic;
	constant video_gear  : natural := video_params.gear;
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);

	constant mem_size    : natural := 8*(1024*8);
	signal so_frm        : std_logic;
	signal so_irdy       : std_logic;
	signal so_trdy       : std_logic;
	signal so_data       : std_logic_vector(0 to 8-1);
	signal si_frm        : std_logic;
	signal si_irdy       : std_logic;
	signal si_trdy       : std_logic;
	signal si_end        : std_logic;
	signal si_data       : std_logic_vector(0 to 8-1);

	signal sio_clk       : std_logic;

	signal sclk          : std_logic;
	signal eclk          : std_logic;

	signal video_pixel   : std_logic_vector(0 to 32-1);

	signal tp            : std_logic_vector(1 to 32);
	signal tp_phy        : std_logic_vector(1 to 32);
	signal sdrphy_locked : std_logic;

	signal sdrphy_rst    : std_logic;
	signal ms_pause      : std_logic;
	signal ddrdel        : std_logic;

begin

	sys_rst <= not rst_n;
	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		clkref_freq => clk48MHz_freq,
		video_params => video_params)
	port map (
		clk_ref     => '0', --clk_48MHz,
		videoio_clk => videoio_clk,
		video_clk   => video_clk,
		video_shift_clk => video_shift_clk,
		video_eclk  => video_eclk,
		video_lck   => video_lck);

	sdrampll_e  : entity hdl4fpga.ecp5_sdrampll
	generic map (
		gear         => sdram_gear,
		clkref_freq  => clk48MHz_freq,
		sdram_params => sdram_params)
	port map (
		clk_ref      => clk_48MHz,
		ctlr_rst     => ctlr_rst,
		sclk         => sclk,
		eclk         => eclk,
		phy_rst      => sdrphy_rst,
		phy_mspause  => ms_pause,
		phy_ddrdel   => ddrdel);

	hdlc_g : if io_link=io_hdlc generate
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
			uart_sin  => uart_rxd,
			uart_sout => uart_txd);

	end generate;

	assert io_link/=io_ipoe 
	report "NO mii ready"
	severity FAILURE;

	graphics_e : entity hdl4fpga.app_graphics
	generic map (
		ena_burstref  => false,
		debug        => debug,
		profile      => 2,
		phy_latencies => ecp5g4_latencies,

		sdram_tcp      => 2.0*sdram_tcp,
		-- mark         => MT41K8G107,
		mark         => MT41K8G125,
		gear         => sdram_gear,
		bank_size    => bank_size,
		addr_size    => addr_size,
		coln_size    => coln_size,
		word_size    => word_size,
		byte_size    => byte_size,
		burst_length => 8,

		timing_id    => video_params.timing,
		video_gear   => video_gear,
		red_length   => 8,
		green_length => 8,
		blue_length  => 8,
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

		ctlr_clk     => sclk,
		ctlr_rst     => ctlr_rst,
		ctlr_bl      => "000",
		ctlr_cl      => sdram_params.cl,
		ctlr_cwl     => sdram_params.cwl,
		ctlr_wrl     => sdram_params.wrl,
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
			rgb_led <= (others => '1');
			rgb_led0_g <= not sdrphy_locked;
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
		process (sclk)
			variable q : std_logic;
			variable q1 : std_logic := '0';
		begin
			if rising_edge(sclk) then
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
		debug        => true, --debug,
		bank_size    => ddram_ba'length,
		addr_size    => ddram_a'length,
		word_size    => word_size,
		byte_size    => byte_size,
		gear         => sdram_gear,
		ba_latency   => 1,
		rd_fifo      => false,
		wr_fifo      => false,
		bypass       => false,
		taps         => natural(ceil((sdram_tcp-25.0e-12)/25.0e-12))) -- FPGA-TN-02035-1-3-ECP5-ECP5-5G-HighSpeed-IO-Interface/3.11. Input/Output DELAY page 13
	port map (
		-- tpin       => btn(1),

		rst          => sdrphy_rst,
		sclk         => sclk,
		eclk         => eclk,
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
	process (sclk)
		variable q : std_logic;
	begin
		if rising_edge(sclk) then
			gpio(2) <= q;
			q := not q;
		end if;
	end process;

	tp(2) <= not (ctlrphy_wlreq xor ctlrphy_wlrdy);
	tp(3) <= not (ctlrphy_rlreq xor ctlrphy_rlrdy);
	tp(4) <= ctlrphy_ini;

end;
