library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_wr_fifo is
	generic (
		data_edges  : natural := 2;
		data_phases : natural := 1;
		byte_size   : natural := 8;
		register_output : boolean := false);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_di  : in  std_logic_vector(data_phases*byte_size-1 downto 0);

		xdr_clk : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		xdr_ena : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dq  : out std_logic_vector(data_phases*byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_wr_fifo is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	function to_bytevector (
		arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'length-1 downto 0));
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*byte'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val := val sll byte_size;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	subtype axdr_word is std_logic_vector(0 to 4-1);
	type aw_vector is array (natural range <>) of axdr_word;

	signal xdr_axdr_q : aw_vector(data_phases-1 downto 0);
	signal sys_axdr_q : axdr_word;
	signal sys_axdr_d : axdr_word;
	signal di : byte_vector(sys_di'length/byte'length-1 downto 0);
	signal do : byte_vector(sys_di'length/byte'length-1 downto 0);
	signal clks : std_logic_vector(data_phases-1 downto 0);
begin

	di <= to_bytevector(sys_di);
	sys_axdr_d <= inc(gray(sys_axdr_q));
	sys_cntr_g: for j in axdr_word'range  generate
		signal axdr_set : std_logic;
	begin
		axdr_set <= not sys_req;
		ffd_i : entity hdl4fpga.sff
		port map (
			clk => sys_clk,
			sr  => axdr_set,
			d   => sys_axdr_d(j),
			q   => sys_axdr_q(j));
	end generate;

	xdr_fifo_g : for l in 0 to data_phases-1 generate
		signal dpo : std_logic_vector(byte_size-1 downto 0);
		signal qpo : std_logic_vector(byte_size-1 downto 0) := (others => '-');
		signal xdr_axdr_d : axdr_word;
	begin

		xdr_axdr_d <= inc(gray(xdr_axdr_q(l)));
		cntr_g: for k in axdr_word'range generate
			signal axdr_set : std_logic;
		begin
			axdr_set <= not xdr_ena(l);
			ffd_i : entity hdl4fpga.sff
			port map (
				clk => xdr_clk(l),
				sr  => axdr_set,
				d   => xdr_axdr_d(k),
				q   => xdr_axdr_q(l)(k));
		end generate;

		ram_i : entity hdl4fpga.dbram
		generic map (
			n   => byte_size)
		port map (
			clk => sys_clk,
			we  => sys_req,
			wa  => sys_axdr_q,
			di  => di(l),
			ra  => xdr_axdr_q(l),
			do  => dpo);

		register_output_g : if register_output generate
			dqo_g: for k in byte'range generate
				ffd_i : entity hdl4fpga.ff
				port map (
					clk => xdr_clk(l),
					d => dpo(k),
					q => qpo(k));
			end generate;
		end generate;

		do(l) <= dpo when register_output else qpo;
	end generate;
	xdr_dq <= to_stdlogicvector(do);
end;
