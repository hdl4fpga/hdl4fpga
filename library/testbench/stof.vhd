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

architecture btos of testbench is

	signal rst       : std_logic := '0';
	signal clk       : std_logic := '0';

	signal bin_frm   : std_logic;
	signal bin_flt   : std_logic;
	signal bin_di    : std_logic_vector(0 to 4-1);
	signal bcd_do    : std_logic_vector(0 to 4-1);
	signal bcd_left  : std_logic_vector(0 to 4-1);
	signal bcd_right : std_logic_vector(0 to 4-1);
	signal bcd_addr  : std_logic_vector(0 to 4-1) := (others => '0');
	signal fix_do    : std_logic_vector(0 to 2*4-1);

	signal btod_frm  : std_logic;
	signal btod_irdy : std_logic;
	signal btod_trdy : std_logic;
	signal stof_frm  : std_logic;
	signal stof_eddn : std_logic;

begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk  after 10 ns;

	bin_frm <= not rst;
	process (clk, bin_frm)
		variable bin : unsigned(0 to 4*4-1) := x"10f8";
		variable flt : unsigned(0 to 4*1-1) := b"0001";
		variable frm : unsigned(0 to 4*1-1) := b"1111";
	begin
		if rising_edge(clk) then
			if bin_frm='0' then
				btod_irdy <= '0';
				bin_flt    <= '0';
			else
				if btod_trdy='1' then
					frm := frm sll 1;
					flt := flt sll 1;
					bin := bin sll 4;
				end if;
				btod_irdy <= frm(0);
				bin_flt   <= std_logic(flt(0));
				bin_di    <= std_logic_vector(bin(bin_di'range));
			end if;
		end if;
		btod_frm <= bin_frm and frm(0);
	end process;

	stof_frm <= bin_frm and not btod_frm;
	process (bin_frm, btod_frm, clk)
		variable frm : std_logic;
	begin
		if rising_edge(clk) then
			frm := btod_frm;
		end if;
	end process;

	btod_e : entity hdl4fpga.btos
	port map (
		clk       => clk,
		bin_frm   => btod_frm,
		bin_trdy  => btod_trdy,
		bin_irdy  => btod_irdy,
		bin_di    => bin_di,
		bin_flt   => bin_flt,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_addr  => bcd_addr,
		bcd_do    => bcd_do);

	stof_eddn <= bin_flt;
	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		bcd_eddn  => stof_eddn,
		bcd_frm   => stof_frm,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_di    => bcd_do,
		fix_do    => fix_do);

end;
