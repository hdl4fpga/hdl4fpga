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
