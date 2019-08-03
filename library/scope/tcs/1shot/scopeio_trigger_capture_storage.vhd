library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of scopeio_trigger_capture_storage is
  signal downsample_dv          : std_logic;
  signal downsample_data        : std_logic_vector(0 to 2*resizedsample_data'length-1);
  signal downsampling           : std_logic;
  signal storage_reset_addr     : std_logic;
  signal storage_increment_addr : std_logic;
  signal storage_mark_t0        : std_logic;
  signal storage_write          : std_logic;
  signal storage_addr           : std_logic_vector(capture_addr'range);
begin
  downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		inputs  => inputs,
		factors => hz_factors)
	port map (
		factor_id    => hz_scale,
		input_clk    => input_clk,
		input_dv     => resizedsample_dv,
		input_shot   => '0', -- for deflickering "downsample_dv" must be independent from trigger level
		input_data   => resizedsample_data,
		downsampling => downsampling,
		output_dv    => downsample_dv,
		output_shot  => open,
		output_data  => downsample_data);

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
		align_to_grid          => 0 -- (-left,+right) shift triggered edge n pixels
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
		captured_scroll        => hz_slider,
		captured_addr          => capture_addr,
		-- to display
		captured_data          => capture_data
	);

  capture_dv <= capture_av; -- to prevent traces drawn over the vtscale
end;
