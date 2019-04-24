library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_trigger is
	generic (
		inputs           : natural);
	port (
		input_clk        : in  std_logic;
		input_ena        : in  std_logic;
		input_data       : in  std_logic_vector;
		trigger_chanid   : in  std_logic_vector;
		trigger_edge     : in  std_logic;
		trigger_level    : in  std_logic_vector;
		trigger_shot     : out std_logic;
		output_ena       : out std_logic;
		output_data      : out std_logic_vector);

end;

architecture beh of scopeio_trigger is

	signal sample : std_logic_vector(input_data'length/inputs-1 downto 0);

begin

	sample <= word2byte(input_data, trigger_chanid, sample'length);
	process (input_clk)
		variable ge : std_logic;
		variable lt : std_logic;
		variable sy : std_logic;
	begin
		if rising_edge(input_clk) then
			trigger_shot <= (lt and ge and not sy) or (not lt and not ge and sy);
			lt := not ge;
			ge := setif(signed(sample) >= signed(trigger_level));
			sy := not trigger_edge;
		end if;
	end process;

	datalat_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (1 to input_data'length => 2))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);

	enalat_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => 2))
	port map (
		clk => input_clk,
		di(0) => input_ena,
		do(0) => output_ena);
end;
