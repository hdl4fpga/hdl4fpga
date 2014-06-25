library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_ph is
	generic (
		data_phases : natural := 4;
		data_edges  : natural := 2);
		n : natural);
	port (
		xdr_ph_clks : in  std_logic_vector(0 to data_phases/data_edges);
		xdr_ph_sel  : in  std_logic_vector(0 to data_phases*n+(data_phases-1)*(data_phases-1)) := (others => '0');
		xdr_ph_din  : in  std_logic_vector(0 to data_phases*n+(data_phases-1)*(data_phases-1)) := (others => '-');
		xdr_ph_qout : out std_logic_vector(0 to data_phases*n+(data_phases-1)*(data_phases-1)));
end;

architecture slr of xdr_ph is
	signal clk : std_logic_vector(0 to 4-1);

	signal q0 : std_logic_vector(1 to (data_phases*n+(data_phases-1)*3)/data_phases);
	signal q3 : std_logic_vector(0 to (data_phases*n+(data_phases-1)*(data_phases-1)-3)/data_phases);
	signal q6 : std_logic_vector(0 to (data_phases*n+(data_phases-1)*3-6)/data_phases);
	signal q9 : std_logic_vector(0 to (data_phases*n+(data_phases-1)*3-9)/data_phases);
	signal delay2 : std_logic;
	signal delay5 : std_logic;
begin

	clk(0) <= xdr_ph_clks(0);
	clk(1) <= not xdr_ph_clk(1);
	clk(2) <= not xdr_ph_clk(0);
	clk(3) <= xdr_ph_clk90;

	process (clk(2))
	begin
		if rising_edge(clk(2)) then
			delay2 <= xdr_ph_din(0);
		end if;
	end process;

	process (clk(3))
	begin
		if rising_edge(clk(3)) then
			delay5 <= q3(0);
		end if;
	end process;

	process (xdr_ph_clk)
	begin
		if rising_edge(xdr_ph_clk) then
			q0 <= xdr_ph_din(0) & q0(1 to q0'right-1);
		end if;
	end process;

	process (clk(1))
	begin
		if rising_edge(clk(1)) then
			q3 <= xdr_ph_din(0) & q3(0 to q3'right-1);
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

	process (xdr_ph_din(0), delay2, delay5, q0, q3, q6, q9)
	begin
		xdr_ph_qout(0) <= xdr_ph_din(0);
		xdr_ph_qout(2) <= delay2;
		xdr_ph_qout(5) <= delay5;
		for i in q0'range loop
			xdr_ph_qout (4*i+0) <= q0(i);
		end loop;
		for i in q3'range loop
			xdr_ph_qout (4*i+3) <= q3(i);
		end loop;
		for i in q6'range loop
			xdr_ph_qout (4*i+6) <= q6(i);
		end loop;
		for i in q9'range loop
			xdr_ph_qout (4*i+9) <= q9(i);
		end loop;
	end process;
end;
