# Copyright (c) 2015 Miguel Angel Sagreras                                       #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
#                                                                                #

set_clock_groups -asynchronous -group { eth_rx_clk } -group { sys_clk   }
set_clock_groups -asynchronous -group { eth_rx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { eth_rx_clk } -group { DCLK      }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { video_clk }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { DCLK      }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { eth_rx_clk }
set_clock_groups -asynchronous -group { video_clk  } -group { sys_clk   }
set_clock_groups -asynchronous -group { video_clk  } -group { DCLK      }
set_clock_groups -asynchronous -group { DCLK       } -group { video_clk }
set_clock_groups -asynchronous -group { DCLK       } -group { sdrampll_g.ddr_clk0_mmce2 }
set_clock_groups -asynchronous -group { eth_tx_clk } -group { sdrampll_g.ddr_clk0_mmce2 }
set_clock_groups -asynchronous -group { sdrampll_g.ddr_clk0_mmce2 }  -group { DCLK }
set_clock_groups -asynchronous -group { sdrampll_g.ddr_clk0_mmce2 }  -group { sys_clk }
set_clock_groups -asynchronous -group { sdrampll_g.ddr_clk90_mmce2 } -group { sys_clk }
set_clock_groups -asynchronous -group { sys_clk } -group { sdrampll_g.ddr_clk0_mmce2 } 
set_clock_groups -asynchronous -group { sys_clk } -group { sdrampll_g.ddr_clk90_mmce2 }



