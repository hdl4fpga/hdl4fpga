library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xdr_wrfifo is
	generic (
		word_size   : natural := 32;
		byte_size   : natural := 8;
		data_edges  : natural := 1;
		data_phases : natural := 1;
		data_bytes  : natural := 2;
		register_output : boolean := false);
	port (
		sys_clk : in  std_logic;
		sys_req : in  std_logic;
		sys_dmi : in  std_logic_vector(data_bytes*data_phases*word_size/byte_size-1 downto 0);
		sys_dqi : in  std_logic_vector(data_bytes*data_phases*word_size-1 downto 0);

		xdr_clks : in  std_logic_vector(data_phases/data_edges-1 downto 0);
		xdr_enas : in  std_logic_vector(data_phases-1 downto 0);
		xdr_dmo  : out std_logic_vector(data_bytes*data_phases*word_size/byte_size-1 downto 0);
		xdr_dqo  : out std_logic_vector(data_bytes*data_phases*word_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture struct of xdr_wrfifo is

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
			val := val sll byte'length;
			val(byte'range) := arg(i);
		end loop;
		return val;
	end;

	signal di : byte_vector(data_bytes-1 downto 0);
	signal do : byte_vector(data_bytes-1 downto 0);

begin

	di <= to_bytevector(sys_dmi);
	xdr_fifo_g : for i in data_bytes-1 downto 0 generate
		signal dmi : std_logic_vector(xdr_dmo'length/data_bytes-1 downto 0);
		signal dmo : std_logic_vector(dmi'range);
		signal dqi : byte_vector(xdr_dmo'length/data_bytes-1 downto 0);
		signal dqo : byte_vector(dqi'range);
		signal fifo_di : std_logic_vector(xdr_dqo'length/data_bytes-1 downto 0);
		signal fifo_do : std_logic_vector(fifo_di'range);
	begin
		shuffle_p : process (sys_dmi, dqi)
		begin
			for j in dmi'range loop
				dmi(j) <= sys_dmi(data_bytes*j+i);
				dqi(j) <= di(data_bytes*j+i);
			end loop;
		end process;


		fifo_di <= to_stdlogicvector(dqi);
		outbyte_i : entity hdl4fpga.xdr_outfifo
		generic map (
			data_phases => data_phases,
			data_edges  => data_edges,
			byte_size => byte_size,
			word_size => word_size,
			register_output => register_output)
		port map (
			sys_clk => sys_clk,
			sys_di  => fifo_di,
			sys_req => sys_req,
			sys_dm  => dmi,
			xdr_clks => xdr_clks,
			xdr_dmo  => dmo,
			xdr_enas => xdr_enas, 
			xdr_dqo  => fifo_do);
		dqo <= to_bytevector(fifo_do);

		unshuffle_p : process (dmo, dqo)
		begin
			for j in dmo'range loop
				xdr_dmo(data_bytes*j+i) <= dmo(i);
				do(data_bytes*j+i) <= dqo(j);
			end loop;
		end process;

	end generate;
	xdr_dqo <= to_stdlogicvector(do);
end;
