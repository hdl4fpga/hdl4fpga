library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ph is
	generic (
		data_phases : natural := 4;
		data_edges  : natural := 2;
		byte_size   : natural := 8;
		word_size   : natural := 32;
		delay_phase : natural := 2;
		delay_size  : natural);
	port (
		sys_clks : in std_logic_vector(0 to data_phases/data_edges-1);
		sys_di : in std_logic;
		ph_qo : out std_ulogic_vector(0 to data_phases*delay_size+(data_phases-1)*(data_phases-1)));
end;


architecture slr of xdr_ph is
	signal clks : std_logic_vector(0 to data_phases-1) := (others => '-');
	signal phi  : std_ulogic_vector(clks'range) := (others => '-');
	signal phi0 : std_ulogic_vector(clks'range) := (others => '-');
begin
	
	clks(sys_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases/data_edges to data_phases-1) <= not sys_clks;
	end generate;

	g0: block
		signal q : std_ulogic_vector(0 to delay_size);
	begin
		q(0) <= sys_di;
		process (clks(0))
		begin
			if rising_edge(clks(0)) then
				q(1 to q'right) <= q(0 to q'right-1);
			end if;
		end process;
		phi (clks'length-1) <= sys_di;
		j: for j in 0 to delay_size-1 generate
			ph_qo(j*clks'length) <= q(j);
		end generate;
	end block;

	gn : for i in 1 to data_phases-1 generate
		signal q  : std_logic_vector(0 to delay_size) := (others => '-');
		signal q0 : std_logic_vector(delay_phase/(i+1) to ((data_phases-i)*(clks'length-1)-1)/data_phases-1) := (others => '-');
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				q <= phi(i) & q(0 to q'right-1);
				if q0'length > 2 then
					q0 <= phi0(i) & q0(q0'left to q0'right-1);
				elsif q0'length > 0 then
					q0(q0'right) <= phi0(i);
				end if;
			end if;
		end process;
		phi ((i+clks'length-1) mod clks'length) <= q(0);
		if generate
			phi0() <= q0(0);
		end generate;
		j0: for j in q0'range generate
			ph_qo(j*data_phases+i) <= q0(j);
		end generate;
		j: for j in 0 to delay_size-1 generate
			ph_qo(j*data_phases+(data_phases-i)*(clks'length-1)) <= q(j);
		end generate;
	end generate;

end;
