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
		bcd_end   : out std_logic;

		mem_addr  : out std_logic_vector;
		mem_do    : out std_logic_vector);
end;
		
architecture def of stof is
	type states is (init_s, data_s, addr_s);
	signal state : states;

	type inputs is (plus_in, minus_in, zero_in, dot_in, blank_in, dout_in);
	signal sel_mux : inputs;

	constant dot_length  : natural := 1;
	constant bcd_sign_length : natural := 1;

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

	process (clk)
		variable addr : signed(bcd_left'range);
	begin
		if rising_edge(clk) then
			if frm='0' then
				state <= init_s;
			else
				case state is
				when init_s =>
					if signed(bcd_left) < 0 then
						addr := (others => '0');
						addr := addr + 1;	-- place of the decimal dot added
					else
						addr := signed(bcd_left);
					end if;
					
					state <= addr_s;
				when addr_s =>
					if addr > signed(bcd_left) then
						if addr = 0 then
							mem_do <= dot;
						else
							mem_do <= zero;
						end if;
					else
						mem_do <= bcd_di;
					end if;

					if bcd_irdy='1' then
						state <= data_s;
					end if;
				when data_s =>
					if bcd_irdy='1' then
						addr := addr - 1;
					end if;

					if bcd_irdy='1' then
						state <= addr_s;
					end if;
				end case;
			end if;
			mem_addr <= std_logic_vector(addr);
		end if;
	end process;

	bcd_trdy <= 
		'0' when state /= data_s else
		'0' when bcd_irdy ='0'   else
		frm;

end;
