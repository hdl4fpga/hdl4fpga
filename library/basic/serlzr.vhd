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

entity serlzr is
	port (
		clk    : in  std_logic;
		frm    : in  std_logic;
		data_i : in  std_logic_vector;
		data_o : out std_logic_vector);
end;

architecture def of serlzr  is
	signal shf  : std_logic_vector(unsigned_num_bits(data_i'length)-1 downto 0);
	signal rgtr : std_logic_vector(data_i'length+data_o'length-2 downto 0);
	signal shfd : std_logic_vector(rgtr'range);
begin 

	process (clk)
		variable shr : unsigned(data_i'length+data_o'length-2 downto 0);
		variable acc : unsigned(shf'range);
	begin 
		if rising_edge(clk) then
			if frm='0' then
				acc := (others => '0');
			elsif acc >= data_o'length then 
				acc := acc - data_o'length;
			else
				shr := shift_left(shr, data_i'length);
				shr(data_i'length-1 downto 0) := unsigned(data_i);
				acc := acc + (data_i'length - data_o'length);
			end if;
			shf  <= std_logic_vector(acc);
			rgtr <= std_logic_vector(shr);
		end if;
	end process;

	shl_i : entity hdl4fpga.barrel
	generic map (
		left => false)
	port map (
		shf => shf,
		di  => rgtr,
		do  => shfd);
	
	data_o <= shfd(data_o'length-1 downto 0);
end;
