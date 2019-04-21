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

entity scopeio_writeticks is
	port (
		clk    : in  std_logic;
		frm    : in  std_logic;
		irdy   : in  std_logic := '1';
		trdy   : out std_logic;
		length : out std_logic_vector;
		base   : in  std_logic_vector;

		wu_frm      : out std_logic;
		wu_irdy     : out std_logic := '1';
		wu_trdy     : in  std_logic;
		wu_float    : out std_logic_vector;
		wu_bcdwidth : out std_logic_vector(4-1 downto 0) := b"1000";
		wu_bcdunit  : out std_logic_vector;
		wu_bcdprec  : out std_logic_vector);
end;

architecture def of scopeio_writeticks is
begin

	process(clk)
		variable frm1 : std_logic;
		variable cntr : unsigned(length'length downto 0);
	begin
		if rising_edge(clk) then
			if frm1='0' then
				cntr   := unsigned(base);
				wr_frm <= frm;
			elsif irdy='1' then
				if cntr(to_integer(unsigned(length)))='0' then
					if wr_frm='0' then 
						cntr := cntr + 64;
					end if;
					if wu_trdy='1' then
						wr_frm <= '0';
					end if;
				end if;
			end if;
			wu_float <= std_logic_vector(cntr(length'length-1 downto 0));
			frm1 := frm;
		end if;
	end process;
	
end;
