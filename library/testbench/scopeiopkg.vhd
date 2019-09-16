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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use  hdl4fpga.std.all;
use  hdl4fpga.scopeiopkg.all;

architecture scopeiopkg of testbench is

		constant width  : natural := 33;
		constant height : natural := 10;
		constant layout : tag_vector(analogtime_layout'range) := text_setaddr(
			analogtime_layout, 
			width,
			height);
		constant rom    : std_logic_vector(0 to width*height*ascii'length-1) := text_content(
			analogtime_layout, 
			width,
			height,
			lang_en);
			signal clk : std_logic := '0';
		signal cga_frm     : std_logic_vector(7-1 downto 0) := ('1', others => '0');
		signal var_id      : std_logic_vector(5-1 downto 0) := (others => '0');
		signal vt_chanid   : std_logic_vector(4-1 downto 0) := (others => '0');
		signal gain_chanid : std_logic_vector(6-1 downto 0) := (others => '0');
begin

		var_id <= std_logic_vector(to_unsigned(primux(
			(
				0 => var_hzoffsetid, 
				1 => var_hzdivid,  
				2 => var_triggerid, 
				3 => word2byte((0 => var_vtoffsetid),   vt_chanid), 
				4 => word2byte((0 => var_vtoffsetid+1), vt_chanid)) &
--				3 => to_integer(mul(unsigned(vt_chanid),3)+var_vtoffsetid), 
--				4 => to_integer(mul(unsigned(gain_chanid),3)+var_vtoffsetid+1)) &
			(
				0 => var_hzunitid,   
				1 => word2byte((0 => var_vtoffsetid+2), gain_chanid)),
--				1 => to_integer(mul(unsigned(gain_chanid),3)+var_vtoffsetid+2)),
			cga_frm), var_id'length));
			
		clk <= not clk after 5 ns;
		process(clk)
		begin
			if rising_edge(clk) then
				cga_frm <= std_logic_Vector(unsigned(cga_frm) ror 1);
			end if;
		end process;
end;
