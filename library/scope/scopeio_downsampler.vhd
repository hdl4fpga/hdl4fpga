library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_downsampler is
	port (
		factor        : in  std_logic_vector;
		input_clk     : in  std_logic;
		input_ena     : in  std_logic;
		input_data    : in  std_logic_vector;
		trigger_shot  : in std_logic;
		display_ena   : in  std_logic;
		output_ena    : out std_logic;
		output_data   : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is
	signal cntr : signed(factor'range);
begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if display_ena='0' and trigger_shot='1' then
				output_ena <= '1';
				cntr       <= signed(factor);
			else
				if input_ena='1' then
					if cntr(cntr'left)='1' then
						cntr <= signed(factor);
					else
						cntr <= cntr - 1;
					end if;
					output_ena <= cntr(cntr'left);
				else
					output_ena <= '0';
				end if;
			end if;
		end if;
	end process;

	lat_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (1 to input_data'length => 1))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);
end;
