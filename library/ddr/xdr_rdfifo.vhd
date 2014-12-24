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
		sys_do  : out std_logic_vector(data_phases*line_size-1 downto 0);

		xdr_win_dq  : in std_logic_vector((word_size/byte_size)-1 downto 0);
		xdr_win_dqs : in std_logic_vector((word_size/byte_size)-1 downto 0);
		xdr_dqsi : in std_logic_vector((word_size/byte_size)-1 downto 0);
		xdr_dqi  : in std_logic_vector(data_phases*line_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of xdr_rdfifo is
	subtype byte is std_logic_vector((line_size*byte_size)/word_size-1 downto 0);
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

	subtype word is std_logic_vector(data_phases*byte'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function shuffle_word (
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

	signal dqi : byte_vector(xdr_dqsi'length-1 downto 0);
	signal do  : word_vector(xdr_dqsi'length-1 downto 0);

begin

	dqi <= to_bytevector(xdr_dqi);
	xdr_fifo_g : for i in xdr_dqsi'range generate

		dqs_delayed_e : entity hdl4fpga.pgm_delay
		port map (
			xi  => xdr_dqsi,
			x_p => xdr_delayed_dqs(0),
			x_n => xdr_delayed_dqs(1));

		inbyte_i : entity hdl4fpga.xdr_infifo
		generic map (
			data_delay => data_delay,
			data_edges => data_edges,
			data_phases => data_phases,
			byte_size  => byte'length)
		port map (
			sys_clk => sys_clk,
			sys_rdy => sys_rdy(i),
			sys_rea => sys_rea,
			sys_do  => do(i),
			xdr_win_dq  => xdr_win_dq(i),
			xdr_win_dqs => xdr_win_dqs(i),
			xdr_dqsi => xdr_dqsi(i),
			xdr_dqi  => dqi(i));
	end generate;
	sys_do <= to_stdlogicvector(shuffle_word(do));

end;
