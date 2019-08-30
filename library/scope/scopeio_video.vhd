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
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_video is
	generic (
		lang          : i18n_langs := lang_en;
		vlayout_id    : natural;
		hz_unit       : std_logic_vector;
		vt_unit       : std_logic_vector;
		inputs        : natural;
		dflt_tracesfg : std_logic_vector;
		dflt_gridfg   : std_logic_vector;
		dflt_gridbg   : std_logic_vector;
		dflt_hzfg     : std_logic_vector;
		dflt_hzbg     : std_logic_vector;
		dflt_vtfg     : std_logic_vector;
		dflt_vtbg     : std_logic_vector;
		dflt_textbg   : std_logic_vector;
		dflt_sgmntbg  : std_logic_vector;
		dflt_bg       : std_logic_vector);
	port (
		rgtr_clk         : in  std_logic;
		rgtr_dv          : in  std_logic;
		rgtr_id          : in  std_logic_vector(8-1 downto 0);
		rgtr_data        : in  std_logic_vector;

		time_scale       : out std_logic_vector;
		time_offset      : out std_logic_vector;

		gain_dv          : in  std_logic;
		gain_ids         : in  std_logic_vector;

		trigger_chanid   : in  std_logic_vector;
		trigger_level    : in  std_logic_vector;

		video_addr       : out std_logic_vector;
		video_frm        : out std_logic;
		video_data       : in  std_logic_vector;
		video_dv         : in  std_logic;

		video_clk        : in  std_logic;
		video_pixel      : out std_logic_vector;
		video_hsync      : out std_logic;
		video_vsync      : out std_logic;

		video_vton       : buffer std_logic;
		video_hzon       : buffer std_logic;
		video_blank      : out std_logic;
		video_sync       : out std_logic);

end;

architecture beh of scopeio_video is

	constant storageaddr_latency  : natural := 1;
	constant storagebram_latency  : natural := 2;
	constant vdata_latency        : natural := 1;
	constant input_latency        : natural := storageaddr_latency+storagebram_latency+vdata_latency;
	constant mainrgtrin_latency   : natural := 1;
	constant mainrgtrout_latency  : natural := 1;
	constant mainrgtrio_latency   : natural := mainrgtrin_latency+mainrgtrout_latency;
	constant sgmntrgtrin_latency  : natural := 1;
	constant sgmntrgtrout_latency : natural := 1;
	constant sgmntrgtrio_latency  : natural := sgmntrgtrout_latency+sgmntrgtrin_latency;
	constant segmment_latency     : natural := 5;
	constant palette_latency      : natural := 3;
	constant vgaio_latency        : natural := input_latency+mainrgtrio_latency+sgmntrgtrio_latency+segmment_latency+palette_latency;

	constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);
	constant hztick_bits : natural := unsigned_num_bits(8*axis_fontsize(layout)-1);

	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
	signal video_vld     : std_logic;
	signal video_vtcntr  : std_logic_vector(11-1 downto 0);
	signal video_hzcntr  : std_logic_vector(11-1 downto 0);
	signal video_color   : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_io      : std_logic_vector(0 to 3-1);

	signal scope_color   : std_logic_vector(video_pixel'length-1 downto 0);

	signal hz_dv         : std_logic;
	signal hz_scale      : std_logic_vector(4-1 downto 0);
	signal hz_slider     : std_logic_vector(time_offset'range);
	signal hz_segment    : std_logic_vector(hz_slider'range);

	constant sgmnt_id : natural := 0;
	constant text_id  : natural := 1;

	signal btof_binfrm   : std_logic_vector(0 to text_id);
	signal btof_binirdy  : std_logic_vector(btof_binfrm'range);
	signal btof_bintrdy  : std_logic_vector(btof_binfrm'range);
	signal btof_binexp   : std_logic_vector(btof_binfrm'range);
	signal btof_binneg   : std_logic_vector(btof_binfrm'range);
	signal btof_bindi    : std_logic_vector(4*btof_binfrm'left to 4*(btof_binfrm'right+1)-1);
	signal btof_bcdprec  : std_logic_vector(4*btof_binfrm'left to 4*(btof_binfrm'right+1)-1);
	signal btof_bcdunit  : std_logic_vector(4*btof_binfrm'left to 4*(btof_binfrm'right+1)-1);
	signal btof_bcdwidth : std_logic_vector(4*btof_binfrm'left to 4*(btof_binfrm'right+1)-1);
	signal btof_bcdalign : std_logic_vector(btof_binfrm'range);
	signal btof_bcdsign  : std_logic_vector(btof_binfrm'range);
	signal btof_bcdtrdy  : std_logic_vector(btof_binfrm'range);
	signal btof_bcdirdy  : std_logic_vector(btof_binfrm'range);
	signal btof_bcdend   : std_logic;
	signal btof_bcddo    : std_logic_vector(4-1 downto 0);

	constant sgmntboxx_bits : natural := unsigned_num_bits(sgmnt_width(layout)-1);
	constant sgmntboxy_bits : natural := unsigned_num_bits(sgmnt_height(layout)-1);

	signal x      : std_logic_vector(sgmntboxx_bits-1 downto 0);
	signal y      : std_logic_vector(sgmntboxy_bits-1 downto 0);
	signal sgmntbox_on   : std_logic;
	signal grid_on         : std_logic;
	signal hz_on           : std_logic;
	signal vt_on           : std_logic;
	signal text_on         : std_logic;

	signal trigger_dot   : std_logic;
	signal trace_dots    : std_logic_vector(0 to inputs-1);
	signal grid_dot      : std_logic;
	signal grid_bgon     : std_logic;
	signal hz_dot        : std_logic;
	signal hz_bgon       : std_logic;
	signal vt_dot        : std_logic;
	signal vt_bgon       : std_logic;
	signal text_dot      : std_logic;
	signal text_bgon     : std_logic;
	signal sgmntbox_bgon : std_logic;
	signal pointer_dot   : std_logic;

	signal vdv   : std_logic;
	signal vdata : std_logic_vector(video_data'range);
begin

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			vdv   <= video_dv;
			vdata <= video_data;
		end if;
	end process;

	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_dv     => hz_dv,
		hz_scale  => hz_scale,
		hz_slider => hz_slider);

	scopeio_btof_e : entity hdl4fpga.scopeio_btof
	port map (
		clk       => rgtr_clk,
		bin_frm   => btof_binfrm,
		bin_irdy  => btof_binirdy,
		bin_trdy  => btof_bintrdy,
		bin_di    => btof_bindi,
		bin_neg   => btof_binneg,
		bin_exp   => btof_binexp,
		bcd_width => btof_bcdwidth,
		bcd_sign  => btof_bcdsign,
		bcd_unit  => btof_bcdunit,
		bcd_align => btof_bcdalign,
		bcd_prec  => btof_bcdprec,
		bcd_irdy  => btof_bcdirdy,
		bcd_trdy  => btof_bcdtrdy,
		bcd_end   => btof_bcdend,
		bcd_do    => btof_bcddo);

	video_e : entity hdl4fpga.video_sync
	generic map (
		mode => video_description(vlayout_id).mode_id)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton);

	video_vld <= video_hzon and video_vton;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => video_io'length,
		d => (video_io'range => vgaio_latency))
	port map (
		clk   => video_clk,
		di(0) => video_hzsync,
		di(1) => video_vtsync,
		di(2) => video_vld,
		do    => video_io);

	scopeio_layout_e : entity hdl4fpga.scopeio_layout
	generic map (
		vlayout_id   => vlayout_id)
	port map (
		video_clk    => video_clk,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton,

		hz_slider    => hz_slider,
		hz_segment   => hz_segment,
		x            => x,
		y            => y,
		sgmntbox_on  => sgmntbox_on,
		video_addr   => video_addr,
		video_frm    => video_frm,
		grid_on      => grid_on,
		hz_on        => hz_on,
		vt_on        => vt_on,
		text_on      => text_on);

	scopeio_texbox_e : entity hdl4fpga.scopeio_textbox
	generic map (
		lang          => lang,
		latency       => segmment_latency+input_latency,
		layout        => layout)
	port map (
		rgtr_clk      => rgtr_clk,
		rgtr_dv       => rgtr_dv,
		rgtr_id       => rgtr_id,
		rgtr_data     => rgtr_data,

		btof_binfrm   => btof_binfrm(text_id),
		btof_binirdy  => btof_binirdy(text_id),
		btof_bintrdy  => btof_bintrdy(text_id),
		btof_bindi    => btof_bindi(4*text_id to 4*(text_id+1)-1),
		btof_binneg   => btof_binneg(text_id),
		btof_binexp   => btof_binexp(text_id),
		btof_bcdwidth => btof_bcdwidth(4*text_id to 4*(text_id+1)-1),
		btof_bcdprec  => btof_bcdprec(4*text_id to 4*(text_id+1)-1),
		btof_bcdunit  => btof_bcdunit(4*text_id to 4*(text_id+1)-1),
		btof_bcdsign  => btof_bcdsign(text_id),
		btof_bcdalign => btof_bcdalign(text_id),
		btof_bcdirdy  => btof_bcdirdy(text_id),
		btof_bcdtrdy  => btof_bcdtrdy(text_id),
		btof_bcdend   => btof_bcdend,
		btof_bcddo    => btof_bcddo,

		video_clk     => video_clk,
		video_hcntr   => x,
		video_vcntr   => y,
		text_on       => text_on,
		text_dot      => text_dot);

	scopeio_segment_e : entity hdl4fpga.scopeio_segment
	generic map (
		input_latency => input_latency,
		latency       => segmment_latency+input_latency,
		inputs        => inputs,
		hz_unit       => hz_unit,
		vt_unit       => vt_unit,
		layout        => layout)
	port map (
		rgtr_clk      => rgtr_clk,
		rgtr_dv       => rgtr_dv,
		rgtr_id       => rgtr_id,
		rgtr_data     => rgtr_data,

		btof_binfrm   => btof_binfrm(sgmnt_id),
		btof_binirdy  => btof_binirdy(sgmnt_id),
		btof_bintrdy  => btof_bintrdy(sgmnt_id),
		btof_bindi    => btof_bindi(4*sgmnt_id to 4*(sgmnt_id+1)-1),
		btof_binneg   => btof_binneg(sgmnt_id),
		btof_binexp   => btof_binexp(sgmnt_id),
		btof_bcdunit  => btof_bcdunit(4*sgmnt_id to 4*(sgmnt_id+1)-1),
		btof_bcdwidth => btof_bcdwidth(4*sgmnt_id to 4*(sgmnt_id+1)-1),
		btof_bcdprec  => btof_bcdprec(4*sgmnt_id to 4*(sgmnt_id+1)-1),
		btof_bcdsign  => btof_bcdsign(sgmnt_id),
		btof_bcdalign => btof_bcdalign(sgmnt_id),
		btof_bcdtrdy  => btof_bcdtrdy(sgmnt_id),
		btof_bcdirdy  => btof_bcdirdy(sgmnt_id),
		btof_bcdend   => btof_bcdend,
		btof_bcddo    => btof_bcddo,

		hz_dv         => hz_dv,
		hz_scale      => hz_scale,
		hz_base       => hz_slider(time_offset'left downto axisx_backscale+hztick_bits),
		hz_offset     => hz_segment,

		gain_dv       => gain_dv,
		gain_ids      => gain_ids,

		video_clk     => video_clk,
		x             => x,
		y             => y,

		hz_on         => hz_on,
		vt_on         => vt_on,
		grid_on       => grid_on,

		sample_dv     => vdv,
		sample_data   => vdata,
		trigger_level => trigger_level,
		grid_dot      => grid_dot,
		hz_dot        => hz_dot,
		vt_dot        => vt_dot,
		trigger_dot   => trigger_dot,
		trace_dots    => trace_dots);

	bg_e : entity hdl4fpga.align
	generic map (
		n => 5,
		d => (
			0 to 4-1 => input_latency+segmment_latency,
			4        => input_latency+segmment_latency+mainrgtrout_latency+sgmntrgtrio_latency))
	port map (
		clk => video_clk,
		di(0) => grid_on,
		di(1) => hz_on,
		di(2) => vt_on,
		di(3) => text_on,
		di(4) => sgmntbox_on,
		do(0) => grid_bgon,
		do(1) => hz_bgon,
		do(2) => vt_bgon,
		do(3) => text_bgon,
		do(4) => sgmntbox_bgon);

	scopeio_palette_e : entity hdl4fpga.scopeio_palette
	generic map (
		dflt_tracesfg => dflt_tracesfg,
		dflt_gridfg   => dflt_gridfg, 
		dflt_gridbg   => dflt_gridbg, 
		dflt_hzfg     => dflt_hzfg,
		dflt_hzbg     => dflt_hzbg, 
		dflt_vtfg     => dflt_vtfg,
		dflt_vtbg     => dflt_vtbg, 
		dflt_textbg   => dflt_textbg, 
		dflt_textfg   => dflt_vtfg, 
		dflt_sgmntbg  => dflt_sgmntbg, 
		dflt_bg       => dflt_bg)
	port map (
		rgtr_clk         => rgtr_clk,
		rgtr_dv          => rgtr_dv,
		rgtr_id          => rgtr_id,
		rgtr_data        => rgtr_data,

		video_clk        => video_clk,
		trace_dots       => trace_dots, 
		trigger_dot      => trigger_dot,
		trigger_chanid   => trigger_chanid,
		grid_dot         => grid_dot,
		grid_bgon        => grid_bgon,
		hz_dot           => hz_dot,
		hz_bgon          => hz_bgon,
		vt_dot           => vt_dot,
		vt_bgon          => vt_bgon,
		text_dot         => text_dot,
		text_bgon        => text_bgon,
		sgmnt_bgon       => sgmntbox_bgon,
		video_color      => scope_color);

	scopeio_pointer_e : entity hdl4fpga.scopeio_pointer
	generic map (
		latency => vgaio_latency)
	port map (
		rgtr_clk   => rgtr_clk,
		rgtr_dv    => rgtr_dv,
		rgtr_id    => rgtr_id,
		rgtr_data  => rgtr_data,

		video_clk    => video_clk,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_dot    => pointer_dot);

	video_color <= scope_color or (video_color'range => pointer_dot);
	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

	time_scale  <= hz_scale;
	time_offset <= hz_slider;
end;
