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

create_clock -name sys_clk -period 10 -waveform {0 5} [get_ports gclk100]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets dcms_e/ddrdcm_e/CLKIN]

create_clock -name dqso0 -period 3 -waveform {0 1.5} [get_ports ddr3_dqs_p[0]]
create_clock -name dqso1 -period 3 -waveform {0 1.5} [get_ports ddr3_dqs_p[1]]

create_clock -name eth_rx_clk -period 40 -waveform {0 20} [get_ports eth_rx_clk]
create_clock -name eth_tx_clk -period 40 -waveform {0 20} [get_ports eth_tx_clk]

# ###################### #
# Ignore crossclock time #
# ###################### #

#NET ddrs_clk0  TNM_NET = FFS  FFS_ddrsclk0;
#NET ddrs_clk0  TNM_NET = RAMS RAMS_ddrsclk0;
#
#NET ddrs_clk90 TNM_NET = FFS  FFS_ddrsclk90;
#NET ddrs_clk90 TNM_NET = RAMS RAMS_ddrsclk90;
#NET input_clk  TNM_NET = FFS  FFS_adcclkab;
#NET input_clk  TNM_NET = RAMS RAMS_adcclkab;
#NET gtx_clk    TNM_NET = FFS  FFS_gtxclk;
#NET gtx_clk    TNM_NET = RAMS RAMS_gtxclk;
##NET video_clk     TNM_NET = FFS  FFS_videoclk;
##NET video_clk     TNM_NET = RAMS RAMS_videoclk;

#TIMESPEC TS_r2o_ddr2ddr = FROM RAMS_ddrsclk0 TO FFS_ddrsclk90  TIG;
#TIMESPEC TS_f2r_ddr2ddr = FROM FFS_ddrsclk0  TO RAMS_ddrsclk90 TIG;
#TIMESPEC TS_f2f_adc2ddr = FROM FFS_adcclkab  TO FFS_ddrsclk0   TIG;
#TIMESPEC TS_r2f_adc2ddr = FROM RAMS_adcclkab TO FFS_ddrsclk0   TIG;
#TIMESPEC TS_f2f_ddr2adc = FROM FFS_ddrsclk0  TO FFS_adcclkab   TIG;

#set_false_path -to [get_cells (ddrphy_e/byte_g[*].ddrdqphy_i/oddr_g[*].ddrto_i/ffd_i)]

set_property INTERNAL_VREF 0.675 [get_iobanks 34]
# Others #
# ###### #

set_property IOSTANDARD DIFF_SSTL135 [get_ports ddr3_clk_p]
set_property IOSTANDARD DIFF_SSTL135 [get_ports ddr3_clk_n]
set_property IOSTANDARD DIFF_SSTL135 [get_ports ddr3_dqs_p[*]]
set_property IOSTANDARD DIFF_SSTL135 [get_ports ddr3_dqs_n[*]]
set_property IOSTANDARD SSTL135 [get_ports ddr3_dq[*]]
set_property IOSTANDARD SSTL135 [get_ports ddr3_dm[*]]
set_property IOSTANDARD SSTL135 [get_ports ddr3_we]
set_property IOSTANDARD SSTL135 [get_ports ddr3_cas]
set_property IOSTANDARD SSTL135 [get_ports ddr3_ras]
set_property IOSTANDARD SSTL135 [get_ports ddr3_cs]
set_property IOSTANDARD SSTL135 [get_ports ddr3_cke]
set_property IOSTANDARD SSTL135 [get_ports ddr3_odt]
set_property IOSTANDARD SSTL135 [get_ports ddr3_ba[*]]
set_property IOSTANDARD SSTL135 [get_ports ddr3_a[*]]
set_property IOSTANDARD SSTL135 [get_ports ddr3_reset]
set_property IOSTANDARD SSTL135 [get_ports ddr3_odt]

set_property LOC B8 [get_ports btn[3]]
set_property LOC B9 [get_ports btn[2]]
set_property LOC C9 [get_ports btn[1]]
set_property LOC D9 [get_ports btn[0]]

set_property LOC D10 [get_ports sw[3]]
set_property LOC C10 [get_ports sw[2]]
set_property LOC C11 [get_ports sw[1]]
set_property LOC A8  [get_ports sw[0]]

set_property LOC T10 [get_ports led[7]]
set_property LOC T9  [get_ports led[6]]
set_property LOC J5  [get_ports led[5]]
set_property LOC H5  [get_ports led[4]]

set_property LOC K1 [get_ports RGBled[11]]
set_property LOC H6 [get_ports RGBled[10]]
set_property LOC K2 [get_ports RGBled[9]]
set_property LOC J3 [get_ports RGBled[8]]
set_property LOC J2 [get_ports RGBled[7]]
set_property LOC H4 [get_ports RGBled[6]]
set_property LOC G3 [get_ports RGBled[5]]
set_property LOC J4 [get_ports RGBled[4]]
set_property LOC G4 [get_ports RGBled[3]]
set_property LOC G6 [get_ports RGBled[2]]
set_property LOC F6 [get_ports RGBled[1]]
set_property LOC E1 [get_ports RGBled[0]]

set_property LOC E3  [get_ports gclk100]
set_property LOC C16 [get_ports eth_rstn]
set_property LOC G18 [get_ports eth_ref_clk]
set_property LOC F16 [get_ports eth_mdc]
set_property LOC G14 [get_ports eth_crs]
set_property LOC D17 [get_ports eth_col]
set_property LOC K13 [get_ports eth_mdio]
set_property LOC H16 [get_ports eth_tx_clk]
set_property LOC H15 [get_ports eth_tx_en]
set_property LOC D18 [get_ports eth_rxd[0]]
set_property LOC E17 [get_ports eth_rxd[1]]
set_property LOC E18 [get_ports eth_rxd[2]]
set_property LOC G17 [get_ports eth_rxd[3]]
set_property LOC F15 [get_ports eth_rx_clk]
set_property LOC C17 [get_ports eth_rxerr]
set_property LOC G16 [get_ports eth_rx_dv]
set_property LOC H14 [get_ports eth_txd[0]]
set_property LOC J14 [get_ports eth_txd[1]]
set_property LOC J13 [get_ports eth_txd[2]]
set_property LOC H17 [get_ports eth_txd[3]]

set_property LOC K6 [get_ports ddr3_reset]
set_property LOC U9 [get_ports ddr3_clk_p]
set_property LOC V9 [get_ports ddr3_clk_n]
set_property LOC N5 [get_ports ddr3_cke]
set_property LOC U8 [get_ports ddr3_cs]
set_property LOC P3 [get_ports ddr3_ras]
set_property LOC M4 [get_ports ddr3_cas]
set_property LOC P5 [get_ports ddr3_we]
set_property LOC R5 [get_ports ddr3_odt]
set_property LOC P2 [get_ports ddr3_ba[2]]
set_property LOC P4 [get_ports ddr3_ba[1]]
set_property LOC R1 [get_ports ddr3_ba[0]]

set_property LOC T8 [get_ports ddr3_a[13]] 
set_property LOC T6 [get_ports ddr3_a[12]] 
set_property LOC U6 [get_ports ddr3_a[11]] 
set_property LOC R6 [get_ports ddr3_a[10]]
set_property LOC V7 [get_ports ddr3_a[9]] 
set_property LOC R8 [get_ports ddr3_a[8]] 
set_property LOC U7 [get_ports ddr3_a[7]] 
set_property LOC V6 [get_ports ddr3_a[6]] 
set_property LOC R7 [get_ports ddr3_a[5]] 
set_property LOC N6 [get_ports ddr3_a[4]] 
set_property LOC T1 [get_ports ddr3_a[3]] 
set_property LOC N4 [get_ports ddr3_a[2]] 
set_property LOC M6 [get_ports ddr3_a[1]] 
set_property LOC R2 [get_ports ddr3_a[0]] 

set_property LOC U1 [get_ports ddr3_dm[1]]   
set_property LOC L1 [get_ports ddr3_dm[0]]   
set_property LOC U2 [get_ports ddr3_dqs_p[1]]
set_property LOC V2 [get_ports ddr3_dqs_n[1]]
set_property LOC N2 [get_ports ddr3_dqs_p[0]]
set_property LOC N1 [get_ports ddr3_dqs_n[0]]
set_property LOC R3 [get_ports ddr3_dq[15]]  
set_property LOC U3 [get_ports ddr3_dq[14]]  
set_property LOC T3 [get_ports ddr3_dq[13]]  
set_property LOC V1 [get_ports ddr3_dq[12]]  
set_property LOC V5 [get_ports ddr3_dq[11]]  
set_property LOC U4 [get_ports ddr3_dq[10]]   
set_property LOC T5 [get_ports ddr3_dq[9]]   
set_property LOC V4 [get_ports ddr3_dq[8]]   
set_property LOC M2 [get_ports ddr3_dq[7]]   
set_property LOC L4 [get_ports ddr3_dq[6]]   
set_property LOC M1 [get_ports ddr3_dq[5]]   
set_property LOC M3 [get_ports ddr3_dq[4]]   
set_property LOC L6 [get_ports ddr3_dq[3]]   
set_property LOC K3 [get_ports ddr3_dq[2]]   
set_property LOC L3 [get_ports ddr3_dq[1]]   
set_property LOC K5 [get_ports ddr3_dq[0]]   
