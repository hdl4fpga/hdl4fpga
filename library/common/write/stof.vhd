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
		frm       : in  std_logic;
		width     : in  std_logic_vector := (0 to 0 => '-');
		unit      : in  std_logic_vector := (0 to 0 => '-');
		neg       : in  std_logic := '0';
		sign      : in  std_logic := '1';

		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic;
		bcd_left  : in  std_logic_vector;
		bcd_right : in  std_logic_vector;
		bcd_prec  : in  std_logic_vector := (0 to 0 => 'U');
		bcd_di    : in  std_logic_vector;
		bcd_end   : out std_logic;

		mem_addr  : out std_logic_vector;
		mem_do    : out std_logic_vector);
end;
		
architecture def of stof is
	type states is (data_s, addr_s);
	signal state : states;

	type inputs is (plus_in, minus_in, zero_in, dot_in, dout_in);
	signal sel_mux : inputs;

	function length (
		constant sign  : std_logic;
		constant neg   : std_logic;
		constant left  : signed;
		constant right : signed)
		return signed is
		constant dot_length  : natural := 1;
		constant sign_length : natural := 1;
		variable retval : signed(left'range);
	begin
		if right >= 0 then
			retval := left+0+1;
		elsif left < 0 and right < 0 then
			retval := 0-right+1+dot_length;
		else
			retval :=  left-right+1+dot_length;
		end if;
		if sign='1' then
			retval := retval + 1;
		elsif neg='1' then
			retval := retval + 1;
		end if;
		return retval;
	end;

	function init_ptr (
		constant left : signed)
		return signed is
		variable retval : signed(left'range);
	begin
		retval := (others => '0');
		if left > 0 then
			retval := left;
		end if;
		return retval;
	end;
begin

	process (frm, clk)
	begin
		if frm='0' then
			state <= addr_s;
		elsif rising_edge(clk) then
			case state is
			when addr_s =>
				if bcd_irdy='1' then
					state <= data_s;
				end if;
			when data_s =>
				if bcd_irdy='1' then
					state <= addr_s;
				end if;
			end case;	
		end if;
	end process;


	process (frm, clk)
		variable ptr   : signed(bcd_left'range);
		variable point : std_logic;
		variable sign1 : std_logic;
	begin
		if frm='0' then
			point := '0';
			sign1 := sign;
			ptr   := signed(bcd_left);
		elsif rising_edge(clk) then
			case state is
			when addr_s =>
				if sign1='1' and neg='1' then
					sel_mux <= minus_in;
				elsif sign1='1' and neg='0' then
					sel_mux <= plus_in;
				elsif ptr+signed(unit)= -1 and point='0' then
					sel_mux <= dot_in;
				elsif ptr+signed(unit)=0 and signed(bcd_left)+signed(unit) < 0 then
					sel_mux <= zero_in;
				elsif ptr < signed(bcd_right) then
					sel_mux <= zero_in;
				else
					sel_mux <= dout_in;
				end if;
			when data_s =>
				if bcd_irdy='1' then
					if sign1='1' then
						sign1 := '0';
					elsif ptr = -1 then
						if point='0' then
							point := '1';
						else
							point := '0';
							ptr   := ptr - 1;
						end if;
					else
						ptr := ptr - 1;
					end if; 
				end if;
			end case;
		end if;
		mem_addr <= std_logic_vector(ptr);
	end process;

	with sel_mux select
	mem_do <= 
		minus  when minus_in,
		plus   when plus_in,
		dot    when dot_in,
		zero   when zero_in,
		bcd_di when dout_in;

	bcd_trdy <= setif(state=data_s and bcd_irdy='1');

end;
