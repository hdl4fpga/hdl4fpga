library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_equalizer is
	port (
		input_clk       : in  std_logic;
		input_ena       : in  std_logic;
		input_data      : in  std_logic_vector;
		trigger_req     : in  std_logic;
		trigger_edge    : in  std_logic;
		trigger_channel : in  std_logic_vector;
		trigger_level   : in  std_logic_vector;
		capture_rdy     : in  std_logic;
		capture_req     : out std_logic;
		output_ena      : out std_logic
		output_data     : out std_logic_vector);
end;

architecture beh of scopeio_equalizer is
	signal trigger_on : std_logic;
	signal sample     : std_logic_vector(trigger_level'range);
begin

	sample <= word2byte(input_data, trigger_channel, trigger_level'length);
	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if trigger_req='1' then
				if capture_rdy='1' then
					trigger_on <= '0';
				elsif trigger_on='0' then
					trigger_on <= trigger_edge xnor setif(signed(sample) >= signed(trigger_level));
				end if;
			elsif capture_rdy='1' then
				trigger_on <= '0';
			end if;
		end if;
	end process;
	capture_req <= capture_rdy and trigger_on;

	input_lat_e : entity hdl4fpga.align 
	generic map (
		n => input_data'length,
		d => (input_data'range => 1)))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);

end;
