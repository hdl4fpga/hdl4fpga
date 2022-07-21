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

entity phy_rl is
	port (
		clk        : in  std_logic;
		rl_req     : in  std_logic;
		rl_rdy     : buffer std_logic;
		write_req  : buffer std_logic;
		write_rdy  : in  std_logic;
		read_req   : buffer std_logic;
		read_rdy   : in  std_logic;
		burst      : out std_logic;
		sti        : in  std_logic := '1';
		adjdqs_req : buffer std_logic;
		adjdqs_rdy : in  std_logic;
		adjdqi_req : buffer std_logic;
		adjdqi_rdy : in  std_logic;
		adjsto_req : buffer std_logic;
		adjsto_rdy : in  std_logic);
end;

architecture def of phy_rl is
begin
	process (clk)
		type states is (s_start, s_write, s_dqs, s_dqi, s_sto);
		variable state : states;
	begin
		if rising_edge(clk) then
			if (to_bit(rl_req) xor to_bit(rl_rdy))='0' then
				adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
				adjdqi_req <= to_stdulogic(to_bit(adjsto_rdy));
				adjsto_req <= to_stdulogic(to_bit(adjsto_rdy));
				state := s_start;
			else
				case state is
				when s_start =>
					write_req <= not to_stdulogic(to_bit(write_rdy));
					burst <= '0';
					state := s_write;
				when s_write =>
					if (to_bit(write_req) xor to_bit(write_rdy))='0' then
						read_req <= not to_stdulogic(to_bit(read_rdy));
						burst <= '1';
						if sti='1' then
							adjdqs_req <= not to_stdulogic(to_bit(adjdqs_rdy));
							state := s_dqs;
						end if;
					end if;
				when s_dqs =>
					if (to_bit(adjdqs_req) xor to_bit(adjdqs_rdy))='0' then
						adjdqi_req <= not adjsto_req;
						state := s_dqi;
					end if;
				when s_dqi =>
					if (adjdqi_req xor adjdqi_rdy)='0' then
						burst <= '0';
						if (to_bit(read_req) xor to_bit(read_rdy))='0' then
							read_req   <= not read_rdy;
							adjsto_req <= not adjsto_rdy;
							state := s_sto;
						end if;
					end if;
				when s_sto =>
					if (read_req xor read_rdy)='0' then
						if (adjsto_req xor adjsto_rdy)='0' then
							rl_rdy <= rl_req;
							state := s_start;
						else
							read_req <= not read_rdy;
						end if;
					end if;
					burst <= '0';
				end case;
			end if;
		end if;
	end process;
end;