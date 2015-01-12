use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

entity xdr_wrfifo is
	generic (
		data_edges  : natural;
		data_phases : natural;
		line_size   : natural;
		word_size   : natural;
		byte_size   : natural;
		registered_output : boolean := true);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dmi : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dqi : in  std_logic_vector(data_phases*line_size-1 downto 0);

		xdr_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0) := (others => '-');
		xdr_enas : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_phases*line_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

use std.textio.all;

architecture struct of xdr_wrfifo is

	subtype byte is std_logic_vector(byte_size downto 0);
	type byte_vector is array (natural range <>) of byte;

	function merge (
		constant arg1 : std_logic_vector;
		constant arg2 : std_logic_vector)
		return std_logic_vector is
		variable dat1 : unsigned(xdr_dqo'length-1 downto 0);
		variable dat2 : unsigned(xdr_dmo'length-1 downto 0);
		variable val  : unsigned(0 to arg1'length+arg2'length-1);
	begin
		dat1 := unsigned(arg1);
		dat2 := unsigned(arg2);
		for i in dat2'range loop
			val  := val  srl byte'length;
			val(0 to byte_size) := dat2(0) & dat1(byte_size-1 downto 0);
			dat1 := dat1 srl byte_size;
			dat2 := dat2 srl 1;
		end loop;
		return std_logic_vector(val);
	end;

	function extract_dm (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable val : std_logic_vector(xdr_dmo'range);
	begin
		for i in val'range loop
			val(i) := arg(i*byte'length+byte_size);
		end loop;
		return val;
	end;

	function extract_dq (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable dat : std_logic_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(0 to xdr_dqo'length-1);
	begin
		dat := arg;
		for i in xdr_dmo'range loop
			val := val srl byte_size;
			val(0 to byte_size-1) := dat(byte_size-1 downto 0);
			dat := dat srl byte'length;
		end loop;
		return val;
	end;

	function to_bytevector (
		arg : std_logic_vector)
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val  : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'range));
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

	subtype word is std_logic_vector(data_phases*(line_size*(byte_size+1)/word_size)-1 downto 0);
	type word_vector is array (natural range <>) of word;

	subtype shuffleword is byte_vector(data_phases*(line_size/word_size)-1 downto 0);

	function unshuffle (
		arg : word_vector)
		return byte_vector is
		variable aux : byte_vector(word'length/byte'length-1 downto 0);
		variable val : byte_vector(xdr_dmo'range);
	begin
		for i in arg'range loop
			aux := to_bytevector(arg(i));
			for j in aux'range loop
				val(j*(word_size/byte_size)+i) := aux(j);
			end loop;
		end loop;
		return val;
	end;

	signal di : byte_vector(sys_dmi'range);
	signal do : byte_vector(xdr_dmo'range);
	signal dqo : word_vector((word_size/byte_size)-1 downto 0);

	signal ser_clk : std_logic_vector(data_phases-1 downto 0);
begin

	ser_clk(xdr_clks'range) <= xdr_clks;
	falling_edge_g : if data_edges /= 1 generate
		ser_clk(data_phases-1 downto data_phases/data_edges) <= not xdr_clks;
	end generate;

	di <= to_bytevector(merge(sys_dqi, sys_dmi));
	xdr_fifo_g : for i in (word_size/byte_size)-1 downto 0 generate

		signal dqi : shuffleword;
		signal fifo_di : word;

		function shuffle (
			arg1 : byte_vector;
			arg2 : natural)
			return shuffleword is
			variable val : shuffleword;
		begin
			for i in val'range loop
				val(i) := arg1((word_size/byte_size)*i+arg2);
			end loop;
			return val;
		end;

	begin
		dqi <= shuffle(di, i);

		fifo_di <= to_stdlogicvector(dqi);
		outbyte_i : entity hdl4fpga.iofifo
		generic map (
			pll2ser => true,
			registered_output => registered_output,
			data_phases => data_phases,
			word_size => word'length,
			byte_size => word'length)
		port map (
			pll_clk => sys_clk,
			pll_req => sys_req,
			ser_clk => ser_clk,
			ser_ena => xdr_enas, 
			ser_req => xdr_enas, 
			di  => fifo_di,
			do  => dqo(i));

	end generate;
	do <= unshuffle(dqo);
	xdr_dqo <= extract_dq(to_stdlogicvector(do));
	xdr_dmo <= extract_dm(to_stdlogicvector(do));
end;
