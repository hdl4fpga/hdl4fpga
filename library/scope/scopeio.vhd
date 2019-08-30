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
		lang        : i18n_langs := lang_en;
		vlayout_id  : natural;
		max_delay   : natural := 2**14;
		hz_unit     : std_logic_vector := std_logic_vector(to_unsigned(25,5)); -- 25.0 each 128 samples
		vt_unit     : std_logic_vector := std_logic_vector(to_unsigned(25,5)); -- 25.0 each 128 samples
		min_storage : natural := 256; -- samples, storage size will be equal or larger than this
		trig1shot   : boolean := false;

		inputs      : natural;

		vt_gains    : natural_vector := (
			 0 => 2**17/(2**(0+0)*5**(0+0)),  1 => 2**17/(2**(1+0)*5**(0+0)),  2 => 2**17/(2**(2+0)*5**(0+0)),  3 => 2**17/(2**(0+0)*5**(1+0)),
			 4 => 2**17/(2**(0+1)*5**(0+1)),  5 => 2**17/(2**(1+1)*5**(0+1)),  6 => 2**17/(2**(2+1)*5**(0+1)),  7 => 2**17/(2**(0+1)*5**(1+1)),
			 8 => 2**17/(2**(0+2)*5**(0+2)),  9 => 2**17/(2**(1+2)*5**(0+2)), 10 => 2**17/(2**(2+2)*5**(0+2)), 11 => 2**17/(2**(0+2)*5**(1+2)),
			12 => 2**17/(2**(0+3)*5**(0+3)), 13 => 2**17/(2**(1+3)*5**(0+3)), 14 => 2**17/(2**(2+3)*5**(0+3)), 15 => 2**17/(2**(0+3)*5**(1+3)));

		hz_factors  : natural_vector := (
			 0 => 2**(0+0)*5**(0+0),  1 => 2**(1+0)*5**(0+0),  2 => 2**(2+0)*5**(0+0),  3 => 2**(0+0)*5**(1+0),
			 4 => 2**(0+1)*5**(0+1),  5 => 2**(1+1)*5**(0+1),  6 => 2**(2+1)*5**(0+1),  7 => 2**(0+1)*5**(1+1),
			 8 => 2**(0+2)*5**(0+2),  9 => 2**(1+2)*5**(0+2), 10 => 2**(2+2)*5**(0+2), 11 => 2**(0+2)*5**(1+2),
			12 => 2**(0+3)*5**(0+3), 13 => 2**(1+3)*5**(0+3), 14 => 2**(2+3)*5**(0+3), 15 => 2**(0+3)*5**(1+3));
		

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

	signal rgtr_id            : std_logic_vector(8-1 downto 0);
	signal rgtr_dv            : std_logic;
	signal rgtr_data          : std_logic_vector(32-1 downto 0);

	signal ampsample_dv       : std_logic;
	signal ampsample_data     : std_logic_vector(0 to input_data'length-1);

	constant capture_bits     : natural := unsigned_num_bits(max(layout.num_of_segments*grid_width(layout),min_storage)-1);

	signal video_addr         : std_logic_vector(0 to capture_bits-1);
	signal video_frm          : std_logic;
	signal video_dv           : std_logic;
	signal video_data         : std_logic_vector(0 to 2*inputs*storage_word'length-1);

	signal video_vton         : std_logic;

	signal time_offset        : std_logic_vector(hzoffset_bits-1 downto 0);
	signal time_scale         : std_logic_vector(4-1 downto 0);
	signal time_dv              : std_logic;

	signal trigger_chanid     : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_level      : std_logic_vector(storage_word'range);

	signal gain_dv            : std_logic;
	signal gain_ids           : std_logic_vector(0 to inputs*gainid_size-1);


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

	amp_b : block
		constant sample_size : natural := input_data'length/inputs;
		signal output_ena    : std_logic_vector(0 to inputs-1);
	begin

		scopeio_rgtrgain_e : entity hdl4fpga.scopeio_rgtrgain
		generic map (
			inputs  => inputs)
		port map (
			rgtr_clk  => si_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,

			gain_dv   => gain_dv,
			gain_ids  => gain_ids);
		
		amp_g : for i in 0 to inputs-1 generate
			subtype sample_range is natural range i*sample_size to (i+1)*sample_size-1;

			signal input_sample : std_logic_vector(0 to sample_size-1);
			signal gain_id      : std_logic_vector(gainid_size-1 downto 0);
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

	scopeio_tds_e : scopeio_tds
	generic map  (
		inputs       => inputs,
		storageword_size => storage_word'length,
		time_factors => hz_factors)
	port map (
		rgtr_clk     => si_clk,
		rgtr_dv      => rgtr_dv,
		rgtr_id      => rgtr_id,
		rgtr_data    => rgtr_data,

		input_clk    => input_clk,
		input_dv     => ampsample_dv,
		input_data   => ampsample_data,
		time_scale   => time_scale,
		time_offset  => time_offset,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,

		video_clk    => video_clk,
		video_addr   => video_addr,  
		video_vton   => video_vton,  
		video_frm    => video_frm,  
		video_dv     => video_dv,  
		video_data   => video_data);

	scopeio_video_e : entity hdl4fpga.scopeio_video
	generic map (
		lang           => lang,
		vlayout_id     => vlayout_id,
		inputs         => inputs,
		hz_unit        => hz_unit,
		vt_unit        => vt_unit,
		dflt_tracesfg  => default_tracesfg,
		dflt_gridfg    => default_gridfg,
		dflt_gridbg    => default_gridbg,
		dflt_hzfg      => default_hzfg,
		dflt_hzbg      => default_hzbg,
		dflt_vtfg      => default_vtfg,
		dflt_vtbg      => default_vtbg,
		dflt_textbg    => default_textbg,
		dflt_sgmntbg   => default_sgmntbg,
		dflt_bg        => default_bg)
	port map (
		rgtr_clk       => si_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		time_scale     => time_scale,
		time_offset    => time_offset,
                                        
		gain_dv        => gain_dv,
		gain_ids       => gain_ids,

		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,

		video_addr     => video_addr,
		video_frm      => video_frm,
		video_data     => video_data,
		video_dv       => video_dv,

		video_clk      => video_clk,
		video_pixel    => video_pixel,
		video_hsync    => video_hsync,
		video_vsync    => video_vsync,
		video_vton     => video_vton,
		video_hzon     => open,
		video_blank    => video_blank,
		video_sync     => video_sync);

end;
