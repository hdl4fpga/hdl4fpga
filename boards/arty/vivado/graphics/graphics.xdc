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
# This source is distributed in the hope that it will be usef`ul, but WITHOUT #
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

set_clock_groups -asynchronous -group { dcm_b.ddr_b.ddr_clk0_mmce2 } -group { sys_clk    }
set_clock_groups -asynchronous -group { dcm_b.ddr_b.ddr_clk0_mmce2 } -group { eth_tx_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { ddr_clk0_mmce2 }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { dd_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { eth_rx_clk }
set_clock_groups -asynchronous -group { sys_clk    } -group { dcm_b.ddr_b.ddr_clk0_mmce2  }
set_clock_groups -asynchronous -group { sys_clk    } -group { dcm_b.ddr_b.ddr_clk90_mmce2 }
set_clock_groups -asynchronous -group { video_clk  } -group { eth_tx_clk  }
set_clock_groups -asynchronous -group { dd_clk  }    -group { eth_tx_clk  }

set_clock_groups -asynchronous -group { dqso0      } -group { sys_clk    }
set_clock_groups -asynchronous -group { dqso0      } -group { dcm_b.ddr_b.ddr_clk0x2_mmce2 }
set_clock_groups -asynchronous -group { dqso0      } -group { dcm_b.ddr_b.ddr_clk90x2_mmce2 }

set_clock_groups -asynchronous -group { dqso1      } -group { sys_clk     }
set_clock_groups -asynchronous -group { dqso1      } -group { dcm_b.ddr_b.ddr_clk0x2_mmce2 }
set_clock_groups -asynchronous -group { dqso1      } -group { dcm_b.ddr_b.ddr_clk90x2_mmce2 }

set_max_delay 0.0 -from [ get_ports ddr3_dqs_p[*] ]

set_false_path -from [ get_pins sdrphy_e/*/*/mem*/*/CLK    ] -to [ get_pins sdrphy_e/*/*/*/D* ]
set_false_path -from [ get_pins sdrphy_e/*/*/mem*/*/CLK    ] -to [ get_pins graphics_e/*/*/D  ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/*/T* ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/D* ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/*/D* ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/*/CLR ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/DP/CLK   ] -to [ get_pins sdrphy_e/*/*/D ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/S ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/CE ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/R ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/*/R ]
set_false_path -from [ get_pins sdrphy_e/*/*/ram*/RAM*/CLK ] -to [ get_pins sdrphy_e/*/*/*/*/WE ]