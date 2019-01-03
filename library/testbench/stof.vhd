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
	signal bcd_frm   : std_logic;
	signal bcd_di    : std_logic_vector(0 to 4-1);
	signal bcd_do    : std_logic_vector(0 to 4-1);
	signal bcd_left  : std_logic_vector(0 to 4-1);
	signal bcd_right : std_logic_vector(0 to 4-1);
	signal bcd_addr  : std_logic_vector(0 to 4-1) := (others => '0');
	signal fix_do    : std_logic_vector(4-1 downto 0);

	signal btod_frm  : std_logic;
	signal bcd_irdy : std_logic;
	signal bcd_trdy : std_logic;
	signal fix_irdy : std_logic;
	signal fix_trdy : std_logic;
	signal stof_frm  : std_logic;
	signal stof_eddn : std_logic;

	signal fmt : unsigned(6*4-1 downto 0);
begin

	rst <= '1', '0' after 35 ns;
	clk <= not clk  after 10 ns;

	process (rst, clk)
		variable num : unsigned(0 to 4*4-1) := x"1234";
		variable flt : unsigned(0 to 4-1)   := b"1110";
		variable frm : unsigned(0 to 4-1)   := b"1111";
	begin
		if rst='1' then
			bin_di  <= std_logic_vector(num(bin_di'range));
			bin_flt <= flt(0);
			bin_frm <= frm(0);
		elsif rising_edge(clk) then
			if bin_trdy='1' then
				num     := num rol bin_di'length;
				bin_di  <= std_logic_vector(num(bin_di'range));
				flt     := flt sll 1;
				bin_flt <= flt(0);
				frm     := frm sll 1;
				bin_frm <= frm(0);
			end if;
		end if;
	end process;

	bin_frm <= not rst;
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

	bcd_frm <= not rst;
	process (bcd_frm, clk)
	begin
		if bcd_frm='0' then
			bcd_addr <= bcd_left;
		elsif rising_edge(clk) then
			if bcd_trdy='1' then
				bcd_addr <= std_logic_vector(signed(bcd_addr) - 1);
			end if;
		end if;
	end process;
	bcd_di  <= bcd_do;

	stof_e : entity hdl4fpga.stof
	port map (
		clk       => clk,
		bcd_eddn  => stof_eddn,
		bcd_frm   => bcd_frm,
		bcd_left  => bcd_left,
		bcd_right => bcd_right,
		bcd_di    => bcd_di,
		bcd_irdy  => bcd_irdy,
		bcd_trdy  => bcd_trdy,
		fix_trdy  => fix_trdy,
		fix_irdy  => fix_trdy,
		fix_do    => fix_do);

	process (bcd_frm, clk)
		constant space : std_logic_vector(4-1 downto 0) := x"f";
	begin
		if bcd_frm='0' then
			fmt <= unsigned(fill(value => space, size => fmt'length));
		elsif rising_edge(clk) then
			if fix_trdy='1' then
				fmt <= fmt rol fix_do'length;
				fmt (fix_do'range) <= unsigned(fix_do);
			end if;
		end if;
	end process;
end;
