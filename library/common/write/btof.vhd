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
		bin_trdy : buffer std_logic;
		bin_flt  : in  std_logic;
		bin_di   : in  std_logic_vector;
		fix_frm  : buffer std_logic;
		fix_end  : out std_logic;
		fix_trdy : in  std_logic := '1';
		fix_irdy : buffer std_logic;
		fix_do   : out std_logic_vector);
end;

architecture def of btof is

	signal btos_frm  : std_logic;
	signal btos_trdy : std_logic;
	signal bcd_rst   : std_logic;
	signal bcd_left  : std_logic_vector(0 to n-1);
	signal bcd_right : std_logic_vector(0 to n-1);
	signal bcd_addr  : std_logic_vector(0 to n-1);
	signal bcd_do    : std_logic_vector(fix_do'range);
	signal bcd_trdy  : std_logic;
	signal bcd_tail  : std_logic;

begin

	btos_frm <= bin_frm when fix_frm='0' else '0';
	bcd_rst  <= not bin_frm;
	btos_e : entity hdl4fpga.btos
	port map (
		clk       => clk,
		bin_frm   => btos_frm,
		bin_irdy  => bin_irdy,
		bin_trdy  => btos_trdy,
		bin_flt   => bin_flt,
		bin_di    => bin_di,

		bcd_rst   => bcd_rst,
		bcd_addr  => bcd_addr,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_do    => bcd_do);

	process(bin_frm, clk)
	begin
		if bin_frm='0' then
			fix_frm <='0' ;
		elsif rising_edge(clk) then
			if btos_trdy='1' then
				if bin_flt='1' then
					fix_frm <= '1' ;
				end if;
			end if;
		end if;
	end process;

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

	bcd_tail <= setif(bcd_addr=bcd_right);
	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_di    => bcd_do,
		bcd_tail  => bcd_tail,
		bcd_trdy  => bcd_trdy,

		fix_frm   => fix_frm,
		fix_trdy  => fix_trdy,
		fix_irdy  => fix_irdy,
		fix_end   => fix_end,
		fix_do    => fix_do);

	bin_trdy <= btos_trdy when bin_flt='0' else fix_trdy;
end;
