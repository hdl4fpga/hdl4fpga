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
use hdl4fpga.hdo.all;
use hdl4fpga.videopkg.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_video is
	generic (
		timing_id          : videotiming_ids;
		sample_length      : natural;
		inputs             : natural;
		waveform           : string);
	port (
		tp                 : out std_logic_vector(1 to 32);
		rgtr_clk           : in  std_logic;
		rgtr_dv            : in  std_logic;
		rgtr_id            : in  std_logic_vector(8-1 downto 0);
		rgtr_data          : in  std_logic_vector;

		time_scale         : buffer std_logic_vector;
		time_offset        : buffer std_logic_vector;


		video_addr         : out std_logic_vector;
		video_frm          : out std_logic;
		video_data         : in  std_logic_vector;
		video_dv           : in  std_logic;

		video_clk          : in  std_logic;
		video_pixel        : out std_logic_vector;
		extern_video       : in  std_logic := '0';
		extern_videohzsync : in std_logic := '-';
		extern_videovtsync : in std_logic := '-';
		extern_videoblankn : in std_logic := '-';
		video_hsync        : out std_logic;
		video_vsync        : out std_logic;

		video_vton         : buffer std_logic;
		video_hzon         : buffer std_logic;
		video_blank        : out std_logic;
		video_sync         : out std_logic);

	constant num_of_segments : natural := hdo(waveform)**".num_of_segments";
	constant axis_fontsize   : natural := hdo(waveform)**".axis.fontsize=8.";
	constant main_width      : natural := hdo(waveform)**".display.width";
	constant main_height     : natural := hdo(waveform)**".display.height";
	constant textbox_width   : natural := hdo(waveform)**".textbox.width";
	constant grid_height     : natural := hdo(waveform)**".grid.height";
	constant chanid_bits     : natural := unsigned_num_bits(inputs-1);
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

end;

architecture beh of scopeio_video is
	
	constant input_latency        : natural := 4;
	constant mainrgtrin_latency   : natural := 1;
	constant mainrgtrout_latency  : natural := 1;
	constant mainrgtrio_latency   : natural := mainrgtrin_latency+mainrgtrout_latency;
	constant sgmntrgtrin_latency  : natural := 1;
	constant sgmntrgtrout_latency : natural := 1;
	constant sgmntrgtrio_latency  : natural := sgmntrgtrout_latency+sgmntrgtrin_latency;
	constant segmment_latency     : natural := 5;
	constant palette_latency      : natural := 2;
	constant vgaio_latency        : natural := input_latency+mainrgtrio_latency+sgmntrgtrio_latency+segmment_latency+palette_latency;
	constant hztick_bits          : natural := unsigned_num_bits(8*axis_fontsize-1);

	signal video_hzsync  : std_logic;
	signal video_vtsync  : std_logic;
	signal video_vld     : std_logic;
	signal video_vtcntr  : std_logic_vector(11-1 downto 0);
	signal video_hzcntr  : std_logic_vector(11-1 downto 0);
	signal video_color   : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_io      : std_logic_vector(0 to 3-1);

	signal scope_color   : std_logic_vector(video_pixel'length-1 downto 0);

	signal hz_ena        : std_logic;
	signal hz_dv         : std_logic;
	signal hz_scale      : std_logic_vector(4-1 downto 0);
	signal hz_slider     : std_logic_vector(time_offset'range);
	signal hz_segment    : std_logic_vector(video_addr'range);
	constant max_delay : natural := 2**hz_slider'length;

	constant sgmnt_id : natural := 0;
	constant text_id  : natural := 1;

	constant mainwidth_bits  : natural  := unsigned_num_bits(main_width-1);
	constant mainheight_bits : natural := unsigned_num_bits(main_height-1);

	signal x              : std_logic_vector(mainwidth_bits-1  downto 0);
	signal y              : std_logic_vector(mainheight_bits-1 downto 0);
	signal textbox_x      : std_logic_vector(mainwidth_bits-1  downto 0);
	signal textbox_y      : std_logic_vector(mainheight_bits-1 downto 0);
	signal sgmntbox_on    : std_logic;
	signal grid_on        : std_logic;
	signal hz_on          : std_logic;
	signal vt_on          : std_logic;
	signal text_on        : std_logic;

	signal trigger_dot    : std_logic;
	signal trace_dots     : std_logic_vector(0 to inputs-1);
	signal grid_dot       : std_logic;
	signal grid_bgon      : std_logic;
	signal hz_dot         : std_logic;
	signal hz_bgon        : std_logic;
	signal vt_dot         : std_logic;
	signal vt_bgon        : std_logic;
	signal text_fgon      : std_logic;
	signal text_bgon      : std_logic;
	signal text_fg        : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+inputs+1-1)-1);
	signal text_bg        : std_logic_vector(text_fg'range);
	signal sgmntbox_bgon  : std_logic;
	signal sgmntbox_ena   : std_logic_vector(0 to num_of_segments-1);

	signal vt_rdy          : std_logic;
	signal vt_req          : std_logic;
	signal hz_rdy          : std_logic;
	signal hz_req          : std_logic;
	signal tgr_rdy         : std_logic;
	signal tgr_req         : std_logic;
	signal vt_scalecid     : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid      : std_logic_vector(4-1 downto 0);
	signal vt_offset       : std_logic_vector((5+8)-1 downto 0);
	signal vt_cid          : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_chanid  : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_freeze  : std_logic;
	signal trigger_slope   : std_logic;
	signal trigger_oneshot : std_logic;
	signal trigger_level   : std_logic_vector(0 to sample_length-1);
	signal code_frm        : std_logic;
	signal code_irdy       : std_logic;
	signal code_data       : std_logic_vector(0 to 8-1);
	signal wid             : std_logic_vector(0 to 6-1);
	signal hz_scaleid      : std_logic_vector(4-1 downto 0);
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	signal hz_offset       : std_logic_vector(hzoffset_bits-1 downto 0);
	signal video_trigger   : std_logic_vector(0 to storage_word'length-1);
	signal trigger_gain : std_logic_vector(0 to trigger_level'length);

begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		timing_id     => timing_id,
		width         => main_width,
		height        => main_height)
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
		waveform => waveform)
	port map (
		video_clk    => video_clk,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton,

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

	state_b : block
		constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
		constant grid_unit     : natural := hdo(waveform)**".grid.unit=32.";

		signal setup_rdy     : std_logic;
		signal setup_req     : std_logic;
		signal vtsetup_rdy   : std_logic;
		signal vtsetup_req   : std_logic;
		signal tgrsetup_rdy  : std_logic;
		signal tgrsetup_req  : std_logic;
		signal hzsetup_rdy   : std_logic;
		signal hzsetup_req   : std_logic;
		signal setup_cid     : std_logic_vector(chanid_bits-1 downto 0);

		signal vtscale_ena   : std_logic;
		signal vt_scalecid   : std_logic_vector(chanid_bits-1 downto 0);
		signal vt_scaleid    : std_logic_vector(4-1 downto 0);
		signal vt_cid        : std_logic_vector(chanid_bits-1 downto 0);
		signal vtoffset_ena  : std_logic;
		signal vt_offsetcid  : std_logic_vector(vt_cid'range);

		signal trigger_ena   : std_logic;
		signal trigger_freeze: std_logic;
		signal trigger_level : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);
		signal trigger_upd   : std_logic;

		signal vts_chanid    : std_logic_vector(vt_cid'range);
		signal vt_chanid     : std_logic_vector(vt_cid'range);

	begin

		state_e : entity hdl4fpga.scopeio_state
		port map (
			rgtr_clk        => rgtr_clk,
			rgtr_dv         => rgtr_dv,
			rgtr_id         => rgtr_id,
			rgtr_data       => rgtr_data,

			hz_ena          => hz_ena,
			hz_scaleid      => hz_scaleid,
			hz_offset       => hz_offset,
			chan_id         => vt_cid,
			vtscale_ena     => vtscale_ena,
			vt_scalecid     => vt_scalecid,
			vt_scaleid      => vt_scaleid,
			vtoffset_ena    => vtoffset_ena,
			vt_offsetcid    => vt_offsetcid,
			vt_offset       => vt_offset,
					  
			trigger_ena     => trigger_ena,
			trigger_chanid  => trigger_chanid,
			trigger_slope   => trigger_slope,
			trigger_oneshot => trigger_oneshot,
			trigger_freeze  => trigger_freeze,
			trigger_level   => trigger_level);

		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if hz_ena='1' then
					if trigger_freeze='0' then
						time_scale <= hz_scaleid;
					end if;
					time_offset <= hz_offset;
				end if;
			end if;
		end process;

		videotrigger_b : block
			constant vt          : string := hdo(waveform)**".vt";
			constant vt_unit     : real := hdo(waveform)**".axis.vertical.unit";
			constant vt_gains    : natural_vector := to_naturalvector(hdo(waveform)**compact(".axis.vertical.gains=" & dlft_vtscale));
			constant gainid_bits : natural := unsigned_num_bits(vt_gains'length-1);
			constant xxx         : natural := (2**(trigger_level'length-1));

			function input_gains
				return natural_vector is
				variable retval : natural_vector(0 to inputs-1);
			begin
				for i in retval'range loop
					retval(i) := natural(real(xxx*grid_unit)*real'(hdo(vt)**("["&natural'image(i)&"].step"))/vt_unit);
				end loop;
				return retval;
			end;

			signal anlg_req     : std_logic := '1';
			signal anlg_rdy     : std_logic := '0';
			signal analog_gain  : std_logic_vector(0 to trigger_level'length-1);

			signal digi_req     : std_logic := '1';
			signal digi_rdy     : std_logic := '0';
			signal digi_gain    : std_logic_vector(0 to 18-1);
			signal trigger_amp  : std_logic_vector(0 to trigger_level'length);

		begin

			process(rgtr_clk)
				type states is (s_rdy, s_anlg, s_digi);
				variable state : states;
			begin
				if rising_edge(rgtr_clk) then
					case state is
					when s_rdy =>
						if (anlg_req xor anlg_rdy)='0' then
							if (digi_req xor digi_rdy)='0' then
								if trigger_ena='1' then
									anlg_req <= not anlg_rdy;
									state := s_anlg;
								elsif (vt_rdy xor vt_req)='1' then
									anlg_req <= not anlg_rdy;
									state := s_anlg;
								end if;
							end if;
						end if;
						trigger_upd <= '0';
					when s_anlg =>
						if (anlg_req xor anlg_rdy)='0' then
							digi_req <= not digi_rdy;
							state := s_digi;
						end if;
						trigger_upd <= '0';
					when s_digi =>
						if (digi_req xor digi_rdy)='0' then
							trigger_upd <= '1';
							state := s_rdy;
						end if;
					end case;
				end if;
			end process;

			analog_gain <= std_logic_vector(to_unsigned(input_gains(to_integer(unsigned(trigger_chanid))), trigger_level'length));
			analoggain_e : entity hdl4fpga.mul_ser
			port map (
				comp => '1',
				clk  => rgtr_clk,
				req  => anlg_req,
				rdy  => anlg_rdy,
				a    => trigger_level,
				b    => analog_gain,
				s    => trigger_gain);

			digi_gain <= std_logic_vector(to_unsigned(vt_gains(to_integer(unsigned(vt_scaleid))), digi_gain'length));
			digitalgain_e : entity hdl4fpga.mul_ser
			port map (
				comp => '1',
				clk  => rgtr_clk,
				req  => digi_req,
				rdy  => digi_rdy,
				a    => trigger_gain(1 to trigger_level'length),
				b    => digi_gain,
				s    => trigger_amp);

			resize_e : entity hdl4fpga.scopeio_resize
			generic map (
				inputs => 1)
			port map (
				input_data => trigger_amp(1 to trigger_amp'right),
				output_data => video_trigger);
			-- tp(1 to 8) <= video_trigger(0 to 8-1);
			
		end block;

		process (rgtr_clk)
			type states is (s_idle, s_vtsetup, s_tgrsetup, s_hzsetup);
			variable state : states;
		begin
			if rising_edge(rgtr_clk) then
				case state is
				when s_idle =>
					if (setup_rdy xor setup_req)='1' then
						setup_cid <= std_logic_vector(to_unsigned(inputs-1, setup_cid'length));
						vtsetup_req <= not vtsetup_rdy;
						state := s_vtsetup;
					end if;
				when s_vtsetup =>
					if (vtsetup_req xor vtsetup_rdy)='0' then
						if unsigned(setup_cid )> 0 then
							setup_cid <= std_logic_vector(unsigned(setup_cid)-1) ;
							vtsetup_req <= not vtsetup_rdy;
						else
							tgrsetup_req <= not tgrsetup_rdy;
							state := s_tgrsetup;
						end if;
					end if;
				when s_tgrsetup =>
					if (tgrsetup_req xor tgrsetup_rdy)='0' then
						hzsetup_req <= not hzsetup_rdy;
						state := s_hzsetup;
					end if;
				when s_hzsetup =>
					if (hzsetup_req xor hzsetup_rdy)='0' then
						setup_rdy <= setup_req;
						state := s_idle;
					end if;
				end case;
			end if;
		end process;

		process (rgtr_clk)
			type states is (s_rdy, s_vtreq, s_tgrreq);
			variable state : states;
		begin
			if rising_edge(rgtr_clk) then
				case state is
				when s_rdy =>
					if vtscale_ena='1' then
						vt_cid <= vt_scalecid;
						vt_req <= not vt_rdy;
						state := s_vtreq;
					elsif vtoffset_ena='1' then
						vt_cid <= vt_offsetcid;
						vt_req <= not vt_rdy;
						state := s_vtreq;
					elsif trigger_upd='1' then
						tgr_req <= not tgr_rdy;
						vt_cid <= trigger_chanid;
						state := s_tgrreq;
					elsif (vtsetup_rdy xor vtsetup_req)='1' then
						vt_cid <= setup_cid;
						vt_req <= not vt_rdy;
						state := s_vtreq;
					elsif (tgrsetup_rdy xor tgrsetup_req)='1' then
						vt_cid <= trigger_chanid;
						tgr_req <= not tgr_rdy;
						state := s_tgrreq;
					else
						-- vt_cid <= trigger_chanid;
					end if;
				when s_vtreq =>
					if (vt_req xor vt_rdy)='0' then
						tgr_req <= not tgr_rdy;
						state := s_tgrreq;
					end if;
				when s_tgrreq =>
					if (tgr_req xor tgr_rdy)='0' then
						state := s_rdy;
					end if;
				end case;
			end if;
		end process;

		process (rgtr_clk)
			type states is (s_rdy, s_req);
			variable state : states;
		begin
			if rising_edge(rgtr_clk) then
				if (hz_req xor hz_rdy)='0' then
					if hz_ena='1' then
						hz_req <= not hz_rdy;
					end if;
				end if;
			end if;
		end process;

	end block;

	textbox_g : if textbox_width/=0 generate
		signal wid : std_logic_vector(0 to 6-1);
	begin

		readings_e : entity hdl4fpga.scopeio_reading
		generic map (
			inputs          => inputs,
			waveform        => waveform)
		port map (
			-- tp => tp,
			clk             => rgtr_clk,
			vt_req          => vt_req,
			vt_rdy          => vt_rdy,
			hz_req          => hz_req,
			hz_rdy          => hz_rdy,
			hz_scaleid      => hz_scaleid,
			hz_offset       => hz_offset,
			vt_cid          => vt_cid,
			vt_scaleid      => vt_scaleid,
	  
			vt_offset       => vt_offset,
	  
			trigger_req     => tgr_req,
			trigger_rdy     => tgr_rdy,
			trigger_chanid  => trigger_chanid,
			trigger_freeze  => trigger_freeze,
			trigger_slope   => trigger_slope,
			trigger_oneshot => trigger_oneshot,
			trigger_level   => trigger_gain(0 to 8),

			wid             => wid,
			code_frm        => code_frm,
			code_irdy       => code_irdy,
			code_data       => code_data);

		scopeio_texbox_e : entity hdl4fpga.scopeio_textbox
		generic map (
			latency       => segmment_latency+input_latency,
			inputs        => inputs,
			waveform      => waveform)
		port map (
			tp => tp,
			rgtr_clk      => rgtr_clk,
			rgtr_dv       => rgtr_dv,
			rgtr_id       => rgtr_id,
			rgtr_data     => rgtr_data,

			wdt_id        => wid,
			code_frm      => code_frm,
			code_irdy     => code_irdy,
			code_data     => code_data,
			video_clk     => video_clk,
			video_hcntr   => textbox_x,
			video_vcntr   => textbox_y,
			video_vton    => video_vton,
			sgmntbox_ena  => sgmntbox_ena,
			text_fg       => text_fg,
			text_bg       => text_bg,
			text_on       => text_on,
			text_fgon     => text_fgon);
	end generate;

	scopeio_segment_e : entity hdl4fpga.scopeio_segment
	generic map (
		input_latency => input_latency,
		latency       => segmment_latency+input_latency,
		inputs        => inputs,
		waveform      => waveform)
	port map (
		rgtr_clk      => rgtr_clk,
		rgtr_dv       => rgtr_dv,
		rgtr_id       => rgtr_id,
		rgtr_data     => rgtr_data,

		hz_offset     => time_offset,
		hz_segment    => hz_segment,

		video_clk     => video_clk,
		x             => x,
		y             => y,

		hz_on         => hz_on,
		vt_on         => vt_on,
		grid_on       => grid_on,

		sample_dv     => video_dv,
		sample_data   => video_data,
		trigger_chanid => trigger_chanid,
		trigger_level => video_trigger,
		grid_dot      => grid_dot,
		hz_dot        => hz_dot,
		vt_dot        => vt_dot,
		trigger_dot   => trigger_dot,
		trace_dots    => trace_dots);
-- 
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
		inputs         => inputs,
		waveform       => waveform)
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

	video_color <= scope_color;
	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
