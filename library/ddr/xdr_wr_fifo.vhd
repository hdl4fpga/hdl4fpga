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
		sys_dmi : in  std_logic_vector(data_phases-1 downto 0);
		sys_di  : in  std_logic_vector(data_phases*byte_size-1 downto 0);

		xdr_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		xdr_enas : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_phases-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_phases*byte_size-1 downto 0));
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
		for i in arg'range loop
			val := val sll byte'length;
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

	clks(xdr_clks'range) <= xdr_clks;
	falling_edge_g : if data_edges /= 1 generate
		clks(data_phases-1 downto data_phases/data_edges) <= not xdr_clks;
	end generate;

	: if generate
		xdr_axdr_g : for l in 0 to data_phases-1 generate
			signal xdr_axdr_d : axdr_word;
		begin
			xdr_axdr_d <= inc(gray(xdr_axdr_q(l)));
			cntr_g: for k in axdr_word'range generate
				signal axdr_set : std_logic;
			begin
				axdr_set <= not xdr_enas(l);
				ffd_i : entity hdl4fpga.sff
				port map (
					clk => clks(l),
					sr  => axdr_set,
					d   => xdr_axdr_d(k),
					q   => xdr_axdr_q(l)(k));
			end generate;
	
			dmram_i : entity hdl4fpga.dbram
			generic map (
				n   => 1)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_axdr_q,
				di(0)  => sys_dmi(l),
				ra  => xdr_axdr_q(l),
				do(0)  => dmo);
		end generate;
	end generate;

	: if generate
		xdr_axdr_g : for l in 0 to data_phases-1 generate
			signal xdr_axdr_d : axdr_word;
		begin
			xdr_axdr_d <= inc(gray(xdr_axdr_q(l)));
			cntr_g: for k in axdr_word'range generate
				signal axdr_set : std_logic;
			begin
				axdr_set <= not xdr_enas(l);
				ffd_i : entity hdl4fpga.sff
				port map (
					clk => clks(l),
					sr  => axdr_set,
					d   => xdr_axdr_d(k),
					q   => xdr_axdr_q(l)(k));
			end generate;
	
			dmram_i : entity hdl4fpga.dbram
			generic map (
				n   => 1)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_axdr_q,
				di(0)  => sys_dmi(l),
				ra  => xdr_axdr_q(l),
				do(0)  => dmo);
		end generate;
	end generate;


	xdr_fifo_g : for l in 0 to data_phases-1 generate
		signal dpo : std_logic_vector(byte_size-1 downto 0);
		signal qpo : std_logic_vector(byte_size-1 downto 0) := (others => '-');
		signal dmo : std_logic;
		signal qmo : std_logic;
	begin

		dqram_i : entity hdl4fpga.dbram
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
			dmo_i : entity hdl4fpga.ff
			port map (
				clk => clks(l),
				d => dmo,
				q => qmo);

			dqo_g: for k in byte'range generate
				ffd_i : entity hdl4fpga.ff
				port map (
					clk => clks(l),
					d => dpo(k),
					q => qpo(k));
			end generate;
		end generate;

		do(l) <= qpo when register_output else dpo;
		xdr_dmo(l) <= qmo when register_output else dmo;
	end generate;
	xdr_dqo <= to_stdlogicvector(do);
end;
