--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity ddr2miitx is
	port (
		ddrios_clk : in std_logic;
		ddrios_gnt : in std_logic;
		ddrios_a0  : in std_logic;
		ddrios_brst_req : out std_logic;
		miitx_rdy  : in std_logic;
		miitx_req  : out std_logic);
end;

architecture def of ddr2miitx is

	signal a0_edge : std_logic;
	signal a0_dly  : std_logic;
	signal req     : std_logic;

begin

	miitx_req <= req;
	a0_edge <= not a0_dly xor ddrios_a0;
	process (ddrios_clk)
	begin
		if rising_edge(ddrios_clk) then

			if ddrios_gnt='1' then
				if req='0' then
					ddrios_brst_req <= '1';
					req <= '0';
					if a0_edge='1' then
						req <= '1';
						ddrios_brst_req <= '0';
					end if;
				elsif miitx_rdy='0' then
					req <= '1';
					ddrios_brst_req <= '0';
				else
					req <= '0';
					ddrios_brst_req <= '0';
				end if;
			else
				req <= '0';
				ddrios_brst_req <= '0';
			end if;

			a0_dly  <= not ddrios_a0;

		end if;
	end process;

end;
