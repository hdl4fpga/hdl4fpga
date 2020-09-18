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

create_clock -name sys_clk -period 10     -waveform { 0.0 5.000 } [ get_ports gclk100       ]

create_clock -name eth_rx_clk -period 40 -waveform { 0 20 } [ get_ports eth_rx_clk ]
 
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { sys_clk   }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { vga_clk   }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { input_clk }
set_clock_groups -asynchronous -group { vga_clk     } -group { sys_clk   }
set_clock_groups -asynchronous -group { vga_clk     } -group { input_clk }
set_clock_groups -asynchronous -group { input_clk   } -group { vga_clk }

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

set_property -dict { PACKAGE_PIN A9  IOSTANDARD LVCMOS18 } [ get_ports uart_txd_in]
set_property -dict { PACKAGE_PIN D10 IOSTANDARD LVCMOS18 } [ get_ports uart_rxd_out]

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

set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [ get_ports eth_rstn]
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_ref_clk]
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 } [ get_ports eth_mdc]
set_property -dict { PACKAGE_PIN G14 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_crs]
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_col]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [ get_ports eth_mdio]
set_property -dict { PACKAGE_PIN H16 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_tx_clk]
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_tx_en]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rxd[0]]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rxd[1]]
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rxd[2]]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rxd[3]]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [ get_ports eth_rx_clk]
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rxerr]
set_property -dict { PACKAGE_PIN G16 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_rx_dv]
set_property -dict { PACKAGE_PIN H14 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_txd[0]]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_txd[1]]
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_txd[2]]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 IOB TRUE } [ get_ports eth_txd[3]]
                      
set_property INTERNAL_VREF 0.675 [get_iobanks 34]

set_property -dict { PACKAGE_PIN U9  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_clk_p    ]
set_property -dict { PACKAGE_PIN V9  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_clk_n    ]
set_property -dict { PACKAGE_PIN U2  IOSTANDARD SSTL135 } [ get_ports ddr3_dqs_p[1] ]
set_property -dict { PACKAGE_PIN V2  IOSTANDARD SSTL135 } [ get_ports ddr3_dqs_n[1] ]
set_property -dict { PACKAGE_PIN N2  IOSTANDARD SSTL135 } [ get_ports ddr3_dqs_p[0] ]
set_property -dict { PACKAGE_PIN N1  IOSTANDARD SSTL135 } [ get_ports ddr3_dqs_n[0] ]

set_property -dict { PACKAGE_PIN R3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[15] ]  
set_property -dict { PACKAGE_PIN U3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[14] ]  
set_property -dict { PACKAGE_PIN T3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[13] ]  
set_property -dict { PACKAGE_PIN V1  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[12] ]  
set_property -dict { PACKAGE_PIN V5  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[11] ]  
set_property -dict { PACKAGE_PIN U4  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[10] ]   
set_property -dict { PACKAGE_PIN T5  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 9] ]   
set_property -dict { PACKAGE_PIN V4  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 8] ]   
set_property -dict { PACKAGE_PIN M2  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 7] ]   
set_property -dict { PACKAGE_PIN L4  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 6] ]   
set_property -dict { PACKAGE_PIN M1  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 5] ]   
set_property -dict { PACKAGE_PIN M3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 4] ]   
set_property -dict { PACKAGE_PIN L6  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 3] ]   
set_property -dict { PACKAGE_PIN K3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 2] ]   
set_property -dict { PACKAGE_PIN L3  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 1] ]   
set_property -dict { PACKAGE_PIN K5  IOSTANDARD SSTL135 } [ get_ports ddr3_dq[ 0] ]   
set_property -dict { PACKAGE_PIN U1  IOSTANDARD SSTL135 } [ get_ports ddr3_dm[ 1] ]   
set_property -dict { PACKAGE_PIN L1  IOSTANDARD SSTL135 } [ get_ports ddr3_dm[ 0] ]   

set_property -dict { PACKAGE_PIN K6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_reset ]
set_property -dict { PACKAGE_PIN N5  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_cke   ]
set_property -dict { PACKAGE_PIN U8  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_cs    ]
set_property -dict { PACKAGE_PIN P3  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_ras   ]
set_property -dict { PACKAGE_PIN M4  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_cas   ]
set_property -dict { PACKAGE_PIN P5  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_we    ]
set_property -dict { PACKAGE_PIN R5  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_odt   ]
set_property -dict { PACKAGE_PIN P2  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_ba[2] ]
set_property -dict { PACKAGE_PIN P4  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_ba[1] ]
set_property -dict { PACKAGE_PIN R1  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_ba[0] ]

set_property -dict { PACKAGE_PIN T8  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[13] ] 
set_property -dict { PACKAGE_PIN T6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[12] ] 
set_property -dict { PACKAGE_PIN U6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[11] ] 
set_property -dict { PACKAGE_PIN R6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[10] ]
set_property -dict { PACKAGE_PIN V7  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 9] ] 
set_property -dict { PACKAGE_PIN R8  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 8] ] 
set_property -dict { PACKAGE_PIN U7  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 7] ] 
set_property -dict { PACKAGE_PIN V6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 6] ] 
set_property -dict { PACKAGE_PIN R7  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 5] ] 
set_property -dict { PACKAGE_PIN N6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 4] ] 
set_property -dict { PACKAGE_PIN T1  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 3] ] 
set_property -dict { PACKAGE_PIN N4  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 2] ] 
set_property -dict { PACKAGE_PIN M6  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 1] ] 
set_property -dict { PACKAGE_PIN R2  IOSTANDARD SSTL135 IOB TRUE } [ get_ports ddr3_a[ 0] ] 

set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS33 } [get_ports { ja[1] }];
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { ja[2] }];
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS33 } [get_ports { ja[3] }];
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports { ja[4] }];
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { ja[7] }];
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports { ja[8] }];
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { ja[9] }];
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { ja[10] }];

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

