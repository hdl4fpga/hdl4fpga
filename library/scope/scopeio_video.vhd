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
use hdl4fpga.jso.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_video is
	generic (
		timing_id        : videotiming_ids;
		modeline         : natural_vector(0 to 9-1) := (others => 0);
		width            : natural := 0;
		height           : natural := 0;
		fps              : real    := 0.0;
		pclk             : real    := 0.0;
		layout           : string;
		inputs           : natural;
		input_names      : tag_vector);
	port (
		tp : out std_logic_vector(1 to 32);
		rgtr_clk         : in  std_logic;
		rgtr_dv          : in  std_logic;
		rgtr_id          : in  std_logic_vector(8-1 downto 0);
		rgtr_data        : in  std_logic_vector;

		time_scale       : buffer std_logic_vector;
		time_offset      : buffer std_logic_vector;

		gain_dv          : in  std_logic;
		gain_ena         : in  std_logic;
		gain_cid         : in  std_logic_vector;
		gain_ids         : in  std_logic_vector;

		video_addr       : out std_logic_vector;
		video_frm        : out std_logic;
		video_data       : in  std_logic_vector;
		video_dv         : in  std_logic;

		video_clk        : in  std_logic;
		video_pixel      : out std_logic_vector;
		extern_video     : in  std_logic := '0';
		extern_videohzsync : in std_logic := '-';
		extern_videovtsync : in std_logic := '-';
		extern_videoblankn : in std_logic := '-';
		video_hsync      : out std_logic;
		video_vsync      : out std_logic;

		video_vton       : buffer std_logic;
		video_hzon       : buffer std_logic;
		video_blank      : out std_logic;
		video_sync       : out std_logic);

	constant chanid_bits : natural := unsigned_num_bits(inputs-1);
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);

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
	constant palette_latency      : natural := 2;
	constant vgaio_latency        : natural := input_latency+mainrgtrio_latency+sgmntrgtrio_latency+segmment_latency+palette_latency;

	constant hztick_bits : natural := unsigned_num_bits(8*axis_fontsize(layout)-1);

	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
	signal video_vld     : std_logic;
	signal video_vtcntr  : std_logic_vector(11-1 downto 0);
	signal video_hzcntr  : std_logic_vector(11-1 downto 0);
	signal video_color   : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_io      : std_logic_vector(0 to 3-1);

	signal scope_color   : std_logic_vector(video_pixel'length-1 downto 0);

	signal trigger_ena    : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_slope  : std_logic;
	signal trigger_chanid : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_level  : std_logic_vector(storage_word'range);

	signal hz_ena        : std_logic;
	signal hz_dv         : std_logic;
	signal hz_scale      : std_logic_vector(4-1 downto 0);
	signal hz_slider     : std_logic_vector(time_offset'range);
	signal hz_segment    : std_logic_vector(hz_slider'range);
	constant max_delay : natural := 2**hz_slider'length;

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

	signal x             : std_logic_vector(sgmntboxx_bits-1 downto 0);
	signal y             : std_logic_vector(sgmntboxy_bits-1 downto 0);
	signal textbox_x     : std_logic_vector(sgmntboxx_bits-1 downto 0);
	signal textbox_y     : std_logic_vector(sgmntboxy_bits-1 downto 0);
	signal sgmntbox_on   : std_logic;
	signal grid_on       : std_logic;
	signal hz_on         : std_logic;
	signal vt_on         : std_logic;
	signal text_on       : std_logic;

	signal trigger_dot   : std_logic;
	signal trace_dots    : std_logic_vector(0 to inputs-1);
	signal grid_dot      : std_logic;
	signal grid_bgon     : std_logic;
	signal hz_dot        : std_logic;
	signal hz_bgon       : std_logic;
	signal vt_dot        : std_logic;
	signal vt_bgon       : std_logic;
	signal text_fgon     : std_logic;
	signal text_bgon     : std_logic;
	signal text_fg       : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+inputs+1-1)-1);
	signal text_bg       : std_logic_vector(text_fg'range);
	signal sgmntbox_bgon : std_logic;
	signal sgmntbox_ena  : std_logic_vector(0 to resolve(layout&".num_of_segments")-1);
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

	rgtrtrigger_e : entity hdl4fpga.scopeio_rgtrtrigger
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		trigger_ena    => trigger_ena,
		trigger_slope  => trigger_slope,
		trigger_freeze => trigger_freeze,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level);

	rgtrhzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_ena    => hz_ena,
		hz_dv     => hz_dv,
		hz_scale  => hz_scale,
		hz_slider => hz_slider);
	tp(1 to 8) <= std_logic_vector(resize(unsigned(hz_slider),8));
	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if hz_ena='1'  then
				if trigger_freeze='0' then
					time_scale <= hz_scale;
				end if;
				time_offset <= hz_slider;
			end if;
		end if;
	end process;

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
		timing_id     => timing_id,
		modeline      => modeline,
		width         => setif(width=0,  main_width(layout),   width),
		height        => setif(height=0, main_height(layout), height),
		fps           => fps,
		pclk          => pclk)
	port map (
		video_clk     => video_clk,
		extern_video  => extern_video,
		extern_hzsync => extern_videohzsync,
		extern_vtsync => extern_videovtsync,
		extern_blankn => extern_videoblankn,
		video_hzsync  => video_hzsync,
		video_vtsync  => video_vtsync,
		video_hzcntr  => video_hzcntr,
		video_vtcntr  => video_vtcntr,
		video_hzon    => video_hzon,
		video_vton    => video_vton);

	video_vld <= video_hzon and video_vton;

	vgaio_e : entity hdl4fpga.latency
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
		layout => layout)
	port map (
		video_clk    => video_clk,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton,

		hz_slider    => time_offset,
		hz_segment   => hz_segment,
		x            => x,
		y            => y,
		textbox_x    => textbox_x,
		textbox_y    => textbox_y,
		sgmntbox_on  => sgmntbox_on,
		sgmntbox_ena => sgmntbox_ena,
		video_addr   => video_addr,
		video_frm    => video_frm,
		grid_on      => grid_on,
		hz_on        => hz_on,
		vt_on        => vt_on,
		textbox_on   => text_on);

	textbox_g : if textbox_width(layout)/=0 generate
		scopeio_texbox_e : entity hdl4fpga.scopeio_textbox
		generic map (
			inputs        => inputs,
			input_names   => input_names,
			max_delay     => max_delay, 
			latency       => segmment_latency+input_latency,
			layout        => layout)
		port map (
			rgtr_clk      => rgtr_clk,
			rgtr_dv       => rgtr_dv,
			rgtr_id       => rgtr_id,
			rgtr_data     => rgtr_data,

			gain_ena      => gain_ena,
			gain_dv       => gain_dv,
			gain_cid      => gain_cid,
			gain_ids      => gain_ids,

			time_ena      => hz_ena,
			time_scale    => time_scale,
			time_offset   => time_offset,

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
			video_hcntr   => textbox_x,
			video_vcntr   => textbox_y,
			sgmntbox_ena  => sgmntbox_ena,
			text_fg       => text_fg,
			text_bg       => text_bg,
			text_on       => text_on,
			text_fgon     => text_fgon);
	end generate;

	notextbox_g : if textbox_width(layout)=0 generate
		btof_binfrm(text_id)  <= '0';
		btof_binirdy(text_id) <= '-';
		btof_bindi(4*text_id to 4*(text_id+1)-1) <= (others => '-');
		btof_binneg(text_id)  <= '-';
		btof_binexp(text_id)  <= '-';
		btof_bcdsign(text_id) <= '-';
		btof_bcdwidth(4*text_id to 4*(text_id+1)-1) <= (others => '-');
		btof_bcdprec(4*text_id to 4*(text_id+1)-1)  <= (others => '-');
		btof_bcdunit(4*text_id to 4*(text_id+1)-1)  <= (others => '-');
		btof_bcdalign(text_id) <= '-';
		btof_bcdirdy(text_id)  <= '-';
	end generate;

	scopeio_segment_e : entity hdl4fpga.scopeio_segment
	generic map (
		input_latency => input_latency,
		latency       => segmment_latency+input_latency,
		inputs        => inputs,
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
		hz_scale      => time_scale,
		hz_base       => time_offset(time_offset'left downto axisx_backscale+hztick_bits),
		hz_offset     => hz_segment,

		gain_cid      => gain_cid,
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
		trigger_chanid => trigger_chanid,
		trigger_level => trigger_level,
		grid_dot      => grid_dot,
		hz_dot        => hz_dot,
		vt_dot        => vt_dot,
		trigger_dot   => trigger_dot,
		trace_dots    => trace_dots);

	bg_e : entity hdl4fpga.latency
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
		layout        => layout)
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		video_clk      => video_clk,
		trace_dots     => trace_dots, 
		trigger_dot    => trigger_dot,
		trigger_chanid => trigger_chanid,
		grid_dot       => grid_dot,
		grid_bgon      => grid_bgon,
		hz_dot         => hz_dot,
		hz_bgon        => hz_bgon,
		vt_dot         => vt_dot,
		vt_bgon        => vt_bgon,
		text_fg        => text_fg,
		text_bg        => text_bg,
		text_fgon      => text_fgon,
		text_bgon      => text_bgon,
		sgmnt_bgon     => sgmntbox_bgon,
		video_color    => scope_color);

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

	-- video_color <= scope_color or (video_color'range => pointer_dot);
	video_color <= scope_color;
	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
