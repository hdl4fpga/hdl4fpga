library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_rdfifo is
	generic (
		data_delay  : natural := 1;
		data_edges  : natural := 2;
		data_phases : natural := 2;
		line_size   : natural := 8;
		word_size   : natural := 8;
		byte_size   : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_rdy : out std_logic_vector((word_size/byte_size)-1 downto 0);
		sys_rea : in  std_logic;
		xdr_win_dq : in std_logic_vector((word_size/byte_size)-1 downto 0);
		sys_do  : out std_logic_vector(data_phases*line_size-1 downto 0);

		xdr_win_dqs : in std_logic_vector(0 to data_phases*line_size/byte_size-1);
		xdr_dqsi : in std_logic_vector((word_size/byte_size)-1 downto 0);
		xdr_dqi  : in std_logic_vector(line_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of xdr_rdfifo is
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
		for i in dat'range loop
			val := val sll byte'length;
			val(byte'range) := dat(i);
		end loop;
		return val;
	end;

	subtype word is std_logic_vector(data_phases*line_size*byte'length/word_size-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function shuffle_word (
		arg : byte_vector)
		return word_vector is
		variable aux : byte_vector(word'length/byte'length-1 downto 0);
		variable val : word_vector(arg'length/aux'length-1 downto 0);
	begin
		for i in val'range loop
			aux := (others => (others => '-'));
			for j in aux'range loop
				aux(j) := arg(i*aux'length+j);
			end loop;
			val(i) := to_stdlogicvector(aux);
		end loop;
		return val;
	end;

	function unshuffle_word (
		arg : word_vector)
		return byte_vector is
		variable aux : byte_vector(word'length/byte'length-1 downto 0);
		variable val : byte_vector(arg'length*aux'length-1 downto 0);
	begin
		for i in arg'range loop
			aux := to_bytevector(arg(i));
			for j in aux'range loop
				val(j*arg'length+i) := aux(j);
			end loop;
		end loop;
		return val;
	end;

	signal do  : word_vector(xdr_dqsi'length-1 downto 0);
	signal di :  word_vector(xdr_dqsi'length-1 downto 0);

begin

	di  <= shuffle_word(to_bytevector(xdr_dqi));
	xdr_fifo_g : for i in xdr_dqsi'range generate
		signal pll_req : std_logic;
		signal ser_clk : std_logic_vector(data_phases-1 downto 0);
		signal ser_req : std_logic_vector(data_edges-1 downto 0);
		signal ser_ena : std_logic_vector(data_phases*line_size/word_size-1 downto 0);

	begin

		process (sys_clk)
			variable acc_rea_dly : std_logic;
			variable sys_do_win : std_logic;
		begin
			if rising_edge(sys_clk) then
				ser_req  <= (others => not sys_do_win);
				sys_do_win  := acc_rea_dly;
				acc_rea_dly := not sys_rea;
			end if;
		end process;

		process (sys_clk)
			variable q : std_logic_vector(0 to data_delay);
		begin 
			if rising_edge(sys_clk) then
				q := q(1 to q'right) & xdr_win_dq(i);
				pll_req <= q(0);
			end if;
		end process;
		sys_rdy(i) <= not pll_req;

		clk_data_phases_g: if data_edges > 1 generate
			dqs_delayed_e : entity hdl4fpga.pgm_delay
			port map (
				xi  => xdr_dqsi(i),
				x_p => ser_clk(0),
				x_n => ser_clk(1));
		end generate;

		clk_edges_g: if data_edges < 2 generate
			ser_clk(0) <= xdr_dqsi(i);
		end generate;

		data_edges_g : for l in data_edges-1 downto 0 generate
			signal ena : std_logic_vector(data_phases/data_edges-1 downto 0);
		begin
			process (ser_req(l), ser_clk(l))
			begin
				if ser_req(l)='0' then
					ena <= (0 => '1', others => '0');
				elsif rising_edge(ser_clk(l)) then
					ena <= ena rol 1;
				end if;
			end process;

			ena_g : for j in data_phases/data_edges-1 downto 0 generate
				byte_ena_g : for m in line_size/word_size-1 downto 0 generate
					ser_ena((j*data_edges+l)*line_size/word_size+m) <=
					xdr_win_dqs(((j*data_edges+l)*line_size/word_size+m)*xdr_dqsi'length+i) when data_phases/data_edges=1 else
					xdr_win_dqs(((j*data_edges+l)*line_size/word_size+m)*xdr_dqsi'length+i) when ena(j)='1' else
					'0';
				end generate;

				inbyte_i : entity hdl4fpga.iofifo
				generic map (
					pll2ser => false,
					data_phases => data_phases,
					word_size  => word'length,
					byte_size  => byte'length)
				port map (
					pll_clk => sys_clk,
					pll_req => pll_req,

					ser_req => ser_req,
					ser_ena => ser_ena,
					ser_clk => ser_clk,

					do  => do(i),
					di  => di(i));
			end generate;
		end generate;
	end generate;
	sys_do <= to_stdlogicvector(unshuffle_word(do));

end;
