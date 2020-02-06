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
		ddrdma_frm   : in  std_logic;
		ddrdma_clk   : in  std_logic;
		ddrdma_irdy  : in  std_logic;
		ddrdma_trdy  : out std_logic;
		ddrdma_iaddr : in  std_logic_vector;
		ddrdma_ilen  : in  std_logic_vector;
		ddrdma_taddr : out std_logic_vector;
		ddrdma_tlen  : out std_logic_vector;
		ddrdma_bnk   : out std_logic_vector;
		ddrdma_row   : out std_logic_vector;
		ddrdma_col   : out std_logic_vector;
		ddrdma_geoc  : buffer std_logic;
		ddrdma_eoc   : buffer std_logic;

		ctlr_req    : buffer std_logic;
		ctlr_ena    : in  std_logic;
		ctlr_refreq  : in  std_logic);
end;

architecture def of ddrdma is
	type states is (init_s, running_s);
	signal state : states;

begin

	addr_p : process (ddrdma_clk)
		variable bnk_addr : unsigned(0 to ddrdma_bnk'length);
		variable row_addr : unsigned(0 to ddrdma_row'length);
		variable col_addr : unsigned(0 to ddrdma_col'length);

		variable bnk_cntr : unsigned(0 to ddrdma_bnk'length);
		variable row_cntr : unsigned(0 to ddrdma_row'length);
		variable col_cntr : unsigned(0 to ddrdma_col'length);

	begin
		if rising_edge(ddrdma_clk) then
			case state is
			when init_s =>
				if ddrdma_frm='1' then
					col_addr := resize((unsigned(ddrdma_iaddr) srl                 0) mod 2**ddrdma_col'length, col_addr'length);
					row_addr := resize((unsigned(ddrdma_iaddr) srl ddrdma_col'length) mod 2**ddrdma_row'length, row_addr'length);
					bnk_addr := resize((unsigned(ddrdma_iaddr) srl ddrdma_row'length) mod 2**ddrdma_bnk'length, bnk_addr'length);

					col_cntr := resize((unsigned(ddrdma_ilen)  srl                 0) mod 2**ddrdma_col'length, col_addr'length);
					row_cntr := resize((unsigned(ddrdma_ilen)  srl ddrdma_col'length) mod 2**ddrdma_row'length, row_addr'length);
					bnk_cntr := resize((unsigned(ddrdma_ilen)  srl ddrdma_row'length) mod 2**ddrdma_bnk'length, bnk_addr'length);
				end if;

				ddrdma_geoc <= '0';

				if ddrdma_frm='1' then
					state <= running_s;
				else
					state <= init_s;
				end if;

			when running_s =>
				if ddrdma_frm='1' then

					if row_addr(0)='1' then
						row_addr(0) := '0';
						bnk_addr := bnk_addr + 1;
					end if;

					if col_addr(0)='1' then
						col_addr(0) := '0';
						row_addr := row_addr + 1;
					end if;

					if ctlr_ena='1' then

						col_cntr := col_cntr - 2;
						if col_cntr(0)='1' then
							col_cntr(0) := '0';
							row_cntr := row_cntr - 1;
						end if;

						if row_cntr(0)='1' then
							row_cntr(0) := '0';
							bnk_cntr := bnk_cntr - 1;
						end if;


						col_addr := col_addr + 2;

						ddrdma_geoc <= col_addr(0) or row_addr(0) or bnk_addr(0);
					end if;

				else
					ddrdma_geoc <= '0';
				end if;

				if ddrdma_frm='1' then
					state <= running_s;
				else
					state <= init_s;
				end if;
			end case;

			ddrdma_bnk <= std_logic_vector(resize(bnk_addr mod 2**ddrdma_bnk'length, ddrdma_bnk'length));
			ddrdma_row <= std_logic_vector(resize(row_addr mod 2**ddrdma_row'length, ddrdma_row'length));
			ddrdma_col <= std_logic_vector(resize(col_addr mod 2**ddrdma_col'length, ddrdma_col'length));

			ddrdma_taddr <= std_logic_vector(
				resize(unsigned(bnk_addr) mod 2**ddrdma_bnk'length, ddrdma_bnk'length) &
				resize(unsigned(row_addr) mod 2**ddrdma_row'length, ddrdma_row'length) &
				resize(unsigned(col_addr) mod 2**ddrdma_col'length, ddrdma_col'length));

			ddrdma_tlen <= std_logic_vector(
				resize(unsigned(bnk_cntr) mod 2**ddrdma_bnk'length, ddrdma_bnk'length) &
				resize(unsigned(row_cntr) mod 2**ddrdma_row'length, ddrdma_row'length) &
				resize(unsigned(col_cntr) mod 2**ddrdma_col'length, ddrdma_col'length));
			ddrdma_eoc <= bnk_cntr(0);
		end if;
	end process;

	ctlr_req <= ddrdma_frm when state=running_s else '0';

end;
