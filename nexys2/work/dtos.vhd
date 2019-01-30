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

entity test_dtos is
	port (
		clk           : in  std_logic;

		bcd_frm       : in  std_logic;
		bcd_irdy      : in  std_logic;
		bcd_trdy      : out std_logic;
		bcd_di        : in  std_logic_vector(4-1 downto 0);
		bcd_cy        : out std_logic;

		mem_full      : in  std_logic;
		mem_ena       : out std_logic;

		mem_left      : in std_logic_vector(4-1 downto 0);
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in std_logic_vector(4-1 downto 0);
		mem_right_up  : out std_logic;
		mem_right_ena : out std_logic;

		mem_addr      : out std_logic_vector(4-1 downto 0);
		mem_do        : in  std_logic_vector(4-1 downto 0);
		mem_di        : out std_logic_vector(4-1 downto 0));
end;

architecture test of test_dtos is
begin
	du : entity hdl4fpga.dtos
	port map (
		clk           => clk,
                                      
		bcd_frm       => bcd_frm,
		bcd_irdy      => bcd_irdy,
		bcd_trdy      => bcd_trdy,
		bcd_di        => bcd_di,
		bcd_cy        => bcd_cy,
                                      
		mem_full      => mem_full,
		mem_ena       => mem_ena,
                                      
		mem_left      => mem_left,
		mem_left_up   => mem_left_up,
		mem_left_ena  => mem_left_ena,
                                      
		mem_right     => mem_right,
		mem_right_up  => mem_right_up,
		mem_right_ena => mem_right_ena,
                                      
		mem_addr      => mem_addr,
		mem_do        => mem_do ,
		mem_di        => mem_di);
end;
