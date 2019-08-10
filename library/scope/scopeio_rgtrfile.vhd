library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrfile is
	generic (
		inputs          : in  natural);
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		hz_dv           : out std_logic;
		hz_scale        : out std_logic_vector;
		hz_slider       : out std_logic_vector;
		vt_dv           : out std_logic;
		vt_chanid       : out std_logic_vector;
		vt_offsets      : out std_logic_vector;

		palette_dv      : out std_logic;
		palette_id      : out std_logic_vector;
		palette_color   : out std_logic_vector;
	
		pointer_dv      : out std_logic;
		pointer_x       : out std_logic_vector;
		pointer_y       : out std_logic_vector);

end;

architecture def of scopeio_rgtrfile is

begin

	vtaxis_e : entity hdl4fpga.scopeio_rgtrvtaxis
	generic map (
		inputs  => inputs)
	port map (
		clk        => clk,
		rgtr_dv    => rgtr_dv,
		rgtr_id    => rgtr_id,
		rgtr_data  => rgtr_data,

		vt_dv      => vt_dv,
		vt_chanid  => vt_chanid,
		vt_offsets => vt_offsets);

	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	port map (
		clk       => clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_dv     => hz_dv,
		hz_scale  => hz_scale,
		hz_slider => hz_slider);
		
	palette_e : entity hdl4fpga.scopeio_rgtrpalette
	port map (
		clk           => clk,
		rgtr_dv       => rgtr_dv,
		rgtr_id       => rgtr_id,
		rgtr_data     => rgtr_data,

		palette_dv    => palette_dv,
		palette_id    => palette_id,
		palette_color => palette_color);
		
end;
