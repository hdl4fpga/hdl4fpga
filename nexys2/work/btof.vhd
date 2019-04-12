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

library hdl4fpga;

entity test_btof is
	port (
		clk      : in  std_logic;
		bin_frm  : in  std_logic;
		bin_irdy : in  std_logic;
		bin_trdy : buffer std_logic;
		bin_flt  : in  std_logic;
		bin_di   : in  std_logic_vector(4-1 downto 0);

		fix_frm  : buffer std_logic;
		fix_end  : out std_logic;
		fix_trdy : out  std_logic;
		fix_irdy : in std_logic;
		fix_do   : out std_logic_vector(4-1 downto 0));
end;

architecture test of test_btof is
begin
	du : entity hdl4fpga.btof
	port map (
		clk      => clk,
		bin_frm  => bin_frm ,
		bin_irdy => bin_irdy,
		bin_trdy => bin_trdy,
		bin_flt  => bin_flt ,
		bin_di   => bin_di  ,
		
		bcd_trdy => fix_trdy,
		bcd_irdy => fix_irdy,
		
		bcd_do   => fix_do);

end ;
