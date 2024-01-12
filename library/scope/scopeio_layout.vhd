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

		hz_slider    : in  std_logic_vector;
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
end;

architecture beh of scopeio_layout is

	constant mainrgtrout_latency  : natural := 1;
	constant sgmntrgtrin_latency  : natural := 1;
	constant sgmntrgtrout_latency : natural := 1;
	constant sgmntrgtrio_latency  : natural := sgmntrgtrout_latency+sgmntrgtrin_latency;

	constant hztick_bits : natural := unsigned_num_bits(8*axis_fontsize(layout)-1);

	constant sgmntboxx_bits : natural := unsigned_num_bits(sgmnt_width(layout)-1);
	constant sgmntboxy_bits : natural := unsigned_num_bits(sgmnt_height(layout)-1);

	signal mainbox_xdiv  : std_logic_vector(0 to 2-1);
	signal mainbox_ydiv  : std_logic_vector(0 to 4-1);
	signal mainbox_xedge : std_logic;
	signal mainbox_yedge : std_logic;
	signal mainbox_nexty : std_logic;
	signal mainbox_eox   : std_logic;
	signal mainbox_xon   : std_logic;
	signal mainbox_yon   : std_logic;

	signal sgmnt_decode  : std_logic_vector(0 to jso(layout)**".num_of_segments"-1);

begin

	mainlayout_e : entity hdl4fpga.videobox_layout
	generic map (
		x_edges => main_xedges(layout),
		y_edges => main_yedges(layout))
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
			for i in 0 to jso(layout)**".num_of_segments"-1 loop
				if main_boxon(box_id => i, x_div => mainbox_xdiv, y_div => mainbox_ydiv, layout => layout)='1' then
					sgmntbox_on     <= mainbox_xon;
					sgmnt_decode(i) <= '1';
				end if;
			end loop;
		end if;
	end process;

	mainbox_b : block

		signal sgmntbox_vyon   : std_logic;
		signal sgmntbox_vxon   : std_logic;
		signal sgmntbox_vx     : std_logic_vector(sgmntboxx_bits-1 downto 0);
		signal sgmntbox_vy     : std_logic_vector(sgmntboxy_bits-1 downto 0);

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
				constant font_width : natural := axis_fontsize(layout);
				constant font_bits : natural := unsigned_num_bits(font_width-1);
				constant textwidth_bits : natural := unsigned_num_bits(textbox_width(layout)-1);
				variable vt_mask : unsigned(x'range);
				variable hz_mask : unsigned(y'range);
				variable box_on  : std_logic;
			begin
				if rising_edge(video_clk) then
					box_on  := xon and yon;

					if vtaxis_width(layout)/=0  then
						if jso(layout)**".axis.vertical.inside" then
							vt_mask := unsigned(sgmntbox_x) srl font_bits;
							if vtaxis_tickrotate(layout)="ccw90" or vtaxis_tickrotate(layout)="ccw270" then
								vt_on <= setif(vt_mask=(vt_mask'range => '0')) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							else
								vt_on <= setif(vt_mask < 6) and sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
							end if;
						else
							vt_on <= sgmnt_boxon(box_id => vtaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						end if;
					else
						vt_on <= '0';
					end if;

					if hzaxis_height(layout)/=0  then
						hz_mask := unsigned(y) srl font_bits;
						if resolve(layout&".axis.horizontal.inside") then
							if true then -- scale at the bottom
								if unsigned(hz_mask)=to_unsigned(grid_height(layout)/axis_fontsize(layout)-1, hz_mask'length) then
									hz_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								else
									hz_on <= '0';
								end if;
							else -- scale at the top
								if unsigned(hz_mask)=0 then
									hz_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								else
									hz_on <= '0';
								end if;
							end if;
						else
							hz_on <= sgmnt_boxon(box_id => hzaxis_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
						end if;
					else
						hz_on <= '0';
					end if;

					grid_on <= sgmnt_boxon(box_id => grid_boxid,   x_div => xdiv, y_div => ydiv, layout => layout) and box_on;

					if textbox_width(layout)/=0  then
						if jso(layout)**".textbox.inside" then
							if 2**unsigned_num_bits(textbox_width(layout)-1)=textbox_width(layout) and (2**font_bits*(grid_width(layout)/2**font_bits)) mod textbox_width(layout)=0 then
								vt_mask := unsigned(sgmntbox_x) srl textwidth_bits;
								if unsigned(vt_mask)=to_unsigned(grid_width(layout)/textbox_width(layout)-1, vt_mask'length) then
									textbox_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								else
									textbox_on <= '0';
								end if;
								textbox_x <= sgmntbox_x;
								textbox_y <= sgmntbox_y;
							else
								vt_mask := unsigned(sgmntbox_x) srl font_bits;
								if vt_mask >= (grid_width(layout)-textbox_width(layout))/2**font_bits then
									textbox_on <= sgmnt_boxon(box_id => grid_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
								else
									textbox_on <= '0';
								end if;
								textbox_x <= std_logic_vector(unsigned(sgmntbox_x)-(grid_width(layout)-textbox_width(layout)));
								textbox_y <= sgmntbox_y;
							end if;
						else
							textbox_x  <= sgmntbox_x;
							textbox_y  <= sgmntbox_y;
							textbox_on <= sgmnt_boxon(box_id => text_boxid, x_div => xdiv, y_div => ydiv, layout => layout) and box_on;
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
			variable base : unsigned(0 to video_addr'length-1);
		begin
			if rising_edge(video_clk) then
				base := (others => '0');
				for i in 0 to jso(layout)**".num_of_segments"-1 loop
					if sgmntbox_sel(i)='1' then
						base := base or to_unsigned((grid_width(layout)-grid_width(layout) mod grid_unit(layout))*i, base'length);
					end if;
				end loop;
				sgmntbox_ena <= sgmntbox_sel;
									   
				video_addr <= std_logic_vector(base + resize(unsigned(x), video_addr'length));
				video_frm  <= grid_on;
				hz_segment <= std_logic_vector(base + resize(unsigned(hz_slider(axisx_backscale+hztick_bits-1 downto 0)), hz_segment'length));
													  
			end if;
		end process;

	end block;
end;
