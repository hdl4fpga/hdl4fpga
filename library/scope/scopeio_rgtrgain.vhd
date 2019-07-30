library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrgain is
	generic (
		inputs          : in  natural);
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		gain_dv         : out std_logic;
		gain_ids        : out std_logic_vector);

end;

architecture def of scopeio_rgtrgain is

	signal gain_ena : std_logic;

begin

	gain_ena <= rgtr_dv when rgtr_id=rid_gain else '0';
	gain_p : process(clk) 
		constant gainid_size : natural := gain_ids'length/inputs;
		variable ids         : unsigned(0 to gain_ids'length-1); 
		variable chanid      : std_logic_vector(0 to chanid_maxsize-1);
	begin
		if rising_edge(clk) then
			if gain_ena='1' then
				chanid := bitfield(rgtr_data, gainchanid_id, gain_bf);
				for i in 0 to inputs-1 loop
					if to_unsigned(i, chanid_maxsize)=unsigned(chanid) then
						ids(0 to gainid_size-1) := resize(unsigned(bitfield(rgtr_data, gainid_id, gain_bf)), gainid_size);
					end if;
					ids := ids rol gainid_size;
				end loop;
			end if;
			gain_dv  <= gain_ena;
			gain_ids <= std_logic_vector(ids);
		end if;
	end process;

end;
