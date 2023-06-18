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
use hdl4fpga.base.all;

entity usbfifo_rx is
	port (
		clk      : in  std_logic;
		cken     : in  std_logic;

		rxdv     : in  std_logic;
		rxbs     : in  std_logic;
		rxd      : in  std_logic;

		out_frm  : out std_logic;
		out_irdy : buffer std_logic;
		out_trdy : in  std_logic;
		out_data : out std_logic_vector(8-1 downto 0));
end;

architecture def of usbfifo_rx is
	type ram is array (natural range <>) of std_logic_vector(out_data'range);
	shared variable mem : ram(0 to 1024-1);
begin
	process(clk)
		variable wptr : natural;
		variable rptr : natural;
		variable data : unsigned(out_data'range);
		variable cntr : natural range 0 to data'length-1;
	begin
		if rising_edge(clk) then
			if cken='1' then
				if rxdv='1' then
					if rxbs='0' then
						data := data rol 1;
						data(0) := rxd;
						cntr := cntr + 1;
					end if;
				else
					cntr := 0;
				end if;

				if cntr=data'length-1 then
					mem(wptr) := std_logic_vector(data);
					wptr := wptr + 1;
					cntr := 0;
				end if;

				if rptr = wptr then
					out_frm <= rxdv;
				else
					out_frm <= '1';
					if cntr = 0 then
						out_irdy <= '1';
					end if;
				end if;
				out_data <= mem(rptr);
				if rptr /= wptr then
					if out_irdy = '1' then
						rptr := rptr + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
end;