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
	constant io_link      : io_comms     := io_ipoe;
	constant sdram_speed  : sdram_speeds := sdram250MHz;
	constant video_mode   : video_modes  := mode720p24bpp;
	--------------------------------------

	constant video_params  : video_record := videoparam(
		video_modes'VAL(setif(debug,
			video_modes'POS(modedebug),
			video_modes'POS(video_mode))), clk25mhz_freq);

	constant sdram_params : sdramparams_record := sdramparams(
		sdram_speeds'VAL(setif(debug,
			sdram_speeds'POS(sdram133MHz),
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
	constant video_gear  : natural := 2;
	signal dvid_crgb     : std_logic_vector(4*video_gear-1 downto 0);
	signal videoio_clk   : std_logic;
	signal video_phyrst  : std_logic;

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

begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		clkref_freq  => clk25mhz_freq,
		default_gear => video_gear,
		video_params  => video_params)
	port map (
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
			sdram_dqs <= (others => not ctlr_clk);
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
		constant baudrate : natural := setif(
			uart_freq >= 32.0e6, 3000000, setif(
			uart_freq >= 25.0e6, 2000000,
								 115200));
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
		rd_fifo    => true,
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

	hdmi_b : block
		signal crgb : std_logic_vector(dvid_crgb'range);
		signal q    : std_logic_vector(gpdi_d'range);
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
			rst       => video_phyrst,
			sclk      => video_shift_clk,
			eclk      => video_eclk,
			d         => crgb,
			q         => q);

		lvds_g : for i in gpdi_d'range generate
			olvds_i : olvds
			port map(
				a  => q(i),
				z  => gpdi_d(i),
				zn => gpdi_dn(i));
		end generate;
	end block;

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