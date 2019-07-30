library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrtrigger is
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_chanid  : out std_logic_vector;
		trigger_level   : out std_logic_vector;
		trigger_edge    : out std_logic);

end;

architecture def of scopeio_rgtrtrigger is

	signal trigger_ena : std_logic;

begin

	trigger_ena <= rgtr_dv when rgtr_id=rid_trigger else '0';
	trigger_p : process(clk)
		variable level : signed(trigger_level'range);
	begin
		if rising_edge(clk) then
			level := resize(-signed(bitfield(rgtr_data, trigger_level_id, trigger_bf)), level'length);
			if trigger_ena='1' then
				trigger_freeze <= bitfield(rgtr_data, trigger_ena_id,  trigger_bf)(0);
				trigger_edge   <= bitfield(rgtr_data, trigger_edge_id, trigger_bf)(0);
				trigger_level  <= std_logic_vector(level);
				trigger_chanid <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, trigger_chanid_id, trigger_bf)), trigger_chanid'length));
			end if;
			trigger_dv <= trigger_ena;
		end if;
	end process;

end;
