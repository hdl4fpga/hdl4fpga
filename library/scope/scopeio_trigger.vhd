library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trigger is
	port (
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_data    : in  std_logic_vector;
		trigger_req   : in  std_logic;
		trigger_edge  : in  std_logic;
		trigger_level : in  std_logic_vector;
		capture_rdy   : in  std_logic;
		capture_req   : out std_logic;
		output_ena    : out std_logic;
		output_data   : out std_logic_vector);
end;

architecture beh of scopeio_trigger is
	signal trigger_on : std_logic;
begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if trigger_req='1' then
				if capture_rdy='1' then
					trigger_on <= '0';
				elsif trigger_on='0' then
					trigger_on <= trigger_edge xnor setif(signed(input_data) >= signed(trigger_level));
				end if;
			elsif capture_rdy='1' then
				trigger_on <= '0';
			end if;
		end if;
	end process;
	capture_req <= capture_rdy and trigger_on;

end;
