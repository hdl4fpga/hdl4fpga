library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity scopeio_trigger is
	generic (
		inputs           : natural);
	port (
		input_clk        : in  std_logic;
		input_dv         : in  std_logic;
		input_data       : in  std_logic_vector;
		trigger_chanid   : in  std_logic_vector;
		trigger_slope    : in  std_logic;
		trigger_level    : in  std_logic_vector;
		trigger_shot     : out std_logic;
		output_dv        : out std_logic;
		output_data      : out std_logic_vector);

end;

architecture beh of scopeio_trigger is
begin

	shot_p : process (input_clk)
		variable sample : signed(input_data'length/inputs-1 downto 0);
		variable shot   : std_logic;
		variable ge     : std_logic;
		variable lt     : std_logic;
		variable edge   : std_logic;
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				shot   := (lt and ge and not edge) or (not lt and not ge and edge);
				lt     := not ge;
				ge     := setif(sample >= signed(trigger_level));
				edge   := not trigger_slope;
				sample := signed(multiplex(input_data, trigger_chanid, sample'length));
			end if;
			trigger_shot <= shot;
		end if;
	end process;
	output_dv <= input_dv;

	datalat_e : entity hdl4fpga.latency
	generic map (
		n => input_data'length,
		d => (1 to input_data'length => 4))
	port map (
		clk => input_clk,
		ena => input_dv,
		di  => input_data,
		do  => output_data);

end;
