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

entity ddrdma is
	port (
		ddrdma_frm  : in  std_logic;
		ddrdma_irdy : in  std_logic;
		ddrdma_trdy : out std_logic;
		ddrdma_iaddr : in  std_logic_vector;
		ddrdma_ilen  : in  std_logic_vector;

		ddr_clk     : in  std_logic;
		ddr_frm     : out std_logic;
		ddr_irdy    : out std_logic;
		ddr_trdy    : in  std_logic;
		ddr_refreq  : in  std_logic;
		ddr_act     : in  std_logic;
		ddr_cas     : in  std_logic;
		ddr_bnk     : out std_logic_vector;
		ddr_row     : out std_logic_vector;
		ddr_col     : out std_logic_vector);
end;

architecture def of ddrdma is
begin

	process (ddr_clk)
		type states is (init_s, running_s);
		variable state : states;

		variable bnk_addr : unsigned(0 to ddr_bnk'length);
		variable row_addr : unsigned(0 to ddr_row'length);
		variable col_addr : unsigned(0 to ddr_col'length);

		variable bnk_cntr : unsigned(0 to ddr_bnk'length);
		variable row_cntr : unsigned(0 to ddr_row'length);
		variable col_cntr : unsigned(0 to ddr_col'length);

	begin
		if rising_edge(ddr_clk) then
			case state is
			when init_s =>
				if ddrdma_frm='1' then
					col_addr := resize((unsigned(ddrdma_addr) srl              0) mod 2**ddr_col'length, col_addr'length);
					row_addr := resize((unsigned(ddrdma_addr) srl ddr_col'length) mod 2**ddr_row'length, row_addr'length);
					bnk_addr := resize((unsigned(ddrdma_addr) srl ddr_row'length) mod 2**ddr_bnk'length, bnk_addr'length);

					col_cntr := resize((unsigned(ddrdma_len)  srl              0) mod 2**ddr_col'length, col_addr'length);
					row_cntr := resize((unsigned(ddrdma_len)  srl ddr_col'length) mod 2**ddr_row'length, row_addr'length);
					bnk_cntr := resize((unsigned(ddrdma_len)  srl ddr_row'length) mod 2**ddr_bnk'length, bnk_addr'length);
				end if;

				if ddrdma_frm='1' then
					state := running_s;
				else
					state := init_s;
				end if;

			when running_s =>
				if ddrdma_frm='1' then
					if ddr_trdy='1' then
						col_addr := col_addr + 1;
						if col_addr(0)='1' then
							row_addr := row_addr + 1;
						end if;
						if row_addr(0)='1' then
							bnk_addr := bnk_addr + 1;
						end if;

						col_cntr := col_cntr - 1;
						if col_cntr(0)='1' then
							row_cntr := row_cntr - 1;
						end if;
						if row_cntr(0)='1' then
							bnk_cntr := bnk_cntr - 1;
						end if;
					end if;

				end if;

				if ddrdma_frm='1' then
					state := running_s;
				else
					state := init_s;
				end if;
			end case;

			ddr_col <= std_logic_vector(col_addr mod 2**ddr_col'length);
			ddr_row <= std_logic_vector(row_addr mod 2**ddr_row'length);
			ddr_bnk <= std_logic_vector(bnk_addr mod 2**ddr_bnk'length);

		end if;
	end process;

end;
