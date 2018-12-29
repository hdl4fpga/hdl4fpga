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
		bcd_eddn  : in  std_logic := '0';
		bcd_frm   : in  std_logic := '1';
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : buffer std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_di    : in  std_logic_vector;
		bcd_addr  : buffer std_logic_vector;
		fix_irdy  : buffer std_logic;
		fix_trdy  : in  std_logic := '1';
		fix_do    : out std_logic_vector);
end;
		
architecture def of stof is
	signal fixoff_q : signed(bcd_left'range) := (others => '0');
	signal fixoff_d : signed(bcd_left'range) := (others => '0');
	signal fixidx_q : unsigned(unsigned_num_bits(fix_do'length/space'length)-1 downto 0);
	signal fixidx_d : unsigned(fixidx_q'range);
	signal bcdidx_q : unsigned(unsigned_num_bits(bcd_di'length/space'length)-1 downto 0);
	signal bcdidx_d : unsigned(bcdidx_q'range);
begin

	fixoff_p : process (clk)
	begin
		if bcd_frm='0' then
			fixoff_q <= (others => '0');
		elsif rising_edge(clk) then
			if bcd_trdy='1' then
				if bcd_irdy='1' then
					if fix_irdy='1' then
						if fix_trdy='1' then
							fixoff_q <= fixoff_d;
							fixidx_q <= fixidx_d;
						end if;
					else
						fixoff_q <= fixoff_d;
						fixidx_q <= fixidx_d;
					end if;
				end if;
			end if;
		end if;
	end process;

	bcdidx_p : process (bcd_frm, clk)
	begin
		if bcd_frm='0' then
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

	fixfmt_p : process (bcd_left, bcd_di, bcd_irdy, fix_trdy, fixidx_q, fixoff_q, bcdidx_q)
		variable fmt    : unsigned(fix_do'length-1 downto 0);
		variable codes  : unsigned(bcd_di'length-1 downto 0);
		variable left   : signed(bcd_left'range);
		variable fixoff : signed(bcd_left'range);
		variable fixidx : unsigned(fixidx_d'range);
		variable bcdidx : unsigned(bcdidx_d'range);
	begin

		codes  := unsigned(bcd_di);
		fmt    := unsigned(fill(value => space, size => fmt'length));
		bcd_trdy <= '0';
		fix_irdy <= bcd_irdy;

		fixoff := fixoff_q;
		bcdidx := bcdidx_q;
		fixidx := fixidx_q;
		if signed(bcd_left) < 0 then
			left := signed(bcd_left)+fixoff_q;
			for i in 0 to fmt'length/space'length-1 loop
				if left <= -i then
					fmt := fmt rol space'length;
					if fixoff=1 then
						fmt(space'range) := unsigned(dot);
					else
						fmt(space'range) := unsigned(zero);
					end if;
				else
					if bcdidx >= codes'length/space'length then
						fix_irdy <= '0';
						exit;
					end if;

					fmt   := fmt   rol space'length;
					codes := codes rol space'length;
					fmt(space'range) := codes(space'range);

					bcdidx := bcdidx + 1;
				end if;
				fixoff := fixoff + 1;
				fixidx := fixidx + 1;
			end loop;
		else
			left := signed(bcd_left)-fixoff_q;
			for i in 0 to fmt'length/space'length-1 loop
				if bcdidx >= codes'length/space'length then
					fix_irdy <= '0';
					exit;
				end if;

				fmt := fmt rol space'length;
				if left-fixoff=-1 then
					fmt(space'range) := unsigned(dot);
				else
					codes := codes rol space'length;
					fmt(space'range) := codes(space'range);
					bcdidx := bcdidx + 1;
				end if;
				fixoff := fixoff + 1;
				fixidx := fixidx + 1;
			end loop;
		end if;

		if bcdidx >= codes'length/space'length then
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

		fix_do <= std_logic_vector(fmt);
	end process;

	

end;
