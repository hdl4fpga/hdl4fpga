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
use hdl4fpga.scopeiopkg.all;

entity scopeio_tds is
	generic (
		inputs           : natural;
		time_factors     : natural_vector;
		storageword_size : natural);
	port (
		tp             : out std_logic_vector(1 to 32);
		rgtr_clk       : in  std_logic;
		rgtr_dv        : in  std_logic;
		rgtr_id        : in  std_logic_vector(8-1 downto 0);
		rgtr_data      : in  std_logic_vector;

		input_clk      : in  std_logic;
		trigger_shot   : in  std_logic;
		input_dv       : in  std_logic;
		input_data     : in  std_logic_vector;
		time_scale     : in  std_logic_vector;
		time_offset    : in  std_logic_vector;
		trigger_freeze : buffer std_logic;

		video_clk      : in  std_logic;
		video_vton     : in  std_logic;
		video_frm      : in  std_logic;
		video_addr     : in  std_logic_vector;
		video_dv       : out std_logic;
		video_data     : out std_logic_vector);

	constant chanid_bits : natural := unsigned_num_bits(inputs-1);

end;

architecture mix of scopeio_tds is

	subtype storage_word is std_logic_vector(storageword_size-1 downto 0);

	signal triggersample_dv   : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);

	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_ishot   : std_logic;
	signal downsample_dv      : std_logic;
	signal downsampling       : std_logic;
	signal downsample_data    : std_logic_vector(0 to 2*resizedsample_data'length-1);

	signal capture_req        : std_logic;
	signal capture_rdy        : std_logic;

begin

	scopeio_resize_e : entity hdl4fpga.scopeio_resize
	generic map (
		inputs => inputs)
	port map (
		input_data  => input_data,
		output_data => resizedsample_data);

	tp(1) <= downsampling;
	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		inputs  => inputs,
		factors => time_factors)
	port map (
		factor_id    => x"6", --time_scale,  --Debug purpose
		input_clk    => input_clk,
		input_dv     => input_dv,
		input_data   => resizedsample_data,
		trigger_shot => trigger_shot,
		downsampling => downsampling,
		capture_req  => capture_req,
		capture_rdy  => capture_rdy,
		output_dv    => downsample_dv,
		output_data  => downsample_data);

	scopeio_capture_e : entity hdl4fpga.scopeio_capture
	port map (
		rgtr_clk     => rgtr_clk,
		input_clk    => input_clk,
		trigger_shot => trigger_shot,
		downsampling => downsampling,
		capture_req  => capture_req,
		capture_rdy  => capture_rdy,
		input_dv     => downsample_dv,
		input_data   => downsample_data,
		time_offset  => time_offset,

		video_clk    => video_clk,
		video_frm    => video_frm,
		video_vton   => video_vton,
		video_addr   => video_addr,
		video_dv     => video_dv,
		video_data   => video_data);

end;
