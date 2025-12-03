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

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.ep2c_profiles.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture ser_debug of acyiib is

	constant up   : std_logic := '0';
	constant down : std_logic := '1';
	constant usb_oversampling : natural := 3;
	constant settings : string := "{"                                                      &
		"io_link: io_ipoe,"                                                                &
		"video:{"                                                                          &
			"timings:" & string'(hdl4fpga.videopkg.timings_db**".'800x600'.'@60'.'40mhz'") & ',' &
			"pixel:"   & "{R:1,G:1,B:1}}}";

	signal video_clk    : std_logic;
	signal videoio_clk  : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck    : std_logic;
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_pixel  : std_logic_vector(0 to 3-1);

	signal usb_cfgd    : std_logic;
	signal usb_cken    : std_logic;
	signal usb_tp      : std_logic_vector(1 to 32);
	alias  usb_fpga_dp is p2_io1(8);
	alias  usb_fpga_dn is p2_io1(9);
	alias  usb_clk     is p2_io1(10);
	alias  rxdv        is p2_io2(16);
	alias  rxbs        is p2_io2(17);
	alias  rxd         is p2_io2(18);
	alias  txen        is p2_io2(19);
	alias  txbs        is p2_io2(20);
	alias  txd         is p2_io2(21);

	signal fltr_on : std_logic;
	signal fltr_en : std_logic;
	signal fltr_bs : std_logic;
	signal fltr_d  : std_logic;

	signal ser_clk  : std_logic;
	signal ser_frm  : std_logic;
	signal ser_irdy : std_logic;
	signal ser_data : std_logic_vector(0 to 0);

begin

	videopll_e : entity hdl4fpga.ep2c_videodcm
	generic map (
		dcm => video_dcm(".'50mhz'.'40mhz'", 12.0e6*real(usb_oversampling)))
	port map (
		clk             => osc_50mhz,
		video_clk       => video_clk,
		videoio_clk     => videoio_clk,
		video_shift_clk => video_shift_clk,
		locked          => video_lck);

	usbdev_e : entity hdl4fpga.usbdev
	generic map (
		oversampling => usb_oversampling)
	port map (
		tp   => usb_tp,
		dp   => usb_fpga_dp,
		dn   => usb_fpga_dn,
		clk  => videoio_clk,
		cken => usb_cken,
		dev_cfgd => usb_cfgd,
		txen => txen, 
		txbs => txbs,
		txd  => txd,
		rxdv => rxdv, 
		rxbs => rxbs,
		rxd  => rxd);
		
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
		usb_cken => usb_cken,
		phy_en   => usb_tp(1),
		phy_bs   => usb_tp(2),
		phy_d    => usb_tp(3),
		fltr_on  => fltr_on,
		fltr_en  => fltr_en,
		fltr_bs  => fltr_bs,
		fltr_d   => fltr_d);

	ser_clk     <= videoio_clk;
	ser_frm     <= fltr_en; 
	ser_irdy    <= not fltr_bs;
	ser_data(0) <= fltr_d;

	clk_i : altddio_bidir
	generic map (
		width             => 1,
		extend_oe_disable => "OFF",
		invert_output     => "OFF",
		power_up_high     => "OFF",
		oe_reg            => "UNREGISTERED",
		lpm_hint          => "UNUSED",
		lpm_type          => "altddio_out",
		intended_device_family => "Cyclone II")
	port map (
		datain_h(0) => '0',
		datain_l(0) => '1',
		outclock    => videoio_clk,
		outclocken  => '1',
		oe          => '1',
		padio(0)    => usb_clk);

	ser_debug_e : entity hdl4fpga.ser_debug
	generic map (
		settings => hdo(settings)**".video")
	port map (
		ser_clk      => ser_clk, 
		ser_frm      => ser_frm, 
		ser_irdy     => ser_irdy, 
		ser_data     => ser_data, 
		
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_blank  => open,
		video_pixel  => video_pixel);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			pin74 <= video_hzsync;
			pin73 <= video_vtsync;
			pin75 <= video_pixel(0);
			pin76 <= video_pixel(1);
			pin79 <= video_pixel(2);
		end if;
	end process;

end;
