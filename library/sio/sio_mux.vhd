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

entity sio_mux is
    port (
		mux_data : in  std_logic_vector;
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic;
		sio_irdy : in  std_logic := '1';
		sio_trdy : out std_logic;
		so_last  : buffer std_logic;
		so_end   : buffer std_logic;
        so_data  : out std_logic_vector);
end;

architecture def of sio_mux is
	constant mux_length : natural := unsigned_num_bits(mux_data'length/so_data'length-1);
	subtype mux_range is natural range 1 to mux_length;

	signal mux_sel : std_logic_vector(mux_range);
	signal rdata   : std_logic_vector(0 to 2**mux_length*so_data'length-1);

begin

	process (so_end, sio_clk)
		variable cntr : signed(0 to mux_length);
	begin
		if rising_edge(sio_clk) then
			if sio_frm='0' then
				cntr   := to_signed(mux_data'length/so_data'length-2, cntr'length);
				so_end <= '0';
			elsif sio_irdy='1' then
				so_end <= cntr(0);
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			mux_sel <= std_logic_vector(cntr(mux_range));
		end if;
		so_last <= not so_end and cntr(0);
	end process;
	sio_trdy <= sio_frm;

	rdata <= std_logic_vector(unsigned(reverse(reverse(std_logic_vector(resize(unsigned(mux_data), rdata'length)), so_data'length))) rol so_data'length);

	so_data <=
		rdata when so_data'length=rdata'length else
		multiplex(rdata, mux_sel, so_data'length);

end;
