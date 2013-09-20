library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_wr_fifo is
	generic (
		std : positive;
		data_bytes : natural := 2;
		data_edges : natural := 2;
		data_phases : natural := 1;
		byte_bits  : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dm  : in  std_logic_vector(data_phases*data_bytes*data_edges-1 downto 0);
		sys_di  : in  std_logic_vector(data_phases*data_bytes*data_edges*byte_bits-1 downto 0);

		ddr_clk : in  std_logic_vector(data_phases-1 downto 0);
		ddr_ena : in  std_logic_vector(data_phases*data_edges*data_bytes-1 downto 0);
		ddr_dm  : out std_logic_vector(data_phases*data_edges*data_bytes-1 downto 0);
		ddr_dq  : out std_logic_vector(data_phases*data_edges*data_bytes*byte_bits-1 downto 0));

	constant data_bits : natural := byte_bits*data_bytes;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of ddr_wr_fifo is
	subtype addr_word is std_logic_vector(0 to 4-1);
	signal ddr_clks : std_logic_vector(data_edges*ddr_clk'length-1 downto 0);

	type aw_vector is array (natural range <>) of addr_word;

	type byte_vector is array (natural range <>) of std_logic_vector(byte_bits-1 downto 0);
	type dme_vector is array(natural range <>) of std_logic_vector(data_phases*data_bytes-1 downto 0);

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte_bits-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(0)'range));
			dat := dat srl val(0)'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'reverse_range loop
			val(byte'range) := dat(i);
			val := val sll dat(0)'length;
		end loop;
		return val;
	end;

	function to_dmevector (
		arg : std_logic_vector) 
		return dme_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : dme_vector(arg'length/data_edges-1 downto 0);
	begin
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(0)'range));
			dat := dat srl val(0)'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : dme_vector)
		return std_logic_vector is
		variable dat : dme_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val(byte'range) := arg(i);
			val := val sll dat(0)'length;
		end loop;
		return val;
	end;

	signal dqe : byte_vector(sys_dm'range);
	signal sys_dme : dme_vector(sys_dm'range);
	signal ddr_dme : dme_vector(sys_dm'range);

	signal ddr_addr_q : aw_vector(data_edges*data_bytes-1 downto 0);
	signal sys_addr_q : aw_vector(data_bytes-1 downto 0);

begin

	ddr_clks(ddr_clk'length-1 downto 0) <= ddr_clk;
	ddr_clks(data_edges*ddr_clk'length-1 downto ddr_clk'length) <= not ddr_clk;

	ddr_dq <= to_stdlogicvector(dqe);

	sys_dme <= to_dmevector(sys_dm);
	dm_g: for i in data_edges-1 downto 0 generate
		ram_i : entity hdl4fpga.dbram
		generic map (
			n => data_phases*data_bytes)
		port map (
			clk => sys_clk,
			we => sys_req,
			wa => sys_addr_q(0),
			di => sys_dme(i),
			ra => ddr_addr_q(data_phases*data_bytes*i),
			do => ddr_dme(i));
	end generate;
	ddr_dm <= to_stdlogicvector(ddr_dme);

	dqe <= to_bytevector(sys_di);
	data_byte_g: for l in data_bytes-1 downto 0 generate
		signal sys_addr_d : addr_word;
	begin
		sys_addr_d <= inc(gray(sys_addr_q(l)));
		sys_cntr_g: for j in addr_word'range  generate
			signal addr_set : std_logic;
		begin
			addr_set <= not sys_req;
			ffd_i : entity hdl4fpga.sff
			port map (
				clk => sys_clk,
				sr  => addr_set,
				d   => sys_addr_d(j),
				q   => sys_addr_q(l)(j));
		end generate;

		ddr_data_g: for i in data_edges*data_phases-1 downto 0 generate
			signal dpo : std_logic_vector(byte_bits-1 downto 0);
			signal qpo : std_logic_vector(byte_bits-1 downto 0);
			signal ddr_addr_d : addr_word;
		begin
			ddr_addr_d <= inc(gray(ddr_addr_q(data_bytes*i+l)));
			cntr_g: for j in addr_word'range generate
				signal addr_set : std_logic;
			begin
				addr_set <= not ddr_ena(i);
				ffd_i : entity hdl4fpga.sff
				port map (
					clk => ddr_clks(i),
					sr  => addr_set,
					d   => ddr_addr_d(j),
					q   => ddr_addr_q(data_bytes*i+l)(j));
			end generate;

			ram_i : entity hdl4fpga.dbram
			generic map (
				n => byte_bits)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_addr_q(l),
				di  => dqe(data_bytes*i+l),
				ra  => ddr_addr_q(data_bytes*i+l),
				do  => dpo);

			ram_g: for j in byte_bits-1 downto 0 generate
				ffd_i : entity hdl4fpga.ff
				port map (
					clk => ddr_clks(i),
					d   => dpo(j),
					q   => qpo(j));
			end generate;

			dqe(data_bytes*i+l) <= dpo when std=1 else qpo;
					
		end generate;
	end generate;
end;
