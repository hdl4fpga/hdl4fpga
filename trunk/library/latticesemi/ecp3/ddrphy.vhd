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
		sys_sclk2x : in  std_logic;
		sys_eclk : in  std_logic;

		sys_cfgi : in  std_logic_vector(9*(word_size/byte_size)-1 downto 0);
		sys_cfgo : out std_logic_vector(1*(word_size/byte_size)-1 downto 0);
		sys_rw   : in  std_logic;
		sys_b    : in  std_logic_vector(line_size*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(line_size*addr_size-1 downto 0);
		sys_cke  : in  std_logic_vector(2-1 downto 0);
		sys_ras  : in  std_logic_vector(2-1 downto 0);
		sys_cas  : in  std_logic_vector(2-1 downto 0);
		sys_we   : in  std_logic_vector(2-1 downto 0);
		sys_odt  : in  std_logic_vector(2-1 downto 0);
		sys_dmt  : in  std_logic_vector(line_size/byte_size/2-1 downto 0);
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(line_size/byte_size/2-1 downto 0);
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

		ddr_dm  : inout std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dq  : inout std_logic_vector(byte_size-1 downto 0);
		ddr_dqs : inout std_logic_vector(word_size/byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of ddrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
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

	function to_dlinevector (
		constant arg : std_logic_vector) 
		return dline_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : dline_vector(arg'length/dline_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_d2linevector (
		constant arg : std_logic_vector) 
		return d2line_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : d2line_vector(arg'length/d2line_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_blinevector (
		constant arg : std_logic_vector) 
		return bline_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : bline_vector(arg'length/bline_word'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(val(val'left)'length-1 downto 0));
			dat := dat srl val(val'left)'length;
		end loop;
		return val;
	end;

	function to_b2linevector (
		constant arg : std_logic_vector) 
		return b2line_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : b2line_vector(arg'length/b2line_word'length-1 downto 0);
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
		constant arg : d2line_vector)
		return std_logic_vector is
		variable dat : d2line_vector(arg'length-1 downto 0);
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
		constant arg : bline_vector)
		return std_logic_vector is
		variable dat : bline_vector(arg'length-1 downto 0);
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
		constant arg : b2line_vector)
		return std_logic_vector is
		variable dat : b2line_vector(arg'length-1 downto 0);
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
		constant arg : coline_vector)
		return std_logic_vector is
		variable dat : coline_vector(arg'length-1 downto 0);
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

	signal sdqsi : b2line_vector(word_size/byte_size-1 downto 0);
	signal sdqst : b2line_vector(word_size/byte_size-1 downto 0);

	signal ddmo : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqst : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqso : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : dline_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal cfgi : ciline_vector(word_size/byte_size-1 downto 0);
	signal cfgo : coline_vector(word_size/byte_size-1 downto 0);

begin

	ddr3phy_i : entity hdl4fpga.ddrbaphy
	generic map (
		bank_size => bank_size,
		addr_size => addr_size,
		line_size => line_size/word_size/2)
	port map (
		sys_sclk => sys_sclk,
		sys_sclk2x => sys_sclk2x,
          
		sys_rw  => sys_rw,
		sys_cke => sys_cke,
		sys_b   => sys_b,
		sys_a   => sys_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		ddr_ck  => ddr_ck,
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi <= to_blinevector(sys_dmi);
	sdmt <= to_b2linevector(sys_dmt);
	sdqt <= to_d2linevector(sys_dqt);
	sdqi <= to_dlinevector(sys_dqi);
	sdqsi <= to_b2linevector(sys_dqsi);
	sdqst <= to_b2linevector(sys_dqst);
	cfgi <= to_cilinevector(sys_cfgi);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		generic map (
			line_size => line_size,
			byte_size => byte_size)
		port map (
			sys_rst  => sys_rst,
			sys_sclk => sys_sclk,
			sys_eclk => sys_eclk,
			sys_rw   => sys_rw,
			sys_cfgi => cfgi(i),
			sys_cfgo => cfgo(i),

			sys_dmt => sdmt(i),
			sys_dmi => sdmi(i),
			sys_dmo => sdmo(i),

			sys_dqi  => sdqi(i),
			sys_dqt  => sdqt(i),
			sys_dqo  => sdqo(i),

			sys_dqsi => sdqsi(i),
			sys_dqst => sdqst(i),

			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),

			ddr_dmi  => ddr_dm(i),
			ddr_dmt  => ddmt(i),
			ddr_dmo  => ddmo(i),

			ddr_dqsi => ddr_dqs(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqso(i));
	end generate;

	process (ddqso, ddqst)
	begin
		for i in ddqso'range loop
			if ddqst(i)='1' then
				ddr_dqs(i) <= 'Z';
			else
				ddr_dqs(i) <= ddqso(i);
			end if;
		end loop;
	end process;

	process (ddqo, ddqt)
		variable dqt : std_logic_vector(ddr_dq'range);
		variable dqo : std_logic_vector(ddr_dq'range);
	begin
		dqt := to_stdlogicvector(ddqt);
		dqo := to_stdlogicvector(ddqo);
		for i in dqo'range loop
			if dqt(i)='1' then
				ddr_dq(i) <= 'Z';
			else
				ddr_dq(i) <= dqo(i);
			end if;
		end loop;
	end process;

	process (ddmo, ddmt)
	begin
		for i in ddmo'range loop
			if ddmt(i)='1' then
				ddr_dm(i) <= 'Z';
			else
				ddr_dm(i) <= ddmo(i);
			end if;
		end loop;
	end process;

	sys_dmo <= to_stdlogicvector(sdmo);
	sys_dqo <= to_stdlogicvector(sdqo);
	sys_cfgo <= to_stdlogicvector(cfgo);
end;
