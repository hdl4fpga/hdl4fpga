--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;

entity main is
end;

architecture def of main is
begin
	process 
		constant altab  : natural_vector := lattab(hdo(sdram_db)**".ddr3.al", 8);
		constant bltab  : natural_vector := lattab(hdo(sdram_db)**".ddr3.bl", 8);
		constant cltab  : natural_vector := lattab(hdo(sdram_db)**".ddr3.cl", 8);
		constant wrltab : natural_vector := lattab(hdo(sdram_db)**".ddr3.wrl={}.", 8);
		constant cwltab : natural_vector := lattab(hdo(sdram_db)**".ddr3.cwl={}.", 8);
		constant xxxx : natural := max(natural_vector'(max(altab), max(bltab), max(cltab), max(wrltab), max(cwltab)));
	begin
		report LF & natural'image(xxxx);
		wait;
	end process;
end;
