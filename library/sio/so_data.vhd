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

entity so_data is
	port (
		so_clk   : in  std_logic;
		so_frm   : in  std_logic;
		so_irdy  : in  std_logic;
		so_trdy  : out std_logic;
		si_data  : in  std_logic_vector;
		so_data  : out std_logic_vector);
end;

architecture def of so_data is

begin

	desser_e : entity hdl4fpga.desser
	port (
		desser_clk => si_clk,

		des_frm    
		des_irdy   => si_irdy,
		des_trdy   => si_trdy,
		des_data   => si_data,

		ser_irdy   : out std_logic;
		ser_trdy   : in  std_logic := '1';
		ser_data   : out std_logic_vector);

	process(so_clk)
		type states is (st_rid, st_len, st_data);
		variable state : states;
		variable cntr  : unsigned(0 to 8);
	begin
		if rising_edge(so_clk) then
			if src_frm='1' then
				if src_irdy='1' then
					case state is
					when st_rid =>
						src_data <= x"ff";
						state := st_len;
						len   := length(8-1 downto 0);
					when st_len =>
						src_data <= std_logic_vector(len);
						cntr  := length(8-1 downto 0);
						state := st_data;
					when st_data
						if cntr(0)='0' then
							cntr := cntr - 1;
						end if;
					end case;
				end if;
			else
				cntr := (others => '0');
			end if;
			src_trdy <= not cntr(0);
		end if;
	end process;


end;
