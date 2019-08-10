library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrvtaxis is
	generic (
		inputs          : in  natural);
	port (
		rgtr_clk        : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		vt_dv           : out std_logic;
		vt_chanid       : out std_logic_vector;
		vt_offsets      : out std_logic_vector);

end;

architecture def of scopeio_rgtrvtaxis is

	signal vtaxis_ena  : std_logic;

begin

	vtaxis_ena  <= rgtr_dv when rgtr_id=rid_vtaxis  else '0';
	vtaxis_p : process(rgtr_clk)
		constant offset_size : natural := vt_offsets'length/inputs;
		variable offsets     : unsigned(0 to vt_offsets'length-1); 
		variable chanid      : std_logic_vector(0 to chanid_maxsize-1);
	begin
		if rising_edge(rgtr_clk) then
			if vtaxis_ena='1' then
				chanid := bitfield(rgtr_data, vtchanid_id, vtoffset_bf);
				for i in 0 to inputs-1 loop
					if to_unsigned(i, chanid_maxsize)=unsigned(chanid) then
						offsets(0 to offset_size-1) := unsigned(bitfield(rgtr_data, vtoffset_id, vtoffset_bf));
					end if;
					offsets := offsets rol offset_size;
				end loop;
				vt_chanid  <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, vtchanid_id, vtoffset_bf)), vt_chanid'length));
				vt_offsets <= std_logic_vector(offsets);
			end if;
			vt_dv <= vtaxis_ena;
		end if;
	end process;
end;
