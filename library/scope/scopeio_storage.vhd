-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_storage is
	generic (
		inputs           : natural;
		time_factors     : natural_vector;
		storageword_size : natural);
	port (
		tp             : out std_logic_vector(1 to 32);
		input_clk      : in  std_logic;
		trigger_shot   : in  std_logic;
		input_dv       : in  std_logic;
		input_data     : in  std_logic_vector;
		time_scale     : in  std_logic_vector;
		time_offset    : in  std_logic_vector;
		trigger_mode   : in  std_logic_vector(0 to 2-1) := "00";
		capture_req    : buffer std_logic;
		capture_rdy    : buffer std_logic;

		video_clk      : in  std_logic;
		video_vton     : in  std_logic;
		video_frm      : in  std_logic;
		video_addr     : in  std_logic_vector;
		video_dv       : out std_logic;
		video_data     : out std_logic_vector);

	alias trigger_freeze  is trigger_mode(0);
	alias trigger_oneshot is trigger_mode(1);
end;

architecture mix of scopeio_storage is

	subtype storage_word is std_logic_vector(storageword_size-1 downto 0);
	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsampling       : std_logic;
	signal downsample_dv      : std_logic;
	signal downsample_data    : std_logic_vector(0 to 2*resizedsample_data'length-1);

begin

	scopeio_resize_e : entity hdl4fpga.scopeio_resize
	generic map (
		inputs => inputs)
	port map (
		input_data  => input_data,
		output_data => resizedsample_data);

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		inputs  => inputs,
		factors => time_factors)
	port map (
		factor_id    => time_scale,
		input_clk    => input_clk,
		input_dv     => input_dv,
		input_data   => resizedsample_data,
		trigger_shot => trigger_shot,
		downsampling => downsampling,
		capture_req  => capture_req,
		capture_rdy  => capture_rdy,
		output_dv    => downsample_dv,
		output_data  => downsample_data);

	scopeio_capture_e : entity hdl4fpga.scopeio_capture(delayfifo)
	port map (
		input_clk    => input_clk,
		trigger_shot => trigger_shot,
		trigger_mode => trigger_mode,
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





