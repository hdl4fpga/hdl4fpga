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

 
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { sys_clk   }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { video_clk }
set_clock_groups -asynchronous -group { eth_rx_clk  } -group { DCLK      }
set_clock_groups -asynchronous -group { eth_tx_clk  } -group { video_clk }
set_clock_groups -asynchronous -group { eth_tx_clk  } -group { DCLK      }
set_clock_groups -asynchronous -group { eth_tx_clk  } -group { eth_rx_clk }
set_clock_groups -asynchronous -group { video_clk   } -group { sys_clk   }
set_clock_groups -asynchronous -group { video_clk   } -group { DCLK      }
set_clock_groups -asynchronous -group { DCLK        } -group { video_clk }