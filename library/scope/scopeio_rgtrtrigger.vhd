library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrtrigger is
	generic (
		rgtr            : boolean := true);
	port (
		rgtr_clk        : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		trigger_ena     : out std_logic;
		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_oneshot : out std_logic;
		trigger_chanid  : buffer std_logic_vector;
		trigger_level   : buffer std_logic_vector;
		trigger_slope   : out std_logic);

end;

architecture def of scopeio_rgtrtrigger is

	signal dv      : std_logic;
	signal freeze  : std_logic_vector(0 to 0);
	signal slope   : std_logic_vector(0 to 0);
	signal oneshot : std_logic_vector(0 to 0);
	signal level   : std_logic_vector(trigger_level'range);
	signal chanid  : std_logic_vector(trigger_chanid'range);

begin

	dv      <= setif(rgtr_id=rid_trigger, rgtr_dv);
	freeze  <= bitfield(rgtr_data, trigger_freeze_id,  trigger_bf);
	slope   <= bitfield(rgtr_data, trigger_slope_id,   trigger_bf);
	oneshot <= bitfield(rgtr_data, trigger_oneshot_id, trigger_bf);
	level   <= std_logic_vector(resize(-signed(bitfield(rgtr_data, trigger_level_id, trigger_bf)), level'length));
	chanid  <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, trigger_chanid_id, trigger_bf)), chanid'length));

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			trigger_dv <= dv;
		end if;
	end process;

	rgtr_e : if rgtr generate
		process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if dv='1' then
					trigger_freeze  <= freeze(0);
					trigger_slope   <= slope(0);
					trigger_oneshot <= oneshot(0);
					trigger_level   <= level;
					trigger_chanid  <= chanid;
				end if;
			end if;
		end process;
	end generate;

	norgtr_e : if not rgtr generate
		trigger_freeze  <= freeze(0);
		trigger_slope   <= slope(0);
		trigger_slope   <= slope(0);
		trigger_level   <= level;
		trigger_chanid  <= chanid;
	end generate;

	trigger_ena <= dv;
end;
