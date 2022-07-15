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

entity clk_start is
	port (
		rst         : in  std_logic;
		sclk        : in  std_logic;
		eclk        : in  std_logic;
		eclksynca_stop : out std_logic;
		dqsbufd_rst : buffer std_logic);
end;

architecture ecp3 of clk_start is
	signal sclk_q  : std_logic;
begin

	process (rst, sclk)
		variable q : std_logic;
	begin
		if rst='1' then
			sclk_q <= '0';
		elsif rising_edge(sclk) then
			if dqsbufd_rst='1' then
				sclk_q <= '1';
			end if;
		end if;
	end process;

	process (rst, eclk)
		variable q : std_logic_vector(0 to 4-1);
	begin
		if rst='1' then
			q := (others => '0');
		elsif rising_edge(eclk) then
			q := q(1 to q'right) & sclk_q;
		end if;
		eclksynca_stop <= not q(0);
		dqsbufd_rst    <= not q(1);
	end process;

end;
