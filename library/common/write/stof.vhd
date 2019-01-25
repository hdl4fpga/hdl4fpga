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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity stof is
	generic (
		minus : std_logic_vector(4-1 downto 0) := x"d";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		zero  : std_logic_vector(4-1 downto 0) := x"0";
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk       : in  std_logic := '-';

		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : buffer std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_tail  : in  std_logic;
		bcd_di    : in  std_logic_vector;

		fix_frm   : in  std_logic;
		fix_trdy  : in  std_logic := '1';
		fix_irdy  : buffer std_logic;
		fix_end   : buffer std_logic;
		fix_do    : out std_logic_vector);
end;
		
architecture def of stof is
	signal fixoff_q : signed(bcd_left'range) := (others => '0');
	signal fixoff_d : signed(bcd_left'range) := (others => '0');
	signal fixidx_q : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal fixidx_d : unsigned(fixidx_q'range);
	signal bcdidx_q : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal bcdidx_d : unsigned(bcdidx_q'range);
	signal fixbuf_d : unsigned(fix_do'length-1 downto 0);
	signal fixbuf_q : unsigned(fix_do'length-1 downto 0);
	signal bcd_end  : std_logic;
begin

	fix_p : process (clk)
	begin
		if fix_frm='0' then
			fixoff_q <= (others => '0');
			fixidx_q <= (others => '0');
			fixbuf_q <= unsigned(fill(value => space, size => fix_do'length));
		elsif rising_edge(clk) then
			if bcd_trdy='1' then
				if bcd_irdy='1' then
					if fix_irdy='1' then
						if fix_trdy='1' then
							fixoff_q <= fixoff_d;
							fixbuf_q <= fixbuf_d;
						end if;
						fixidx_q <= fixidx_d;
					else
						fixidx_q <= fixidx_d;
						fixbuf_q <= fixbuf_d;
					end if;
				end if;
			end if;
			if fix_trdy='1' then
				fixoff_q <= fixoff_d;
			end if;
		end if;
	end process;

	bcdidx_p : process (fix_frm, clk)
	begin
		if fix_frm='0' then
			bcdidx_q <= (others => '0');
		elsif rising_edge(clk) then
			if bcd_irdy='1' then
				if bcd_trdy='1' then
					if fix_irdy='1' then
						if fix_trdy='1' then
							bcdidx_q <= bcdidx_d;
						end if;
					else
						bcdidx_q <= bcdidx_d;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(fix_frm, clk)
	begin
		if fix_frm='0' then
			bcd_end <= '0';
		elsif rising_edge(clk) then
			if bcd_end='0' then
				bcd_end <= fix_end;
			end if;
		end if;
	end process;

	fixfmt_p : process (bcd_left, bcd_di, bcd_irdy, fixbuf_q, fix_trdy, fixidx_q, fixoff_q, bcdidx_q)
		variable fixbuf : unsigned(fix_do'length-1 downto 0);
		variable bcdbuf : unsigned(bcd_di'length-1 downto 0);
		variable left   : signed(bcd_left'range);
		variable fixoff : signed(bcd_left'range);
		variable fixidx : unsigned(fixidx_d'range);
		variable bcdidx : unsigned(bcdidx_d'range);
		variable msg : line;
	begin

		bcd_trdy <= '0';
		fix_irdy <= bcd_irdy;

		bcdbuf := unsigned(bcd_di);
		fixbuf := fixbuf_q;
		fixoff := fixoff_q;
		bcdidx := bcdidx_q;
		fixidx := fixidx_q;
		fix_end <= bcd_tail;
		if signed(bcd_left) < 0 then
			left := signed(bcd_left)+fixoff_q;
			for i in 0 to fixbuf'length/space'length-1 loop
				if left <= -i then
					fixbuf := fixbuf rol space'length;
					if fixoff=1 then
						fixbuf(space'range) := unsigned(dot);
					else
						fixbuf(space'range) := unsigned(zero);
					end if;
				else
					if bcdidx >= bcdbuf'length/space'length then
						fix_irdy <= '0';
						exit;
					end if;

					fixbuf := fixbuf rol space'length;
					bcdbuf := bcdbuf rol space'length;
					fixbuf(space'range) := bcdbuf(space'range);

					bcdidx := bcdidx + 1;
				end if;
				fixoff := fixoff + 1;
				fixidx := fixidx + 1;
			end loop;
		else
			left := signed(bcd_left);
			for i in 0 to fixbuf'length/space'length-1 loop
				if bcdidx >= bcdbuf'length/space'length then
					fix_irdy <= '0';
					exit;
				end if;

				fixbuf := fixbuf rol space'length;
				if bcd_end='1' then
					fixbuf(space'range) := unsigned(space);
				elsif left-fixoff = -1 then
					fixbuf(space'range) := unsigned(dot);
					fix_end <= '0';
				else
					bcdbuf := bcdbuf rol space'length;
					fixbuf(space'range) := bcdbuf(space'range);
					bcdidx := bcdidx + 1;
				end if;
				fixoff := fixoff + 1;
				fixidx := fixidx + 1;
			end loop;
		end if;

		if bcdidx >= bcdbuf'length/space'length then
			bcdidx   := (others => '0');
			bcd_trdy <= fix_trdy;
		end if;

		if fixidx >= fix_do'length/space'length then
			fixidx   := (others => '0');
			fix_irdy <= bcd_irdy;
		end if;

		bcdidx_d <= bcdidx;
		fixidx_d <= fixidx;
		fixoff_d <= fixoff;
		fixbuf_d <= fixbuf;

		fix_do <= std_logic_vector(fixbuf);
	end process;

end;
