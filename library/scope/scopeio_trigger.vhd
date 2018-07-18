library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trigger is
	generic (
		inputs        : natural);
	port (
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_data    : in  std_logic_vector;
		trigger_rgtr  : in  std_logic_vector;
		trigger_req   : in  std_logic;
		capture_rdy   : in  std_logic;
		capture_req   : out std_logic;
		output_ena    : out std_logic;
		output_data   : out std_logic_vector);
end;

architecture beh of scopeio_trigger is
	signal sample         : std_logic_vector(input_data'length/inputs-1 downto 0);
	signal trigger_on     : std_logic;

	constant level_rid   : natural := 0;
	constant edge_rid    : natural := 1;
	constant channel_rid : natural := 2;

	constant rgtr_map : natural_vector := (
		level_rid   => sample'length,
		edge_rid    => 1,
		channel_rid => unsigned_num_bits(inputs-1));

	signal trigger_edge    : std_logic;
	signal trigger_level   : std_logic_vector(sample'range);
	signal trigger_channel : std_logic_vector(rgtr_map(channel_rid)-1 downto 0);

begin


	trigger_level   <= slice_select(trigger_rgtr, rgtr_map, level_rid);
	trigger_edge    <= slice_select(trigger_rgtr, rgtr_map, edge_rid)(0);
	trigger_channel <= slice_select(trigger_rgtr, rgtr_map, channel_rid);

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
		d => (input_data'range => 1))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);

end;
