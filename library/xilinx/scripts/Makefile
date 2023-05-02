#                                                                            #
# author(s):                                                                 #
#   miguel angel sagreras                                                    #
#                                                                            #
# copyright (c) 2015                                                         #
#    miguel angel sagreras                                                   #
#                                                                            #
# this source file may be used and distributed without restriction provided  #
# that this copyright statement is not removed from the file and that any    #
# derivative work contains  the original copyright notice and the associated #
# disclaimer.                                                                #
#                                                                            #
# this source file is free software; you can redistribute it and/or modify   #
# it under the terms of the gnu general public license as published by the   #
# free software foundation, either version 3 of the license, or (at your     #
# option) any later version.                                                 #
#                                                                            #
# this source is distributed in the hope that it will be useful, but without #
# any warranty; without even the implied warranty of merchantability or      #
# fitness for a particular purpose. see the gnu general public license for   #
# more details at http://www.gnu.org/licenses/.                              #
#                                                                            #
 vivado -mode batch myscript.tcl
open_project graphics.xpr
synth_design 
opt_design
place_design
route_design
write_bitstream -force $outputDir/cpu.bit
#
