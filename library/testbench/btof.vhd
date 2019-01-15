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

entity btof is
	generic (
		n : natural := 4);
	port (
		clk      : in  std_logic;
		bin_frm  : in  std_logic;
		bin_irdy : in  std_logic := '1';
		bin_trdy : out std_logic;
		bin_flt  : in  std_logic;
		bin_di   : in  std_logic_vector;
		fix_frm  : out std_logic;
		fix_trdy : in  std_logic := '1';
		fix_irdy : out std_logic;
		fix_do   : out std_logic_vector);
end;

architecture def of btof is

	signal bcd_left  : std_logic_vector(0 to n-1);
	signal bcd_right : std_logic_vector(0 to n-1);
	signal bcd_addr  : std_logic_vector(0 to n-1);
	signal bcd_do    : std_logic_vector(fix_do'range);
	signal bcd_trdy  : std_logic;

begin

	btos_e : entity hdl4fpga.btos
	port map (
		clk       => clk,
		bin_frm   => bin_frm,
		bin_irdy  => bin_irdy,
		bin_trdy  => bin_trdy,
		bin_flt   => bin_flt,
		bin_di    => bin_di,

		bcd_addr  => bcd_addr,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_do    => bcd_do);

	process (fix_frm, clk)
	begin
		if fix_frm='0' then
			bcd_addr <= bcd_left;
		elsif rising_edge(clk) then
			if bcd_trdy='1' then
				bcd_addr <= std_logic_vector(signed(bcd_addr) - 1);
			end if;
		end if;
	end process;

	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_di    => bcd_do,
		bcd_trdy  => bcd_trdy,

		fix_frm   => fix_frm,
		fix_trdy  => fix_trdy,
		fix_irdy  => fix_trdy,
		fix_do    => fix_do);

end;
