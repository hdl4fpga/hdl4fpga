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

entity scopeio_pointer is
	generic (
		latency      : integer := 0);
	port (
		rgtr_clk     : in  std_logic;
		rgtr_dv      : in  std_logic;
		rgtr_id      : in  std_logic_vector(8-1 downto 0);
		rgtr_data    : in  std_logic_vector;

		video_clk    : in  std_logic;
		video_hzcntr : in  std_logic_vector;
		video_vtcntr : in  std_logic_vector;
		video_dot    : out std_logic);
end;

architecture beh of scopeio_pointer is
	constant xbar_latency : natural := 2;

	signal x_bar : std_logic;

	signal pointer_dv : std_logic;
	signal pointer_x  : std_logic_vector(11-1 downto 0);
	signal pointer_y  : std_logic_vector(11-1 downto 0);
begin

	scopeio_rgtrpointer_e : entity hdl4fpga.scopeio_rgtrpointer
	port map (
		rgtr_clk   => rgtr_clk,
		rgtr_dv    => rgtr_dv,
		rgtr_id    => rgtr_id,
		rgtr_data  => rgtr_data,

		pointer_dv => pointer_dv,
		pointer_x  => pointer_x,
		pointer_y  => pointer_y);
		
	xbar_p : process(video_clk)
		variable hz_bar : std_logic;
		variable vt_bar : std_logic;
	begin
		if rising_edge(video_clk) then
			x_bar  <= hz_bar or vt_bar;
			hz_bar := setif(video_hzcntr=pointer_x);
			vt_bar := setif(video_vtcntr=pointer_y);
		end if;
	end process;

	latency_e : entity hdl4fpga.latency
	generic map (
		n     => 1,
		d     => (0 to 0 => latency-xbar_latency))
	port map (
		clk   => video_clk,
		di(0) => x_bar,
		do(0) => video_dot);

end;
