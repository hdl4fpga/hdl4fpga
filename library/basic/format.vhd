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
	type xxx is array (0 to 3-1) of std_logic_vector(bcd'range);
	signal fmt_bcd : xxx;
	signal fmt_ena : std_logic_vector(xxx'range);
begin

	process (clk)
		type states is (s_init, s_blank, s_blanked);
		variable state : states;
	begin
		if rising_edge(clk) then
			fmt_ena(0) <= fmt_ena(1);
			fmt_bcd(0) <= fmt_bcd(1);
			if bcd_frm='1' then
				case state is
				when s_init =>
					if bcd=x"0" then
						fmt_ena(1) <= '0';
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, blank, bcd'length);
						state := s_blank;
					elsif neg='1' then
						fmt_ena(1) <= '0';
						fmt_bcd(1) <= multiplex(bcd_tab, minus, bcd'length);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab,   bcd,   bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_ena(1) <= '1';
						fmt_bcd(1) <= multiplex(bcd_tab, plus, bcd'length);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, bcd,  bcd'length);
						state := s_blanked;
					else
						fmt_ena(1) <= '0';
						fmt_bcd(1) <= multiplex(bcd_tab, bcd, bcd'length);
						fmt_ena(2) <= '0';
						fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
						state := s_blanked;
					end if;
				when s_blank =>
					if bcd=x"0" then
						fmt_ena(1) <= fmt_ena(2);
						fmt_bcd(1) <= fmt_bcd(2);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, blank, bcd'length);
					elsif neg='1' then
						fmt_ena(1) <= '1';
						if fmt_bcd(1)=x"a" then
							fmt_bcd(0) <= multiplex(bcd_tab, minus, bcd'length);
							fmt_bcd(1) <= x"0";
						else
							fmt_bcd(1) <= multiplex(bcd_tab, minus, bcd'length);
						end if;
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab,   bcd, bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_ena(1) <= '1';
						fmt_bcd(1) <= multiplex(bcd_tab, plus, bcd'length);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab,  bcd, bcd'length);
						state := s_blanked;
					elsif bcd=x"e" then 
						fmt_ena(1) <= '1';
						fmt_bcd(1) <= multiplex(bcd_tab, x"0", bcd'length);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
						state := s_blanked;
					else 
						fmt_ena(1) <= fmt_ena(2);
						fmt_bcd(1) <= fmt_bcd(2);
						fmt_ena(2) <= '1';
						fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
						state := s_blanked;
					end if;
				when s_blanked =>
					fmt_ena(1) <= fmt_ena(2);
					fmt_bcd(1) <= fmt_bcd(2);
					fmt_ena(2) <= '1';
					fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
				end case;
			else
				fmt_ena(1) <= fmt_ena(2);
				if fmt_bcd(2)=x"a" then
					fmt_bcd(1) <= x"0";
				else
					fmt_bcd(1) <= fmt_bcd(2);
				end if;
				fmt_ena(2) <= '0';
				fmt_bcd(2) <= multiplex(bcd_tab, bcd, bcd'length);
				state := s_init;
			end if;
		end if;
	end process;
	bcd_trdy <= bcd_frm;
	code_frm <= fmt_ena(0);
	code     <= multiplex(tab, fmt_bcd(0), code'length);
end;