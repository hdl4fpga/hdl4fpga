library ieee;
use ieee.std_logic_1164.all;

entity xdr_io_dq is
	generic (
		ddr_phases : natural := 0;
		data_edges : natural;
		data_bytes : natural;
		byte_bits  : natural);
	port (
		ddr_io_clk : in std_logic;
		ddr_mpu_dqz : in std_logic_vector(data_bytes-1 downto 0);
		ddr_io_phs : in std_logic_vector(2**ddr_phases-1 downto 0) := (others => '0'); 
		ddr_io_dqz : out std_logic_vector(data_bytes*byte_bits-1 downto 0);
		ddr_io_dq  : in  std_logic_vector(data_bytes*data_edges*byte_bits-1 downto 0);
		ddr_io_dqo : out std_logic_vector(data_bytes*byte_bits-1 downto 0));

	constant data_bits : natural := data_bytes*byte_bits;
	constant data_phases : natural := 2**ddr_phases;
	constant r : natural := 0;
	constant f : natural := 1;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture std of xdr_io_dq is
	type oddri_vector is array (natural range <>) of std_logic_vector(data_phases-1 downto 0);
	signal oddri : oddri_vector(data_edges*data_bytes*byte_bits-1 downto 0);

	function to_oddrivector (
		arg : std_logic_vector)
		return oddri_vector is
		variable dat : std_logic_vector(arg'length-1 downto 0);
		variable val : oddri_vector(arg'length/data_phases-1 downto 0);
	begin
		dat := arg;
		for i in arg'length/data_phases-1 downto 0 loop
			for k in data_phases-1 downto 0 loop
				val(i)(k) := dat(i*data_phases+k);
			end loop;
		end loop;
		return val;
	end;

begin

	oddri <= to_oddrivector(ddr_io_dq);
	bytes_g : for i in data_bytes-1 downto 0 generate
		bits_g : for j in byte_bits-1 downto 0 generate
			signal d : std_logic_vector(data_edges-1 downto 0);
		begin
			oddrt_i : entity hdl4fpga.ddrto
			port map (
				clk => ddr_io_clk,
				d   => ddr_mpu_dqz(i),
				q   => ddr_io_dqz(i));

			d(r) <= mux(oddri(r*data_bits+i*byte_bits+j),ddr_io_phs);
			d(f) <= mux(oddri(f*data_bits+i*byte_bits+j),ddr_io_phs);

			oddr_i : entity hdl4fpga.ddro
			generic map (
				ddr_phases => ddr_phases,
				data_edges => data_edges)
			port map (
				clk => ddr_io_clk,
				d   => d,
				q   => ddr_io_dqo(i*byte_bits+j));
		end generate;
	end generate;
end;
