library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrgain is
	generic (
		inputs    : in  natural);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		gain_dv   : out std_logic;
		chan_id   : out std_logic_vector;
		gain_id   : out std_logic_vector);

end;

architecture def of scopeio_rgtrgain is

begin

	gain_dv <= setif(rgtr_id=rid_gain, rgtr_dv);
	chan_id <= bitfield(rgtr_data, gainchanid_id, gain_bf);
	gain_id <= bitfield(rgtr_data, gainid_id,     gain_bf);

end;
