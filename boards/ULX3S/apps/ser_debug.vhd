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
use hdl4fpga.videopkg.all;
use hdl4fpga.ipoepkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

library ecp5u;
use ecp5u.components.all;

architecture ser_debug of ulx3s is

	constant usb_oversampling : natural := 3;
	constant io_link : io_comms := io_usb;

	constant video_mode   : video_modes := mode600p24bpp;
	constant video_params : video_record := videoparam(
		video_modes'VAL(setif(debug,
			video_modes'POS(video_mode),
			video_modes'POS(video_mode))), clk25mhz_freq);

	signal video_pixel   : std_logic_vector(0 to setif(
		video_params.pixel=rgb565, 16, setif(
		video_params.pixel=rgb888, 24, 0))-1);

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal videoio_clk     : std_logic;
	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;
	signal video_hzsync    : std_logic;
	signal video_vtsync    : std_logic;
	signal dvid_crgb       : std_logic_vector(7 downto 0);

	signal so_frm          : std_logic;
	signal so_irdy         : std_logic;
	signal so_trdy         : std_logic;
	signal so_data         : std_logic_vector(0 to 8-1);
	signal si_frm          : std_logic;
	signal si_irdy         : std_logic;
	signal si_trdy         : std_logic;
	signal si_end          : std_logic;
	signal si_data         : std_logic_vector(0 to 8-1);

	signal ser_clk         : std_logic;
	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to setif(io_link=io_ipoe, 2,1)-1);

	constant hdplx         : std_logic := setif(debug, '0', '1');
begin

	sys_rst <= '0';

	videopll_e : entity hdl4fpga.ecp5_videopll
	generic map (
		io_link      => io_link,
		clkio_freq   => 12.0e6*real(usb_oversampling),
		clkref_freq  => clk25mhz_freq,
		default_gear => 2,
		video_params => video_params)
	port map (
		clk_ref     => clk_25mhz,
		video_clk   => video_clk,
		videoio_clk => videoio_clk,
		video_shift_clk => video_shift_clk,
		video_lck   => video_lck);

	usb_g : if io_link=io_usb generate 
		signal cken : std_logic;
		signal cfgd : std_logic;

		signal txen : std_logic;
		signal txbs : std_logic;
		signal txd  : std_logic;

		signal rxdv : std_logic;
		signal rxbs : std_logic;
		signal rxd  : std_logic;

		signal fltr_on : std_logic;
		signal fltr_en : std_logic;
		signal fltr_bs : std_logic;
		signal fltr_d  : std_logic;

		signal tp   : std_logic_vector(1 to 32);
	begin
		usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
		usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
		usb_fpga_dp    <= 'Z';-- when up='0' else '0';
		usb_fpga_dn    <= 'Z';-- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';

		txen <= rxdv;
		rxbs <= txbs;
		txd  <= rxd;
		usbphy_e : entity hdl4fpga.usbdev
		generic map (
			oversampling => usb_oversampling)
		port map (
			tp   => tp,
			dp   => usb_fpga_dp,
			dn   => usb_fpga_dn,
			clk  => videoio_clk,
			dev_cfgd => cfgd,
			cken => cken,
			txen => txen, 
			txbs => txbs,
			txd  => txd,
			rxdv => rxdv, 
			rxbs => rxbs,
			rxd  => rxd);
			
		fltr_on <= not up;
		usbfltrsof_e : entity hdl4fpga.usbfltr_sof
		port map (
			usb_clk  => videoio_clk,
			usb_cken => cken,
			phy_en   => tp(1),
			phy_bs   => tp(2),
			phy_d    => tp(3),
			fltr_on  => fltr_on,
			fltr_en  => fltr_en,
			fltr_bs  => fltr_bs,
			fltr_d   => fltr_d);

		ser_clk     <= videoio_clk;
		ser_frm     <= fltr_en; 
		ser_irdy    <= not fltr_bs;
		ser_data(0) <= fltr_d;

		led(4) <= tp(4);
		led(3) <= tp(5);
		led(2) <= cfgd;
	end generate;

	hdlc_g : if io_link=io_hdlc generate
		constant uart_freq : real := 
			real(video_params.pll.clkfb_div*video_params.pll.clkos_div)*clk25mhz_freq/
			real(video_params.pll.clki_div*video_params.pll.clkos3_div);
		constant baudrate : natural := setif(
			uart_freq >= 32.0e6, 3000000, setif(
			uart_freq >= 25.0e6, 2000000,
								 115200));
		signal uart_clk : std_logic;
		signal uart_frm    : std_logic;
		signal uart_rxdv   : std_logic;
		signal uart_rxd    : std_logic_vector(0 to 0);
	begin
		uart_clk <= videoio_clk;

		uartrx_e : entity hdl4fpga.uart_rx
		generic map (
			baudrate => baudrate,
			clk_rate => uart_freq)
		port map (
			uart_rxc  => uart_clk,
			uart_sin  => ftdi_txd,
			uart_frm  => uart_frm,
			uart_rxd  => uart_rxd(0),
			uart_rxdv => uart_rxdv);

		ser_clk  <= uart_clk;
		ser_frm  <= uart_frm;
		ser_irdy <= uart_rxdv;
		ser_data <= uart_rxd;

		ftdi_txden <= '1';
	end generate;

	ipoe_e : if io_link=io_ipoe generate
		signal mii_clk : std_logic;
		signal tp : std_logic_vector(1 to 32);
	begin

		rmii_nintclk <= 'Z';
		rmii_crsdv   <= 'Z';
		rmii_rx0     <= 'Z';
		rmii_rx1     <= 'Z';

		process (rmii_nintclk)
			variable cntr : unsigned (0 to 4-1);
		begin
			if rising_edge(rmii_nintclk) then
				if cntr < (10/2-1) then
					cntr := cntr + 1 ;
				else
					mii_clk <= not mii_clk;
					cntr := (others => '0');
				end if;
			end if;
		end process;

		rmii_e : entity hdl4fpga.link_mii
		generic map (
			rmii          => true,
			default_mac   => x"00_40_00_01_02_03",
			default_ipv4a => aton("192.168.0.14"),
			n             => 2)
		port map (
			tp         => tp,
			si_frm     => si_frm,
			si_irdy    => si_irdy,
			si_trdy    => si_trdy,
			si_end     => si_end,
			si_data    => si_data,
	
			so_frm     => so_frm,
			so_irdy    => so_irdy,
			so_trdy    => so_trdy,
			so_data    => so_data,
			dhcp_btn   => fire1,
			hdplx      => hdplx,
			mii_txc    => mii_clk,
			mii_txen   => rmii_tx_en,
			mii_txd(0) => rmii_tx0,
			mii_txd(1) => rmii_tx1,

			mii_rxc    => mii_clk,
			mii_rxdv   => rmii_crsdv,
			mii_rxd(0) => rmii_rx0,
			mii_rxd(1) => rmii_rx1);

		ser_clk  <= mii_clk;
		ser_frm  <= rmii_crsdv; --tp(1);
		ser_irdy <= '1';

		datalat_e : entity hdl4fpga.latency
		generic map (
			n => 2,
			d => (0 to 2-1 => 4))
		port map (
			clk => mii_clk,
			di(0) => rmii_rx0,
			di(1) => rmii_rx1,
			do    => ser_data);

		wifi_en   <= '0';
		rmii_mdio <= '0';
		rmii_mdc  <= '0';

		process (rmii_crsdv)
			variable q : std_logic;
		begin
			if rising_edge(rmii_crsdv) then
				q := not q;
				led(6) <= q;
				led(7) <= not q;
			end if;
		end process;

		process (rmii_nintclk)
			variable q : std_logic;
		begin
			if rising_edge(rmii_nintclk) then
				q := not q;
				led(0) <= q;
				led(1) <= not q;
			end if;
		end process;

	end generate;

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

end;
