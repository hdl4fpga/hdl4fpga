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

entity scopeio_ticks is
	port (
		clk   : in  std_logic;
		frm   : in  std_logic;
		irdy  : in  std_logic := '1';
		trdy  : out std_logic := '1';
		first : in  std_logic_vector;
		last  : in  std_logic_vector;
		step  : in  std_logic_vector;
		updn  : in  std_logic := '0';

		wu_frm      : buffer std_logic;
		wu_irdy     : out std_logic := '1';
		wu_trdy     : in  std_logic;
		wu_float    : out std_logic_vector;
		wu_bcdwidth : out std_logic_vector(4-1 downto 0) := b"1000";
		wu_bcdunit  : out std_logic_vector(4-1 downto 0) := b"1101";
		wu_bcdprec  : out std_logic_vector(4-1 downto 0) := b"1110");
end;

architecture def of scopeio_ticks is
begin

	process(clk)
		variable frm1 : std_logic;
		variable cntr : unsigned(first'length-1 downto 0);
	begin
		if rising_edge(clk) then
			if frm1='0' then
				cntr   := unsigned(first);
				wu_frm <= frm;
			elsif irdy='1' then
				if unsigned(last)>cntr then
					if wu_frm='0' then 
						if updn='0' then
							cntr := cntr + unsigned(step);
						else
							cntr := cntr - unsigned(step);
						end if;
						wu_frm <= '1';
					elsif wu_trdy='1' then
						wu_frm <= '0';
					end if;
				else
					wu_frm <= '0';
				end if;
			end if;
			wu_float <= std_logic_vector(cntr(first'length-1 downto 0));
			frm1 := frm;
		end if;
	end process;
	
end;
