library ieee;
use ieee.std_logic_1164.all;

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
		sys_di   : in  std_logic_vector(line_size-1 downto 0);
		sys_do   : out std_logic_vector(line_size-1 downto 0);
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

	subtype line_word is std_logic_vector(byte_size*line_size/word_size-1 downto 0);
	type line_vector is array (natural range <>) of line_word;

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

	function shuffle_bytes (
		constant arg : byte_vector)
		return line_vector is
		variable aux : byte_vector(arg'length-1 downto 0);
		variable val : line_vector(word_size/byte_size-1 downto 0);
	begin
		aux := to_bytevector(arg(i));
		for i in val'range loop
			for j in 0 to line_size*byte_size/word_size-1 loop
				val(i) := val(i) sll byte'length;
				val(i)(byte'range) := aux(j*val'length+i);
			end loop;
		end loop;
		return val;
	end;

	signal sdqi : line_vector(word_size/byte_size-1 downto 0);
	signal sdqt : line_vector(word_size/byte_size-1 downto 0);
	signal sdqo : line_vector(word_size/byte_size-1 downto 0);

	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqso : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqst : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqsi : std_logic_vector(word_size/byte_size-1 downto 0);

begin

	byte_g : for i in 0 to n-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		port map (
			sys_rst  => sys_rst,
			sys_sclk => sys_sclk,
			sys_eclk => sys_eclk,
			sys_rw   => sys_rw,
			sys_cfgi => cfgi(i),
			sys_cfgo => cfgo(i),
			sys_dqsi => sdqsi(i),
			sys_dqst => sdqst(i),
			sys_do   => sdo(i),
			sys_di   => sdi(i),
	
			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),
	
			ddr_dqsi => ddqsi(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqso(i));
	end generate;
end;
