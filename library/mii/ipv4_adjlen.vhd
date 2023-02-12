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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ipv4_adjlen is
	generic (
		adjust  : std_logic_vector);
	port (
		sio_clk  : in  std_logic;
		sio_frm  : in  std_logic;
		sio_irdy : in  std_logic;
		sio_trdy : out std_logic;
		si_data  : in  std_logic_vector;
		so_data  : out std_logic_vector);
end;

architecture def of ipv4_adjlen is
	signal si_b   : std_logic_vector(si_data'range);
	signal si_ci  : std_logic;
	signal si_co  : std_logic;
	signal so_sum : std_logic_vector(so_data'range);

	constant crtn_data : std_logic_vector := reverse(reverse(adjust), si_b'length);
begin

	crtnmux_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => crtn_data,
		sio_clk  => sio_clk,
		sio_frm  => sio_frm,
		sio_irdy => sio_irdy,
		sio_trdy => open,
		so_data  => si_b);

	si_adder_e : entity hdl4fpga.adder
	port map (
		ci  => si_ci,
		a   => si_data,
		b   => si_b,
		s   => so_sum,
		co  => si_co);

	si_cy_p : process (sio_clk)
	begin
		if rising_edge(sio_clk) then
			if sio_frm='0' then
				si_ci <= '0';
			elsif sio_irdy='1' then
				si_ci <= si_co;
			end if;
		end if;
	end process;

	so_data <= so_sum;
end;