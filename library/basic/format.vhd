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
use std.textio.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity format is
	generic (
		max_width : natural);
	port (
		tab       : in  std_logic_vector; -- := x"0123456789abcde";
		clk       : in  std_logic;
		neg       : in  std_logic := '0';
		sign      : in  std_logic := '0';
		bcd_frm   : in  std_logic;
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic := '1';
		bcd       : in  std_logic_vector(0 to 4-1);
		code_frm  : buffer std_logic;
		code_irdy : buffer std_logic;
		code_trdy : in  std_logic := '1';
		code      : out std_logic_vector);

	constant bcd_digits : natural := 1;
	constant bcd_tab    : std_logic_vector := x"0123456789abcdef";

	constant zero       : std_logic_vector(0 to bcd'length-1) := x"0";
	constant blank      : std_logic_vector(0 to bcd'length-1) := x"a";
	constant plus       : std_logic_vector(0 to bcd'length-1) := x"b";
	constant minus      : std_logic_vector(0 to bcd'length-1) := x"c";
	constant comma      : std_logic_vector(0 to bcd'length-1) := x"d";
	constant dot        : std_logic_vector(0 to bcd'length-1) := x"e";

end;

architecture def of format is
	signal fmt_bcd : std_logic_vector(bcd'range);
begin

	process (clk)
		type states is (s_init, s_blank, s_blanked);
		variable state : states;
		variable buff  : std_logic_vector(bcd'range);
		variable buff_frm : std_logic;
	begin
		if rising_edge(clk) then
			if bcd_frm='1' then
				case state is
				when s_init =>
					if bcd=x"0" then
						code_frm  <= '0';
						buff := multiplex(bcd_tab, blank, bcd'length);
						buff_frm := '1';
						bcd_trdy <= '1';
						state := s_blank;
					elsif neg='1' then
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, minus, bcd'length);
						buff_frm := '1';
						buff     := multiplex(bcd_tab, bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					elsif sign='1' then
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, plus, bcd'length);
						buff_frm := '1';
						buff     := multiplex(bcd_tab, bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					else
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, minus, bcd'length);
						buff_frm := '0';
						buff     := (others => '-');
						bcd_trdy <= '1';
						bcd_trdy <= '1';
						state := s_blanked;
					end if;
				when s_blank =>
					if bcd=x"0" then
						fmt_bcd  <= buff;
						code_frm <= buff_frm;
						buff_frm := '1';
						buff     := multiplex(bcd_tab, blank, bcd'length);
						bcd_trdy <= '1';
					elsif neg='1' then
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, minus, bcd'length);
						buff_frm := '1';
						buff     := multiplex(bcd_tab,   bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					elsif sign='1' then
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, plus, bcd'length);
						buff_frm := '1';
						buff     := multiplex(bcd_tab,  bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					elsif bcd=x"e" then 
						code_frm <= '1';
						fmt_bcd  <= multiplex(bcd_tab, x"0", bcd'length);
						buff_frm := '1';
						buff     := multiplex(bcd_tab, bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					else 
						code_frm <= buff_frm;
						fmt_bcd  <= buff;
						buff_frm := '1';
						buff     := multiplex(bcd_tab, bcd, bcd'length);
						bcd_trdy <= '1';
						state := s_blanked;
					end if;
				when s_blanked =>
					code_frm <= buff_frm;
					fmt_bcd  <= buff;
					buff_frm := '1';
					buff     := multiplex(bcd_tab, bcd, bcd'length);
					bcd_trdy <= '1';
				end case;
			else
				code_frm <= buff_frm;
				fmt_bcd  <= buff;
				buff     := multiplex(bcd_tab, bcd, bcd'length);
				buff_frm := '0';
				bcd_trdy <= '0';
				state := s_init;
			end if;
		end if;
	end process;
	code <= multiplex(tab, fmt_bcd, code'length);
end;