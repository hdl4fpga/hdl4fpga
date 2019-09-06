library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrhzaxis is
	port (
		rgtr_clk        : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		hz_dv           : out std_logic;
		hz_scale        : out std_logic_vector;
		hz_slider       : out std_logic_vector);

end;

architecture def of scopeio_rgtrhzaxis is

begin

	hz_dv     <= setif(rgtr_id=rid_hzaxis, rgtr_dv);
	hz_slider <= std_logic_vector(resize(signed(bitfield(rgtr_data, hzoffset_id, hzoffset_bf)), hz_slider'length));
	hz_scale  <= bitfield(rgtr_data, hzscale_id,  hzoffset_bf);

end;
