library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_dm_fifo is
	generic (
		data_phases : natural := 1);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dm  : in  std_logic_vector(data_phases-1 downto 0);

		xdr_clk : in  std_logic_vector(data_phases-1 downto 0);
		xdr_ena : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dm  : out std_logic_vector(data_phases-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_dm_fifo is
	subtype axdr_word is std_logic_vector(0 to 4-1);

	type aw_vector is array (natural range <>) of axdr_word;

	type byte_vector is array (natural range <>) of std_logic_vector(byte_size-1 downto 0);
	type dme_vector  is array (natural range <>) of std_logic_vector(data_phases*data_bytes-1 downto 0);

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte_size-1 downto 0);
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
		variable val : std_logic_vector(byte_size*arg'length-1 downto 0);
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
		variable val : dme_vector(data_edges-1 downto 0);
	begin
		dat := unsigned(arg);
		for i in data_phases-1 downto 0 loop
			for j in data_edges-1 downto 0 loop
				for k in data_bytes-1 downto 0 loop
					val(j)(i*data_bytes+k) := dat(i*data_edges*data_bytes+data_bytes*j+k);
				end loop;
			end loop;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : dme_vector)
		return std_logic_vector is
		variable dat : dme_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(data_edges*arg'length-1 downto 0);
	begin
		for i in data_phases-1 downto 0 loop
			for j in data_edges-1 downto 0 loop
				for k in data_bytes-1 downto 0 loop
					val(i*data_edges*data_bytes+data_bytes*j+k) := dat(j)(i*data_bytes+k);
				end loop;
			end loop;
		end loop;
		dat := arg;
		return val;
	end;

	signal dqe  : byte_vector(sys_dm'range);
	signal sys_dme : dme_vector(data_phases*data_bytes-1 downto 0);
	signal xdr_dme : dme_vector(data_phases*data_bytes-1 downto 0);

	signal xdr_axdr_q : aw_vector(data_phases*data_edges*data_bytes-1 downto 0);
	signal sys_axdr_q : aw_vector(data_bytes-1 downto 0);

begin

	xdr_dq <= to_stdlogicvector(dqe);

	sys_dme <= to_dmevector(sys_dm);
	dm_g: for i in data_edges-1 downto 0 generate
		ram_i : entity hdl4fpga.dbram
		generic map (
			n => data_phases*data_bytes)
		port map (
			clk => sys_clk,
			we => sys_req,
			wa => sys_axdr_q(0),
			di => sys_dme(i),
			ra => xdr_axdr_q(data_phases*data_bytes*i),
			do => xdr_dme(i));
	end generate;
	xdr_dm <= to_stdlogicvector(xdr_dme);

	dqe <= to_bytevector(sys_di);
	data_byte_g: for l in data_bytes-1 downto 0 generate
		signal sys_axdr_d : axdr_word;
	begin
		sys_axdr_d <= inc(gray(sys_axdr_q(l)));
		sys_cntr_g: for j in axdr_word'range  generate
			signal axdr_set : std_logic;
		begin
			axdr_set <= not sys_req;
			ffd_i : entity hdl4fpga.sff
			port map (
				clk => sys_clk,
				sr  => axdr_set,
				d   => sys_axdr_d(j),
				q   => sys_axdr_q(l)(j));
		end generate;

		xdr_phases_g: for i in data_phases-1 downto 0 generate
			xdr_data_g: for k in data_edges-1 downto 0 generate
				signal dpo : std_logic_vector(byte_size-1 downto 0);
				signal qpo : std_logic_vector(byte_size-1 downto 0);
				signal xdr_axdr_d : axdr_word;
			begin
				xdr_axdr_d <= inc(gray(xdr_axdr_q(data_bytes*i+l)));
				cntr_g: for j in axdr_word'range generate
					signal axdr_set : std_logic;
				begin
					axdr_set <= not xdr_ena(i*data_bytes);
					ffd_i : entity hdl4fpga.sff
					port map (
						clk => xdr_clk((i*data_edges+k)),
						sr  => axdr_set,
						d   => xdr_axdr_d(j),
						q   => xdr_axdr_q(data_bytes*(i*data_edges+k)+l)(j));
				end generate;

				ram_i : entity hdl4fpga.dbram
				generic map (
					n => byte_size)
				port map (
					clk => sys_clk,
					we  => sys_req,
					wa  => sys_axdr_q(l),
					di  => dqe(data_bytes*(i*data_edges+k)+l),
					ra  => xdr_axdr_q(data_bytes*(i*data_edges+k)+l),
					do  => dpo);

				ram_g: for j in byte_size-1 downto 0 generate
					ffd_i : entity hdl4fpga.ff
					port map (
						clk => xdr_clk((i*data_edges+k)),
						d   => dpo(j),
						q   => qpo(j));
				end generate;

				dqe(data_bytes*(i*data_edges+k)+l) <= dpo when std=1 else qpo;
			end generate;
		end generate;
	end generate;
end;
