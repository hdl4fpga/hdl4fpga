#                                                                            #
# Author(s):                                                                 #
#   Miguel Angel Sagreras                                                    #
#                                                                            #
# Copyright (C) 2015                                                         #
#    Miguel Angel Sagreras                                                   #
#                                                                            #
# This source file may be used and distributed without restriction provided  #
# that this copyright statement is not removed from the file and that any    #
# derivative work contains  the original copyright notice and the associated #
# disclaimer.                                                                #
#                                                                            #
# This source file is free software; you can redistribute it and/or modify   #
# it under the terms of the GNU General Public License as published by the   #
# Free Software Foundation, either version 3 of the License, or (at your     #
# option) any later version.                                                 #
#                                                                            #
# This source is distributed in the hope that it will be useful, but WITHOUT #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   #
# more details at http://www.gnu.org/licenses/.                              #
#                                                                            #
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets eth_rxclk_bufg]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets eth_txclk_bufg]

create_clock -name sys_clk -period 10     -waveform { 0.0 5.000 } [ get_ports gclk100       ]
create_clock -name eth_rx_clk -period 40 -waveform { 0 20 } [ get_ports eth_rx_clk ]
create_clock -name eth_tx_clk -period 40 -waveform { 0 20 } [ get_ports eth_tx_clk ]

set_clock_groups -asynchronous -group { eth_rx_clk  } -group { sys_clk   }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { video_clk   }
#set_clock_groups -asynchronous -group { eth_rx_clk  } -group { input_clk }
set_clock_groups -asynchronous -group { eth_tx_clk  } -group { video_clk   }
set_clock_groups -asynchronous -group { video_clk   } -group { sys_clk   }
#set_clock_groups -asynchronous -group { video_clk   } -group { input_clk }
set_clock_groups -asynchronous -group { input_clk   } -group { video_clk }

set_property -dict { PACKAGE_PIN C2 IOSTANDARD LVCMOS18 } [get_ports resetn]

set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS18 } [get_ports gclk100]

set_property -dict { PACKAGE_PIN B8  IOSTANDARD LVCMOS33 } [ get_ports btn[3]]
set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [ get_ports btn[2]]
set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [ get_ports btn[1]]
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [ get_ports btn[0]]

set_property -dict { PACKAGE_PIN A10 IOSTANDARD LVCMOS33 } [ get_ports sw[3]]
set_property -dict { PACKAGE_PIN C10 IOSTANDARD LVCMOS33 } [ get_ports sw[2]]
set_property -dict { PACKAGE_PIN C11 IOSTANDARD LVCMOS33 } [ get_ports sw[1]]
set_property -dict { PACKAGE_PIN A8  IOSTANDARD LVCMOS33 } [ get_ports sw[0]]

set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [ get_ports led[3]]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [ get_ports led[2]]
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS18 } [ get_ports led[1]]
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS18 } [ get_ports led[0]]

set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS33 } [ get_ports uart_txd_in]
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS33 } [ get_ports uart_rxd_out]

set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS18 } [ get_ports RGBled[11]]
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS18 } [ get_ports RGBled[10]]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS18 } [ get_ports RGBled[9]]
set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS18 } [ get_ports RGBled[8]]
set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS18 } [ get_ports RGBled[7]]
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS18 } [ get_ports RGBled[6]]
set_property -dict { PACKAGE_PIN G3  IOSTANDARD LVCMOS18 } [ get_ports RGBled[5]]
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS18 } [ get_ports RGBled[4]]
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS18 } [ get_ports RGBled[3]]
set_property -dict { PACKAGE_PIN G6  IOSTANDARD LVCMOS18 } [ get_ports RGBled[2]]
set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS18 } [ get_ports RGBled[1]]
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS18 } [ get_ports RGBled[0]]

set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS25 } [ get_ports eth_rstn]
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_ref_clk]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS25 } [ get_ports eth_mdc]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_crs]
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_col]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS25 } [ get_ports eth_mdio]
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_tx_clk]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_tx_en]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rxd[0]]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rxd[1]]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rxd[2]]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rxd[3]]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS25 } [ get_ports eth_rx_clk]
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rxerr]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_rx_dv]
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_txd[0]]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_txd[1]]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_txd[2]]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS25 IOB TRUE } [ get_ports eth_txd[3]]

set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS25 } [get_ports { ja[1] }];
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS25 } [get_ports { ja[2] }];
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS25 } [get_ports { ja[3] }];
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS25 } [get_ports { ja[4] }];
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS25 } [get_ports { ja[7] }];
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS25 } [get_ports { ja[8] }];
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS25 } [get_ports { ja[9] }];
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS25 } [get_ports { ja[10] }];

set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS_25 } [get_ports { ja[1] }];
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS_25 } [get_ports { ja[2] }];
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS_25 } [get_ports { ja[3] }];
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS_25 } [get_ports { ja[4] }];
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS_25 } [get_ports { ja[7] }];
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS_25 } [get_ports { ja[8] }];
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS_25 } [get_ports { ja[9] }];
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS_25 } [get_ports { ja[10] }];

set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVDS_25 } [get_ports { jb[1] }];
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVDS_25 } [get_ports { jb[2] }];
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVDS_25 } [get_ports { jb[3] }];
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVDS_25 } [get_ports { jb[4] }];
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVDS_25 } [get_ports { jb[7] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVDS_25 } [get_ports { jb[8] }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVDS_25 } [get_ports { jb[9] }];
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVDS_25 } [get_ports { jb[10] }];

set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { jc[1] }];
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { jc[2] }];
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { jc[3] }];
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { jc[4] }];
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { jc[7] }];
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { jc[8] }];
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { jc[9] }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { jc[10] }];

set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS18 } [get_ports { jd[1] }];
set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS18 } [get_ports { jd[2] }];
set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS18 } [get_ports { jd[3] }];
set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS18 } [get_ports { jd[4] }];
set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS18 } [get_ports { jd[7] }];
set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS18 } [get_ports { jd[8] }];
set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS18 } [get_ports { jd[9] }];
set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS18 } [get_ports { jd[10] }];

