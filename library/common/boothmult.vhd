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

entity boothmult is
	port (
		clk     : in  std_logic;
		ini     : in  std_logic;
		multand : in  signed;
		multier : in  signed;
		valid   : out std_logic;
		product : out signed);
end;

architecture def of boothmult is

		signal cntr : unsigned(0 to unsigned_num_bits(multier'length-1));
begin

	process(clk)
		variable acc : signed(0 to multier'length+multand'length-1);
		variable lsb : unsigned(0 to 2-1);
	begin
		if rising_edge(clk) then
			if ini='1' then
				lsb := (others => '0');
				acc := (multand'range => '0') & multier;
			else
				lsb    := lsb srl 1;
				lsb(0) := acc(acc'right);
				acc    := shift_right(acc, 1);
				case lsb is 
				when "10" =>
					acc(0 to multand'length-1) := acc(0 to multand'length-1) - multand;
				when "01" =>
					acc(0 to multand'length-1) := acc(0 to multand'length-1) + multand;
				when others =>
				end case;
			end if;
			product <= acc;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if ini='1' then
				cntr <= to_unsigned(multier'length-1, cntr'length);
			elsif cntr(0)='0' then
				cntr <= cntr - 1;
			end if;
			valid <= cntr(0);
		end if;
	end process;
end;
