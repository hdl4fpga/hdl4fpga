entity is
	generic map (
		data_delay => data_delay,
		data_edges => data_edges,
		data_phases => data_phases,
	port map (
		sys_clk => clk0,
		sys_rdy => sys_do_rdy,
		sys_rea => xdr_mpu_rea,
		sys_do  => sys_do,
		xdr_win_dq  => xdr_mpu_rwin,
		xdr_win_dqs => xdr_win_dqs(i),
		xdr_dqsi => xdr_rd_dqsi(i),
		xdr_dqi  => xdr_rd_dqi(i));
end;

architecture of is
	subtype dmword is std_logic_vector(sys_dm'length/xdr_dmo'length-1 downto 0);
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

begin

	xdr_fifo_g : for i in xdr_dmo'range generate
		rd_i : entity hdl4fpga.xdr_rd_fifo
		generic map (
			data_delay => data_delay,
			data_edges => data_edges,
			data_phases => data_phases,
			word_size  => byte_size)
		port map (
			sys_clk => clk0,
			sys_rdy => sys_do_rdy,
			sys_rea => xdr_mpu_rea,
			sys_do  => sys_do,
			xdr_win_dq  => xdr_mpu_rwin,
			xdr_win_dqs => xdr_win_dqs(i),
			xdr_dqsi => xdr_rd_dqsi(i),
			xdr_dqi  => xdr_rd_dqi(i));
			
		wr_i : entity hdl4fpga.xdr_wr_fifo
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges,
			byte_size => byte_size,
			word_size => byte_size)
		port map (
			sys_clk => clk0,
			sys_di  => sys_di,
			sys_req => xdr_wr_fifo_req,
			sys_dm  => sys_dm,
			xdr_clks => xdr_wr_clk,
			xdr_dmo  => xdr_wr_dm(i),
			xdr_enas => xdr_wr_fifo_ena(i), 
			xdr_dqo  => xdr_wr_dq(i));
	end generate;

end;
