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


entity ddrphy is
	generic (
		data_phases : natural := 2;
		cmd_phases : natural := 1;
		bank_size : natural := 2;
		addr_size : natural := 13;
		line_size : natural := 32;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		sys_clk0  : in std_logic;
		sys_clk90 : in std_logic;
		phy_rst : in std_logic;

		sys_cs   : in  std_logic_vector(cmd_phases-1 downto 0) := (others => '0');
		sys_cke  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_ras  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_cas  : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_we   : in  std_logic_vector(cmd_phases-1 downto 0);
		sys_b    : in  std_logic_vector(cmd_phases*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(cmd_phases*addr_size-1 downto 0);
		sys_odt  : in  std_logic_vector(cmd_phases-1 downto 0);

		sys_dmt  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqi  : out std_logic_vector(line_size-1 downto 0);

		sys_dqso : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqst : in  std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqsi : out std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');

		ddr_cs  : out std_logic := '0';
		ddr_cke : out std_logic := '1';
		ddr_clk_p  : out std_logic;
		ddr_clk_n  : out std_logic;
		ddr_odt : out std_logic;
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);

		ddr_dm  : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dq  : inout std_logic_vector(word_size-1 downto 0);
		ddr_dqs_n : inout std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqs_p : inout std_logic_vector(word_size/byte_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

library unisim;
use unisim.vcomponents.all;

architecture virtex of ddrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(line_size*byte_size/word_size-1 downto 0);
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
	signal ddqso : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqsi : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);

	signal dqrst : std_logic;
	signal clk : std_logic;


begin

	ddr3phy_i : entity hdl4fpga.ddrbaphy
	generic map (
		cmd_phases => cmd_phases,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clk => sys_clk0,
          
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => sys_b,
		sys_a   => sys_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		ddr_ck  => clk,
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi  <= to_blinevector(sys_dmi);
	sdmt  <= to_blinevector(not sys_dmt);
	sdqt  <= to_blinevector(not sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqo);
	ddqi  <= to_bytevector(ddr_dq);
	sdqsi <= to_blinevector(sys_dqso);
	sdqst <= to_blinevector(sys_dqst);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ddrdqphy
		generic map (
			line_size => line_size*byte_size/word_size,
			byte_size => byte_size)
		port map (
			sys_clk0  => sys_clk0,
			sys_clk90 => sys_clk90,

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

			ddr_dqsi => ddqso(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqsi(i));
	end generate;

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

	ddr2_dqs_g : for i in data_phases-1 downto 0 generate
		signal dqsi : std_logic;
		signal st   : std_logic;
	begin

--		dqsidelay_i : idelay 
--		port map (
--			rst => ictlr_rst,
--			c   => '0',
--			ce  => '0',
--			inc => '0',
--			i   => dqsi,
--			o   => ddr_dqsi(i));

		dqsiobuf_i : iobufds
		generic map (
			iostandard => "DIFF_SSTL18_II_DCI")
		port map (
			t   => ddqst(i),
			i   => ddqso(i),
			o   => ddqsi(i),
			io  => ddr_dqs_p(i),
			iob => ddr_dqs_n(i));

	end generate;

	ddr_ck_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL18_II")
	port map (
		i  => clk,
		o  => ddr_clk_p,
		ob => ddr_clk_n);
--	sys_dqsi <= (others => sys_clk);
	sys_dmo <= to_stdlogicvector(sdmo);
	sys_dqi <= to_stdlogicvector(sdqo);
end;
