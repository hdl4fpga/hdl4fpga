library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of scopeio_trigger_capture_storage is
	signal downsample_oshot   : std_logic;
	signal downsample_ishot   : std_logic;
	signal downsample_dv      : std_logic;
	signal downsample_data    : std_logic_vector(0 to 2*resizedsample_data'length-1);
	signal downsampling       : std_logic;

	signal capture_shot       : std_logic;
	signal capture_end        : std_logic;
begin
	triggers_modes_b : block
	begin
		capture_shot <= capture_end and downsample_oshot and not video_vton;
	end block;

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	generic map (
		inputs  => inputs,
		factors => hz_factors)
	port map (
		factor_id    => hz_scale,
--		factor_id    => b"0000",  --Debug purpose
		input_clk    => input_clk,
		input_dv     => resizedsample_dv,
		input_shot   => downsample_ishot,
		input_data   => resizedsample_data,
		downsampling => downsampling,
		output_dv    => downsample_dv,
		output_shot  => downsample_oshot,
		output_data  => downsample_data);

	downsample_ishot <= capture_end and trigger_shot;
	scopeio_capture_e : entity hdl4fpga.scopeio_capture
	port map (
		input_clk    => input_clk,
		capture_shot => capture_shot,
		capture_end  => capture_end,
		input_dv     => downsample_dv,
		input_data   => downsample_data,
		input_delay  => hz_slider,
--		input_delay  => b"00_0000_0000_0000",  --Debug purpose

		downsampling => downsampling,
		capture_clk  => video_clk,
		capture_addr => capture_addr,
		capture_data => capture_data,
		capture_av   => capture_av,
		capture_dv   => capture_dv);
end;
