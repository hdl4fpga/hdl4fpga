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
		vlayout_id       : natural;
		axis_unit        : std_logic_vector;
		inputs           : natural;
		default_tracesfg : std_logic_vector;
		default_gridfg   : std_logic_vector;
		default_gridbg   : std_logic_vector;
		default_hzfg     : std_logic_vector;
		default_hzbg     : std_logic_vector;
		default_vtfg     : std_logic_vector;
		default_vtbg     : std_logic_vector;
		default_textbg   : std_logic_vector;
		default_sgmntbg  : std_logic_vector;
		default_bg       : std_logic_vector);
	port (
		si_clk        : in  std_logic;

		hz_dv         : in  std_logic;
		hz_scale      : in  std_logic_vector(4-1 downto 0);
		hz_offset     : in  std_logic_vector;

		vt_dv         : in  std_logic;
		vt_offsets    : in  std_logic_vector(inputs*(5+8)-1 downto 0);
		vt_chanid     : in  std_logic_vector(chanid_maxsize-1 downto 0);

		palette_dv    : in  std_logic;
		palette_id    : in  std_logic_vector;
		palette_color : in  std_logic_vector;

		gain_dv       : in  std_logic;
		gain_ids      : in  std_logic_vector;

		trigger_chanid: in  std_logic_vector;
		trigger_level : in  std_logic_vector;

		capture_addr  : out std_logic_vector;
		capture_data  : in  std_logic_vector;
		capture_dv    : in  std_logic;

		pointer_x     : in  std_logic_vector;
		pointer_y     : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_pixel   : out std_logic_vector;
		video_hsync   : out std_logic;
		video_vsync   : out std_logic;

		video_vton    : out std_logic;
		video_hzon    : out std_logic;
		video_blank   : out std_logic;
		video_sync    : out std_logic);

end;

architecture beh of scopeio_video is

	constant storageaddr_latency  : natural := 1;
	constant storagebram_latency  : natural := 2;
	constant input_latency        : natural := storageaddr_latency+storagebram_latency;
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

	signal video_vton1   : std_logic;
	signal video_hzon1    : std_logic;
	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
	signal video_vld     : std_logic;
	signal video_vtcntr  : std_logic_vector(11-1 downto 0);
	signal video_hzcntr  : std_logic_vector(11-1 downto 0);
	signal video_color   : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_io      : std_logic_vector(0 to 3-1);

	signal scope_color   : std_logic_vector(video_pixel'length-1 downto 0);

	signal hz_segment    : std_logic_vector(hz_offset'range);

	signal wu_frm        : std_logic;
	signal wu_irdy       : std_logic;
	signal wu_trdy       : std_logic;
	signal wu_unit       : std_logic_vector(4-1 downto 0);
	signal wu_neg        : std_logic;
	signal wu_sign       : std_logic;
	signal wu_align      : std_logic;
	signal wu_value      : std_logic_vector(4*4-1 downto 0);
	signal wu_format     : std_logic_vector(8*4-1 downto 0);

	constant hztick_bits : natural := unsigned_num_bits(8*axis_fontsize(layout)-1);

	signal trigger_dot   : std_logic;
	signal traces_dots   : std_logic_vector(0 to inputs-1);
	signal grid_dot      : std_logic;
	signal grid_bgon     : std_logic;
	signal hz_dot        : std_logic;
	signal hz_bgon       : std_logic;
	signal vt_dot        : std_logic;
	signal vt_bgon       : std_logic;
	signal text_bgon     : std_logic;
	signal sgmntbox_on   : std_logic;
	signal sgmntbox_bgon : std_logic;
	signal pointer_dot   : std_logic;

begin
	formatu_e : entity hdl4fpga.scopeio_formatu
	port map (
		clk    => si_clk,
		frm    => wu_frm,
		irdy   => wu_irdy,
		trdy   => wu_trdy,
		float  => wu_value,
		width  => b"1000",
		sign   => wu_sign,
		neg    => wu_neg,
		unit   => wu_unit,
		align  => wu_align,
		prec   => b"1111",
		format => wu_format);

	video_e : entity hdl4fpga.video_sync
	generic map (
		mode => video_description(vlayout_id).mode_id)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon1,
		video_vton   => video_vton1);

	video_vld <= video_hzon1 and video_vton1;

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

	layout_b : block

		signal mainbox_xdiv  : std_logic_vector(0 to 2-1);
		signal mainbox_ydiv  : std_logic_vector(0 to 4-1);
		signal mainbox_xedge : std_logic;
		signal mainbox_yedge : std_logic;
		signal mainbox_nexty : std_logic;
		signal mainbox_eox   : std_logic;
		signal mainbox_xon   : std_logic;
		signal mainbox_yon   : std_logic;

		signal sgmnt_decode  : std_logic_vector(0 to layout.num_of_segments-1);
	begin

		mainlayout_e : entity hdl4fpga.videobox_layout
		generic map (
			x_edges => main_xedges(layout),
			y_edges => main_yedges(layout))
		port map (
			video_clk  => video_clk,
			video_x    => video_hzcntr,
			video_y    => video_vtcntr,
			video_xon  => video_hzon1,
			video_yon  => video_vton1,
			box_xedge  => mainbox_xedge,
			box_yedge  => mainbox_yedge,
			box_eox    => mainbox_eox,
			box_xon    => mainbox_xon,
			box_yon    => mainbox_yon,
			box_xdiv   => mainbox_xdiv,
			box_nexty  => mainbox_nexty,
			box_ydiv   => mainbox_ydiv);

		sgmnt_decode_p: process (video_clk)
		begin
			if rising_edge(video_clk) then
				sgmntbox_on   <= '0';
				sgmnt_decode <= (others => '0');
				for i in 0 to layout.num_of_segments-1 loop
					if main_boxon(box_id => i, x_div => mainbox_xdiv, y_div => mainbox_ydiv, layout => layout)='1' then
						sgmntbox_on     <= mainbox_xon;
						sgmnt_decode(i) <= '1';
					end if;
				end loop;
			end if;
		end process;

		mainbox_b : block

			constant sgmntboxx_bits : natural := unsigned_num_bits(sgmnt_width(layout)-1);
			constant sgmntboxy_bits : natural := unsigned_num_bits(sgmnt_height(layout)-1);

			signal sgmntbox_vyon   : std_logic;
			signal sgmntbox_vxon   : std_logic;
			signal sgmntbox_vx     : std_logic_vector(sgmntboxx_bits-1 downto 0);
			signal sgmntbox_vy     : std_logic_vector(sgmntboxy_bits-1 downto 0);

			signal sgmntbox_x      : std_logic_vector(sgmntboxx_bits-1 downto 0);
			signal sgmntbox_y      : std_logic_vector(sgmntboxy_bits-1 downto 0);
			signal sgmntbox_xedge  : std_logic;
			signal sgmntbox_yedge  : std_logic;
			signal sgmntbox_xdiv   : std_logic_vector(0 to 3-1);
			signal sgmntbox_ydiv   : std_logic_vector(0 to 3-1);
			signal sgmntbox_xon    : std_logic;
			signal sgmntbox_yon    : std_logic;
			signal sgmntbox_eox    : std_logic;
			signal sgmntbox_sel    : std_logic_vector(sgmnt_decode'range);

			signal grid_on         : std_logic;
			signal hz_on           : std_logic;
			signal vt_on           : std_logic;
			signal text_on         : std_logic;

		begin

			box_b : block
				signal xon   : std_logic;
				signal yon   : std_logic;
				signal eox   : std_logic;
				signal xedge : std_logic;
				signal yedge : std_logic;
				signal nexty : std_logic;
				signal x     : std_logic_vector(sgmntboxx_bits-1 downto 0);
				signal y     : std_logic_vector(sgmntboxy_bits-1 downto 0);
			begin 

				rgtrin_p : process (video_clk)
				begin
					if rising_edge(video_clk) then
						yon   <= mainbox_yon;
						eox   <= mainbox_eox;
						xedge <= mainbox_xedge;
						yedge <= mainbox_yedge;
						nexty <= mainbox_nexty;
					end if;
				end process;
			
				xon <= sgmntbox_on;
				videobox_e : entity hdl4fpga.videobox
				port map (
					video_clk => video_clk,
					video_xon => xon,
					video_yon => yon,
					video_eox => eox,
					box_xedge => xedge,
					box_yedge => yedge,
					box_x     => x,
					box_y     => y);

				rgtrout_p : process (video_clk)
					variable init_layout : std_logic;
				begin
					if rising_edge(video_clk) then
						sgmntbox_vxon <= xon;
						sgmntbox_vyon <= yon and not init_layout;
						sgmntbox_vx   <= x;
						sgmntbox_vy   <= y;
						init_layout   := nexty;
					end if;
				end process;

			end block;

			sgmntlayout_b : block
			begin

				layout_e : entity hdl4fpga.videobox_layout
				generic map (
					x_edges   => sgmnt_xedges(layout),
					y_edges   => sgmnt_yedges(layout))
				port map (
					video_clk => video_clk,
					video_xon => sgmntbox_vxon,
					video_yon => sgmntbox_vyon,
					video_x   => sgmntbox_vx,
					video_y   => sgmntbox_vy,
					box_xon   => sgmntbox_xon,
					box_yon   => sgmntbox_yon,
					box_eox   => sgmntbox_eox,
					box_xedge => sgmntbox_xedge,
					box_yedge => sgmntbox_yedge,
					box_xdiv  => sgmntbox_xdiv,
					box_ydiv  => sgmntbox_ydiv);
			end block;

			sgmntbox_b : block
				signal xon   : std_logic;
				signal yon   : std_logic;
				signal eox   : std_logic;
				signal xedge : std_logic;
				signal yedge : std_logic;
				signal xdiv  : std_logic_vector(sgmntbox_xdiv'range);
				signal ydiv  : std_logic_vector(sgmntbox_ydiv'range);
				signal x     : std_logic_vector(sgmntbox_x'range);
				signal y     : std_logic_vector(sgmntbox_y'range);
			begin

				rgtrin_p : process (video_clk)
				begin
					if rising_edge(video_clk) then
						xon   <= sgmntbox_xon;
						yon   <= sgmntbox_yon;
						eox   <= sgmntbox_eox;
						xedge <= sgmntbox_xedge;
						yedge <= sgmntbox_yedge;
						xdiv  <= sgmntbox_xdiv;
						ydiv  <= sgmntbox_ydiv;
					end if;
				end process;

				box_e : entity hdl4fpga.videobox
				port map (
					video_clk => video_clk,
					video_xon => xon,
					video_yon => yon,
					video_eox => eox,
					box_xedge => xedge,
					box_yedge => yedge,
					box_x     => x,
					box_y     => y);

				rgtrout_p: process (video_clk)
					constant font_bits : natural := unsigned_num_bits(axis_fontsize(layout)-1);
					variable vt_mask : unsigned(x'range);
					variable hz_mask : unsigned(y'range);
					variable box_on  : std_logic;
				begin
					if rising_edge(video_clk) then
						box_on  := xon and yon;
						vt_mask := unsigned(x) srl font_bits;
						if vtaxis_width(layout)=0  then
							if vtaxis_tickrotate(layout)=ccw90 or vtaxis_tickrotate(layout)=ccw270 then
								vt_on <= setif(vt_mask=(vt_mask'range => '0')) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							else
								vt_on <= setif(vt_mask < 6) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							end if;
						else
							vt_on <= sgmnt_boxon(box_id => vtaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						end if;
						hz_mask := unsigned(y) srl 3;
						if hzaxis_height(layout)=0  then
							hz_on <= setif((hz_mask'range => '0')=hz_mask) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						else
							hz_on <= sgmnt_boxon(box_id => hzaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						end if;
						grid_on    <= sgmnt_boxon(box_id => grid_boxid,   x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						text_on    <= sgmnt_boxon(box_id => text_boxid,   x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						sgmntbox_x <= x;
						sgmntbox_y <= y;
					end if;
				end process;
			end block;

			decode_e : entity hdl4fpga.align
			generic map (
				n => sgmnt_decode'length,
				d => (sgmnt_decode'range => mainrgtrout_latency+sgmntrgtrio_latency))
			port map (
				clk => video_clk,
				di  => sgmnt_decode,
				do  => sgmntbox_sel);

			capture_addr_p : process (video_clk)
				variable base : unsigned(0 to capture_addr'length-1);
			begin
				if rising_edge(video_clk) then
					base := (others => '0');
					for i in 0 to layout.num_of_segments-1 loop
						if sgmntbox_sel(i)='1' then
							base := base or to_unsigned((grid_width(layout)-grid_width(layout) mod grid_divisionsize(layout))*i, base'length);
						end if;
					end loop;
										   
					capture_addr <= std_logic_vector(base + resize(unsigned(sgmntbox_x), capture_addr'length));
					hz_segment   <= std_logic_vector(base + resize(unsigned(hz_offset(axisx_backscale+hztick_bits-1 downto 0)), hz_segment'length));
														  
				end if;
			end process;

			scopeio_segment_e : entity hdl4fpga.scopeio_segment
			generic map (
				input_latency => input_latency,
				latency       => segmment_latency+input_latency,
				inputs        => inputs,
				axis_unit     => axis_unit,
				layout        => layout)
			port map (
				in_clk        => si_clk,

				wu_frm        => wu_frm ,
				wu_irdy       => wu_irdy,
				wu_trdy       => wu_trdy,
				wu_unit       => wu_unit,
				wu_neg        => wu_neg,
				wu_sign       => wu_sign,
				wu_align      => wu_align,
				wu_value      => wu_value,
				wu_format     => wu_format,

				hz_dv         => hz_dv,
				hz_scale      => hz_scale,
				hz_base       => hz_offset(hz_offset'left downto axisx_backscale+hztick_bits),
				hz_offset     => hz_segment,

				gain_dv       => gain_dv,
				gain_ids      => gain_ids,
				vt_dv         => vt_dv,
				vt_chanid     => vt_chanid,
				vt_offsets    => vt_offsets,

				video_clk     => video_clk,
				x             => sgmntbox_x,
				y             => sgmntbox_y,

				hz_on         => hz_on,
				vt_on         => vt_on,
				grid_on       => grid_on,

				sample_dv     => capture_dv,
				sample_data   => capture_data,
				trigger_level => trigger_level,
				grid_dot      => grid_dot,
				hz_dot        => hz_dot,
				vt_dot        => vt_dot,
				trigger_dot   => trigger_dot,
				traces_dots   => traces_dots);

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

		end block;

	end block;

	scopeio_palette_e : entity hdl4fpga.scopeio_palette
	generic map (
		default_tracesfg => default_tracesfg,
		default_gridfg   => default_gridfg, 
		default_gridbg   => default_gridbg, 
		default_hzfg     => default_hzfg,
		default_hzbg     => default_hzbg, 
		default_vtfg     => default_vtfg,
		default_vtbg     => default_vtbg, 
		default_textbg   => default_textbg, 
		default_sgmntbg  => default_sgmntbg, 
		default_bg       => default_bg)
	port map (
		wr_clk           => si_clk,
		wr_dv            => palette_dv,
		wr_palette       => palette_id,
		wr_color         => palette_color,
		video_clk        => video_clk,
		traces_dots      => traces_dots, 
		trigger_dot      => trigger_dot,
		trigger_chanid   => trigger_chanid,
		grid_dot         => grid_dot,
		grid_bgon        => grid_bgon,
		hz_dot           => hz_dot,
		hz_bgon          => hz_bgon,
		vt_dot           => vt_dot,
		vt_bgon          => vt_bgon,
		text_bgon        => text_bgon,
		sgmnt_bgon       => sgmntbox_bgon,
		video_color      => scope_color);

	scopeio_pointer_e : entity hdl4fpga.scopeio_pointer
	generic map (
		latency => vgaio_latency)
	port map (
		video_clk    => video_clk,
		pointer_x    => pointer_x,
		pointer_y    => pointer_y,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_dot    => pointer_dot);

	video_color <= scope_color or (video_color'range => pointer_dot);
	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_vton  <= video_vton1;
	video_hzon  <= video_hzon1;
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
