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
	signal video_vcntr  : std_logic_vector(11-1 downto 0);
	signal video_hcntr  : std_logic_vector(11-1 downto 0);

	signal box_sidex    : std_logic;
	signal box_sidey    : std_logic;
	signal box_xon      : std_logic;
	signal box_eol      : std_logic;
	signal box_yon      : std_logic;
	signal box_posx     : std_logic_vector(11-1 downto 0);
	signal box_posy     : std_logic_vector(11-1 downto 0);
	signal box_divx     : std_logic_vector(2-1 downto 0);
	signal box_divy     : std_logic_vector(2-1 downto 0);

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
		mode => 7)
	port map (
		video_clk   => video_clk,
		video_hsync => video_hzsync,
		video_vsync => video_vtsync,
		video_hcntr => video_hcntr,
		video_vcntr => video_vcntr,
		video_hzon  => video_hzon,
		video_vton  => video_vton);

	boxlayout_e : entity hdl4fpga.videobox_layout
	generic map (
		x_sides     => (6*8-1, (6*8)+15*32-1, ((6*8)+15*32)+33*8-1),
		y_sides     => (257-1, (257)+8-1))
	port map (
		video_clk  => video_clk,
		video_xon  => video_hzon,
		video_yon  => video_vton,
		video_posx => video_hcntr,
		video_posy => video_vcntr,
		box_xon    => box_xon,
		box_eol    => box_eol,
		box_yon    => box_yon,
		box_sidex  => box_sidex,
		box_sidey  => box_sidey,
		box_divx   => box_divx,
		box_divy   => box_divy);

	box_e : entity hdl4fpga.video_box
	port map (
		video_clk => video_clk,
		video_xon => box_xon,
		video_yon => box_yon,
		video_eol => box_eol,
		box_sidex => box_sidex,
		box_sidey => box_sidey,
		box_posx  => box_posx,
		box_posy  => box_posy);

	vga_hsync <= video_hzsync;
	vga_vsync <= video_vtsync;
	vga_red   <= setif(unsigned(box_divx)=0) and video_hzon and setif(unsigned(box_divy)=1) and video_vton;
	vga_green <= setif(unsigned(box_divx)=1) and video_hzon and setif(unsigned(box_divy)=1) and video_vton;
	vga_blue  <= setif(unsigned(box_divx)=2) and video_hzon and setif(unsigned(box_divy)=1) and video_vton;

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

