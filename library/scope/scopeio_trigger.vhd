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

	constant outdata_samplesize : natural := output_data'length/inputs;
	signal sample : std_logic_vector(input_data'length/inputs-1 downto 0);

	signal resized_inputdata : std_logic_vector(output_data'length-1 downto 0);
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

	process(input_data)
		variable out_data : unsigned(output_data'length-1 downto 0);
		variable in_data  : unsigned(input_data'length-1 downto 0);
	begin 
		in_data := unsigned(input_data);
		for i in 0 to inputs-1 loop
			out_data(outdata_samplesize-1 downto 0) := in_data(sample'length-1 downto sample'length-outdata_samplesize);
			out_data := out_data rol outdata_samplesize;
			in_data  := in_data  rol sample'length;
		end loop;
		resized_inputdata <= std_logic_vector(out_data);
	end process;

	datalat_e : entity hdl4fpga.align
	generic map (
		n => resized_inputdata'length,
		d => (1 to resized_inputdata'length => 2))
	port map (
		clk => input_clk,
		di  => resized_inputdata,
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
