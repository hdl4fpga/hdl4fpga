library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;

entity ddrphy is
	generic (
		data_phases : natural := 1;
		cmnd_phases : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13;
		line_size : natural := 32;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		sys_sclk : in  std_logic;
		sys_sclk2x : in std_logic;
		sys_eclk : in  std_logic;
		phy_rst : in std_logic;

		sys_rst  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cfgi : in  std_logic_vector(9*(word_size/byte_size)-1 downto 0);
		sys_cfgo : out std_logic_vector(4+1*(word_size/byte_size)-1 downto 0) := (others => '1');
		sys_cs   : in  std_logic_vector(cmnd_phases-1 downto 0) := (others => '0');
		sys_rw   : in  std_logic;
		sys_b    : in  std_logic_vector(cmnd_phases*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(cmnd_phases*addr_size-1 downto 0);
		sys_cke  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_ras  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cas  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_we   : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_odt  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_dmt  : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dmi  : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(data_phases*line_size-1 downto 0);
		sys_dqi  : out std_logic_vector(data_phases*line_size-1 downto 0);
		sys_dqso : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dqst : in  std_logic_vector(data_phases*line_size/byte_size-1 downto 0);
		sys_dqsi : out std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');

		ddr_rst : out std_logic;
		ddr_cs  : out std_logic := '0';
		ddr_cke : out std_logic := '1';
		ddr_ck  : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);

		ddr_dm  : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dq  : inout std_logic_vector(word_size-1 downto 0);
		ddr_dqs : inout std_logic_vector(word_size/byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of ddrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(data_phases*byte_size*line_size/word_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(line_size/word_size-1 downto 0);
	type bline_vector is array (natural range <>) of bline_word;

	subtype ciline_word is std_logic_vector(9-1 downto 0);
	type ciline_vector is array (natural range <>) of ciline_word;

	subtype coline_word is std_logic_vector(1-1 downto 0);
	type coline_vector is array (natural range <>) of coline_word;

	function to_bytevector (
		constant arg : std_logic_vector) 
		return byte_vector is
		variable dat : unsigned(arg'length-1 downto 0);
		variable val : byte_vector(arg'length/byte'length-1 downto 0);
	begin	
		dat := unsigned(arg);
		for i in val'reverse_range loop
			val(i) := std_logic_vector(dat(byte'range));
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

	function shuffle_dlinevector (
		constant arg : std_logic_vector) 
		return dline_vector is
		variable dat : byte_vector(arg'length/byte'length-1 downto 0);
		variable val : byte_vector(dat'range);
--		variable val : dline_vector(arg'length/dline_word'length-1 downto 0);
	begin	
		dat := to_bytevector(arg);
		for i in word_size/byte_size-1 downto 0 loop
			for j in line_size/word_size-1 downto 0 loop
				val(i*line_size/word_size+j) := dat(j*word_size/byte_size+i);
			end loop;
		end loop;
		return to_dlinevector(to_stdlogicvector(val));
	end;

	signal dqsdel : std_logic;
	signal sdmt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmo : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqst : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqsi : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal cfgi : ciline_vector(word_size/byte_size-1 downto 0);
	signal cfgo : coline_vector(word_size/byte_size-1 downto 0);

	signal dqsdll_rst : std_logic;
	signal dqsdll_lock : std_logic;
	signal dqsdll_uddcntln : std_logic;
	signal dqsdll_uddcntln_rdy : std_logic;
	signal dqrst : std_logic;
	signal lock : std_logic;
	signal synceclk : std_logic;
	signal eclk_stop : std_logic;
	signal stop : std_logic;
begin

	ddr3phy_i : entity hdl4fpga.ddrbaphy
	generic map (
		cmnd_phases => cmnd_phases,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_sclk => sys_sclk,
		sys_sclk2x => sys_sclk2x,
          
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => sys_b,
		sys_a   => sys_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		ddr_rst => ddr_rst,
		ddr_ck  => ddr_ck,
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_cs => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi <= to_blinevector(sys_dmi);
	sdmt <= to_blinevector(not sys_dmt);
	sdqt <= to_blinevector(not sys_dqt);
	sdqi <= shuffle_dlinevector(sys_dqo);
	ddqi <= to_bytevector(ddr_dq);
	sdqsi <= to_blinevector(sys_dqso);
	sdqst <= to_blinevector(sys_dqst);
	cfgi <= to_cilinevector(sys_cfgi);

	process (phy_rst, sys_sclk)
		variable sr : std_logic_vector(0 to 1);
	begin
		if phy_rst='1' then
			sr := (others => '0');
			stop <= not sr(0);
		elsif rising_edge(sys_sclk) then
			sr := sr(1 to 1) & '1';
			stop <= not sr(0);
		end if;
	end process;

	process (sys_sclk)
	begin
		if falling_edge(sys_sclk) then
			eclk_stop <= not dqsdll_uddcntln_rdy;
		end if;
	end process;

	sys_cfgo(5 downto 2) <= "0010";
	eclksynca_i : eclksynca
	port map (
		stop  => eclk_stop,
		eclki => sys_eclk,
		eclko => synceclk);

	eclk_phase_p : block
		signal eclk_ff : std_logic;
		signal eclksync_ff : std_logic;
		signal edge_ff : std_logic;
	begin

		process (phy_rst, synceclk)
		begin
			if phy_rst='1' then
				eclk_ff <= '0';
			elsif rising_edge(synceclk) then
				eclk_ff <= not eclk_ff;
			end if;
		end process;

		process (phy_rst, sys_sclk)
		begin
			if phy_rst='1' then
				eclk_ff <= '0';
			elsif rising_edge(sys_sclk) then
				eclk_ff <= sys_eclk;
			end if;
		end process;

		process (phy_rst, sys_sclk)
		begin
			if phy_rst='1' then
				edge_ff <= '0';
			elsif rising_edge(sys_sclk) then
				edge_ff <= eclksync_ff;
			end if;
		end process;

	end block;

	dqsdllb_i : dqsdllb
	port map (
		rst => phy_rst,
		clk => sys_sclk2x,
		uddcntln => dqsdll_uddcntln,
		dqsdel => dqsdel,
		lock => dqsdll_lock);

	process (sys_sclk2x)
		variable sr : std_logic_vector(0 to 4);
	begin
		if rising_edge(sys_sclk2x) then
			sr := sr(1 to 4) & dqsdll_lock;
			lock <= sr(0);
		end if;
	end process;

	process (lock, sys_sclk2x)
		variable counter : unsigned(0 to 3);
	begin
		if lock='0' then
			counter := (others => '0');
			dqsdll_uddcntln_rdy <= counter(0);
			dqsdll_uddcntln <= '1';
		elsif rising_edge(sys_sclk2x) then
			dqsdll_uddcntln <= counter(0);
			if counter(0)='0' then
				counter := counter + 1;
			end if;
			dqsdll_uddcntln_rdy <= counter(0);
		end if;
	end process;

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		generic map (
			line_size => line_size*byte_size/word_size,
			byte_size => byte_size)
		port map (
			sys_rst  => phy_rst,
			sys_sclk => sys_sclk,
			sys_eclk => synceclk,
			sys_eclkw => synceclk,
			sys_dqsdel => dqsdel,
			sys_rw   => sys_rw,
			sys_cfgi => cfgi(i),
			sys_cfgo => cfgo(i),

			sys_dmt => sdmt(i),
			sys_dmi => sdmi(i),
			sys_dmo => sdmo(i),

			sys_dqo  => sdqi(i),
			sys_dqt  => sdqt(i),
			sys_dqi  => sdqo(i),

			sys_dqso => sdqsi(i),
			sys_dqst => sdqst(i),

			ddr_dqi  => ddqi(i),
			ddr_dqt  => ddqt(i),
			ddr_dqo  => ddqo(i),

--			ddr_dmi  => ddr_dm(i),
			ddr_dmt  => ddmt(i),
			ddr_dmo  => ddmo(i),

			ddr_dqsi => ddr_dqs(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqsi(i));
	end generate;

	process (ddqsi, ddqst)
	begin
		for i in ddqsi'range loop
			if ddqst(i)='1' then
				ddr_dqs(i) <= 'Z';
			else
				ddr_dqs(i) <= ddqsi(i);
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

	sys_dqsi <= (others => sys_sclk);
	sys_dmo <= to_stdlogicvector(sdmo);
	sys_dqi <= to_stdlogicvector(sdqo);
	sys_cfgo(2-1 downto 0) <= to_stdlogicvector(cfgo);
end;
