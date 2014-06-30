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
		sys_clks : in std_logic_vector(0 to data_phases/data_edges-1);
		sys_di : in std_logic;
		ph_qo : out std_ulogic_vector(0 to data_phases*delay_size+(data_phases-1)*(data_phases-1)));
end;


architecture slr of xdr_ph is
	signal clks : std_logic_vector(0 to data_phases-1);
	signal phi : std_ulogic_vector(clks'range);
begin
	
	clks(sys_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases/data_edges to data_phases-1) <= not sys_clks;
	end generate;

	g0: block
		signal q : std_logic_vector(0 to delay_size);
	begin
		process (clks(0))
		begin
			if rising_edge(clks(0)) then
				q <= sys_di & q(0 to q'right-1);
			end if;
		end process;
		phi (clks'length-1) <= sys_di;
		j: for j in 0 to delay_size-1 generate
			ph_qo(j*clks'length) <= q(j);
		end generate;
	end block;

	g : for i in 1 to data_phases-1 generate
		signal q : std_logic_vector(0 to delay_size);
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				q <= phi(i) & q(0 to q'right-1);
			end if;
		end process;
		phi ((i+clks'length-1) mod clks'length) <= q(0);
		j: for j in 0 to delay_size-1 generate
			ph_qo(j*data_phases+i) <= q(j);
		end generate;
	end generate;

end;
