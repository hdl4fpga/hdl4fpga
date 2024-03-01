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
		width     : in  std_logic_vector := (0 to 0 => '0');
		bcd_frm   : in  std_logic;
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic := '1';
		bcd       : in  std_logic_vector(0 to 4-1);
		code_frm  : buffer std_logic;
		code_irdy : out std_logic;
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

-- Combinatorial version
-- https://github.com/hdl4fpga/hdl4fpga/blob/62b576a8d626e379257136259202cbcdf41c3a45/library/basic/format.vhd#L24

architecture def of format is
	constant addr_size : natural := unsigned_num_bits(max_width/bcd_digits-1);
	signal bcd_wraddr  : std_logic_vector(1 to addr_size);

	signal fmt_req     : std_logic;
	signal fmt_rdy     : std_logic;
	signal code_req    : std_logic;
	signal code_rdy    : std_logic;

begin

	bcd_read_p : process (fmt_rdy, clk)
		type states is (s_init, s_blank, s_blanked);
		variable state : states;
		variable buff  : std_logic_vector(bcd'range);
	begin
		if rising_edge(clk) then
			if bcd_frm='1' then
				case state is
				when s_init =>
					if bcd=x"0" then
						buff  := multiplex(bcd_tab, blank, bcd'length);
						state := s_blank;
					elsif neg='1' then
						data <= fmt_wrdata;
						fmt_wrdata <= multiplex(bcd_tab, minus, bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_wrdata <= multiplex(bcd_tab, plus, bcd'length);
						state := s_blanked;
					else
						fmt_wrdata <= multiplex(bcd_tab, bcd, bcd'length);
						state := s_blanked;
					end if;
				when s_blank =>
					if bcd=x"0" then
						fmt_wrdata := buff;
						buff := multiplex(bcd_tab, blank, bcd'length);
					elsif neg='1' then
						fmt_wrdata <= multiplex(bcd_tab, minus, bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_wrdata <= multiplex(bcd_tab, plus, bcd'length);
						state := s_blanked;
					else 
						fmt_wrdata <= multiplex(bcd_tab, bcd, bcd'length);
						state := s_blanked;
					end if;
				when s_blanked =>
					fmt_wrdata <= multiplex(bcd_tab, bcd, bcd'length);
				end case;
				fmt_wraddr <= std_logic_vector(fmt_wrcntr(fmt_wraddr'range));
			else
				state := s_init;
			end if;
		end if;
	end process;

	code_frm  <= not bcd_frm when fmt_wraddr/=fmt_rdaddr else '0';
	code_irdy <= code_frm;
	code      <= multiplex(tab, fmt_wrdata, code'length);
end;