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
use hdl4fpga.base.all;

package ethpkg is

	constant octect_size  : natural := 8;

	type mode_t is (le, eq, ge, gt);

	constant eth_hwda : natural := 0;
	constant eth_hwsa : natural := 1;
	constant eth_type : natural := 2;

	constant llc_ip  : std_logic_vector := x"0800";
	constant llc_arp : std_logic_vector := x"0806";

	constant eth_frame : natural_vector := (
		eth_hwda => 6*8,
		eth_hwsa => 6*8,
		eth_type => 2*8);

	function frame_decode (
		constant ptr   : std_logic_vector;
		constant frame : natural_vector;
		constant size  : natural)
		return std_logic_vector;

	function frame_decode (
		constant ptr   : std_logic_vector;
		constant frame : natural_vector;
		constant size  : natural;
		constant field : natural;
		constant mode  : mode_t := eq;
		constant debug : boolean := false)
		return std_logic;

	function frame_decode (
		constant ptr    : std_logic_vector;
		constant frame  : natural_vector;
		constant size   : natural;
		constant fields : natural_vector;
		constant debug  : boolean := false)
		return std_logic;

	function reverse (
		constant arg : natural_vector)
		return natural_vector;

end;

package body ethpkg is

	function frame_decode (
		constant ptr   : std_logic_vector;
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
			if low <= unsigned(ptr) and unsigned(ptr) < high then
				retval(i) := '1';
				exit;
			end if;
			low := high;
		end loop;
		return retval;
	end;

	function frame_decode (
		constant ptr   : std_logic_vector;
		constant frame : natural_vector;
		constant size  : natural;
		constant field : natural;
		constant mode  : mode_t := eq;
		constant debug : boolean := false)
		return std_logic is
		variable retval : std_logic;
		variable sumup  : natural;
	begin
		retval := '0';
		sumup  := 0;
		for i in frame'range loop
			if i=field then
				case mode is
				when le =>
					if unsigned(ptr) < sumup+frame(i)/size then
						retval := '1';
					end if;
				when eq =>
					if sumup <= unsigned(ptr) and unsigned(ptr) < sumup+frame(i)/size then
						retval := '1';
					end if;
				when ge =>
					if sumup <= unsigned(ptr) then
						retval := '1';
					end if;
				when gt =>
					if sumup+frame(i)/size <= unsigned(ptr) then
						retval := '1';
					end if;
				end case;
				exit;
			end if;
			sumup := sumup + frame(i)/size;
		end loop;

		return retval;
	end;

	function frame_decode (
		constant ptr    : std_logic_vector;
		constant frame  : natural_vector;
		constant size   : natural;
		constant fields : natural_vector;
		constant debug : boolean := false)
		return std_logic is
		variable retval : std_logic;
		variable sumup  : natural;
	begin
		retval := '0';
		for i in fields'range loop
			retval := retval or frame_decode(ptr, frame, size, fields(i));
		end loop;

		return retval;
	end;

	function reverse (
		constant arg : natural_vector)
		return natural_vector is
		variable retval : natural_vector(arg'reverse_range);
	begin
		for i in arg'reverse_range loop
			retval(i) := arg(i);
		end loop;
		return retval;
	end;

end;
