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
		test : boolean := false;
		vlayout_id  : natural;
		max_delay   : natural := 2**14;
		axis_unit   : std_logic_vector := std_logic_vector(to_unsigned(25,5)); -- 25.0 each 128 samples

		inputs      : natural;
		vt_gains    : natural_vector := (
			 0 => 2**17/(2**(0+0)*5**(0+0)),  1 => 2**17/(2**(1+0)*5**(0+0)),  2 => 2**17/(2**(2+0)*5**(0+0)),  3 => 2**17/(2**(0+0)*5**(1+0)),
			 4 => 2**17/(2**(0+1)*5**(0+1)),  5 => 2**17/(2**(1+1)*5**(0+1)),  6 => 2**17/(2**(2+1)*5**(0+1)),  7 => 2**17/(2**(0+1)*5**(1+1)),
			 8 => 2**17/(2**(0+2)*5**(0+2)),  9 => 2**17/(2**(1+2)*5**(0+2)), 10 => 2**17/(2**(2+2)*5**(0+2)), 11 => 2**17/(2**(0+2)*5**(1+2)),
			12 => 2**17/(2**(0+3)*5**(0+3)), 13 => 2**17/(2**(1+3)*5**(0+3)), 14 => 2**17/(2**(2+3)*5**(0+3)), 15 => 2**17/(2**(0+3)*5**(1+3)));
		vt_factsyms : std_logic_vector := (0 to 0 => '0');
		vt_untsyms  : std_logic_vector := (0 to 0 => '0');

		hz_factors  : natural_vector := (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(1+0)*5**(0+0),  2 => 2**(2+0)*5**(0+0),  3 => 2**(0+0)*5**(1+0),
			 4 => 2**(0+1)*5**(0+1),  5 => 2**(1+1)*5**(0+1),  6 => 2**(2+1)*5**(0+1),  7 => 2**(0+1)*5**(1+1),
			 8 => 2**(0+2)*5**(0+2),  9 => 2**(1+2)*5**(0+2), 10 => 2**(2+2)*5**(0+2), 11 => 2**(0+2)*5**(1+2),
			12 => 2**(0+3)*5**(0+3), 13 => 2**(1+3)*5**(0+3), 14 => 2**(2+3)*5**(0+3), 15 => 2**(0+3)*5**(1+3));
		
		hz_factsyms      : std_logic_vector := (0 to 0 => '0');
		hz_untsyms       : std_logic_vector := (0 to 0 => '0');

		max_pixelsize    : natural := 24;
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
		si_clk           : in  std_logic := '-';
		si_frm           : in  std_logic := '0';
		si_irdy          : in  std_logic := '0';
		si_data          : in  std_logic_vector;
		so_clk           : in  std_logic := '-';
		so_frm           : out std_logic;
		so_irdy          : out std_logic;
		so_trdy          : in  std_logic := '0';
		so_data          : out std_logic_vector;

		input_clk        : in  std_logic;
		input_ena        : in  std_logic := '1';
		input_data       : in  std_logic_vector;
		video_clk        : in  std_logic;
		video_pixel      : out std_logic_vector;
		video_hsync      : out std_logic;
		video_vsync      : out std_logic;
		video_blank      : out std_logic;
		video_sync       : out std_logic);

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);

end;

architecture beh of scopeio is

	constant layout : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant gainid_size : natural := unsigned_num_bits(vt_gains'length-1);

	signal video_vld          : std_logic;

	signal rgtr_id            : std_logic_vector(8-1 downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_data          : std_logic_vector(32-1 downto 0);

	signal ampsample_dv      : std_logic;
	signal ampsample_data     : std_logic_vector(0 to input_data'length-1);
	signal triggersample_dv   : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);

	signal resizedsample_dv   : std_logic;
	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_dv      : std_logic;
	signal downsample_data    : std_logic_vector(resizedsample_data'range);

	constant capture_bits     : natural := unsigned_num_bits(layout.num_of_segments*grid_width(layout)-1);
	signal capture_addr       : std_logic_vector(0 to capture_bits-1);

	signal trigger_shot       : std_logic;
	signal downsample_shot    : std_logic;

	signal capture_shot       : std_logic;
	signal capture_end        : std_logic;
	signal capture_dv         : std_logic;
	signal capture_data       : std_logic_vector(0 to inputs*storage_word'length-1);
	signal scope_color        : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_color        : std_logic_vector(video_pixel'length-1 downto 0);
	signal video_vton         : std_logic;
	signal video_hzon         : std_logic;

	signal hz_offset          : std_logic_vector(hzoffset_bits-1 downto 0);

	signal hz_scale           : std_logic_vector(4-1 downto 0);
	signal hz_dv              : std_logic;
	signal vt_dv              : std_logic;
	signal vt_offsets         : std_logic_vector(inputs*(5+8)-1 downto 0);
	signal vt_chanid          : std_logic_vector(chanid_maxsize-1 downto 0);

	signal palette_dv         : std_logic;
	signal palette_id         : std_logic_vector(0 to unsigned_num_bits(max_inputs+9-1)-1);
	signal palette_color      : std_logic_vector(max_pixelsize-1 downto 0);

	signal gain_dv            : std_logic;
	signal gain_ids           : std_logic_vector(0 to inputs*gainid_size-1);

	signal trigger_dv         : std_logic;
	signal trigger_chanid     : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_edge       : std_logic;
	signal trigger_freeze     : std_logic;
	signal trigger_level      : std_logic_vector(storage_word'range);

	signal pointer_dv         : std_logic;
	signal pointer_x          : std_logic_vector(11-1 downto 0);
	signal pointer_y          : std_logic_vector(11-1 downto 0);

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

			signal input_sample : std_logic_vector(0 to sample_size-1);
			signal gain_id      : std_logic_vector(gainid_size-1 downto 0);
			signal gain_value   : std_logic_vector(18-1 downto 0);
		begin

			gain_id <= word2byte(gain_ids, i, gainid_size);
			input_sample <= word2byte(input_data, i, sample_size);
			amp_e : entity hdl4fpga.scopeio_amp
			generic map (
				gains => vt_gains)
			port map (
				input_clk     => input_clk,
				input_dv      => input_ena,
				input_sample  => input_sample,
				gain_id       => gain_id,
				output_dv     => output_ena(i),
				output_sample => ampsample_data(sample_range));

		end generate;

		ampsample_dv <= output_ena(0);
	end block;

	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	generic map (
		inputs => inputs)
	port map (
		input_clk      => input_clk,
		input_dv       => ampsample_dv,
		input_data     => ampsample_data,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge,
--		trigger_chanid => "0",             -- Debug purpose
--		trigger_level  => b"00_0010",      -- Debug purpose
--		trigger_edge   => '1',             -- Debug purpose
		trigger_shot   => trigger_shot,
		output_dv      => triggersample_dv,
		output_data    => triggersample_data);

	resizedsample_dv <= triggersample_dv;
	scopeio_resize_e : entity hdl4fpga.scopeio_resize
	generic map (
		inputs => inputs)
	port map (
		input_data  => triggersample_data,
		output_data => resizedsample_data);

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		factors => hz_factors)
	port map (
		factor_id    => hz_scale,
		input_clk    => input_clk,
		input_dv     => resizedsample_dv,
		input_shot   => trigger_shot,
		input_data   => resizedsample_data,
		output_dv    => downsample_dv,
		output_shot  => downsample_shot,
		output_data  => downsample_data);

	emard : if not test generate
	scopeio_capture1shot_b : block
		signal storage_reset_addr     : std_logic;
		signal storage_increment_addr : std_logic;
		signal storage_mark_t0        : std_logic;
		signal storage_write          : std_logic;
		signal storage_addr           : std_logic_vector(capture_addr'range);
	begin
	scopeio_capture1shot_e : entity hdl4fpga.scopeio_capture1shot
	generic map (
		deflicker              => true,
		strobe                 => 1 -- (more->slower) temporary freeze triggered wave for viewing
	)
	port map (
		input_clk              => input_clk,
		input_ena              => downsample_dv,

		video_vton             => video_vton,
		trigger_freeze         => trigger_freeze,
		trigger_shot           => trigger_shot,
		-- to storage module
		storage_reset_addr     => storage_reset_addr,
		storage_increment_addr => storage_increment_addr,
		storage_mark_t0        => storage_mark_t0,
		storage_write          => storage_write,
		-- from storage module
		storage_addr           => storage_addr
	);
	scopeio_storage_e : entity hdl4fpga.scopeio_storage
	generic map (
		align_to_grid          => 1 -- (-left,+right) shift triggered edge 1 pixel to the right
	)
	port map (
		storage_clk            => input_clk,

		-- from capture1shot module
		storage_reset_addr     => storage_reset_addr,
		storage_increment_addr => storage_increment_addr,
		storage_mark_t0        => storage_mark_t0,
		storage_write          => storage_write,
		-- to capture1shot module
		storage_addr           => storage_addr,

		-- from sample source
		storage_data           => downsample_data,

		-- from display
		captured_clk           => video_clk,
		captured_scroll        => hz_offset,
		captured_addr          => capture_addr,
		-- to display
		captured_data          => capture_data
	);
	end block;
	capture_dv <= '1';
	end generate;

	triggers_modes_b : block
	begin
		capture_shot <= downsample_shot and not video_vton;
--		capture_shot <= capture_end and downsample_shot;  --Debug purpose
	end block;

	xxx : if test generate
	scopeio_capture_e : entity hdl4fpga.scopeio_capture
	port map (
		input_clk      => input_clk,
		capture_shot   => capture_shot,
		capture_end    => capture_end,
		input_dv       => downsample_dv,
		input_data     => downsample_data,
		input_delay    => hz_offset,
--		input_delay    => b"00_0000_0000_0000",  --Debug purpose

		capture_clk    => video_clk,
		capture_addr   => capture_addr,
		capture_data   => capture_data,
		capture_dv     => capture_dv);
	end generate;

	scopeio_video_e : entity hdl4fpga.scopeio_video
	generic map (
		vlayout_id       => vlayout_id,
		inputs           => inputs,
		axis_unit        => axis_unit,
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
		si_clk           => si_clk,
		hz_dv            => hz_dv,
		hz_scale         => hz_scale,
		hz_offset        => hz_offset,
                                          
		vt_dv            => vt_dv,
		vt_offsets       => vt_offsets,
		vt_chanid        => vt_chanid,
                                          
		palette_dv       => palette_dv,
		palette_id       => palette_id,
		palette_color    => palette_color,
                                          
		gain_dv          => gain_dv,
		gain_ids         => gain_ids,

		trigger_chanid   => trigger_chanid,
		trigger_level    => trigger_level,

		capture_addr     => capture_addr,
		capture_data     => capture_data,
		capture_dv       => capture_dv,

		pointer_x        => pointer_x,
		pointer_y        => pointer_y,

		video_clk        => video_clk,
		video_pixel      => video_pixel,
		video_hsync      => video_hsync,
		video_vsync      => video_vsync,
		video_vton       => video_vton,
		video_hzon       => video_hzon,
		video_blank      => video_blank,
		video_sync       => video_sync);

end;
