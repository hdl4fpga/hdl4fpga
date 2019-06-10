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

entity scopeio is
	generic (
		vlayout_id  : natural := 0;

		max_inputs  : natural := 64;
		inputs      : natural := 1;
		vt_gain     : natural_vector := (0 => 2**17, 1 => 2**16, 2 => 2**15, 3 => 2**14);
		vt_factsyms : std_logic_vector := (0 to 0 => '0');
		vt_untsyms  : std_logic_vector := (0 to 0 => '0');

		hz_gain     : natural_vector := (0 to 0 => 2**18);
		hz_factsyms : std_logic_vector := (0 to 0 => '0');
		hz_untsyms  : std_logic_vector := (0 to 0 => '0');

		max_pixelsize  : natural := 24;
		default_tracesfg : std_logic_vector := b"1_1_1";
		default_gridfg   : std_logic_vector := b"1_0_0";
		default_gridbg   : std_logic_vector := b"0_0_0";
		default_hzfg     : std_logic_vector := b"1_1_1";
		default_hzbg     : std_logic_vector := b"0_0_1";
		default_vtfg     : std_logic_vector := b"1_1_1";
		default_vtbg     : std_logic_vector := b"0_0_1";
		default_textbg   : std_logic_vector := b"0_0_0";
		default_sgmntbg  : std_logic_vector := b"0_1_1";
		default_bg       : std_logic_vector := b"1_1_1");
	port (
		si_clk      : in  std_logic := '-';
		si_frm      : in  std_logic := '0';
		si_irdy     : in  std_logic := '0';
		si_data     : in  std_logic_vector;
		so_clk      : in  std_logic := '-';
		so_frm      : out std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic := '0';
		so_data     : out std_logic_vector;

		input_clk   : in  std_logic;
		input_ena   : in  std_logic := '1';
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_pixel : out std_logic_vector;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);

	constant chanid_size  : natural := unsigned_num_bits(inputs-1);

end;

architecture beh of scopeio is

	subtype storage_word is std_logic_vector(0 to 9-1);

	constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);

	constant gainid_size : natural := unsigned_num_bits(vt_gain'length-1);

	signal video_hzsync       : std_logic;
	signal video_vtsync       : std_logic;
	signal video_vton         : std_logic;
	signal video_hzon         : std_logic;
	signal video_hzl          : std_logic;
	signal video_vld          : std_logic;
	signal video_vtcntr       : std_logic_vector(11-1 downto 0);
	signal video_hzcntr       : std_logic_vector(11-1 downto 0);

	signal video_io           : std_logic_vector(0 to 3-1);
	
	signal rgtr_id            : std_logic_vector(8-1 downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_data          : std_logic_vector(32-1 downto 0);

	signal ampsample_ena      : std_logic;
	signal ampsample_data     : std_logic_vector(0 to input_data'length-1);
	signal triggersample_ena  : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);
	signal resizedsample_ena  : std_logic;
	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_ena     : std_logic;
	signal downsample_data    : std_logic_vector(resizedsample_data'range);

	constant storage_size : natural := unsigned_num_bits(layout.num_of_segments*grid_width(layout)-1);
	signal storage_addr : std_logic_vector(0 to storage_size-1);
	signal storage_bsel   : std_logic_vector(0 to layout.num_of_segments-1);

	signal capture_addr   : std_logic_vector(storage_addr'range);
	signal trigger_addr   : std_logic_vector(storage_addr'range);
	signal trigger_shot   : std_logic;

	signal storage_data   : std_logic_vector(0 to inputs*storage_word'length-1);
	signal scope_color    : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_color    : std_logic_vector(video_pixel'length-1 downto 0);

	signal hz_segment     : std_logic_vector(13-1 downto 0);
	signal hz_scale       : std_logic_vector(4-1 downto 0);
	signal hz_dv          : std_logic;
	signal vt_dv          : std_logic;
	signal hz_offset      : std_logic_vector(6+9-1 downto 0);
	signal vt_offsets     : std_logic_vector(inputs*(5+8)-1 downto 0);
	signal vt_chanid      : std_logic_vector(chanid_size-1 downto 0);

	signal palette_dv     : std_logic;
	signal palette_id     : std_logic_vector(0 to unsigned_num_bits(max_inputs+9-1)-1);
	signal palette_color  : std_logic_vector(max_pixelsize-1 downto 0);

	signal gain_dv        : std_logic;
	signal gain_ids       : std_logic_vector(0 to inputs*gainid_size-1);

	signal trigger_dv     : std_logic;
	signal trigger_chanid : std_logic_vector(chanid_size-1 downto 0);
	signal trigger_edge   : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_level  : std_logic_vector(storage_word'range);

	signal pointer_dv     : std_logic;
	signal pointer_x      : std_logic_vector(video_hzcntr'range);
	signal pointer_y      : std_logic_vector(video_vtcntr'range);

	signal wu_frm         : std_logic;
	signal wu_irdy        : std_logic;
	signal wu_trdy        : std_logic;
	signal wu_unit        : std_logic_vector(4-1 downto 0);
	signal wu_neg         : std_logic;
	signal wu_sign        : std_logic;
	signal wu_align       : std_logic;
	signal wu_value       : std_logic_vector(4*4-1 downto 0);
	signal wu_format      : std_logic_vector(8*4-1 downto 0);

begin

	assert inputs < max_inputs
		report "inputs greater than max_inputs"
		severity failure;

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	port map (
		sin_clk   => si_clk,
		sin_frm   => si_frm,
		sin_irdy  => si_irdy,
		sin_data  => si_data,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data);

	scopeio_rtgr_e : entity hdl4fpga.scopeio_rgtr
	generic map (
		max_inputs     => max_inputs,
		inputs         => inputs)
	port map (
		clk            => si_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		hz_dv          => hz_dv,
		hz_scale       => hz_scale,
		hz_offset      => hz_offset,
		vt_dv          => vt_dv,
		vt_offsets     => vt_offsets,
		vt_chanid      => vt_chanid,
	
		pointer_dv     => pointer_dv,
		pointer_y      => pointer_y,
		pointer_x      => pointer_x,

		palette_dv     => palette_dv,
		palette_id     => palette_id,
		palette_color  => palette_color,

		gain_dv        => gain_dv,
		gain_ids       => gain_ids,

		trigger_dv     => trigger_dv,
		trigger_freeze => trigger_freeze,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge);
	
	amp_b : block
		constant sample_size : natural := input_data'length/inputs;
		signal output_ena    : std_logic_vector(0 to inputs-1);
	begin
		amp_g : for i in 0 to inputs-1 generate
			subtype sample_range is natural range i*sample_size to (i+1)*sample_size-1;

			function to_bitrom (
				value : natural_vector;
				size  : natural)
				return std_logic_vector is
				variable retval : unsigned(0 to value'length*size-1);
			begin
				for i in value'range loop
					retval(0 to size-1) := to_unsigned(value(i), size);
					retval := retval rol size;
				end loop;
				return std_logic_vector(retval);
			end;

			signal input_sample : std_logic_vector(0 to sample_size-1);
			signal gain_id      : std_logic_vector(gainid_size-1 downto 0);
			signal gain_value   : std_logic_vector(18-1 downto 0);
		begin

			gain_id <= word2byte(gain_ids, i, gainid_size);
			mult_e : entity hdl4fpga.rom 
			generic map (
				latency => 1,
				bitrom  => to_bitrom(vt_gain,18))
			port map (
				clk  => input_clk,
				addr => gain_id,
				data => gain_value);

			input_sample <= word2byte(input_data, i, sample_size);
			amp_e : entity hdl4fpga.scopeio_amp
			port map (
				input_clk     => input_clk,
				input_ena     => input_ena,
				input_sample  => input_sample,
				gain_value    => gain_value,
				output_ena    => output_ena(i),
				output_sample => ampsample_data(sample_range));

		end generate;

		ampsample_ena <= output_ena(0);
	end block;

	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	generic map (
		inputs => inputs)
	port map (
		input_clk      => input_clk,
		input_ena      => ampsample_ena,
		input_data     => ampsample_data,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge,
		trigger_shot   => trigger_shot,
		output_ena     => triggersample_ena,
		output_data    => triggersample_data);

	resize_p : process (triggersample_data)
		variable aux1 : unsigned(0 to storage_word'length*inputs-1);
		variable aux2 : unsigned(0 to triggersample_data'length-1);
	begin
		aux1 := (others => '-');
		aux2 := unsigned(triggersample_data);
		for i in 0 to inputs-1 loop
			aux1(storage_word'range) := aux2(storage_word'range);
			aux1 := aux1 rol storage_word'length;
			aux2 := aux2 rol triggersample_data'length/inputs;
		end loop;
		resizedsample_data <= std_logic_vector(aux1);
	end process;
	resizedsample_ena <= triggersample_ena;

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	port map (
		factor       => b"1111" , --hz_scale,
		input_clk    => input_clk,
		input_ena    => resizedsample_ena,
		input_data   => resizedsample_data,
		trigger_shot => trigger_shot,
		display_ena  => video_vton,
		output_ena   => downsample_ena,
		output_data  => downsample_data);

	storage_b : block

		signal wr_clk    : std_logic;
		signal wr_ena    : std_logic;
		signal wr_addr   : std_logic_vector(storage_addr'range);
		signal wr_cntr   : signed(0 to wr_addr'length+1);
		signal wr_data   : std_logic_vector(0 to storage_word'length*inputs-1);
		signal rd_clk    : std_logic;
		signal rd_addr   : std_logic_vector(wr_addr'range);
		signal rd_data   : std_logic_vector(wr_data'range);
		signal free_shot : std_logic;
		signal sync_tf   : std_logic;
		signal hz_delay  : signed(hz_offset'length-1 downto 0);

	begin

		wr_clk  <= input_clk;
		wr_ena  <= (not wr_cntr(0) or free_shot) and not sync_tf;
		wr_data <= downsample_data;

		process(wr_clk)
		begin
			if rising_edge(wr_clk) then
				sync_tf <= trigger_freeze;
			end if;
		end process;

		hz_delay <= signed(hz_offset);
		rd_clk   <= video_clk;
		gen_addr_p : process (wr_clk)
			variable sync_videofrm : std_logic;
		begin
			if rising_edge(wr_clk) then

--              ----------------
--				-- CALIBRATON --
--              ----------------
--
--				wr_data <= ('0','0', '0', '0', others => '1');
--				if wr_addr=std_logic_vector(to_unsigned(0,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1600,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				elsif wr_addr=std_logic_vector(to_unsigned(1601,wr_addr'length)) then
--					wr_data <= ('0', '0', '1', others => '0');
--				end if;
--				wr_data  <= std_logic_vector(resize(unsigned(wr_addr),wr_data'length));

				free_shot <= '0';
				if sync_videofrm='0' and trigger_shot='0' then
					free_shot <= '1';
				end if;

				if sync_tf='1' then
					capture_addr <= std_logic_vector(hz_delay(capture_addr'reverse_range) + signed(trigger_addr));
				elsif sync_videofrm='0' and trigger_shot='1' then
					capture_addr <= std_logic_vector(hz_delay(capture_addr'reverse_range) + signed(wr_addr));
					wr_cntr      <= resize(hz_delay, wr_cntr'length) +(2**wr_addr'length-1);
					trigger_addr <= wr_addr;
				elsif wr_cntr(0)='0' then
					if downsample_ena='1' then
						wr_cntr <= wr_cntr - 1;
					end if;
				end if;
				if downsample_ena='1' then
					wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
				end if;

				sync_videofrm := video_vton;
			end if;

		end process;


--		mem_e : entity hdl4fpga.bram(bram_true2p_2clk)    -- Tested for portabilty
		mem_e : entity hdl4fpga.bram(inference)           -- Faster and smaller. Less tested for portabilty
		port map (
			clka  => wr_clk,
			addra => wr_addr,
			wea   => wr_ena,
			dia   => wr_data,
			doa   => rd_data,

			clkb  => rd_clk,
			addrb => storage_addr,
			dib   => rd_data,
			dob   => storage_data);

	end block;

	video_b : block

		constant storageaddr_latency   : natural := 2;
		constant storagebram_latency   : natural := 2;
		constant segmment_latency      : natural := storage_data'length+2;
		constant mainpipeline_latency  : natural := 1;
		constant sgmntpipeline_latency : natural := 1;
		constant palette_latency       : natural := 4;
		constant vgaio_latency         : natural := storageaddr_latency+storagebram_latency+mainpipeline_latency+sgmntpipeline_latency+segmment_latency+palette_latency;

		signal trigger_dot : std_logic;
		signal traces_dots : std_logic_vector(0 to inputs-1);
		signal grid_dot    : std_logic;
		signal grid_bgon   : std_logic;
		signal hz_dot      : std_logic;
		signal hz_bgon     : std_logic;
		signal vt_dot      : std_logic;
		signal vt_bgon     : std_logic;
		signal text_bgon   : std_logic;
		signal sgmnt_on    : std_logic;
		signal sgmnt_bgon  : std_logic;
		signal pointer_dot : std_logic;
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

		graphics_b : block

			signal pbox_xdiv     : std_logic_vector(0 to 1-1);
			signal pbox_ydiv     : std_logic_vector(0 to unsigned_num_bits(layout.num_of_segments)-1);
			signal pbox_xedge    : std_logic;
			signal pbox_yedge    : std_logic;
			signal pbox_nexty    : std_logic;
			signal pbox_eox      : std_logic;
			signal pbox_xon      : std_logic;
			signal pbox_yon      : std_logic;

		begin

			box_layout_e : entity hdl4fpga.videobox_layout
			generic map (
				x_edges => main_xedges(layout),
				y_edges => main_yedges(layout))
			port map (
				video_clk  => video_clk,
				video_x    => video_hzcntr,
				video_y    => video_vtcntr,
				video_xon  => video_hzon,
				video_yon  => video_vton,
				box_xedge  => pbox_xedge,
				box_yedge  => pbox_yedge,
				box_xon    => pbox_xon,
				box_yon    => pbox_yon,
				box_eox    => pbox_eox,
				box_xdiv   => pbox_xdiv,
				box_nexty  => pbox_nexty,
				box_ydiv   => pbox_ydiv);

			storagebsel_p : process (pbox_xdiv, pbox_ydiv)
			begin
				sgmnt_on     <= '0';
				storage_bsel <= (others => '0');
				for i in 0 to layout.num_of_segments-1 loop
					if main_boxon(box_id => i, x_div => pbox_xdiv, y_div => pbox_ydiv, layout => layout)='1' then
						sgmnt_on        <= '1';
						storage_bsel(i) <= '1';
					end if;
				end loop;
			end process;

			sgmnt_b : block

				constant pboxx_size : natural := unsigned_num_bits(sgmnt_width(layout)-1);
				constant pboxy_size : natural := unsigned_num_bits(sgmnt_height(layout)-1);

				signal pbox_x       : std_logic_vector(pboxx_size-1 downto 0);
				signal pbox_y       : std_logic_vector(pboxy_size-1 downto 0);

				signal cbox_y       : std_logic_vector(pbox_y'range);
				signal cbox_x       : std_logic_vector(pbox_x'range);

				signal cbox_vyon    : std_logic;
				signal cbox_vxon    : std_logic;
				signal cbox_vx      : std_logic_vector(pboxx_size-1 downto 0);
				signal cbox_vy      : std_logic_vector(pboxy_size-1 downto 0);
				signal cbox_xedge   : std_logic;
				signal cbox_yedge   : std_logic;
				signal cbox_xdiv    : std_logic_vector(0 to 3-1);
				signal cbox_ydiv    : std_logic_vector(0 to 3-1);
				signal cbox_xon     : std_logic;
				signal cbox_yon     : std_logic;
				signal cbox_eox     : std_logic;

				signal grid_on      : std_logic;
				signal hz_on        : std_logic;
				signal vt_on        : std_logic;
				signal text_on      : std_logic;
				signal sgmnt_x      : std_logic_vector(cbox_x'range);
				signal sgmnt_y      : std_logic_vector(cbox_y'range);

				signal pbox_vxon    : std_logic;
				signal pbox_vyon    : std_logic;

			begin

				pbox_vxon <= sgmnt_on and pbox_xon;
				pbox_vyon <= pbox_yon;
				
				parent_e : entity hdl4fpga.videobox
				port map (
					video_clk => video_clk,
					video_xon => pbox_vxon,
					video_yon => pbox_vyon,
					video_eox => pbox_eox,
					box_xedge => pbox_xedge,
					box_yedge => pbox_yedge,
					box_x     => pbox_x,
					box_y     => pbox_y);

				mainpipeline_p : process (video_clk)
				begin
					if rising_edge(video_clk) then
						cbox_vxon <= pbox_vxon;
						cbox_vyon <= pbox_vyon and not pbox_nexty;
						cbox_vx   <= pbox_x;
						cbox_vy   <= pbox_y;
					end if;
				end process;

				layout_e : entity hdl4fpga.videobox_layout
				generic map (
					x_edges     => sgmnt_xedges(layout),
					y_edges     => sgmnt_yedges(layout))
				port map (
					video_clk   => video_clk,
					video_xon   => cbox_vxon,
					video_yon   => cbox_vyon,
					video_x     => cbox_vx,
					video_y     => cbox_vy,
					box_xon     => cbox_xon,
					box_yon     => cbox_yon,
					box_xedge   => cbox_xedge,
					box_yedge   => cbox_yedge,
					box_eox     => cbox_eox,
					box_xdiv    => cbox_xdiv,
					box_ydiv    => cbox_ydiv);


				box_e : entity hdl4fpga.videobox
				port map (
					video_clk => video_clk,
					video_xon => cbox_xon,
					video_yon => cbox_yon,
					video_eox => cbox_eox,
					box_xedge => cbox_xedge,
					box_yedge => cbox_yedge,
					box_x     => cbox_x,
					box_y     => cbox_y);

				sgmntpipeline_p: process (video_clk)
					variable sgmnt_on : std_logic;
				begin
					if rising_edge(video_clk) then
						sgmnt_on := cbox_xon and cbox_yon;
						vt_on   <= sgmnt_boxon(box_id => vtaxis_boxid, x_div => cbox_xdiv, y_div => cbox_ydiv, layout => layout) and sgmnt_on;
						hz_on   <= sgmnt_boxon(box_id => hzaxis_boxid, x_div => cbox_xdiv, y_div => cbox_ydiv, layout => layout) and sgmnt_on;
						grid_on <= sgmnt_boxon(box_id => grid_boxid,   x_div => cbox_xdiv, y_div => cbox_ydiv, layout => layout) and sgmnt_on;
						text_on <= sgmnt_boxon(box_id => text_boxid,   x_div => cbox_xdiv, y_div => cbox_ydiv, layout => layout) and sgmnt_on;
						sgmnt_x <= cbox_x;
						sgmnt_y <= cbox_y;
					end if;
				end process;

				storage_addr_p : process (video_clk)
					variable base     : unsigned(0 to storage_addr'length-1);
				begin
					if rising_edge(video_clk) then
						base     := (others => '0');
						for i in 0 to layout.num_of_segments-1 loop
							if storage_bsel(i)='1' then
								base := base or to_unsigned((grid_width(layout)-1)*i, base'length);
							end if;
						end loop;
						storage_addr <= std_logic_vector(base + unsigned(sgmnt_x) + unsigned(capture_addr));
						hz_segment   <= std_logic_vector(base + resize(unsigned(hz_offset(9-1 downto 0)), hz_segment'length));
					end if;
				end process;

				scopeio_segment_e : entity hdl4fpga.scopeio_segment
				generic map (
					latency       => segmment_latency,
					inputs        => inputs)
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
					hz_base       => hz_offset(5+9-1 downto 9),
					hz_offset     => hz_segment,

					gain_dv       => gain_dv,
					gain_ids      => gain_ids,
					vt_dv         => vt_dv,
					vt_chanid     => vt_chanid,
					vt_offsets    => vt_offsets,

					video_clk     => video_clk,
					x             => sgmnt_x,
					y             => sgmnt_y,

					hz_on         => hz_on,
					vt_on         => vt_on,
					grid_on       => grid_on,

					samples       => storage_data,
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
						0 to 4-1 => storageaddr_latency+storagebram_latency+segmment_latency,
						4        => storageaddr_latency+storagebram_latency+segmment_latency+mainpipeline_latency+sgmntpipeline_latency))
				port map (
					clk => video_clk,
					di(0) => grid_on,
					di(1) => hz_on,
					di(2) => vt_on,
					di(3) => text_on,
					di(4) => sgmnt_on,
					do(0) => grid_bgon,
					do(1) => hz_bgon,
					do(2) => vt_bgon,
					do(3) => text_bgon,
					do(4) => sgmnt_bgon);

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
			wr_clk         => si_clk,
			wr_dv          => palette_dv,
			wr_palette     => palette_id,
			wr_color       => palette_color,
			video_clk      => video_clk,
			traces_dots    => traces_dots, 
			trigger_dot    => trigger_dot,
			trigger_chanid => trigger_chanid,
			grid_dot       => grid_dot,
			grid_bgon      => grid_bgon,
			hz_dot         => hz_dot,
			hz_bgon        => hz_bgon,
			vt_dot         => vt_dot,
			vt_bgon        => vt_bgon,
			text_bgon      => text_bgon,
			sgmnt_bgon     => sgmnt_bgon,
			video_color    => scope_color);

		scopeio_pointer_e : entity hdl4fpga.scopeio_pointer
		generic map (
			latency => 0)
		port map (
			video_clk    => video_clk,
			video_on     => video_io(2),
			pointer_x    => pointer_x,
			pointer_y    => pointer_y,
			video_hzcntr => video_hzcntr,
			video_vtcntr => video_vtcntr,
			video_dot    => pointer_dot);

		video_color <= (video_color'range => '1') when pointer_dot='1' else scope_color; 
	end block;


	video_pixel <= (video_pixel'range => video_io(2)) and video_color;
	video_blank <= not video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
