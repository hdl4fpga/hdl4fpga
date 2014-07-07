library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ph is
	generic (
		data_phases : natural := 4;
		data_edges  : natural := 2;
		delay_phase : natural := 2;
		delay_size  : natural := 2);
	port (
		sys_clks : in std_logic_vector(0 to data_phases/data_edges-1);
		sys_di : in std_logic;
		ph_qo  : out std_logic_vector(0 to delay_size-1));
end;

library hdl4fpga;
use hdl4fpga.std.all;

use std.textio.all;

architecture slr of xdr_ph is
	signal clks : std_logic_vector(0 to data_phases-1) := (others => '-');
	signal phi  : std_logic_vector(clks'range) := (others => '-');
	signal phi0 : std_logic_vector(clks'range) := (others => '-');
	signal qo : std_logic_vector(0 to delay_size);

begin
	
	clks(sys_clks'range) <= sys_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases/data_edges to data_phases-1) <= not sys_clks;
	end generate;

	g0: block
		signal q : std_logic_vector(0 to delay_size/data_phases);
	begin
		q(0) <= sys_di;
		process (clks(0))
		begin
			if rising_edge(clks(0)) then
				q(1 to q'right) <= q(0 to q'right-1);
			end if;
		end process;
		phi (clks'length-1) <= q(0);
		j: for j in q'range generate
			qo(j*data_phases) <= q(j);
		end generate;
	end block;

	gn : for i in 1 to data_phases-1 generate
		signal q  : std_logic_vector((data_phases-i)*(clks'length-1)/data_phases to (delay_size-i)/data_phases) := (others => '-');
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

	xx: if data_phases > 1 generate
		phi0 (delay_phase) <= sys_di;
		g : for i in 1 to data_phases-1 generate
			constant left : natural := selecton (
				data_phases*((delay_phase+i)/data_phases) > delay_phase,
				(delay_phase+i-1)/data_phases,
				(delay_phase+i-1)/data_phases+1);
			signal q : std_logic_vector(left to (data_phases-i)*(clks'length-1)/data_phases-1) := (others => '-');
		begin
			xx : if q'length > 0 generate
				process (clks(i))
				begin
					if rising_edge(clks(i)) then
						q(q'left) <= phi0(i);
						for i in q'left+1 to q'right loop
							q(i) <= q(i-1);
						end loop;
					end if;
				end process;
				phi0 ((i+clks'length-1) mod clks'length) <= q(q'left);
				j: for j in q'range generate
					qo(j*data_phases+i) <= q(j);
				end generate;
			end generate;
		end generate;
	end generate;
	ph_qo <= qo;
end;
