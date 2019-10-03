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
use  hdl4fpga.scopeiopkg.all;

architecture scopeio_palette of testbench is

	signal rst : std_logic;
	signal clk : std_logic := '0';
	signal color : std_logic_vector(0 to 2);
begin

	rst <= '1', '0' after 20 ns;
	clk <= not clk  after 10 ns;

	process (rst, clk)
		variable dv : std_logic;
	begin
		if rst='1' then
		elsif rising_edge(clk) then
		end if;
	end process;

	scopeio_palette_e : entity hdl4fpga.scopeio_palette
	generic map (
		dflt_tracesfg => b"1_1_1_1_1_1",
		dflt_gridfg   => b"1_0_0",
		dflt_gridbg   => b"0_0_0",
		dflt_hzfg     => b"1_1_1",
		dflt_hzbg     => b"0_0_1",
		dflt_vtfg     => b"1_1_1",
		dflt_vtbg     => b"0_0_1",
		dflt_textbg   => b"0_0_0",
		dflt_sgmntbg  => b"1_1_1",
		dflt_bg       => b"0_0_0")
	port map (
		rgtr_clk    => clk,
		rgtr_dv     => '0',
		rgtr_id     => x"00",
		rgtr_data   => x"00000000",
		
		trigger_chanid => x"2",

		video_clk   => clk,
		trigger_dot => '0',
		grid_dot    => '1',
		grid_bgon   => '0',
		hz_dot      => '0',
		hz_bgon     => '0',
		vt_dot      => '0',
		vt_bgon     => '0',
		text_dot    => '0',
		text_bgon   => '0',
		sgmnt_bgon  => '0',
		trace_dots  => "00",
		video_color => color);
end;

