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

entity ip_adjlen is
	generic (
		adjust  : std_logic_vector);
	port (
		si_clk  : in  std_logic;
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_full : out std_logic;
		si_data : in  std_logic_vector;
		
		so_clk  : in  std_logic;
		so_frm  : in  std_logic;
		so_irdy : in  std_logic;
		so_trdy : out std_logic;
		so_end  : out std_logic;
		so_data : out std_logic_vector);
end;

architecture def of ip_adjlen is
	signal si_b      : std_logic_vector(si_data'range);
	signal si_ci     : std_logic;
	signal si_co     : std_logic;
	signal si_sum    : std_logic_vector(si_data'range);
	signal so_sum    : std_logic_vector(so_data'range);

begin

	crtnmux_e : entity hdl4fpga.sio_mux
	port map (
		-- mux_data => reverse(reverse(std_logic_vector(to_unsigned((summation(udp4hdr_frame)/octect_size),16))), si_b'length),
		-- mux_data => reverse(reverse(std_logic_vector(to_unsigned((summation(ipv4hdr_frame)/octect_size),16))), si_b'length),
		mux_data => reverse(reverse(adjust), si_b'length),
		sio_clk  => si_clk,
		sio_frm  => si_frm,
		sio_irdy => si_irdy,
		sio_trdy => open,
		so_data  => si_b);

	si_adder_e : entity hdl4fpga.adder
	port map (
		ci  => si_ci,
		a   => si_data,
		b   => si_b,
		s   => si_sum,
		co  => si_co);

	si_cy_p : process (si_clk)
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				si_ci <= '0';
			elsif si_irdy='1' then
				si_ci <= si_co;
			end if;
		end if;
	end process;

	ram_e : entity hdl4fpga.sio_ram
	generic map (
		mode_fifo => false,
		mem_length => 16)
	port map (
		si_clk  => si_clk,
		si_frm  => si_frm,
		si_irdy => si_irdy,
		si_trdy => si_trdy,
		si_full => si_full,
		si_data => si_sum,

		so_clk  => so_clk,
		so_frm  => so_frm,
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_end  => so_end,
		so_data => so_sum);

	so_data <= reverse(so_sum);
end;