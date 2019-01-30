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

entity test_btod is
	port (
		clk           : in  std_logic;

		bin_frm       : in  std_logic;
		bin_irdy      : in  std_logic;
		bin_trdy      : out std_logic;
		bin_di        : in  std_logic_vector(4-1 downto 0);

		mem_ena       : out std_logic;
		mem_full      : in  std_logic;

		mem_left      : in  std_logic_vector(4-1 downto 0);
		mem_left_up   : out std_logic;
		mem_left_ena  : out std_logic;

		mem_right     : in  std_logic_vector(4-1 downto 0);
		mem_right_up  : out std_logic;
		mem_right_ena : out std_logic;

		mem_addr      : out std_logic_vector(4-1 downto 0);
		mem_di        : out std_logic_vector(4-1 downto 0);
		mem_do        : in  std_logic_vector(4-1 downto 0));
end;

architecture btod of test_btod is
begin
	du_e : entity hdl4fpga.btod
	port map (
		clk           => clk,
                                      
		bin_frm       => bin_frm,
		bin_irdy      => bin_irdy,
		bin_trdy      => bin_trdy,
		bin_di        => bin_di,
                                      
		mem_ena       => mem_ena,
		mem_full      => mem_full,
                                      
		mem_left      => mem_left,
		mem_left_up   => mem_left_up,
		mem_left_ena  => mem_left_ena,
                                      
		mem_right     => mem_right,
		mem_right_up  => mem_right_up ,
		mem_right_ena => mem_right_ena,
                                      
		mem_addr      => mem_addr,
		mem_di        => mem_di,
		mem_do        => mem_do);
end;
