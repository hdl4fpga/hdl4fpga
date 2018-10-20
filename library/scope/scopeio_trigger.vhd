library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trigger is
	generic (
		inputs         : natural);
	port (
		input_clk      : in  std_logic;
		input_ena      : in  std_logic;
		input_data     : in  std_logic_vector;
		trigger_ena    : in  std_logic;
		trigger_chanid : in  std_logic_vector;
		trigger_edge   : in  std_logic;
		trigger_level  : in  std_logic_vector;
		trigger_shot   : out std_logic);
end;

architecture beh of scopeio_trigger is

	signal sample : std_logic_vector(input_data'length/inputs-1 downto 0);

begin

	sample <= word2byte(input_data, trigger_chanid, sample'length);
	process (input_clk)
	begin
		if rising_edge(input_clk) then
			trigger_shot <= '0';
			if trigger_ena='1' then
				trigger_shot <= trigger_edge xnor setif(signed(sample) >= signed(trigger_level));
			end if;
		end if;
	end process;

end;
