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

entity scopeio_tds is
	generic (
		inputs           : natural;
		time_factors     : natural_vector;
		storageword_size : natural);
	port (
		rgtr_clk         : in  std_logic;
		rgtr_dv          : in  std_logic;
		rgtr_id          : in  std_logic_vector(8-1 downto 0);
		rgtr_data        : in  std_logic_vector;

		input_clk        : in  std_logic;
		input_dv         : in  std_logic;
		input_data       : in  std_logic_vector;
		time_scale       : in  std_logic_vector;
		time_offset      : in  std_logic_vector;
		trigger_chanid   : buffer std_logic_vector;
		trigger_level    : buffer std_logic_vector;
		trigger_freeze   : buffer std_logic;
		video_clk        : in  std_logic;
		video_vton       : in  std_logic;
		video_frm        : in  std_logic;
		video_addr       : in  std_logic_vector;
		video_dv         : out std_logic;
		video_data       : out std_logic_vector);

	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);

end;

architecture mix of scopeio_tds is

	subtype storage_word is std_logic_vector(storageword_size-1 downto 0);

	signal triggersample_dv   : std_logic;
	signal triggersample_data : std_logic_vector(input_data'range);
	signal trigger_shot       : std_logic;

	signal resizedsample_dv   : std_logic;
	signal resizedsample_data : std_logic_vector(0 to inputs*storage_word'length-1);
	signal downsample_oshot   : std_logic;
	signal downsample_ishot   : std_logic := '0';
	signal downsample_dv      : std_logic;
	signal downsampling       : std_logic;
	signal downsample_data    : std_logic_vector(0 to 2*resizedsample_data'length-1);

	signal capture_shot       : std_logic;
	signal capture_end        : std_logic;

	signal trigger_dv         : std_logic;
	signal trigger_edge       : std_logic;

	signal storage_reset_addr     : std_logic;
	signal storage_increment_addr : std_logic;
	signal storage_mark_t0        : std_logic;
	signal storage_write          : std_logic;
	signal storage_addr           : std_logic_vector(video_addr'range);
	signal trace_visible          : std_logic;
	
	signal video_frm_delay    : std_logic_vector(1 downto 0);
	signal video_frm_first    : std_logic;
	signal video_frm_regular  : std_logic;

begin

	scopeio_rtgrtrigger_e : entity hdl4fpga.scopeio_rgtrtrigger
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		trigger_dv     => trigger_dv,
		trigger_freeze => trigger_freeze,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge);
		
	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	generic map (
		inputs => inputs)
	port map (
		input_clk      => input_clk,
		input_dv       => input_dv,
		input_data     => input_data,
		trigger_chanid => trigger_chanid,
		trigger_level  => trigger_level,
		trigger_edge   => trigger_edge,
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
		inputs  => inputs,
		factors => time_factors)
	port map (
		factor_id    => time_scale,
		input_clk    => input_clk,
		input_dv     => resizedsample_dv,
		input_shot   => downsample_ishot,
		input_data   => resizedsample_data,
		downsampling => downsampling,
		output_dv    => downsample_dv,
		output_shot  => downsample_oshot,
		output_data  => downsample_data);

	--downsample_ishot <= capture_end and trigger_shot;
	scopeio_capture1shot_e : entity hdl4fpga.scopeio_capture1shot
	generic map (
		track_addr             => true,  -- improves deflickering
		persistence            => 1      -- 2**n frames persistence
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
		inputs                 => inputs,
		align_to_grid          => -1 -- (-left,+right) shift triggered edge n pixels
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

		-- special case for downsampling = 0
		-- 2 samples stored at the same address
		downsampling           => downsampling,

		-- from display
		captured_clk           => video_clk,
		captured_scroll        => time_offset,
		captured_addr          => video_addr,
		-- to display
		captured_visible       => trace_visible,
		captured_data          => video_data
	);
	-- video_frm should be delayed two cycles if we want it to control video_dv.
	-- scopeio_video waits two cycles till the very first moment it asks for the
	-- sample by sending video_frm. This gives BRAM enough cycles to send the
	-- samples along with a video_dv.
        -- to get rid of vertical line alias in downsampling=0 mode:
        -- downsampling=0 is a special case. I use the change in video_frm from 0 to 1
        -- to know that is the first sample and send the first sample twice. Then, I
        -- copy the sample into a register. The next sample is combination of the
        -- saved sample with the next one and I save that in the register.
        -- simplification of this is to not draw first sample if downsampling=0
        -- final downside: trace pixels at right side of the grid when viewsed timespan
        -- exceeds sampled data. It is not too annoying anymore....
	B_video_frm_delay: block
	  signal video_frm_shift : std_logic_vector(2 downto 0);
	begin
	  process(video_clk)
	  begin
	    if rising_edge(video_clk) then
	      video_frm_shift <= video_frm & video_frm_shift(video_frm_shift'high downto 1);
	    end if;
	  end process;
	  video_frm_first <= video_frm_shift(1) and not video_frm_shift(0);
	  video_frm_regular <= downsampling or not video_frm_first;
	  video_dv <= trace_visible and video_frm_shift(1) and video_frm_regular;
	end block;
end;
