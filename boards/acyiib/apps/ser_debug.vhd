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
use hdl4fpga.videopkg.all;
use hdl4fpga.app_profiles.all;
use hdl4fpga.ecp5_profiles.all;

architecture ser_debug of acyiib is

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

	signal ser_clk         : std_logic;
	signal ser_frm         : std_logic;
	signal ser_irdy        : std_logic;
	signal ser_data        : std_logic_vector(0 to setif(io_link=io_ipoe, 2,1)-1);

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

	constant device : boolean := false;
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

		usb_fpga_dp    <= 'Z';-- when up='0' else '0';
		usb_fpga_dn    <= 'Z';-- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';

		txen <= rxdv;
		rxbs <= txbs;
		txd  <= rxd;

	usbdev_g : if device generate
		usb_fpga_pu_dp <= '1'; -- D+ pullup for USB1.1 device mode
		usb_fpga_pu_dn <= 'Z'; -- D- no pullup for USB1.1 device mode
		usbdev_e : entity hdl4fpga.usbdev
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
	end generate;
		
	usbhost_g : if not device generate
		signal init_req : std_logic := '0';
		signal init_rdy : std_logic := '0';
	begin
		process (videoio_clk)
			variable ena : bit := '1';
		begin
			if rising_edge(videoio_clk) then
				if left='1' then
					init_req <= init_rdy;
				elsif fire1='1' then
					if ena='1' then
						init_req <= not init_rdy;
					end if;
					ena := '0';
				elsif fire2='1' then
					ena := '1';
				end if;
			end if;
		end process;

		usb_fpga_pu_dp <= 'Z' when left='0' else '0'; -- D+ pullup for USB1.1 host mode
		usb_fpga_pu_dn <= 'Z' when left='0' else '0'; -- D- no pullup for USB1.1 host mode
		usbhost_e : entity hdl4fpga.usbhostdvr
		generic map (
			oversampling => usb_oversampling)
		port map (
			dp   => usb_fpga_dp,
			dn   => usb_fpga_dn,
			clk  => videoio_clk,
			cken => cken,
			init_req => init_req,
			init_rdy => init_rdy);
	end generate;
		
	monitor_b : block 
		signal tp : std_logic_vector(1 to 32);
		signal cken : std_logic;
	begin

		--tp(1 to 3) <= tp_phy (1 to 3);
		usbphy_e : entity hdl4fpga.usbphy
	   	generic map (
			-- monitor => true,
			oversampling => usb_oversampling)
		port map (
			tp    => tp,
			dp    => usb_fpga_dp,
			dn    => usb_fpga_dn,
			clk   => videoio_clk,
			cken  => cken);

		process (videoio_clk)
		begin
			if rising_edge(videoio_clk) then
				if up='1' then
					fltr_on <= '0';
				elsif down='1' then
					fltr_on <= '1';
				end if;
			end if;
		end process;

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
	end block;


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
