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

--library unisim;
--use unisim.vcomponents.all;
--
--architecture ffdi  of ddr_ph is
--	signal clks : std_logic_vector(1 to 4-1);
--	signal qout : std_logic_vector(0 to ddr_ph_qout'right) := (others => '-');
--begin
--	qout(0) <= ddr_ph_din(0);
--	delay0: for i in 0 to n+2-1 generate
--		signal din : std_logic;
--	begin
--		din <= qout(4*i) when ddr_ph_sel(4*i)='0' else ddr_ph_din(4*i);
--		ffd_i : fdrse
--		port map (
--			s  => '0',
--			r  => '0',
--			c  => ddr_ph_clk,
--			ce => '1',
--			d  => din,
--			q  => qout(4*(i+1)));
--	end generate;
--
--	clks(1) <= not ddr_ph_clk90;
--	clks(2) <= not ddr_ph_clk;
--	clks(3) <= ddr_ph_clk90;
--
--	ffd_i2 : fdrse
--	port map (
--		s  => '0',
--		r  => '0',
--		c  => clks(2),
--		ce => '1',
--		d  => qout(0),
--		q  => qout(2));
--
--	ffd_i5 : fdrse
--	port map (
--		s  => '0',
--		r  => '0',
--		c  => clks(3),
--		ce => '1',
--		d  => qout(3),
--		q  => qout(5));
--
--	delay369 : for i in 1 to 3 generate
--		signal din : std_logic;
--	begin
--		ffd_i : fdrse
--		port map (
--			s  => '0',
--			r  => '0',
--			c  => clks(i),
--			ce => '1',
--			d  => qout(3*(i-1)),
--			q  => qout(3*i));
--	end generate;
--
--	delay: for i in 1 to n generate
--		ph: for j in 1 to 4-1 generate
--			ffd_i : fdrse
--			port map (
--				s  => '0',
--				r  => '0',
--				c  => clks(j),
--				ce => '1',
--				d  => qout(4*i+3*(j-1)),
--				q  => qout(4*i+3*(j-1)+3));
--		end generate;
--	end generate;
--	ffd_i : fdrse
--	port map (
--		s  => '0',
--		r  => '0',
--		c  => clks(1),
--		ce => '1',
--		d  => qout(4*(n+1)),
--		q  => qout(4*(n+1)+3));
--	ddr_ph_qout <= qout;
--end;

library unisim;
use unisim.vcomponents.all;

architecture slr of ddr_ph is
	signal clk : std_logic_vector(0 to 4-1);

	signal q0 : std_logic_vector(1 to (4*n+3*3)/4);
	signal q3 : std_logic_vector(0 to (4*n+3*3-3)/4);
	signal q6 : std_logic_vector(0 to (4*n+3*3-6)/4);
	signal q9 : std_logic_vector(0 to (4*n+3*3-9)/4);
	signal delay2 : std_logic;
	signal delay5 : std_logic;
begin

	clk(0) <= ddr_ph_clk;
	clk(1) <= not ddr_ph_clk90;
	clk(2) <= not ddr_ph_clk;
	clk(3) <= ddr_ph_clk90;

	ffd2_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clk(2),
		ce => '1',
		d  => ddr_ph_din(0),
		q  => delay2);

	ffd5_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => clk(3),
		ce => '1',
		d  => q3(0),
		q  => delay5);

	process (ddr_ph_clk)
	begin
		if rising_edge(ddr_ph_clk) then
			q0 <= ddr_ph_din(0) & q0(1 to q0'right-1);
		end if;
	end process;

	process (clk(1))
	begin
		if rising_edge(clk(1)) then
			q3 <= ddr_ph_din(0) & q3(0 to q3'right-1);
		end if;
	end process;

	process (clk(2))
	begin
		if rising_edge(clk(2)) then
			q6 <= q3(0) & q6(0 to q6'right-1);
		end if;
	end process;

	process (clk(3))
	begin
		if rising_edge(clk(3)) then
			q9 <= q6(0) & q9(0 to q9'right-1);
		end if;
	end process;

	process (ddr_ph_din(0), delay2, delay5, q0, q3, q6, q9)
	begin
		ddr_ph_qout(0) <= ddr_ph_din(0);
		ddr_ph_qout(2) <= delay2;
		ddr_ph_qout(5) <= delay5;
		for i in q0'range loop
			ddr_ph_qout (4*i+0) <= q0(i);
		end loop;
		for i in q3'range loop
			ddr_ph_qout (4*i+3) <= q3(i);
		end loop;
		for i in q6'range loop
			ddr_ph_qout (4*i+6) <= q6(i);
		end loop;
		for i in q9'range loop
			ddr_ph_qout (4*i+9) <= q9(i);
		end loop;
	end process;
end;
