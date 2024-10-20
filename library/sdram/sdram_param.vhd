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
use hdl4fpga.hdo.all;

package sdram_param is

	constant sdram_db : string := compact("{" &
		"sdr : {" &
		"    al  : { '000' : 0 }," &
		"    bl  : { '000' : 0, '001' : 1, '010' : 2, '011' : 4 }," &
		"    cl  : { '001' : 1, '010' : 2, '011' : 3 }," &
		"    cwl : { '000' : 0 }}," &
		"ddr : {" &
		"    al  : { '000' : 0}" &
		"    bl  : { '001' : 2, '010' : 4, '011' : 8}," &
		"    cl  : { '010' : 4, '110' : 5, '011' : 3}," &
		"    cwl : { '000' : 2}}," &
		"ddr2 : {" &
		"    al  : { '000' : 0, '001' : 2, 010 :  4, 011 :  6, 100 :  8, 101 : 10, 110: 12}," &
		"    bl  : { '010' : 2, '011' : 8}," &
		"    cl  : { '011' : 6, '100' : 8, '101' : 10, '110' : 12, '111' : 14}," &
		"    wrl : { '001' : 4, '010' : 6, '011' :  8, '100' : 10, '101' : 12, '110' : 14, '111' : 16}}," &
		"ddr3 : {" &
		"    al  : { '000' :  0, '001' :  2, '010' :  4}," &
		"    bl  : { '000' :  8, '001' :  8, '010' :  8}," &
		"    cl  : { '001' : 10, '010' : 12, '011' : 14, '100' : 16, '101' : 18, '110' : 20, '111' : 22}," &
		"    wrl : { '001' : 10, '010' : 12, '011' : 14, '100' : 16, '101' : 20, '110' : 24}," &
		"    cwl : { '000' : 10, '001' : 12, '010' : 14, '011' : 16}}}");

	type sdram_cmd is record
		cs  : std_logic;
		ras : std_logic;
		cas : std_logic;
		we  : std_logic;
	end record;

	constant sdram_nop : sdram_cmd := (cs => '0', ras => '1', cas => '1', we => '1');
	constant sdram_mrs : sdram_cmd := (cs => '0', ras => '0', cas => '0', we => '0');
	constant sdram_pre : sdram_cmd := (cs => '0', ras => '0', cas => '1', we => '0');
	constant sdram_ref : sdram_cmd := (cs => '0', ras => '0', cas => '0', we => '1');
	constant sdram_zqc : sdram_cmd := (cs => '0', ras => '1', cas => '1', we => '0');

	constant mpu_nop   : std_logic_vector(0 to 2) := "111";
	constant mpu_act   : std_logic_vector(0 to 2) := "011";
	constant mpu_read  : std_logic_vector(0 to 2) := "101";
	constant mpu_write : std_logic_vector(0 to 2) := "100";
	constant mpu_pre   : std_logic_vector(0 to 2) := "010";
	constant mpu_aut   : std_logic_vector(0 to 2) := "001";
	constant mpu_dcare : std_logic_vector(0 to 2) := "000";

	function lattab (
		constant table  : string;
		constant length : natural)
		return natural_vector;
end package;

package body sdram_param is

	function lattab (
		constant table  : string;
		constant length : natural)
		return natural_vector is
		variable retval : natural_vector(0 to length-1);
	begin
		retval := (others => 0);
		for i in 0 to length-1 loop
			retval(i) := hdo(table)**("."&"'"&to_string(to_unsigned(i,unsigned_num_bits(length-1)))&"'"&"=0.");
		end loop;
		return retval;
	end;

end package body;
