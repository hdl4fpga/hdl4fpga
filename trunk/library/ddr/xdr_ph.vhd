library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ph is
	generic (
		data_phases : natural := 4;
		data_edges  : natural := 2;
		byte_size  : natural := 8;
		word_size  : natural := 32;
		delay_size : natural);
	port (
		sys_clks : in std_logic_vector(0 to data_phases/data_edges);
		sys_di : in std_logic;
		ph_qo : out std_logic_vector(0 to data_phases*delay_size+(data_phases-1)*(data_phases-1)));
end;


architecture slr of xdr_ph is
	signal clks : std_logic_vector(0 to data_phases-1);
	signal phi : std_logic_vector(0 to data_phases-1);
begin
	
	g : for i in 1 to sys_clks'length-1 generate
		signal q : std_logic_vector(0 to delay_size);
	begin
		phi ((i+sys_clks'length-1) mod clks'length) <= q(0);
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				q <= phi(i) & q(0 to q'right-1);
			end if;
		end process;
		g : for j in 0 to delay_size-1 generate
			ph_qo(j*clks'length+i) <= q(i);
		end generate;
	end generate;

end;
