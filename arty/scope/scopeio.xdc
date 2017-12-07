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
create_clock -name eth_tx_clk -period 40 -waveform { 0 20 } [ get_ports eth_tx_clk ]
 
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { sys_clk     }
set_clock_groups -asynchronous -group { eth_tx_clk  } -group { eth_rx_clk  }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { vga_clk     }
set_clock_groups -asynchronous -group { vga_clk     } -group { sys_clk     }

set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports gclk100]

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
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [ get_ports led[1]]
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [ get_ports led[0]]

set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [ get_ports RGBled[11]]
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [ get_ports RGBled[10]]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [ get_ports RGBled[9]]
set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [ get_ports RGBled[8]]
set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS33 } [ get_ports RGBled[7]]
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [ get_ports RGBled[6]]
set_property -dict { PACKAGE_PIN G3  IOSTANDARD LVCMOS33 } [ get_ports RGBled[5]]
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [ get_ports RGBled[4]]
set_property -dict { PACKAGE_PIN G4  IOSTANDARD LVCMOS33 } [ get_ports RGBled[3]]
set_property -dict { PACKAGE_PIN G6  IOSTANDARD LVCMOS33 } [ get_ports RGBled[2]]
set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS33 } [ get_ports RGBled[1]]
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [ get_ports RGBled[0]]

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

set_property -dict { PACKAGE_PIN G13 IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_0_15 Sch=ja[1]
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L4P_T0_15 Sch=ja[2]
set_property -dict { PACKAGE_PIN A11 IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L4N_T0_15 Sch=ja[3]
set_property -dict { PACKAGE_PIN D12 IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L6P_T0_15 Sch=ja[4]
set_property -dict { PACKAGE_PIN D13 IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L6N_T0_VREF_15 Sch=ja[7]
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports { ja[8] }]; #IO_L10P_T1_AD11P_15 Sch=ja[8]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { ja[9] }]; #IO_L10N_T1_AD11N_15 Sch=ja[9]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { ja[10] }]; #IO_L11P_T1_SRCC_15 Sch=ja[10]

set_property -dict { PACKAGE_PIN C5  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[0] }]; #IO_L1N_T0_AD4N_35 Sch=ck_an_n[0]
set_property -dict { PACKAGE_PIN C6  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[0] }]; #IO_L1P_T0_AD4P_35 Sch=ck_an_p[0]
set_property -dict { PACKAGE_PIN A5  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=ck_an_n[1]
set_property -dict { PACKAGE_PIN A6  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[1] }]; #IO_L3P_T0_DQS_AD5P_35 Sch=ck_an_p[1]
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[2] }]; #IO_L7N_T1_AD6N_35 Sch=ck_an_n[2]
set_property -dict { PACKAGE_PIN C4  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[2] }]; #IO_L7P_T1_AD6P_35 Sch=ck_an_p[2]
set_property -dict { PACKAGE_PIN A1  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[3] }]; #IO_L9N_T1_DQS_AD7N_35 Sch=ck_an_n[3]
set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[3] }]; #IO_L9P_T1_DQS_AD7P_35 Sch=ck_an_p[3]
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[4] }]; #IO_L10N_T1_AD15N_35 Sch=ck_an_n[4]
set_property -dict { PACKAGE_PIN B3  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[4] }]; #IO_L10P_T1_AD15P_35 Sch=ck_an_p[4]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[5] }]; #IO_L1N_T0_AD0N_15 Sch=ck_an_n[5]
set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[5] }]; #IO_L1P_T0_AD0P_15 Sch=ck_an_p[5]
set_property -dict { PACKAGE_PIN B7  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[6] }]; #IO_L2P_T0_AD12P_35 Sch=ad_p[12]
set_property -dict { PACKAGE_PIN B6  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[6] }]; #IO_L2N_T0_AD12N_35 Sch=ad_n[12]
set_property -dict { PACKAGE_PIN E6  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[7] }]; #IO_L5P_T0_AD13P_35 Sch=ad_p[13]
set_property -dict { PACKAGE_PIN E5  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[7] }]; #IO_L5N_T0_AD13N_35 Sch=ad_n[13]
set_property -dict { PACKAGE_PIN A4  IOSTANDARD LVCMOS33 } [get_ports { ck_an_p[8] }]; #IO_L8P_T1_AD14P_35 Sch=ad_p[14]
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports { ck_an_n[8] }]; #IO_L8N_T1_AD14N_35 Sch=ad_n[14]
set_property -dict { PACKAGE_PIN K9  } [get_ports { v_n[0]      }];
set_property -dict { PACKAGE_PIN J10 } [get_ports { v_p[0]      }]; 
