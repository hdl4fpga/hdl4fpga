
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_ctlr is
	port (
		exit_req  : in  std_logic;
		exit_rdy  : out std_logic;
		next_req  : in  std_logic;
		next_rdy  : out std_logic;
		prev_req  : in  std_logic;
		prev_rdy  : out std_logic;
		enter_req : in  std_logic;
		enter_rdy : out std_logic;

		sio_clk   : in  std_logic;
		so_frm    : buffer std_logic;
		so_irdy   : buffer std_logic;
		so_trdy   : in  std_logic := '0';
		so_data   : buffer std_logic_vector);

end;

architecture def of scopeio_ctlr is
	signal rgtr_id          : std_logic_vector(8-1 downto 0);
	signal rgtr_dv          : std_logic;
	signal rgtr_revs        : std_logic_vector(0 to 4*8-1);
	signal rgtr_data        : std_logic_vector(rgtr_revs'reverse_range);

	signal	hz_scaleid      : std_logic_vector;
	signal	hz_offset       : std_logic_vector;
	signal	chan_id         : std_logic_vector;
	signal	vtscale_ena     : std_logic;
	signal	vt_scalecid     : std_logic_vector;
	signal	vt_scaleid      : std_logic_vector(4-1 downto 0);
	signal	vtoffset_ena    : std_logic;
	signal	vt_offsetcid    : std_logic_vector;
	signal	vt_offset       : std_logic_vector;

	signal	trigger_ena     : std_logic;
	signal	trigger_chanid  : std_logic_vector;
	signal	trigger_slope   : std_logic;
	signal	trigger_oneshot : std_logic;
	signal	trigger_freeze  : std_logic;
	signal	trigger_level   : std_logic_vector;
begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		sin_clk   => sio_clk,
		sin_frm   => so_frm,
		sin_irdy  => so_trdy,
		sin_data  => so_data,
		rgtr_id   => rgtr_id,
		rgtr_dv   => rgtr_dv,
		rgtr_data => rgtr_revs);
	rgtr_data <= reverse(rgtr_revs,8);

	state_e : entity hdl4fpga.scopeio_state
	port map (
		rgtr_clk        => rgtr_clk,
		rgtr_dv         => rgtr_dv,
		rgtr_id         => rgtr_id,
		rgtr_data       => rgtr_data,

		hz_scaleid      => hz_scaleid,
		hz_offset       => hz_offset,
		chan_id         => chan_id,
		vtscale_ena     => vtscale_ena,
		vt_scalecid     => vt_scalecid,
		vt_scaleid      => vt_scaleid,
		vtoffset_ena    => vtoffset_ena,
		vt_offsetcid    => vt_offsetcid,
		vt_offset       => vt_offset,
                  
		trigger_ena     => trigger_ena,
		trigger_chanid  => trigger_chanid,
		trigger_slope   => trigger_slope,
		trigger_oneshot => trigger_oneshot,
		trigger_freeze  => trigger_freeze,
		trigger_level   => trigger_level);

end;
