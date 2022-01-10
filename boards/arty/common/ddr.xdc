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

set_property INTERNAL_VREF 0.675 [get_iobanks 34]

create_clock -name dqso0   -period  1.667 -waveform { 0.0 0.833 } [ get_ports ddr3_dqs_p[0] ]
create_clock -name dqso1   -period  1.667 -waveform { 0.0 0.833 } [ get_ports ddr3_dqs_p[1] ]

set_max_delay 0.0 -from [ get_ports ddr3_dqs_p[*] ]
set_max_delay -datapath_only 0.0 -from [ get_clocks dqso0 ] -to [ get_clocks I* ]
set_max_delay -datapath_only 0.0 -from [ get_clocks dqso1 ] -to [ get_clocks I* ]
set_input_delay -clock dqso0 -max 0 [get_ports ddr3_dq[*] ]
set_input_delay -clock dqso1 -max 0 [get_ports ddr3_dq[*] ]

set_property -dict { PACKAGE_PIN U9  IOSTANDARD DIFF_SSTL135 IOB TRUE } [ get_ports ddr3_clk_p    ]
set_property -dict { PACKAGE_PIN V9  IOSTANDARD DIFF_SSTL135 IOB TRUE } [ get_ports ddr3_clk_n    ]
set_property -dict { PACKAGE_PIN U2  IOSTANDARD DIFF_SSTL135 } [ get_ports ddr3_dqs_p[1] ]
set_property -dict { PACKAGE_PIN V2  IOSTANDARD DIFF_SSTL135 } [ get_ports ddr3_dqs_n[1] ]
set_property -dict { PACKAGE_PIN N2  IOSTANDARD DIFF_SSTL135 } [ get_ports ddr3_dqs_p[0] ]
set_property -dict { PACKAGE_PIN N1  IOSTANDARD DIFF_SSTL135 } [ get_ports ddr3_dqs_n[0] ]

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
