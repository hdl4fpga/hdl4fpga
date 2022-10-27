library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrgain is
	generic (
		rgtr      : boolean := true);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		gain_ena  : out std_logic;
		gain_dv   : out std_logic;
		chan_id   : out std_logic_vector;
		gain_id   : out std_logic_vector);

end;

architecture def of scopeio_rgtrgain is

	signal ena     : std_logic;
	signal chanid : std_logic_vector(maxinputs_bits-1 downto 0);
	signal gainid : std_logic_vector(gain_id'range);

begin

	ena    <= setif(rgtr_id=rid_gain, rgtr_dv);
	chanid <= bitfield(rgtr_data, gainchanid_id, gain_bf);
	gainid <= bitfield(rgtr_data, gainid_id,     gain_bf);

	dv_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			gain_dv <= ena;
		end if;
	end process;
	gain_ena <= ena;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if ena='1' then
					chan_id <= std_logic_vector(resize(unsigned(chanid), chan_id'length));
					gain_id <= std_logic_vector(resize(unsigned(gainid), gain_id'length));
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		chan_id <= std_logic_vector(resize(unsigned(chanid), chan_id'length));
		gain_id <= std_logic_vector(resize(unsigned(gainid), gain_id'length));
	end generate;

end;
