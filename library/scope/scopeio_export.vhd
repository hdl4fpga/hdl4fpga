library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_export is
	generic (
		inputs          : in  natural);
	port (
		si_clk          : in  std_logic;
		si_frm          : in  std_logic := '0';
		si_irdy         : in  std_logic := '0';
		si_data         : in  std_logic_vector;

		hz_dv           : out std_logic;
		hz_scale        : out std_logic_vector;
		hz_slider       : out std_logic_vector;
		vt_dv           : out std_logic;
		vt_chanid       : out std_logic_vector;
		vt_offsets      : out std_logic_vector;

		palette_dv      : out std_logic;
		palette_id      : out std_logic_vector;
		palette_color   : out std_logic_vector;
	
		gain_dv         : out std_logic;
		gain_ids        : out std_logic_vector;

		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_chanid  : out std_logic_vector;
		trigger_level   : out std_logic_vector;
		trigger_edge    : out std_logic;

		pointer_dv      : out std_logic;
		pointer_x       : out std_logic_vector;
		pointer_y       : out std_logic_vector);

end;

architecture def of scopeio_export is

	signal rgtr_id   : std_logic_vector(8-1 downto 0);
	signal rgtr_dv   : std_logic;
	signal rgtr_data : std_logic_vector(32-1 downto 0);

begin

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
		hz_slider      => hz_slider,
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


end;
