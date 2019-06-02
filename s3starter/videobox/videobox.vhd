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

library unisim;
use unisim.vcomponents.all;

architecture video of s3starter is

	signal sys_clk      : std_logic;
	signal video_clk    : std_logic := '0';
	signal video_hzsync : std_logic;
	signal video_vtsync : std_logic;
	signal video_vton   : std_logic;
	signal video_hzon   : std_logic;
	signal video_vtcntr : std_logic_vector(11-1 downto 0);
	signal video_hzcntr : std_logic_vector(11-1 downto 0);

	signal box_xedge    : std_logic;
	signal box_yedge    : std_logic;
	signal box_eox      : std_logic;
	signal box_xon      : std_logic;
	signal box_yon      : std_logic;
	signal box_on       : std_logic;
	signal box_x        : std_logic_vector(11-1 downto 0);
	signal box_y        : std_logic_vector(11-1 downto 0);
	signal box_xdiv     : std_logic_vector(2-1 downto 0);
	signal box_ydiv     : std_logic_vector(2-1 downto 0);

 begin

	clkin_ibufg : ibufg
	port map (
		I => xtal,
		O => sys_clk);

	videodcm_e : entity hdl4fpga.dfs
	generic map (
		dfs_frequency_mode => "low",
		dcm_per => 20.0,
		dfs_mul => 3, --4,
		dfs_div => 1) --5)
	port map(
		dcm_rst => button(0),
		dcm_clk => sys_clk,
		dfs_clk => video_clk);

	video_e : entity hdl4fpga.video_sync
	generic map (
--		mode => pclk38_25m800x600Cat60)
		mode => pclk148_50m1920x1080Rat60)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton);

	boxlayout_e : entity hdl4fpga.videobox_layout
	generic map (
		x_edges     => (6*8-1, (6*8)+15*32-1, ((6*8)+15*32)+33*8-1),
		y_edges     => (257-1, (257)+8-1))
	port map (
		video_clk => video_clk,
		video_xon => video_hzon,
		video_yon => video_vton,
		video_x   => video_hzcntr,
		video_y   => video_vtcntr,
                 
		box_xedge => box_xedge,
		box_yedge => box_yedge,
		box_xon   => box_xon,
		box_yon   => box_yon,
		box_eox   => box_eox,
		box_xdiv  => box_xdiv,
		box_ydiv  => box_ydiv);
	box_on <= box_xon and box_yon;

	box_e : entity hdl4fpga.video_box
	port map (
		video_clk => video_clk,
		video_xon => box_xon,
		video_yon => box_yon,
		video_eox => box_eox,
		box_xedge => box_xedge,
		box_yedge => box_yedge,
		box_x     => box_x,
		box_y     => box_y);

	vga_hsync <= video_hzsync;
	vga_vsync <= video_vtsync;
	vga_red   <= setif(unsigned(box_xdiv)=0) and setif(unsigned(box_ydiv)=1) and box_on;
	vga_green <= setif(unsigned(box_xdiv)=1) and setif(unsigned(box_ydiv)=1) and box_on;
	vga_blue  <= setif(unsigned(box_xdiv)=2) and setif(unsigned(box_ydiv)=1) and box_on;

	led <= (others => 'Z');

	s3s_anodes     <= (others => 'Z');
	s3s_segment_a  <= 'Z';
	s3s_segment_b  <= 'Z';
	s3s_segment_c  <= 'Z';
	s3s_segment_d  <= 'Z';
	s3s_segment_e  <= 'Z';
	s3s_segment_f  <= 'Z';
	s3s_segment_g  <= 'Z';
	s3s_segment_dp <= 'Z';

	expansion_a2 <= (others => 'Z');
	rs232_txd <= 'Z';
end;

