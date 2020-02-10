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

entity dmacntr is
	port (
		clk     : in  std_logic;
		load    : in  std_logic;
		ena     : in  std_logic := '0';
		updn    : in  std_logic := '0';
		addr    : in  std_logic_vector;
		bnk     : out std_logic_vector;
		row     : out std_logic_vector;
		col     : out std_logic_vector;
		bnk_eoc : out std_logic;
		row_eoc : out std_logic;
		col_eoc : out std_logic);
end;

architecture def of dmacntr is
	signal bnk_cntr1 : unsigned(0 to bnk'length);
	signal row_cntr1 : unsigned(0 to row'length);
begin

	cntr_p : process (clk)
		variable bnk_cntr  : unsigned(0 to bnk'length);
		variable row_cntr  : unsigned(0 to row'length);
		variable col_cntr  : unsigned(0 to col'length);

	begin
		if rising_edge(clk) then
			if load='1' then
				bnk_cntr  := resize((unsigned(addr) srl row'length), bnk_cntr'length);
				row_cntr  := resize((unsigned(addr) srl col'length), row_cntr'length);
				col_cntr  := resize((unsigned(addr) srl          0), col_cntr'length);

				if updn='0' then
					row_cntr1 <= row_cntr + 1;
					bnk_cntr1 <= bnk_cntr + 1;
				else
					row_cntr1 <= row_cntr - 1;
					bnk_cntr1 <= bnk_cntr - 1;
				end if;

				bnk <= std_logic_vector(resize(bnk_cntr, bnk'length));
				row <= std_logic_vector(resize(row_cntr, row'length));
				col <= std_logic_vector(resize(col_cntr, col'length));
				bnk_eoc <= '0';
				row_eoc <= '0';
				col_eoc <= '0';
			elsif ena='1' then
				if updn='0' then
					row_cntr1 <= row_cntr + 1;
					bnk_cntr1 <= bnk_cntr + 1;
					col_cntr  := col_cntr + 1;
				else
					row_cntr1 <= row_cntr - 1;
					bnk_cntr1 <= bnk_cntr - 1;
					col_cntr  := col_cntr - 1;
				end if;

				col_eoc <= col_cntr(0);
				col <= std_logic_vector(resize(col_cntr, col'length));
				if col_cntr(0)='0' then
					row <= std_logic_vector(resize(row_cntr, row'length));
					bnk <= std_logic_vector(resize(bnk_cntr, bnk'length));
					row_eoc <= row_cntr(0);
					bnk_eoc <= bnk_cntr(0);
				else
					row <= std_logic_vector(resize(row_cntr1, row'length));
					row_cntr := row_cntr1;
					row_eoc  <= bnk_cntr(0);
					if row_cntr(0)='0' then
						bnk <= std_logic_vector(resize(bnk_cntr, bnk'length));
						bnk_eoc <= bnk_cntr(0);
					else
						bnk <= std_logic_vector(resize(bnk_cntr1, bnk'length));
						bnk_cntr := bnk_cntr1;
						bnk_eoc  <= bnk_cntr(0);
						bnk_cntr(0) := '0';
						row_cntr(0) := '0';
					end if;
					col_cntr(0) := '0';
				end if;
			end if;
		end if;
	end process;

end;
