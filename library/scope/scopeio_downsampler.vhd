library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;

entity scopeio_downsampler is
	port (
		input_clk   : in  std_logic;
		input_ena   : in  std_logic;
		input_data  : in  std_logic_vector;
		factor_addr : in  std_logic_vector := (0 to 0 => '-');
		factor_data : in  std_logic_vector;
		output_ena  : out std_logic;
		output_data : out std_logic_vector);
end;

architecture beh of scopeio_downsampler is
	signal cntr : signed(factor_data'range);
begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			output_ena <= cntr(cntr'left) and input_ena;
			if input_ena='1' then
				if cntr(cntr'left)='1' then
					cntr <= signed(factor_data);
				else
					cntr <= cntr - 1;
				end if;
			end if;
		end if;
	end process;

	lat_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (input_data'range => 1))
	port map (
		clk => input_clk,
		di  => input_data,
		do  => output_data);
end;
