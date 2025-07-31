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

entity acyiib is
	generic (
		debug : boolean := false);
	port (
		osc_50mhz      : in  std_logic;
		usb_fpga_dp    : inout std_logic;
		usb_fpga_dn    : inout std_logic;
		usb_fpga_bd_dp : out std_logic;
		usb_fpga_bd_dn : out std_logic;
		usb_fpga_pu_dp : out std_logic;
		usb_fpga_pu_dn : out std_logic;
		fire1          : in  std_logic;
		fire2          : in  std_logic;
		left           : in  std_logic;
		up             : in  std_logic;
		down           : in  std_logic;

		clk            : out std_logic;
		cken           : out std_logic;
		txen           : in  std_logic;
		txbs           : out std_logic;
		txd            : in  std_logic;
		rxdv           : out std_logic;
		rxbs           : inout std_logic;
		rxd            : out std_logic);

	attribute chip_pin : string;
	attribute chip_pin of osc_50mhz      : signal is "17";
	attribute chip_pin of usb_fpga_dp    : signal is "112";
	attribute chip_pin of usb_fpga_dn    : signal is "113";
	attribute chip_pin of usb_fpga_bd_dp : signal is "114";
	attribute chip_pin of usb_fpga_bd_dn : signal is "115";
	attribute chip_pin of usb_fpga_pu_dp : signal is "118";
	attribute chip_pin of usb_fpga_pu_dn : signal is "121";
	attribute chip_pin of fire1          : signal is "122";
	attribute chip_pin of fire2          : signal is "125";
	attribute chip_pin of left           : signal is "126";
	attribute chip_pin of up             : signal is "133";
	attribute chip_pin of down           : signal is "134";

	attribute chip_pin of clk            : signal is "40";
	attribute chip_pin of cken           : signal is "41";
	attribute chip_pin of txen           : signal is "135";
	attribute chip_pin of txbs           : signal is "137";
	attribute chip_pin of txd            : signal is "139";
	attribute chip_pin of rxdv           : signal is "141";
	attribute chip_pin of rxbs           : signal is "142";
	attribute chip_pin of rxd            : signal is "143";

	constant osc50mhz_freq : real := 50.0e6;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture usbdev of acyiib is
	constant usb_oversampling : natural := 3;

	signal sys_rst         : std_logic;
	signal sys_clk         : std_logic;

	signal videoio_clk     : std_logic;
	signal video_clk       : std_logic;
	signal video_shift_clk : std_logic;
	signal video_lck       : std_logic;

	signal cfgd : std_logic;

	signal tp   : std_logic_vector(1 to 32);

begin

	sys_rst <= '0';

	videopll_e : entity hdl4fpga.alt_videopll
	generic map (
		clkio_freq   => 12.0e6*real(usb_oversampling),
		clkref_freq  => osc50mhz_freq)
	port map (
		clk_ref     => osc_50mhz,
		video_clk   => video_clk,
		videoio_clk => videoio_clk,
		video_shift_clk => video_shift_clk,
		video_lck   => video_lck);

		usb_fpga_dp    <= 'Z';-- when up='0' else '0';
		usb_fpga_dn    <= 'Z';-- when up='0' else '0';
		usb_fpga_bd_dp <= 'Z';
		usb_fpga_bd_dn <= 'Z';

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
		
	clk_i : altddio_out
	generic map (
		width   => 1,
		extend_oe_disable => "OFF",
		invert_output => "OFF",
		power_up_high => "OFF",
		oe_reg   => "UNREGISTERED",
		lpm_hint => "UNUSED",
		lpm_type => "altddio_out",
		intended_device_family => "Cyclone II")
	port map (
		datain_h(0) => '0',
		datain_l(0) => '1',
		outclock => videoio_clk,
		outclocken => '1',
		dataout(0) => clk);
end;
