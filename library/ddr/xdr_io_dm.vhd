library ieee;
use ieee.std_logic_1164.all;

entity xdr_io_dm is
	generic (
		strobe : string;
		ddr_phases : natural;
		data_edges : natural;
		data_bytes : natural);
	port (
		ddr_io_clk  : in  std_logic_vector(2**ddr_phases-1 downto 0);
		ddr_mpu_dmx : in  std_logic_vector(data_edges*data_bytes-1 downto 0);
		ddr_mpu_st  : in  std_logic_vector(2**ddr_phases*data_edges-1 downto 0);
		ddr_mpu_dm  : in  std_logic_vector(2**ddr_phases*data_edges*data_bytes-1 downto 0);
		ddr_io_dmo  : out std_logic_vector(data_bytes-1 downto 0));

	constant data_phases : natural := 2**ddr_phases;
	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;
use hdl4fpga.std."sll";

architecture arch of xdr_io_dm is

	type oddri_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);
	signal oddri : oddri_vector(data_edges-1 downto 0);

	function to_oddrivector (
		arg : std_logic_vector)
		return oddri_vector is
		variable dat : std_logic_vector(arg'length-1 downto 0);
		variable val : oddri_vector(data_edges-1 downto 0);
	begin
		dat := arg;
		for i in data_edges*data_bytes-1 downto 0 loop
			for k in data_phases-1 downto 0 loop
				val(i)(k) := dat(i*data_phases+k);
			end loop;
		end loop;
		return val;
	end;

	signal clks : std_logic_vector(data_phases*data_edges-1 downto 0);

begin

	process (ddr_io_clk)
		variable aux : std_logic_vector(clks'range);
	begin
		aux(ddr_io_clk'range) := ddr_io_clk;
		aux := hdl4fpga.std."sll"(aux, ddr_io_clk'length);
		aux(ddr_io_clk'range) := not ddr_io_clk;
		clks <= aux;
	end process;

	bits_g : for i in ddr_io_dmo'range generate
		signal d : std_logic_vector(clks'range);
	begin

		dmff_g: for l in clks'range generate
			signal di : std_logic;
		begin
			di <=
			ddr_mpu_dm(i*data_edges+l) when strobe="EXTERNAL" else
			ddr_mpu_dm(i*data_edges+l) when ddr_mpu_dmx(i*data_edges+l)='1' else
			ddr_mpu_st(l);

			ffd_i : entity hdl4fpga.ff
			port map (
				clk => clks(l),
				d   => di,
				q   => d(l));

		end generate;

		oddr_du : entity hdl4fpga.ddro
		generic map (
			ddr_phases => ddr_phases,
			data_edges => data_edges)
		port map (
			clk => ddr_io_clk(0),
			d   => d,
			q   => ddr_io_dmo(i));

	end generate;
end;
