entity xdr_wrfifo is
	generic (
		word_size   : natural := 8;
		byte_size   : natural := 8;
		data_edges  : natural := 1;
		data_phases : natural := 1;
		data_bytes  : natural := 1;
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
	subtype dmword is std_logic_vector(xdr_dqo'range/data_bytes-1 downto 0);
	type dmword_vector is array (natural range <>) of dmword;

	function to_dmwordvector (
		arg : std_logic_vector) 
		return dmword_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : dmword_vector(arg'length/dmword'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(dmword'length-1 downto 0));
			dat := dat srl dmword'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : dmword_vector)
		return std_logic_vector is
		variable dat : dmword_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*dmword'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val := val sll dmword'length;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	subtype byte is std_logic_vector(word_size/xdr_dqsi'length-1 downto 0);
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
			val := val sll byte'length;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	subtype word is std_logic_vector(word_size-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function to_wordvector (
		arg : std_logic_vector) 
		return word_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : word_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(word'length-1 downto 0));
			dat := dat srl word'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		arg : word_vector)
		return std_logic_vector is
		variable dat : word_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*word'length-1 downto 0);
	begin
		dat := arg;
		for i in arg'reverse_range loop
			val := val sll word'length;
			val(word'range) := arg(i);
		end loop;
		return val;
	end;

	signal di : word_vector(data_bytes-1 downto 0);

begin

	di <= to_wordvector(xdr_di);
	xdr_fifo_g : for i in data_bytes-1 downto 0 generate
		signal dm : std_logic_vector(xdr_dqo'length/data_bytes-1 downto 0);
		signal dq : byte_vector(xdr_dqo'length/data_bytes-1 downto 0);
	begin
		shuffle_dm_p : process (sys_dm)
		begin
			for j in dm'range loop
				dm(j) <= sys_dm(data_bytes*j+i);
			end loop;
		end process;

		shuffle_word_p : process (sys_dm)
		begin
			for j in dm'range loop
				dq(j) <= dq(data_bytes*j+i);
			end loop;
		end process;

		outbyte_i : entity hdl4fpga.xdr_outfifo
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges,
			byte_size => byte_size,
			word_size => word_size,
			register_output => register_output)
		port map (
			sys_clk => sys_clk,
			sys_di  => dq,
			sys_req => sys_req,
			sys_dm  => dm,
			xdr_clks => xdr_clks,
			xdr_dmo  => dmo,
			xdr_enas => enas(i), 
			xdr_dqo  => dqo);
	end generate;
end;
