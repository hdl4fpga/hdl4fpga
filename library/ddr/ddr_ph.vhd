library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_ph is
	generic (
		n : natural);
	port (
		ddr_ph_clk   : in  std_logic;
		ddr_ph_clk90 : in  std_logic;
		ddr_ph_sel   : in  std_logic_vector(0 to 4*n+3*3) := (others => '0');
		ddr_ph_din   : in  std_logic_vector(0 to 4*n+3*3) := (others => '-');
		ddr_ph_qout  : out std_logic_vector(0 to 4*n+3*3));
end;

library unisim;
use unisim.vcomponents.all;

architecture arch of ddr_ph is
	signal clks : std_logic_vector(1 to 4-1);
	signal qout : std_logic_vector(0 to ddr_ph_qout'right) := (others => '-');
begin
	qout(0) <= ddr_ph_din(0);
	delay0: for i in 0 to n+2-1 generate
		signal din : std_logic;
	begin
		din <= qout(4*i) when ddr_ph_sel(4*i)='0' else ddr_ph_din(4*i);
		ffd_i : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => ddr_ph_clk,
			ce => '1',
			d  => din,
			q  => qout(4*(i+1)));
	end generate;

	clks(1) <= not ddr_ph_clk90;
	clks(2) <= not ddr_ph_clk;
	clks(3) <= ddr_ph_clk90;

	ffd_i2 : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clks(2),
		ce => '1',
		d  => qout(0),
		q  => qout(2));

	ffd_i5 : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clks(3),
		ce => '1',
		d  => qout(3),
		q  => qout(5));

	delay369 : for i in 1 to 3 generate
		signal din : std_logic;
	begin
		ffd_i : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => clks(i),
			ce => '1',
			d  => qout(3*(i-1)),
			q  => qout(3*i));
	end generate;

	delay: for i in 1 to n generate
		ph: for j in 1 to 4-1 generate
			ffd_i : fdrse
			port map (
				s  => '0',
				r  => '0',
				c  => clks(j),
				ce => '1',
				d  => qout(4*i+3*(j-1)),
				q  => qout(4*i+3*(j-1)+3));
		end generate;
	end generate;
	ffd_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clks(1),
		ce => '1',
		d  => qout(4*(n+1)),
		q  => qout(4*(n+1)+3));
	ddr_ph_qout <= qout;
end;

-- library unisim;
-- use unisim.vcomponents.all;
-- 
-- architecture arch1 of ddr_ph is
-- 	signal clks : std_logic_vector(0 to 4-1);
-- 	signal qout : std_logic_vector(0 to ddr_ph_qout'right) := (others => '-');
-- begin
-- 	qout(0) <= ddr_ph_din(0);
-- 
-- 	clks(0) <= ddr_ph_clk;
-- 	clks(1) <= not ddr_ph_clk90;
-- 	clks(2) <= not ddr_ph_clk;
-- 	clks(3) <= ddr_ph_clk90;
-- 
-- 	ffd_i2 : fdrse
-- 	port map (
-- 		s  => '0',
-- 		r  => '0',
-- 		c  => clks(2),
-- 		ce => '1',
-- 		d  => qout(0),
-- 		q  => qout(2));
-- 
-- 	delay369 : for i in 1 to 3 generate
-- 		signal din : std_logic;
-- 	begin
-- 		ffd_i : fdrse
-- 		port map (
-- 			s  => '0',
-- 			r  => '0',
-- 			c  => clks(i),
-- 			ce => '1',
-- 			d  => qout(3*(i-1)),
-- 			q  => qout(3*i));
-- 	end generate;
-- 
-- 	ffd_i5 : fdrse
-- 	port map (
-- 		s  => '0',
-- 		r  => '0',
-- 		c  => clks(3),
-- 		ce => '1',
-- 		d  => qout(3),
-- 		q  => qout(5));
-- 
-- 	delay: for i in 0 to n+1 generate
-- 		ph: for j in 0 to 4-1 generate
-- 			ffd : if 4*(i+1)+3*j <= 4*n+3*3 generate
-- 				signal din : std_logic;
-- 			begin
-- 				din <= qout(4*i+3*j) when ddr_ph_sel(4*i+3*j)='0' else ddr_ph_din(4*i+3*j);
-- 
-- 				ffd_i : fdrse
-- 				port map (
-- 					s  => '0',
-- 					r  => '0',
-- 					c  => clks(j),
-- 					ce => '1',
-- 					d  => din,
-- 					q  => qout(4*(i+1)+3*j));
-- 			end generate;
-- 		end generate;
-- 	end generate;
-- 
-- 	ddr_ph_qout <= qout;
-- end;
-- 
-- library unisim;
-- use unisim.vcomponents.all;
-- 
-- architecture arch2 of ddr_ph is
-- 	signal clks : std_logic_vector(0 to 4-1);
-- 	signal qout : std_logic_vector(0 to ddr_ph_qout'right) := (others => '-');
-- begin
-- 	qout(0) <= ddr_ph_din(0);
-- 
-- 	clks(0) <= ddr_ph_clk;
-- 	clks(1) <= not ddr_ph_clk90;
-- 	clks(2) <= not ddr_ph_clk;
-- 	clks(3) <= ddr_ph_clk90;
-- 
-- 	process (clks(2))
-- 	begin
-- 		if rising_edge(clks(2)) then
-- 			qout(2) <= qout(0);
-- 		end if;
-- 	end process;
-- 
-- 	delay369 : for i in 1 to 3 generate
-- 		signal din : std_logic;
-- 	begin
-- 		ffd_i : fdrse
-- 		port map (
-- 			s  => '0',
-- 			r  => '0',
-- 			c  => clks(i),
-- 			ce => '1',
-- 			d  => qout(3*(i-1)),
-- 			q  => qout(3*i));
-- 	end generate;
-- 
-- 	process (clks(3))
-- 	begin
-- 		if rising_edge(clks(3)) then
-- 			qout(5) <= qout(3);
-- 		end if;
-- 	end process;
-- 
-- 	process (clks(0))
-- 		variable q : std_logic_vector(0 to n-1);
-- 	begin
-- 		if rising_edge(clks(0)) then
-- 			q := q(1 to q'right) & '0';
-- 			for i in q'range loop
-- 				qout(4*i+3*0) <= q(i);
-- 			end loop;
-- 		end if;
-- 	end process;
-- 
-- 	delay: for i in 0 to n+1 generate
-- 		ph: for j in 0 to 4-1 generate
-- 			ffd : if 4*(i+1)+3*j <= 4*n+3*3 generate
-- 				signal din : std_logic;
-- 			begin
-- 				din <= qout(4*i+3*j) when ddr_ph_sel(4*i+3*j)='0' else ddr_ph_din(4*i+3*j);
-- 
-- 				ffd_i : fdrse
-- 				port map (
-- 					s  => '0',
-- 					r  => '0',
-- 					c  => clks(j),
-- 					ce => '1',
-- 					d  => din,
-- 					q  => qout(4*(i+1)+3*j));
-- 			end generate;
-- 		end generate;
-- 	end generate;
-- 
-- 	ddr_ph_qout <= qout;
-- end;
