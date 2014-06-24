entity xdr_wrfifo is
	generic (
		word_size   : natural := 8;
		byte_size   : natural := 8;
		data_edges  : natural := 1;
		data_phases : natural := 1;
		register_output : boolean := false);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dm  : in  std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		sys_di  : in  std_logic_vector(data_phases*word_size-1 downto 0);

		xdr_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		xdr_enas : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_phases*word_size/byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_phases*word_size-1 downto 0));
end;

architecture struct of xdr_wrfifo is
begin

	xdr_fifo_g : for i in downto 0 generate
		outbyte_i : entity hdl4fpga.xdr_outfifo
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges,
			byte_size => byte_size,
			word_size => word_size,
			register_output => register_output)
		port map (
			sys_clk => sys_clk,
			sys_di  => sys_di,
			sys_req => sys_req,
			sys_dm  => sys_dm,
			xdr_clks => xdr_clks,
			xdr_dmo  => xdr_dmo(i),
			xdr_enas => xdr_enas(i), 
			xdr_dqo  => xdr_dqo(i));
	end generate;
end;
