--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;

entity ddrphy is
	generic (
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
		sys_wlreq : in  std_logic;
		sys_wlrdy : out  std_logic;
		sys_pha  : out std_logic_vector;
		sys_cs   : in  std_logic_vector(cmnd_phases-1 downto 0) := (others => '0');
		sys_sti  : out  std_logic_vector(word_size/byte_size-1 downto 0);
		sys_sto  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_b    : in  std_logic_vector(cmnd_phases*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(cmnd_phases*addr_size-1 downto 0);
		sys_cke  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_ras  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_cas  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_we   : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_odt  : in  std_logic_vector(cmnd_phases-1 downto 0);
		sys_dmt  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqi  : out std_logic_vector(line_size-1 downto 0);
		sys_dqso : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqst : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqsi : out std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		sys_wlpha : out std_logic_vector(8-1 downto 0) := (others => '-');
		sys_pll : out std_logic_vector(8-1 downto 0);

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
	constant gear : natural := line_size/word_size;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp3 of ddrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(byte_size*line_size/word_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(line_size/word_size-1 downto 0);
	type bline_vector is array (natural range <>) of bline_word;


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

	function to_stdlogicvector (
		constant arg : byte_vector)
		return std_logic_vector is
		variable dat : byte_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
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
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
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
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

	function shuffle_dlinevector (
		constant arg : std_logic_vector) 
		return dline_vector is
		variable dat : byte_vector(arg'length/byte'length-1 downto 0);
		variable val : byte_vector(dat'range);
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

	signal adjdll_stop : std_logic;
	signal adjdll_rst  : std_logic;
	signal dqsdll_rst : std_logic;
	signal dqsdll_lock : std_logic;
	signal dqsdll_uddcntln : std_logic;
	signal dqsdll_uddcntln_rdy : std_logic;
	signal dqrst : std_logic;
	signal eclk_stop : std_logic;
	signal synceclk : std_logic;
	signal dqsbufd_rst : std_logic;

	signal wlnxt : std_logic;
	signal wlrdy : std_logic_vector(0 to word_size/byte_size-1);
	signal dqsbufd_arst : std_logic;

	signal test : std_logic_vector(word_size/byte_size-1 downto 0);
	type wlword_vector is array (natural range <>) of std_logic_vector(8-1 downto 0);
	signal wlpha : wlword_vector(word_size/byte_size-1 downto 0);
	signal pha : std_logic_vector(sys_pha'range);
	signal okt : std_logic;

begin

	sys_wlpha <= wlpha(1);
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

	dqsdll_b : block
		signal lock : std_logic;
		signal uddcntln : std_logic;
	begin
		process (phy_rst, sys_sclk)
			variable sr : std_logic_vector(0 to 4);
		begin
			if phy_rst='1' then
				sr := (others => '0');
			elsif rising_edge(sys_sclk) then
				sr := sr(1 to 4) & lock;
			end if;
			uddcntln <= sr(1) xnor sr(3);
			dqsbufd_rst <= not sr(0);
		end process;

		dqsdllb_i : dqsdllb
		port map (
			rst => phy_rst,
			clk => sys_eclk,
			uddcntln => uddcntln,
			dqsdel => dqsdel,
			lock => lock);
	end block;

	adjdll_rst <= phy_rst;
	adjdll_e : entity hdl4fpga.adjdll
	port map (
		rst  => adjdll_rst,
		sclk => sys_sclk,
		eclk => sys_eclk,
		synceclk => synceclk,
		okt => okt,
		pha => pha);
	sys_pha <= pha;

	process (sys_sclk)
		variable aux : std_logic;
	begin
		if rising_edge(sys_sclk) then
			aux := '1';
			for i in wlrdy'range loop
				aux := aux and wlrdy(i);
			end loop;
			sys_wlrdy <= aux;
		end if;
	end process;

	sys_pll(5-1 downto 0) <= okt & pha;
--	process (sys_sclk)
--	begin
--		if rising_edge(sys_sclk) then
--			if test(0)='1'then
--				sys_pll(0) <= sdqo(0)(0*8);
--				sys_pll(1) <= sdqo(0)(1*8);
--				sys_pll(2) <= sdqo(0)(2*8);
--				sys_pll(3) <= sdqo(0)(3*8);
--			else
--				sys_pll(4) <= sdqo(0)(0*8);
--				sys_pll(5) <= sdqo(0)(1*8);
--				sys_pll(6) <= sdqo(0)(2*8);
--				sys_pll(7) <= sdqo(0)(3*8);
--			end if;
--		end if;
--	end process;

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		generic map (
			line_size => line_size*byte_size/word_size,
			byte_size => byte_size)
		port map (
			dqsbufd_rst => dqsbufd_rst,
			sys_sclk => sys_sclk,
			sys_eclk1 => sys_eclk,
			sys_eclk => synceclk,
			sys_eclkw => synceclk,
			sys_dqsdel => dqsdel,
			sys_rw => sys_sto(i*gear+0),
			sys_wlreq => sys_wlreq,
			sys_wlrdy => wlrdy(i),
			sys_wlpha => wlpha(i),

			sys_dmt => sdmt(i),
			sys_dmi => sdmi(i),
			sys_dmo => sdmo(i),

			sys_dqo => sdqi(i),
			sys_dqt => sdqt(i),
			sys_dqi => sdqo(i),

			sys_dqso => sdqsi(i),
			sys_dqst => sdqst(i),
			sys_test => test(i),

			ddr_dqi => ddqi(i),
			ddr_dqt => ddqt(i),
			ddr_dqo => ddqo(i),

--			ddr_dmi => ddr_dm(i),
			ddr_dmt => ddmt(i),
			ddr_dmo => ddmo(i),

			ddr_dqsi => ddr_dqs(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqsi(i));


		wr_address_i : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => 3))
		port map (
			clk => sys_sclk,
			di(0)  => sys_sto(i*gear+0),
			do(0)  => sys_sti(i));

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
end;
