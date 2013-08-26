library ieee;
use ieee.std_logic_1164.all;

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

--	ffd2_i : fdrse
--	port map (
--		s  => '0',
--		r  => '0',
--		c  => clk(2),
--		ce => '1',
--		d  => ddr_ph_din(0),
--		q  => delay2);

	process (clk(2))
	begin
		if rising_edge(clk(2)) then
			delay2 <= ddr_ph_din(0);
		end if;
	end process;

--	ffd5_i : fdrse
--	port map (
--		s  => '0',
--		r  => '0',
--		c  => clk(3),
--		ce => '1',
--		d  => q3(0),
--		q  => delay5);

	process (clk(3))
	begin
		if rising_edge(clk(3)) then
			delay5 <= q3(0);
		end if;
	end process;

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
