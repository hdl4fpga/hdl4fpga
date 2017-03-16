library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;
library hdl4fpga;

architecture beh of ecp3versa is

	signal ser_data : std_logic_vector(2*phy1_rx_d'length-1 downto 0);
	signal pll_data : std_logic_vector(64-1 downto 0);

begin

	dut : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => phy1_125clk,
		mii_rxdv => phy1_rx_dv,
		mii_rxd  => phy1_rx_d,
		pll_data => pll_data,
		ser_data => ser_data);

end;
