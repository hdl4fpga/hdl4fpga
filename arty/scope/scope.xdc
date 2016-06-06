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

create_clock -name sys_clk -period 10 ns -waveform {0 5} [get_ports sys_clk]

create_clock -name dqso0 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[0]]
create_clock -name dqso1 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[1]]
create_clock -name dqso2 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[2]]
create_clock -name dqso3 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[3]]
create_clock -name dqso4 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[4]]
create_clock -name dqso5 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[5]]
create_clock -name dqso6 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[6]]
create_clock -name dqso7 -period 3 ns -waveform {0 1.5} [get_ports ddr2_dqs_p[7]]

create_clock -name eth_rx_clk -period 40 ns -waveform {0 20} [get_ports eth_rx_clk]
create_clock -name eth_tx_clk -period 40 ns -waveform {0 20} [get_ports eth_tx_clk]

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

set_false_path -to [get_cells (ddrphy_e/byte_g[*].ddrdqphy_i/oddr_g[*].ddrto_i/ffd_i)]

# Others #
# ###### #


set_property IOSTANDARD DIFF_SSTL18_II     [get_ports ddr3_clk_p[*]]
set_property IOSTANDARD DIFF_SSTL18_II     [get_ports ddr3_clk_n[*]]
set_property IOSTANDARD DIFF_SSTL18_II_DCI [get_ports ddr3_dqs_p[*]]
set_property IOSTANDARD DIFF_SSTL18_II_DCI [get_ports ddr3_dqs_n[*]]
set_property IOSTANDARD SSTL18_II_DCI      [get_ports ddr3_d[*]]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_dm[*]]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_we]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_cas]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_ras]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_cs]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_cke]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_odt]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_ba[*]]
set_property IOSTANDARD SSTL18_II          [get_ports ddr3_a[*]]
