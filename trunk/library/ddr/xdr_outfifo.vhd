library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_outfifo is
	generic (
		line_size   : natural := 8;
		byte_size   : natural := 8;
		data_edges  : natural := 2;
		data_phases : natural := 1;
		register_output : boolean := false);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dm  : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_di  : in  std_logic_vector(data_phases*line_size-1 downto 0);

		xdr_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		xdr_enas : in  std_logic_vector(0 to data_phases*line_size/byte_size-1);
		xdr_dmo  : out std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_phases*line_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture mix of xdr_outfifo is
	subtype word is std_logic_vector(byte_size-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function to_wordvector (
		arg : std_logic_vector) 
		return word_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : word_vector(arg'length/word'length-1 downto 0);
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
		for i in dat'range loop
			val := val sll word'length;
			val(word'range) := dat(i);
		end loop;
		return val;
	end;

	subtype axdr_word is std_logic_vector(0 to 4-1);
	type aw_vector is array (natural range <>) of axdr_word;

	signal sys_axdr_q : axdr_word;
	signal sys_axdr_d : axdr_word;
	signal xdr_axdr_q : aw_vector(xdr_enas'range);
	signal di : word_vector(xdr_enas'range);
	signal do : word_vector(xdr_enas'range);
	signal clks : std_logic_vector(0 to data_phases-1);

begin

	di  <= to_wordvector(sys_di);
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

	xdr_fifo_g : for l in 0 to line_size/byte_size-1 generate
		phases_g : for m in clks'range generate
			signal dpo : word;
			signal qpo : word := (others => '-');
			signal dmo : std_logic := '-';
			signal qmo : std_logic := '-';
			signal xdr_axdr_d : axdr_word;
		begin

			xdr_axdr_d <= inc(gray(xdr_axdr_q(data_phases*l)));
			cntr_g: for k in axdr_word'range generate
				signal axdr_set : std_logic;
			begin
				axdr_set <= not xdr_enas(data_phases*l+m);
				ffd_i : entity hdl4fpga.sff
				port map (
					clk => clks(m),
					sr  => axdr_set,
					d   => xdr_axdr_d(k),
					q   => xdr_axdr_q(data_phases*l+m)(k));
			end generate;

			dqram_i : entity hdl4fpga.dbram
			generic map (
				n   => word'length)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_axdr_q,
				di  => di(data_phases*l+m),
				ra  => xdr_axdr_q(data_phases*l+m),
				do  => dpo);

			dmram_i : entity hdl4fpga.dbram
			generic map (
				n   => 1)
			port map (
				clk => sys_clk,
				we  => sys_req,
				wa  => sys_axdr_q,
				di(0) => sys_dm(data_phases*l+m),
				ra  => xdr_axdr_q(data_phases*l+m),
				do(0) => dmo);

			register_output_g : if register_output generate
				ffd_i : entity hdl4fpga.ff
				port map (
					clk => clks(m),
					d => dmo,
					q => qmo);

				dqo_g: for k in word'range generate
					ffd_i : entity hdl4fpga.ff
					port map (
						clk => clks(m),
						d => dpo(k),
						q => qpo(k));
				end generate;
			end generate;

			xdr_dmo(data_phases*l+m) <= qmo when register_output else dmo;
			do(data_phases*l+m) <= qpo when register_output else dpo;
		end generate;
	end generate;
	xdr_dqo <= to_stdlogicvector(do);
end;
