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
		caputure_req   : out std_logic;
		caputure_rdy   : in  std_logic;
		output_ena     : out std_logic;
		output_data    : out std_logic_vector);
end;

architecture beh of scopeio_trigger is

	signal sample : std_logic_vector(input_data'length/inputs-1 downto 0);

begin

	sample = word2byte(input_data, trigger_chanid, sample'length);
	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if trigger_ena='1' then
				if caputure_req='0' then
					caputere_req <= trigger_edge xnor setif(signed(sample) >= signed(trigger_level));
				elsif caputure_rdy='1' then
					caputere_req <= '0';
				end if;
			else
				caputere_req <= '1';
			end if;
		end if;
	end process;

	input_lat_e : entity hdl4fpga.align 
	generic map (
		n => input_data'length,
		d => (input_data'range => 1))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);

end;
