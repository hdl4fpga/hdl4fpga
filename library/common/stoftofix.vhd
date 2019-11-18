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
	type states is (init_s, data_s, addr_s);
	signal state  : states;
	signal fmt_do : std_logic_vector(4-1 downto 0);
begin

	process (clk)
		variable addr : signed(0 to mem_addr'length);
		variable stop : signed(addr'range);
		variable prec : signed(addr'range);
	begin
		if rising_edge(clk) then
			if frm='0' then
				bcd_end <= '0';

				state <= init_s;
			else
				case state is
				when init_s =>
					if signed(bcd_prec) <= 0 then
						prec := resize(signed(bcd_prec), stop'length);
					end if;

					if bcd_width=(bcd_width'range => '0') then
						if signed(bcd_left) < 0 then
							addr := (others => '0');
						else
							addr := resize(signed(bcd_left), addr'length);
						end if;
						stop := resize(signed(bcd_right), stop'length);
					else
						addr := signed(resize(unsigned(bcd_width), addr'length))+signed(bcd_right);
						if signed(bcd_right) < 0 then
							addr := addr - 1;
						end if;
						stop := resize(signed(bcd_right), stop'length);
					end if;
					
					fmt_do  <= "01--";
					bcd_end <= '0';
					
					state <= addr_s;

				when addr_s =>
					if addr < prec then
						fmt_do <= space;
					elsif signed(bcd_left) > 0 then
						if addr=resize(signed(bcd_left), addr'length) then
							if fmt_do = minus then
								fmt_do <= bcd_di;
							elsif fmt_do = plus then
								fmt_do <= bcd_di;
							elsif bcd_neg='1' then
								fmt_do <= minus;
							elsif bcd_sign='1' then
								fmt_do <= plus;
							else
								fmt_do <= "01--";
							end if;
						elsif addr > signed(bcd_left) then
							fmt_do <= space;
						elsif addr /= 0 then
							fmt_do <= "01--";
						end if;
					elsif addr >= signed(bcd_left) then
						if addr = 0 then
							case fmt_do is
							when minus|plus =>
								fmt_do <= bcd_di;
							when dot =>
								fmt_do <= dot;
							when others =>
								if bcd_neg='1' then
									fmt_do <= minus;
								elsif bcd_sign='1'  then
									fmt_do <= plus;
								else
									fmt_do <= zero;
								end if;
							end case;
						elsif addr > 0 then
							fmt_do <= space;
						elsif addr=resize(signed(bcd_left), addr'length) then
							fmt_do <= "01--";
						else
							fmt_do <= zero;
						end if;
					elsif addr >= signed(bcd_right) then
						fmt_do <= "01--";
					else
						fmt_do <= zero;
					end if;

					if addr = stop then
						bcd_end <= '1';
					end if;

					if bcd_irdy='1' then
						state <= data_s;
					end if;

				when data_s =>
					if bcd_irdy='1' then
						if bcd_end='0'then
							case fmt_do is
							when minus|plus =>
							when dot =>
								fmt_do <= "01--";
								addr   := addr - 1;
							when others =>
								if addr= 0 then
									if prec = 0 then
										addr   := addr - 1;
									else
										fmt_do <= dot;
									end if;
								else
									fmt_do <= "01--";
									addr   := addr - 1;
								end if;
							end case;
						end if;
					end if;

					if bcd_irdy='1' then
						state <= addr_s;
					end if;
				end case;
			end if;
			mem_addr <= std_logic_vector(addr(1 to mem_addr'length));
		end if;
	end process;

	bcd_trdy <= 
		'0' when state /= data_s else
		'0' when bcd_irdy ='0'   else
		frm;

	with fmt_do select
	mem_do <= 
		bcd_di when "01--",
		fmt_do when others;
end;
