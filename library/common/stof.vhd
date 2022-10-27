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
use hdl4fpga.base.all;

entity stof is
	generic (
		minus : std_logic_vector(4-1 downto 0) := x"d";
		plus  : std_logic_vector(4-1 downto 0) := x"c";
		zero  : std_logic_vector(4-1 downto 0) := x"0";
		dot   : std_logic_vector(4-1 downto 0) := x"b";
		space : std_logic_vector(4-1 downto 0) := x"f");
	port (
		clk       : in  std_logic := '-';
		frm       : in  std_logic;

		bcd_endian: in  std_logic := '0';
		bcd_align : in  std_logic := '0';
		bcd_width : in  std_logic_vector;
		bcd_unit  : in  std_logic_vector;
		bcd_neg   : in  std_logic := '0';
		bcd_sign  : in  std_logic := '1';
		bcd_prec  : in  std_logic_vector;

		bcd_irdy  : in  std_logic;
		bcd_trdy  : out std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_di    : in  std_logic_vector;
		bcd_end   : buffer std_logic;

		mem_addr  : buffer std_logic_vector;
		mem_do    : out std_logic_vector);
end;
		
architecture def of stof is
	signal fmt_do : std_logic_vector(4-1 downto 0);
begin

	process (clk)
		type states is (init_s, check0_s, data_s, addr_s);
		variable state  : states;

		variable sign   : std_logic;
		variable addr   : signed(0 to mem_addr'length);
		variable stop   : signed(addr'range);
		variable prec   : signed(addr'range);
		variable left   : signed(addr'range);
		variable right  : signed(addr'range);
		variable offset : signed(addr'range);
	begin
		if rising_edge(clk) then
			case state is
			when init_s =>
				bcd_end  <= '0';
				bcd_trdy <= '0';

				offset := resize(signed(bcd_unit), offset'length);
				left   := offset + resize(signed(bcd_left),  left'length);
				right  := offset + resize(signed(bcd_right), right'length);
				sign   := bcd_sign;

				if signed(bcd_prec) <= 0 then
					prec := resize(signed(bcd_prec),  prec'length);
				elsif right <= 0 then
					prec := right;
				else
					prec := (others => '0');
				end if;

				if bcd_width=(bcd_width'range => '0') then
					if left < 0 then
						addr := (others => '0');
					else
						addr := left;
					end if;
					stop := prec;
				elsif bcd_align='1' then
					if left < 0 then
						addr := (others => '0');
					else
						addr := left;
					end if;

					stop := addr - signed(resize(unsigned(bcd_width), stop'length))+1;

					if signed(prec) < 0 then
						stop := stop + 1;
					end if;

					if bcd_neg='1' then
						stop := stop + 1;
					elsif bcd_sign='1' then
						stop := stop + 1;
					end if;
				else
					addr := signed(resize(unsigned(bcd_width), addr'length)) + prec - 1;
					if signed(prec) < 0 then
						addr := addr - 1;
					end if;

					if bcd_neg='1' then
						addr := addr - 1;
					elsif bcd_sign='1' then
						addr := addr - 1;
					end if;
					stop := prec;
				end if;
				
				fmt_do  <= "0100";
				bcd_end <= '0';
				
				if frm='0' then
					state := init_s;
				else
					state := check0_s;
				end if;
				mem_addr <= (mem_addr'range => '0');

			when check0_s =>
				bcd_end  <= '0';
				bcd_trdy <= '0';

				if bcd_left=(bcd_left'range => '0') then
					if bcd_di=(bcd_di'range => '0') then
						left   := (others => '0');
						right  := (others => '0');
						offset := (others => '0');
						sign   := '0';

--						report itoa(to_integer(stop)) & " " & itoa(to_integer(addr));
						if bcd_width=(bcd_width'range => '0') then
							addr := (others => '0');
						elsif signed(bcd_unit) > 0 then
							if bcd_align='1' then
								stop := stop - signed(bcd_unit);
							end if;
						end if;
--						report itoa(to_integer(stop)) & " " & itoa(to_integer(addr));

						if bcd_neg='1' then
							if bcd_align='1' then
								stop := stop - 1;
							else
								addr := addr + 1;
							end if;
						elsif bcd_sign='1' then
							if bcd_align='1' then
								stop := stop - 1;
							else
								addr := addr + 1;
							end if;
						end if;
					end if;
				end if;
				mem_addr <= std_logic_vector(addr(1 to mem_addr'length)-offset(1 to mem_addr'length));

				if frm='0' then
					state := init_s;
				else
					state := addr_s;
				end if;

			when addr_s =>
				bcd_end  <= '0';
				bcd_trdy <= '0';
				data_if : if addr < prec then
					fmt_do <= space;
				elsif left > 0 then
					if addr=left then
						if fmt_do = minus then
							fmt_do <= bcd_di;
						elsif fmt_do = plus then
							fmt_do <= bcd_di;
						elsif bcd_neg='1' then
							fmt_do <= minus;
						elsif sign='1' then
							fmt_do <= plus;
						else
							fmt_do <= "0100";
						end if;
					elsif addr > left then
						fmt_do <= space;
					elsif addr /= 0 then
						if addr >= right then
							fmt_do <= "0100";
						elsif addr >= prec then
							fmt_do <= zero;
						else
							fmt_do <= space;
						end if;
					elsif addr < right then
						if fmt_do /= dot then
							fmt_do <= zero;
						end if;
					end if;
				elsif addr >= left then
					if addr = 0 then
						case fmt_do is
						when minus|plus =>
							if addr > left then
								fmt_do <= zero;
							else
								fmt_do <= bcd_di;
							end if;
						when dot =>
							fmt_do <= dot;
						when others =>
							if bcd_neg='1' then
								fmt_do <= minus;
							elsif sign='1'  then
								fmt_do <= plus;
							elsif left=0 then
								fmt_do <= "0100";
							else
								fmt_do <= zero;
							end if;
						end case;
					elsif addr > 0 then
						fmt_do <= space;
					elsif addr=left then
						fmt_do <= "0100";
					else
						fmt_do <= zero;
					end if;
				elsif addr >= right then
					fmt_do <= "0100";
				elsif addr >= prec then
					fmt_do <= zero;
				else
					fmt_do <= space;
				end if;

				finish_if : if addr = stop then
					if addr >= left then
						if addr = 0 then
							case fmt_do is
							when minus|plus =>
								bcd_end <= '1';
							when others =>
								if bcd_neg='0' then
									if sign='0'  then
										bcd_end <= '1';
									end if;
								end if;
							end case;
						else
							bcd_end <= '1';
						end if;
					else
						bcd_end <= '1';
					end if;
				end if;

				if bcd_irdy='1' then
					bcd_trdy <= '1';
				else
					bcd_trdy <= '0';
				end if;
				mem_addr <= std_logic_vector(addr(1 to mem_addr'length)-offset(1 to mem_addr'length));

				if frm='0' then
					state := init_s;
				elsif bcd_irdy='1' then
					state := data_s;
				end if;

			when data_s =>
				if bcd_irdy='1' then
					bcd_trdy <= '0';
					if bcd_end='0'then
						case fmt_do is
						when minus|plus =>
						when dot =>
							fmt_do <= "0100";
							addr   := addr - 1;
						when others =>
							if addr= 0 then
								if prec = 0 then
									addr   := addr - 1;
								else
									fmt_do <= dot;
								end if;
							else
								fmt_do <= "0100";
								addr   := addr - 1;
							end if;
						end case;
					elsif bcd_irdy='1' then
						bcd_end <= '0';
					end if;
				else
					bcd_trdy <= '1';
				end if;
				mem_addr <= std_logic_vector(addr(1 to mem_addr'length)-offset(1 to mem_addr'length));

				if frm='0' then
					state := init_s;
				elsif bcd_irdy='1' then
					if bcd_end='0' then
						state := addr_s;
					else
						state := init_s;
					end if;
				end if;
			end case;
		end if;
	end process;

	with fmt_do select
	mem_do <= 
		bcd_di when "0100"|"0101"|"0111"|"0110",
		fmt_do when others;
end;
