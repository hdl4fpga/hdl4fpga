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

architecture stof of testbench is

	signal rst       : std_logic := '0';
	signal clk       : std_logic := '0';

	signal bin_frm  : std_logic;
	signal bin_irdy : std_logic;
	signal bin_trdy : std_logic;
	signal bin_di    : std_logic_vector(0 to 4-1);
	signal bin_flt   : std_logic;
	signal fix_do    : std_logic_vector(4-1 downto 0);

	signal fix_frm   : std_logic;
	signal fix_irdy  : std_logic;
	signal fix_trdy  : std_logic;

	signal fmt : unsigned(6*4-1 downto 0);
begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk  after 10 ns;

	process (rst, clk)
		variable frm : unsigned(0 to 4-1);
		variable flt : unsigned(0 to 4-1);

		variable num : unsigned(0 to 4*4-1) := x"123b";
	begin
		if rst='1' then
			frm     := (others => '1');
			flt     := b"0001";
			bin_di  <= std_logic_vector(num(bin_di'range));
			bin_flt <= '0';
			bin_frm <= '0';
		elsif rising_edge(clk) then
			if bin_trdy='1' then
				num     := num rol bin_di'length;
				bin_di  <= std_logic_vector(num(bin_di'range));
				flt     := flt sll 1;
				frm     := frm sll 1;
			end if;
			bin_frm <= frm(0);
			bin_flt <= flt(0);
		end if;
	end process;

	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		bin_frm   => bin_frm,
		bin_trdy  => bin_trdy,
		bin_flt   => bin_flt,
		bin_di    => bin_di,

		fix_frm   => fix_frm,
		fix_trdy  => fix_trdy,
		fix_irdy  => fix_trdy,
		fix_do    => fix_do);

	process (rst, bin_frm, clk)
		constant space : std_logic_vector(4-1 downto 0) := x"f";
		variable frm   : unsigned(0 to fmt'length/space'length-1);
	begin
		if rst='1' or bin_frm='1' then
			frm := (others => '1');
			fmt <= unsigned(fill(value => space, size => fmt'length));
		elsif rising_edge(clk) then
			if fix_trdy='1' then
				fmt <= fmt rol fix_do'length;
				fmt (fix_do'range) <= unsigned(fix_do);
				frm := frm sll 1;
			end if;
		end if;
		fix_frm <= (not rst and not bin_frm) and frm(0);
	end process;
end;
