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

package usbpkg is
	constant tk_out            : std_logic_vector := x"1";
	constant tk_in             : std_logic_vector := x"9";
	constant tk_setup          : std_logic_vector := x"d";
	constant tk_sof            : std_logic_vector := x"5";

	constant data0             : std_logic_vector := x"3";
	constant data1             : std_logic_vector := x"b";

	constant hs_ack            : std_logic_vector := x"2";
	constant hs_nack           : std_logic_vector := x"a";
	constant hs_stall          : std_logic_vector := x"e";

	type requests is (
    	get_status,
    	clear_status,
    	set_feature,
    	set_address,
    	get_descriptor,
    	set_descriptor,
    	get_configuration,
    	set_configuration,
    	get_interface,
    	set_interface,
    	synch_frame);

	type requestid_vector is array(requests) of std_logic_vector(4-1 downto 0);
	constant request_ids : requestid_vector := (
	    get_status        => x"0",
	    clear_status      => x"1",
	    set_feature       => x"3",
	    set_address       => x"5",
	    get_descriptor    => x"6",
	    set_descriptor    => x"7",
	    get_configuration => x"8",
	    set_configuration => x"9",
	    get_interface     => x"a",
	    set_interface     => x"b",
	    synch_frame       => x"c");

	constant device    : std_logic_vector := x"1";
	constant config    : std_logic_vector := x"2";
	constant string    : std_logic_vector := x"3";
	constant interface : std_logic_vector := x"4";
	constant endpoint  : std_logic_vector := x"5";
end;