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

set ddr_tck  1.667
set ddr_qh   [ expr $ddr_tck*0.38 ]
set ddr_dqsq 0.150

create_clock -name dqso0 -period $ddr_tck -waveform [list 0 [expr $ddr_tck/2 ]] [ get_ports ddr3_dqs_p[0] ]
set_input_delay -clock dqso0 -min [ expr -$ddr_dqsq ] [get_ports ddr3_dq[*] ]
set_input_delay -clock dqso0 -max $ddr_qh [get_ports ddr3_dq[*] ]

create_clock -name dqso1 -period $ddr_tck -waveform [list 0 [expr $ddr_tck/2 ]] [ get_ports ddr3_dqs_p[1] ]
set_input_delay -clock dqso1 -min [ expr -$ddr_dqsq ]  [get_ports ddr3_dq[*] ]
set_input_delay -clock dqso1 -max $ddr_qh [get_ports ddr3_dq[*] ]

#set_max_delay -datapath_only 0.0 -from [ get_clocks dqso0 ] -to [ get_clocks I* ]
#set_max_delay -datapath_only 0.0 -from [ get_clocks dqso1 ] -to [ get_clocks I* ]

set_clock_groups -asynchronous -group { ddr_clk0div_mmce2 } -group { sys_clk    }
set_clock_groups -asynchronous -group { ddr_clk0div_mmce2 } -group { eth_tx_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { ddr_clk0div_mmce2 }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { eth_rx_clk }
set_clock_groups -asynchronous -group { sys_clk    } -group { ddr_clk0div_mmce2  }
set_clock_groups -asynchronous -group { sys_clk    } -group { ddr_clk90div_mmce2 }
set_clock_groups -asynchronous -group { video_clk  } -group { eth_tx_clk  }

set_clock_groups -asynchronous -group { dqso0      } -group { sys_clk    }
set_clock_groups -asynchronous -group { dqso0      } -group { ddr_clk90_mmce2 }

set_clock_groups -asynchronous -group { dqso1      } -group { sys_clk     }
set_clock_groups -asynchronous -group { dqso1      } -group { ddr_clk90_mmce2 }

set_max_delay 0.0 -from [ get_ports ddr3_dqs_p[*] ]

set_false_path -from [ get_pins grahics_e/ddrctlr_b.ddrctlr_e/rdfifo_i/bytes_g[*].DATA_PHASES_g[*].inbyte_i/phases_g[*].ram_b/ram_g[*].ram_i/DP/CLK ] -to [ get_pins grahics_e/dmactlr_b.dmado_e/delay[*].q_reg[*]/D ]
set_false_path -from [ get_pins grahics_e/ddrctlr_b.ddrctlr_e/wrfifo_b.wrfifo_i/ddr_fifo_g[*].outbyte_i/phases_g[*].sr_g.gcntr_g[*].ffd_i/ffd_i/C   ] -to [ get_pins ddrphy_e/byte_g[*].ddrdqphy_i/oddr_g[*].registered_g[*].gear_g[*].dqo_reg[*]/D ]
set_false_path -from [ get_pins grahics_e/ddrctlr_b.ddrctlr_e/wrfifo_b.wrfifo_i/ddr_fifo_g[*].outbyte_i/phases_g[*].ram_b/ram_g[*].ram_i/DP/CLK     ] -to [ get_pins ddrphy_e/byte_g[*].ddrdqphy_i/oddr_g[*].registered_g[*].gear_g[*].dqo_reg[*]/D ]
set_false_path -from [ get_pins */rdfifo_i/sys_do_win_reg/C ] -to [ get_pins */rdfifo_i/bytes_g[*].DATA_PHASES_g[*].inbyte_i/phases_g[*].ar_g.gcntr_g[*].ffd_i/ffd_i/CLR ]
