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

library hdl4fpga;
use hdl4fpga.std.all;

entity ipv4d is
end;

architecture def of ipv4d is
begin

	llc_e : entity hdl4fpga.sio_cmp
	generic map (
		n => 2)
	port map (
		mux_data  => reverse(llc_arp & llc_ip,8),
        sio_clk   => mii_clk,
        sio_frm   => miirx_frm,
		sio_irdy  => hwtyprx_irdy,
		sio_trdy  => hwtyprx_trdy,
        si_data   => miirx_data,
		so_last   => llc_last,
		so_equ(0) => arprx_equ,
		so_equ(1) => iprx_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if miirx_frm='0' then
				arprx_vld <= '0';
			elsif llc_last='1' then
				arprx_vld <= arprx_equ;
			end if;
		end if;
	end process;
	arprx_frm <= miirx_frm and arprx_vld;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if miirx_frm='0' then
				iprx_vld <= '0';
			elsif llc_last='1' then
				iprx_vld <= iprx_equ;
			end if;
		end if;
	end process;
	iprx_frm <= miirx_frm and iprx_vld;

end;
