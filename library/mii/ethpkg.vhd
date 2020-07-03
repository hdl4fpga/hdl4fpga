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
use hdl4fpga.std.all;

package ethpkg is

	constant eth_hwda : natural := 0;
	constant eth_hwsa : natural := 1;
	constant eth_type : natural := 2;

	constant eth_frame : natural_vector := (
		eth_hwda => 6*8,
		eth_hwsa => 6*8,
		eth_type => 2*8);

	function eth_decode (
		constant ptr   : unsigned;
		constant frame : natural_vector;
		constant size  : natural)
		return std_logic_vector;

end;

package body ethpkg is

	function eth_decode (
		constant ptr   : unsigned;
		constant frame : natural_vector;
		constant size  : natural)
		return std_logic_vector is
		variable retval : std_logic_vector(frame'range);
		variable low    : natural;
		variable high   : natural;
	begin
		retval := (others => '0');
		low    := 0;
		for i in frame'range loop
			high := low + frame(i)/size;
			if low <= ptr and ptr < high then
				retval(i) := '1';
				exit;
			end if;
			low := high;
		end loop;
		return retval;
	end;

end;
