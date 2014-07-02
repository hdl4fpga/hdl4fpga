library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ph is
	generic (
		data_phases : natural := 4;
		data_edges  : natural := 2;
		byte_size   : natural := 1;
		word_size   : natural := 4;
		delay_phase : natural := 2;
		delay_size  : natural := 2);
	port (
		sys_clks : in std_logic_vector(0 to data_phases/data_edges-1);
		sys_di : in std_logic_vector(0 to word_size/byte_size-1);
		ph_qo  : out std_logic_vector(0 to (delay_size+1)*word_size/byte_size-1));
end;

architecture slr of xdr_ph is
	subtype phword is std_ulogic_vector(0 to word_size/byte_size-1);
	type phword_vector is array (natural range <>) of phword;
	signal clks : std_logic_vector(0 to data_phases-1) := (others => '-');
	signal phi  : phword_vector(clks'range) := (others => (others => '-'));
	signal phi0 : phword_vector(clks'range) := (others => (others => '-'));
	signal di : phword;
	signal qo : phword_vector(0 to delay_size);

	function to_stdlogicvector (
		constant arg : phword_vector)
		return std_logic_vector is
		variable val : unsigned(0 to ph_qo'length-1) := (others => '-');
	begin
		for i in arg'reverse_range loop
			val := val srl phword'length;
			val(phword'range) := unsigned(arg(i));
		end loop;
		return std_logic_vector(val);
	end;

begin
	
	clks(sys_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases/data_edges to data_phases-1) <= not sys_clks;
	end generate;

	g0: block
		signal q : phword_vector(0 to delay_size/data_phases);
	begin
		q(0) <= std_ulogic_vector(sys_di);
		process (clks(0))
		begin
			if rising_edge(clks(0)) then
				q(1 to q'right) <= q(0 to q'right-1);
			end if;
		end process;
		phi (clks'length-1) <= std_ulogic_vector(sys_di);
		phi0 (delay_phase) <= std_ulogic_vector(sys_di);
		j: for j in q'range generate
			qo(j*data_phases) <= q(j);
		end generate;
	end block;

	gn : for i in 1 to data_phases-1 generate
		signal q  : phword_vector((data_phases-i)*(clks'length-1)/data_phases to (delay_size-i)/data_phases) := (others => (others => '-'));
	begin
		process (clks(i))
		begin
			if rising_edge(clks(i)) then
				q <= phi(i) & q(q'left to q'right-1);
			end if;
		end process;
		phi ((i+clks'length-1) mod clks'length) <= q(q'left);
		j: for j in q'range generate
			qo(j*data_phases+i) <= q(j);
		end generate;
	end generate;

	g1 : for i in 1 to data_phases-2 generate
		signal q : phword_vector((delay_phase+i-1)/data_phases to (data_phases-i)*(clks'length-1)/data_phases-1) := (others => (others => '-'));
	begin
		process (clks(i))
			constant  k : natural := ((delay_phase+i-1)/data_phases)*data_phases;
		begin
			if rising_edge(clks(i)) then
				q((delay_phase+i-1)/data_phases) <= phi0(i);
				for i in (delay_phase+i-1)/data_phases+1 to q'right loop
					q(i) <= q(i-1);
				end loop;
			end if;
		end process;
		phi0 ((i+clks'length-1) mod clks'length) <= q(q'left);
		j: for j in q'range generate
			qo(j*data_phases+i) <= q(j);
		end generate;
	end generate;
	ph_qo <= to_stdlogicvector(qo);
end;
