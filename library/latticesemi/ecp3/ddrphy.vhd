library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddrphy is
	generic (
		bank_size : natural := 2;
		addr_size : natural := 13;
		line_size : natural := 13;
		word_size : natural := 2;
		byte_size : natural := 2);
	port (
		sys_rst  : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk : in  std_logic;

		sys_cfgi : in  std_logic_vector(9*(word_size/byte_size)-1 downto 0);
		sys_cfgo : out std_logic_vector(1*(word_size/byte_size)-1 downto 0);
		sys_rw  : in  std_logic;
		sys_b   : in  std_logic_vector(line_size*bank_size-1 downto 0);
		sys_a   : in  std_logic_vector(line_size*addr_size-1 downto 0);
		sys_cke : in  std_logic_vector(2-1 downto 0);
		sys_ras : in  std_logic_vector(2-1 downto 0);
		sys_cas : in  std_logic_vector(2-1 downto 0);
		sys_we  : in  std_logic_vector(2-1 downto 0);
		sys_odt : in  std_logic_vector(2-1 downto 0);
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqi  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqo  : out std_logic_vector(line_size-1 downto 0);
		sys_dqsi : in  std_logic_vector(line_size/byte_size/2-1 downto 0);
		sys_dqst : in  std_logic_vector(line_size/byte_size/2-1 downto 0);

		ddr_ck  : out std_logic;
		ddr_cke : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);

		ddr_dmt  : out std_logic;
		ddr_dmi  : in  std_logic;
		ddr_dmo  : out std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqsi : in  std_logic;
		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of ddrphy is
	subtype byte is std_logic_vector((line_size*byte_size)/word_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(byte_size*line_size/word_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype d2line_word is std_logic_vector(byte_size*line_size/word_size/2-1 downto 0);
	type d2line_vector is array (natural range <>) of d2line_word;

	subtype bline_word is std_logic_vector(line_size/word_size-1 downto 0);
	type bline_vector is array (natural range <>) of bline_word;

	subtype b2line_word is std_logic_vector(line_size/word_size/2-1 downto 0);
	type b2line_vector is array (natural range <>) of b2line_word;

	subtype ciline_word is std_logic_vector(line_size/word_size-1 downto 0);
	type ciline_vector is array (natural range <>) of ciline_word;

	subtype coline_word is std_logic_vector(line_size/word_size-1 downto 0);
	type coline_vector is array (natural range <>) of ciline_word;

	function to_bytevector (
		constant arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_cilinevector (
		constant arg : std_logic_vector) 
		return ciline_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : ciline_vector(arg'length/ciline_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll arg(arg'left)'length;
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : dline_vector)
		return std_logic_vector is
		variable dat : dline_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll arg(arg'left)'length;
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function to_stdlogicvector (
		constant arg : ciline_vector)
		return std_logic_vector is
		variable dat : ciline_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := val sll arg(arg'left)'length;
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	signal sdmt : b2line_vector(word_size/byte_size-1 downto 0);
	signal sdmi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmo : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt : d2line_vector(word_size/byte_size-1 downto 0);
	signal sdqi : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo : dline_vector(word_size/byte_size-1 downto 0);

	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : dline_vector(word_size/byte_size-1 downto 0);
	signal ddqi : dline_vector(word_size/byte_size-1 downto 0);
	signal cfgi : ciline_vector(word_size/byte_size-1 downto 0);
	signal cfgo : coline_vector(word_size/byte_size-1 downto 0);

begin

	sdmi <= shuffle(sys_dmi);
	sdmi <= shuffle(sys_dmi);
	sdqi <= shuffle(to_bytevector(sys_dqi));
	sdqt <= shuffle(to_bytevector(sys_dqt));

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		generic map (
			dqs_size => 2,
			line_size => 32,
			byte_size => 8)
		port map (
			sys_rst  => sys_rst,
			sys_sclk => sys_sclk,
			sys_eclk => sys_eclk,
			sys_rw   => sys_rw,
			sys_cfgi => cfgi(i),
			sys_cfgo => cfgo(i),

			sys_dqsi => sdqsi(i),
			sys_dqst => sdqst(i),
			sys_dqso => sys_dqso(i),

			sys_dmi => sdmi(i),
			sys_dmo => sdmo(i),
			sys_dqo => sdqo(i),
			sys_dqi => sdqi(i),

			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),

			ddr_dqsi => ddr_dqsi(i),
			ddr_dqst => ddr_dqst(i),
			ddr_dqso => ddr_dqso(i));
	end generate;

	sys_dqo <= to_stdlogicvector(sdqi);
	ddr_dqt <= to_stdlogicvector(ddqt);
	ddr_dqo <= to_stdlogicvector(ddqo);
end;
