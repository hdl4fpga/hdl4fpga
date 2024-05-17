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
use hdl4fpga.scopeiopkg.all;

entity scopeio_layout is
	generic (
		layout       : string);
	port (
		video_clk    : in  std_logic;
		video_vtcntr : in  std_logic_vector;
		video_hzcntr : in  std_logic_vector;
		video_vton   : in  std_logic;
		video_hzon   : in  std_logic;

		hz_segment   : out std_logic_vector;
		x            : buffer std_logic_vector;
		y            : buffer std_logic_vector;
		textbox_x    : out std_logic_vector;
		textbox_y    : out std_logic_vector;
		sgmntbox_on  : buffer std_logic;
		sgmntbox_ena : out std_logic_vector;
		video_addr   : out std_logic_vector;
		video_frm    : out std_logic;
		grid_on      : buffer std_logic;
		hz_on        : out std_logic;
		vt_on        : out std_logic;
		textbox_on   : out std_logic);

	constant num_of_segments       : natural := jso(layout)**".num_of_segments";
	constant main_top              : natural := jso(layout)**".main.top";
	constant main_bottom           : natural := jso(layout)**".main.bottom";
	constant main_height           : natural := jso(layout)**".display.height";
	constant main_width            : natural := jso(layout)**".display.width";
	constant main_left             : natural := jso(layout)**".main.left";
	constant main_right            : natural := jso(layout)**".main.right";
	constant main_horizontal       : natural := jso(layout)**".main.horizontal";
	constant main_vertical         : natural := jso(layout)**".main.vertical";

	constant segment_vertical      : natural := jso(layout)**".segment.vertical";
	constant segment_horizontal    : natural := jso(layout)**".segment.horizontal";
	constant segment_top           : natural := jso(layout)**".segment.top";
	constant segment_bottom        : natural := jso(layout)**".segment.bottom";
	constant segment_left          : natural := jso(layout)**".segment.left";
	constant segment_right         : natural := jso(layout)**".segment.right";

	constant grid_width            : natural := jso(layout)**".grid.width";
	constant grid_height           : natural := jso(layout)**".grid.height";
	constant grid_unit             : natural := jso(layout)**".grid.unit";

	constant hzaxis_height         : natural := jso(layout)**".axis.horizontal.height";
	constant vtaxis_width          : natural := jso(layout)**".axis.vertical.width";
	constant vtaxis_height         : natural := jso(layout)**".grid.height";
	constant vtaxis_tickrotate     : string  := jso(layout)**".axis.vertical.rotate";

	constant axishorizontal_inside : boolean := jso(layout)**".axis.horizontal.inside";
	constant axishorizontal_height : natural := jso(layout)**".axis.horizontal.height";
	constant axisvertical_inside   : boolean := jso(layout)**".axis.vertical.inside";
	constant axisvertical_width    : natural := jso(layout)**".axis.vertical.width";
	constant axis_fontsize         : natural := jso(layout)**".axis.fontsize";

	constant textbox_width         : natural := jso(layout)**".textbox.width";
	constant textbox_height        : natural := jso(layout)**".grid.height";
	constant textbox_inside        : boolean := jso(layout)**".textbox.inside";

	function is_postive(
		constant val : natural)
		return natural is
	begin
		if val > 0 then
			return 1;
		end if;
		return 0;
	end;

	function sgmnt_height
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + segment_top;
		retval := retval + grid_height;
		if not axishorizontal_inside then
			retval := retval + axishorizontal_height;
			retval := retval + segment_vertical;
		end if;
		retval := retval + segment_bottom;
		return retval;
	end;

	function sgmnt_width
		return natural is
		variable retval : natural := 0;
	begin
		retval := retval + segment_left;
		if not axisvertical_inside then
			retval := retval + axisvertical_width;
			retval := retval + segment_horizontal;
		end if;
		retval := retval + grid_width;
		if not textbox_inside then
			retval := retval + textbox_width;
			retval := retval + segment_horizontal;
		end if;
		retval := retval + segment_right;
		return retval;
	end;

	function boxes_sides(
		constant sides        : natural_vector;
		constant margin_start : natural := 0;
		constant margin_end   : natural := 0;
		constant gap          : natural := 0)
		return natural_vector is

		variable edge   : natural;
		variable index  : natural;
		variable edges  : natural_vector(0 to sides'length+(sides'length-1)*gap+is_postive(margin_end)-1);
		variable retval : natural_vector(0 to sides'length+(sides'length-1)*gap+is_postive(margin_start)+is_postive(margin_end)-1);
	begin

		index := 0;
		edge  := margin_start;
		for i in sides'range loop
			if sides(i)/=0 then
				if index > 0 then
					if gap/=0 then
						edges(index) := gap + edge;
						edge  := edges(index);
						index := index + 1;
					end if;
				end if;
				edges(index) := sides(i) + edge;
				edge  := edges(index);
				index := index + 1;
			end if;
		end loop;
		if margin_end > 0 then
			edges(index) := margin_end + edge;
			index := index + 1;
		end if;
		if margin_start > 0 then
			retval(0) := margin_start;
			retval(1 to index) := edges(0 to index-1);
			index := index + 1;
		else
			retval(0 to index-1) := edges(0 to index-1);
		end if;

		return retval(0 to index-1);
	end;

	function sgmnt_hzedges
		return natural_vector is
	begin

		return to_edges(boxes_sides(
			sides        => (
				vtaxis_boxid => setif(not axisvertical_inside, vtaxis_width), 
				grid_boxid   => grid_width, 
				text_boxid   => setif(not textbox_inside, textbox_width)),
			margin_start => segment_left,
			margin_end   => segment_right,
			gap          => segment_horizontal));
	end;

	function sgmnt_vtedges
		return natural_vector is
	begin
		return to_edges(boxes_sides(
			sides        => (
				0 => grid_height,
				1 => setif(not axishorizontal_inside, hzaxis_height)),
			margin_start => segment_top,
			margin_end   => segment_bottom,
			gap          => segment_vertical));
	end;

	function sgmnt_boxon (
		constant box_id : natural;
		constant x_div  : std_logic_vector;
		constant y_div  : std_logic_vector)
		return std_logic is
		constant textbox_width : natural := textbox_width;
		constant x_sides  : natural_vector := (
			vtaxis_boxid => setif(not axisvertical_inside, vtaxis_width),
			grid_boxid   => grid_width,
			text_boxid   => setif(not textbox_inside, textbox_width),
			hzaxis_boxid => setif(not axishorizontal_inside,  hzaxis_height));

		constant y_sides  : natural_vector := (
			vtaxis_boxid => setif(not axisvertical_inside, vtaxis_height),
			grid_boxid   => grid_height,
			text_boxid   => setif(not textbox_inside, textbox_height),
			hzaxis_boxid => setif(not axishorizontal_inside, hzaxis_height));

		variable retval   : std_logic;
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap    : natural;
		variable y_gap    : natural;

		function lookup (
			constant id    : natural;
			constant sides : natural_vector)
			return natural is
			variable div   : natural;
		begin
			div := 0;
			for i in 0 to id-1  loop
				if sides(i) /= 0 then
					div := div + 1;
				end if;
			end loop;
			return div;
		end;

	begin

		retval   := '0';
		x_margin := is_postive(segment_left);
		y_margin := is_postive(segment_top);
		x_gap    := is_postive(segment_horizontal);
		y_gap    := is_postive(segment_vertical);

		case box_id is
		when vtaxis_boxid | grid_boxid | text_boxid =>                 
			if x_sides(box_id)/=0 then
				retval := setif(unsigned(y_div)=(0*(y_gap+1)+y_margin) and unsigned(x_div)=(lookup(box_id, x_sides)*(x_gap+1)+x_margin));
			end if;
		when hzaxis_boxid =>               
			if y_sides(hzaxis_boxid)/=0 then
				retval := setif(unsigned(y_div)=(1*(y_gap+1)+y_margin) and unsigned(x_div)=(lookup(grid_boxid, x_sides)*(x_gap+1)+x_margin));
			end if;
		when others =>
			retval := '0';
		end case;
		return retval;
	end;

	function main_hzedges
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			sides        => (0 => sgmnt_width),
			margin_start => main_left,
			margin_end   => main_right,
			gap          => main_horizontal);
	begin
		assert sides(sides'right)<=main_width
			report "Boxes' Width sum up cannot be greater than Display's Width"
			severity FAILURE;
		return to_edges(sides);
	end;

	function main_vtedges
		return natural_vector is
		constant sides : natural_vector := boxes_sides(
			sides        => (0 to num_of_segments-1 => sgmnt_height),
			margin_start => main_top,
			margin_end   => main_bottom,
			gap          => main_vertical);
	begin
		assert sides(sides'right)<=main_height
			report "Boxes' Height sum up cannot be greater than Display's Height"
			severity FAILURE;
		return to_edges(sides);
	end;

	function main_boxon (
		constant box_id   : natural;
		constant x_div    : std_logic_vector;
		constant y_div    : std_logic_vector)
		return std_logic is
		variable x_margin : natural;
		variable y_margin : natural;
		variable x_gap    : natural;
		variable y_gap    : natural;
	begin

		x_margin := is_postive(main_left);
		y_margin := is_postive(main_top);
		x_gap    := is_postive(main_horizontal);
		y_gap    := is_postive(main_vertical);

		return setif(unsigned(y_div)=box_id*(y_gap+1)+y_margin and unsigned(x_div)=0*(x_gap+1)+x_margin);
	end;

end;

architecture beh of scopeio_layout is

	constant mainrgtrout_latency  : natural := 1;
	constant sgmntrgtrin_latency  : natural := 1;
	constant sgmntrgtrout_latency : natural := 1;
	constant sgmntrgtrio_latency  : natural := sgmntrgtrout_latency+sgmntrgtrin_latency;

	constant hztick_bits : natural := unsigned_num_bits(8*axis_fontsize-1);

	signal mainbox_xdiv  : std_logic_vector(0 to 2-1);
	signal mainbox_ydiv  : std_logic_vector(0 to 4-1);
	signal mainbox_xedge : std_logic;
	signal mainbox_yedge : std_logic;
	signal mainbox_nexty : std_logic;
	signal mainbox_eox   : std_logic;
	signal mainbox_xon   : std_logic;
	signal mainbox_yon   : std_logic;

	signal sgmnt_decode  : std_logic_vector(0 to num_of_segments-1);

begin

	mainlayout_e : entity hdl4fpga.videobox_layout
	generic map (
		x_edges => main_hzedges,
		y_edges => main_vtedges)
	port map (
		video_clk  => video_clk,
		video_x    => video_hzcntr,
		video_y    => video_vtcntr,
		video_xon  => video_hzon,
		video_yon  => video_vton,
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
			for i in 0 to num_of_segments-1 loop
				if main_boxon(box_id => i, x_div => mainbox_xdiv, y_div => mainbox_ydiv)='1' then
					sgmntbox_on     <= mainbox_xon;
					sgmnt_decode(i) <= '1';
				end if;
			end loop;
		end if;
	end process;

	mainbox_b : block

		signal sgmntbox_vyon   : std_logic;
		signal sgmntbox_vxon   : std_logic;
		signal sgmntbox_vx     : std_logic_vector(x'range);
		signal sgmntbox_vy     : std_logic_vector(y'range);

		signal sgmntbox_xedge  : std_logic;
		signal sgmntbox_yedge  : std_logic;
		signal sgmntbox_xdiv   : std_logic_vector(0 to 3-1);
		signal sgmntbox_ydiv   : std_logic_vector(0 to 3-1);
		signal sgmntbox_xon    : std_logic;
		signal sgmntbox_yon    : std_logic;
		signal sgmntbox_eox    : std_logic;
		signal sgmntbox_sel    : std_logic_vector(sgmnt_decode'range);

	begin

		box_b : block
			signal xon   : std_logic;
			signal yon   : std_logic;
			signal eox   : std_logic;
			signal xedge : std_logic;
			signal yedge : std_logic;
			signal nexty : std_logic;
			signal box_x : std_logic_vector(x'range);
			signal box_y : std_logic_vector(y'range);
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
				box_x     => box_x,
				box_y     => box_y);

			rgtrout_p : process (video_clk)
				variable init_layout : std_logic;
			begin
				if rising_edge(video_clk) then
					sgmntbox_vxon <= xon;
					sgmntbox_vyon <= yon and not init_layout;
					sgmntbox_vx   <= box_x;
					sgmntbox_vy   <= box_y;
					init_layout   := nexty;
				end if;
			end process;

		end block;

		sgmntlayout_b : block
		begin

			layout_e : entity hdl4fpga.videobox_layout
			generic map (
				x_edges   => sgmnt_hzedges,
				y_edges   => sgmnt_vtedges)
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

			signal sgmntbox_x : std_logic_vector(x'range);
			signal sgmntbox_y : std_logic_vector(y'range);
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
				box_x     => sgmntbox_x,
				box_y     => sgmntbox_y);

			rgtrout_p: process (video_clk)
				constant font_width : natural := axis_fontsize;
				constant font_bits : natural := unsigned_num_bits(font_width-1);
				constant textwidth_bits : natural := unsigned_num_bits(textbox_width-1);
				variable vt_mask : unsigned(x'range);
				variable hz_mask : unsigned(y'range);
				variable box_on  : std_logic;
			begin
				if rising_edge(video_clk) then
					box_on  := xon and yon;

					if vtaxis_width/=0  then
						if axisvertical_inside then
							vt_mask := unsigned(sgmntbox_x) srl font_bits;
							if vtaxis_tickrotate="ccw90" or vtaxis_tickrotate="ccw270" then
								vt_on <= setif(vt_mask=(vt_mask'range => '0')) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
							else
								vt_on <= setif(vt_mask < 6) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
							end if;
						else
							vt_on <= sgmnt_boxon(box_id => vtaxis_boxid, x_div => xdiv, y_div => ydiv) and box_on;
						end if;
					else
						vt_on <= '0';
					end if;

					if hzaxis_height/=0  then
						hz_mask := unsigned(y) srl font_bits;
						if axishorizontal_inside then
							if true then -- scale at the bottom
								if unsigned(hz_mask)=to_unsigned(grid_height/axis_fontsize-1, hz_mask'length) then
									hz_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
								else
									hz_on <= '0';
								end if;
							else -- scale at the top
								if unsigned(hz_mask)=0 then
									hz_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
								else
									hz_on <= '0';
								end if;
							end if;
						else
							hz_on <= sgmnt_boxon(box_id => hzaxis_boxid, x_div => xdiv, y_div => ydiv) and box_on;
						end if;
					else
						hz_on <= '0';
					end if;

					grid_on <= sgmnt_boxon(box_id => grid_boxid,   x_div => xdiv, y_div => ydiv) and box_on;

					if textbox_width/=0  then
						if textbox_inside then
							if 2**unsigned_num_bits(textbox_width-1)=textbox_width and (2**font_bits*(grid_width/2**font_bits)) mod textbox_width=0 then
								vt_mask := unsigned(sgmntbox_x) srl textwidth_bits;
								if unsigned(vt_mask)=to_unsigned(grid_width/textbox_width-1, vt_mask'length) then
									textbox_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
								else
									textbox_on <= '0';
								end if;
								textbox_x <= sgmntbox_x;
								textbox_y <= sgmntbox_y;
							else
								vt_mask := unsigned(sgmntbox_x) srl font_bits;
								if vt_mask >= (grid_width-textbox_width)/2**font_bits then
									textbox_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv) and box_on;
								else
									textbox_on <= '0';
								end if;
								textbox_x <= std_logic_vector(unsigned(sgmntbox_x)-(grid_width-textbox_width));
								textbox_y <= sgmntbox_y;
							end if;
						else
							textbox_x  <= sgmntbox_x;
							textbox_y  <= sgmntbox_y;
							textbox_on <= sgmnt_boxon(box_id => text_boxid, x_div => xdiv, y_div => ydiv) and box_on;
						end if;
					else
						textbox_on <= '0';
					end if;

					x <= sgmntbox_x;
					y <= sgmntbox_y;
				end if;
			end process;
		end block;

		decode_e : entity hdl4fpga.latency
		generic map (
			n => sgmnt_decode'length,
			d => (sgmnt_decode'range => mainrgtrout_latency+sgmntrgtrio_latency))
		port map (
			clk => video_clk,
			di  => sgmnt_decode,
			do  => sgmntbox_sel);

		capture_addr_p : process (video_clk)
			variable base : unsigned(video_addr'range);
		begin
			if rising_edge(video_clk) then
				base := (others => '0');
				for i in 0 to num_of_segments-1 loop
					if sgmntbox_sel(i)='1' then
						base := base or to_unsigned((grid_width-grid_width mod grid_unit)*i, base'length);
					end if;
				end loop;
				sgmntbox_ena <= sgmntbox_sel;
									   
				video_addr <= std_logic_vector(base + resize(unsigned(x), video_addr'length));
				video_frm  <= grid_on;
				hz_segment <= std_logic_vector(base);
													  
			end if;
		end process;

	end block;
end;
