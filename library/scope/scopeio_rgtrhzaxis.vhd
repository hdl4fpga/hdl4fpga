library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrhzaxis is
	generic (
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		hz_ena    : out std_logic;
		hz_dv     : out std_logic;
		hz_scale  : out std_logic_vector;
		hz_slider : out std_logic_vector);

end;

architecture def of scopeio_rgtrhzaxis is

	signal ena    : std_logic;
	signal slider : std_logic_vector(hz_slider'range);
	signal scale  : std_logic_vector(hz_scale'range);

begin

	ena     <= setif(rgtr_id=rid_hzaxis, rgtr_dv);
	slider <= std_logic_vector(resize(signed(bitfield(rgtr_data, hzoffset_id, hzoffset_bf)), hz_slider'length));
	scale  <= bitfield(rgtr_data, hzscale_id,  hzoffset_bf);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			hz_dv <= ena;
		end if;
	end process;
	hz_ena <= ena;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if ena='1' then
					hz_slider <= slider;
					hz_scale  <= scale;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		hz_slider <= slider;
		hz_scale  <= scale;
	end generate;

end;
