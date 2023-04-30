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
	-- constant app_profile : app_profiles := hdlc_sdr225MHz_1440p24bpp30;
	-- constant app_profile : app_profiles := hdlc_sdr250MHz_1080p24bpp30;
	-- constant app_profile : app_profiles := hdlc_sdr200MHz_1080p24bpp30;
	-- constant app_profile : app_profiles := hdlc_sdr166MHz_1080p24bpp30;
	constant app_profile : app_profiles := hdlc_sdr166MHz_720p24bpp;
	-- constant app_profile : app_profiles := hdlc_sdr133MHz_600p24bpp;
	--------------------------------------

	constant video_mode   : video_modes := setdebug(debug, profile_tab(app_profile).video_mode);
	constant video_record : video_params := videoparam(video_mode);

	constant sdram_speed  : sdram_speeds := sdram_speeds'VAL(setif(not debug,
		sdram_speeds'POS(profile_tab(app_profile).sdram_speed),
		sdram_speeds'POS(sdram166MHz)));
	constant sdram_params : sdramparams_record := sdramparams(sdram_speed);
	constant sdram_tcp    : real := 
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
	signal ctlrphy_sti   : std_logic_vector(gear*word_size/byte_size-1 downto 0);
	signal sdram_dqs     : std_logic_vector(word_size/byte_size-1 downto 0);

	signal video_clk     : std_logic;
	signal video_lck     : std_logic;
	signal video_shift_clk : std_logic;
	signal video_eclk    : std_logic;
	signal video_pixel   : std_logic_vector(0 to setif(
		video_record.pixel=rgb565, 16, setif(
		video_record.pixel=rgb888, 32, 0))-1);
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

	constant io_link     : io_comms := profile_tab(app_profile).comms;
	constant hdplx       : std_logic := setif(debug, '0', '1');
begin

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		clkref_freq  => clk25mhz_freq,
		video_gear   => video_gear,
		video_record => video_record)
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
		ctlr_clk => ctlr_clk);

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
			real(video_record.pll.clkfb_div*video_record.pll.clkop_div)*clk25mhz_freq/
			real(video_record.pll.clki_div*video_record.pll.clkos3_div);
		constant baudrate : natural := setif(
			uart_freq >= 32.0e6, 3000000, setif(
			uart_freq >= 25.0e6, 2000000,
								 115200));
		alias uart_clk is sio_clk;
	begin

		ftdi_txden <= '1';
		nodebug_g : if not debug generate
			uart_clk <= videoio_clk;
		end generate;

		debug_g : if debug generate
			uart_clk <= not to_stdulogic(to_bit(uart_clk)) after 0.1 ns /2;
		end generate;

		hdlc_e : entity hdl4fpga.hdlc_link
		generic map (
			uart_freq => uart_freq,
			baudrate => baudrate,
			mem_size => mem_size)
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
	end generate;

	ipoe_e : if io_link=io_ipoe generate
	begin

		rmii_b : block
			generic (
				n : natural);
			generic map (
				n => 2);
			port (
				dhcp_btn : in  std_logic;

				mii_rxc  : in  std_logic;
				mii_rxdv : in  std_logic;
				mii_rxd  : in  std_logic_vector(0 to n-1);

				mii_txc  : in  std_logic;
				mii_txen : out std_logic;
				mii_txd  : out std_logic_vector(0 to n-1));
			port map (
				dhcp_btn   => fire1,
				mii_txc    => rmii_nint,
				mii_txen   => rmii_tx_en,
				mii_txd(0) => rmii_tx0,
				mii_txd(1) => rmii_tx1,

				mii_rxc    => rmii_nint,
				mii_rxdv   => rmii_crs,
				mii_rxd(0) => rmii_rx0,
				mii_rxd(1) => rmii_rx1);

			signal dhcpcd_req : std_logic;
			signal dhcpcd_rdy : std_logic;

			signal miitx_frm  : std_logic;
			signal miitx_irdy : std_logic;
			signal miitx_trdy : std_logic;
			signal miitx_end  : std_logic;
			signal miitx_data : std_logic_vector(si_data'range);

		begin
		
			dhcp_p : process(mii_txc)
				type states is (s_request, s_wait);
				variable state : states;
			begin
				if rising_edge(mii_txc) then
					case state is
					when s_request =>
						if dhcp_btn='1' then
							dhcpcd_req <= not dhcpcd_rdy;
							state := s_wait;
						end if;
					when s_wait =>
						if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
							if dhcp_btn='0' then
								state := s_request;
							end if;
						end if;
					end case;
				end if;
			end process;

			udpdaisy_e : entity hdl4fpga.sio_dayudp
			generic map (
				my_mac        => x"00_40_00_01_02_03",
				default_ipv4a => aton("192.168.1.1"))
			port map (
				hdplx      => hdplx,
				mii_clk    => mii_txc,
				dhcpcd_req => dhcpcd_req,
				dhcpcd_rdy => dhcpcd_rdy,
				miirx_frm  => mii_rxdv,
				miirx_data => mii_rxd,
			
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
			
				so_clk     => mii_txc,
				so_frm     => so_frm,
				so_irdy    => so_irdy,
				so_trdy    => so_trdy,
				so_data    => so_data);
			
			desser_e: entity hdl4fpga.desser
			port map (
				desser_clk => mii_txc,
			
				des_frm  => miitx_frm,
				des_irdy => miitx_irdy,
				des_trdy => miitx_trdy,
				des_data => miitx_data,
			
				ser_irdy => open,
				ser_data => mii_txd);
			
			mii_txen <= miitx_frm and not miitx_end;
		end block;
		
		miirefclk_b : block
			type ref_freqs is (f25MHz, f50MHz);
			constant ref_freq : ref_freqs := f25MHz;

			signal shtclk : std_logic;
			signal d0     : std_logic;
			signal d1     : std_logic;
			signal refclk : std_logic;
			
		begin

			ref50_g : if ref_freq=f50MHz generate
			begin
				process (video_shift_clk)
					variable reg : unsigned(0 to 10-1) := b"11_10_01_11_00";
				begin
					if rising_edge(video_shift_clk) then
						reg := reg rol 2;
					end if;
					d0 <= reg(0);
					d1 <= reg(1);
				end process;
				shtclk <= video_shift_clk;
			end generate;

			ref25_g : if ref_freq=f25MHz generate
				shtclk <= clk_25mhz;
				d0     <= '1';
				d1     <= '0';
			end generate;
	
			oddr_i : oddrx1f
			port map(
				sclk => video_shift_clk,
				rst  => '0',
				d0   => d0,
				d1   => d1,
				q    => refclk);

			debug_g : block
				signal debug_clk : std_logic;
			begin
				debug_clk <= not to_stdulogic(to_bit(debug_clk)) after 0.1 ns /2;
				rmii_refclk <= refclk when video_mode/=modedebug else debug_clk;
			end block;

	
		end block;

		wifi_en   <= '0';
		sio_clk   <= rmii_nint;
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

		timing_id    => video_record.timing,
		video_gear   => video_gear,
		red_length   => setif(video_record.pixel=rgb565, 5, setif(video_record.pixel=rgb888, 8, 0)),
		green_length => setif(video_record.pixel=rgb565, 6, setif(video_record.pixel=rgb888, 8, 0)),
		blue_length  => setif(video_record.pixel=rgb565, 5, setif(video_record.pixel=rgb888, 8, 0)),
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
		sys_sti    => ctlrphy_sto,
		sys_sto    => ctlrphy_sti,

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
		signal q : std_logic_vector(gpdi_d'range);
	begin

		reg_e : entity hdl4fpga.latency
		generic map (
			n => dvid_crgb'length,
			d => (dvid_crgb'range => 1))
		port map (
			clk => video_shift_clk,
			di => dvid_crgb,
			do => crgb);

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