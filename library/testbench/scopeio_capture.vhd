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

architecture scopeio_capture of testbench is

	signal rst        : std_logic;
	signal input_clk  : std_logic := '0';
	signal input_data : unsigned(0 to 2*9-1);

	signal shot : std_logic;
	signal capture_shot : std_logic;
	signal capture_end : std_logic;
	signal video_clk  : std_logic := '0';
	signal video_frm  : std_logic := '0';
	signal video_addr : unsigned(0 to 13-1);
	signal video_data : std_logic_vector(0 to input_data'length-1);

begin

	rst <= '1', '0' after 20 ns;
	input_clk <= not input_clk after 500 ns;
	video_clk <= not video_clk after 6.67 ns;

	process (rst, video_clk)
		variable dv : std_logic;
	begin
		if rst='1' then
			video_addr <= (others => '0');
			video_frm  <= '0';
			shot <= '0';
		elsif rising_edge(video_clk) then
			video_frm  <= '1';
			shot <= '1';
			if video_frm='1' then
				video_addr <= video_addr + 1;
			end if;
		end if;
	end process;

	input_data <= (others => '0');
	capture_shot <= capture_end and shot;
	scopeio_capture_e : entity hdl4fpga.scopeio_capture
	port map (
		input_clk    => input_clk,
		downsampling => '1',
		capture_shot => capture_shot,
		capture_a0   => '0',
		capture_end  => capture_end,

		input_data   => std_logic_vector(input_data),
		time_offset  => b"0_0000_0000_1000_0010",

		video_clk    => video_clk,
		video_addr   => std_logic_vector(video_addr),
		video_frm    => video_frm,
		video_data   => video_data);
end;

