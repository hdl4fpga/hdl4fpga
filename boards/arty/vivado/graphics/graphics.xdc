# Copyright (c) <2015> <Miguel Angel Sagreras>                                    #
#                                                                                 #
# Permission is hereby granted, free of charge, to any person obtaining a copy of #
# this software and associated documentation files (the "Software"), to deal in   #
# the Software without restriction, including without limitation the rights to    #
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   #
# of the Software, and to permit persons to whom the Software is furnished to do  #
# so, subject to the following conditions:                                        #
#                                                                                 #
# The above copyright notice and this permission notice shall be included in all  #
# copies or substantial portions of the Software.                                 #
#                                                                                 #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   #
# SOFTWARE.                                                                       #
#                                                                                 #

set ddr_tck  1.667
set ddr_qh   [ expr $ddr_tck*0.38 ]
set ddr_dqsq 0.150

create_clock -name dqso0 -period $ddr_tck -waveform [list 0 [expr $ddr_tck/2 ]] [ get_ports ddr3_dqs_p[0] ]
set_input_delay -clock dqso0 -min [ expr -$ddr_dqsq ] [get_ports ddr3_dq[*] ]
set_input_delay -clock dqso0 -max $ddr_qh [get_ports ddr3_dq[*] ]

create_clock -name dqso1 -period $ddr_tck -waveform [list 0 [expr $ddr_tck/2 ]] [ get_ports ddr3_dqs_p[1] ]
set_input_delay -clock dqso1 -min [ expr -$ddr_dqsq ]  [get_ports ddr3_dq[*] ]
set_input_delay -clock dqso1 -max $ddr_qh [get_ports ddr3_dq[*] ]

set_clock_groups -asynchronous -group { sdrampll_b.ddr_clk0_mmce2 } -group { sys_clk    }
set_clock_groups -asynchronous -group { sdrampll_b.ddr_clk0_mmce2 } -group { eth_tx_clk }
set_clock_groups -asynchronous -group { sdrampll_b.ddr_clk0_mmce2 } -group { videopll_b.pll_i_n_1 }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { sdrampll_b.ddr_clk0_mmce2 }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { dd_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { eth_rx_clk }
set_clock_groups -asynchronous -group { eth_rx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { sys_clk    } -group { sdrampll_b.ddr_clk0_mmce2  }
set_clock_groups -asynchronous -group { sys_clk    } -group { sdrampll_b.ddr_clk90_mmce2 }
set_clock_groups -asynchronous -group { video_clk  } -group { eth_tx_clk  }
set_clock_groups -asynchronous -group { video_clk  } -group { sdrampll_b.ddr_clk0_mmce2 }
set_clock_groups -asynchronous -group { videopll_b.pll_i_n_1 } -group { eth_tx_clk }
set_clock_groups -asynchronous -group { videopll_b.pll_i_n_1 } -group { videopll_b.pll_i_n_3 }
set_clock_groups -asynchronous -group { videopll_b.pll_i_n_1 } -group { videopll_b.pll_i_n_3 }
set_clock_groups -asynchronous -group { dd_clk  }    -group { eth_tx_clk  }

set_clock_groups -asynchronous -group { dqso0      } -group { sys_clk    }
set_clock_groups -asynchronous -group { dqso0      } -group { sdrampll_b.ddr_clk0x2_mmce2 }
set_clock_groups -asynchronous -group { dqso0      } -group { sdrampll_b.ddr_clk90x2_mmce2 }

set_clock_groups -asynchronous -group { dqso1      } -group { sys_clk     }
set_clock_groups -asynchronous -group { dqso1      } -group { sdrampll_b.ddr_clk0x2_mmce2 }
set_clock_groups -asynchronous -group { dqso1      } -group { sdrampll_b.ddr_clk90x2_mmce2 }

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
