--                                                                            --
-- author(s):                                                                 --
--   miguel angel sagreras                                                    --
--                                                                            --
-- copyright (c) 2015                                                         --
--    miguel angel sagreras                                                   --
--                                                                            --
-- this source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- this source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the gnu general public license as published by the   --
-- free software foundation, either version 3 of the license, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- this source is distributed in the hope that it will be useful, but without --
-- any warranty; without even the implied warranty of merchantability or      --
-- fitness for a particular purpose. see the gnu general public license for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp5;
use ecp5.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ecp5_ddrphy is
	generic (
		cmmd_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13;
		data_gear : natural := 32;
		word_size : natural := 16;
		byte_size : natural := 8;
		tcp : real);
	port (
		phy_sclk : in  std_logic;
		phy_sclk2x : in std_logic;
		phy_eclk : in  std_logic;
		phy_rst : in std_logic;

		phy_rst   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_wlreq : in  std_logic;
		phy_wlrdy : out std_logic;
		phy_cs    : in  std_logic_vector(cmmd_gear-1 downto 0) := (others => '0');
		phy_sti   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_sto   : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_b     : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		phy_a     : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		phy_cke   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_ras   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cas   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_we    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_odt   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_dmt   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dmi   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dmo   : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqt   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqo   : out std_logic_vector(data_gear*word_size-1 downto 0);
		phy_dqi   : in  std_logic_vector(data_gear*word_size-1 downto 0);
		phy_dqso  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqst  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_dqsi  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		phy_pll   : out std_logic_vector(8-1 downto 0);

		ddr_rst : out std_logic;
		ddr_ck  : out std_logic;
		ddr_cke : out std_logic := '1';
		ddr_cs  : out std_logic := '0';
		ddr_ras : out std_logic;
		ddr_cas : out std_logic;
		ddr_we  : out std_logic;
		ddr_b   : out std_logic_vector(bank_size-1 downto 0);
		ddr_a   : out std_logic_vector(addr_size-1 downto 0);
		ddr_odt : out std_logic;

		ddr_dm  : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dq  : inout std_logic_vector(word_size-1 downto 0);
		ddr_dqs : inout std_logic_vector(word_size/byte_size-1 downto 0));
end;

architecture lscc of ecp5_ddrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(byte_size*data_gear*word_size/word_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(data_gear*word_size/word_size-1 downto 0);
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
			for j in data_gear*word_size/word_size-1 downto 0 loop
				val(i*data_gear*word_size/word_size+j) := dat(j*word_size/byte_size+i);
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

	signal dqsdllb_dqsdel : std_logic;
	signal eclksynca_start : std_logic;
	signal eclksynca_stop : std_logic;
	signal eclksynca_eclk : std_logic;

	signal dqsbufd_rst : std_logic;

	signal wlnxt : std_logic;
	signal wlrdy : std_logic_vector(0 to word_size/byte_size-1);
	signal wlreq : std_logic;
	signal wlr : std_logic;
	signal clkstart_rst : std_logic;

	type wlword_vector is array (natural range <>) of std_logic_vector(8-1 downto 0);
	signal wlpha : wlword_vector(word_size/byte_size-1 downto 0);
	signal xxx : std_logic;
	signal yyy : std_logic;

	attribute hgroup : string;
	attribute pbbox  : string;

	attribute hgroup of clk_start_i : label is "clk_stop";
	attribute pbbox  of clk_start_i : label is "3,2";

begin

	ddr3baphy_i : entity hdl4fpga.ecp5_ddrbaphy
	generic map (
		cmmd_gear => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		phy_sclk => phy_sclk,
		phy_sclk2x => phy_sclk2x,
          
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
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	sdmi <= to_blinevector(sys_dmi);
	sdmt <= to_blinevector(not sys_dmt);
	sdqt <= to_blinevector(not sys_dqt);
	sdqi <= shuffle_dlinevector(sys_dqi);
	ddqi <= to_bytevector(ddr_dq);
	sdqsi <= to_blinevector(sys_dqsi);
	sdqst <= to_blinevector(sys_dqst);

	dqsdll_b : block
		signal lock : std_logic;
		signal uddcntln : std_logic;
		signal dqsdllb_uddcntln : std_logic;
		signal rst : std_logic;
	begin
		process(phy_sclk2x)
		begin
			if rising_edge(phy_sclk2x) then
				rst <= phy_rst; 
			end if;
		end process;

		dqsdllb_i : dqsdllb
		port map (
			rst => rst,
			clk => phy_sclk2x,
			uddcntln => dqsdllb_uddcntln,
			dqsdel => dqsdel,
			lock => lock);

		dqsdllb_dqsdel <= dqsdel;
		process (phy_sclk)
			variable q : std_logic_vector(0 to 4-1);
			variable wlr_edge : std_logic;
		begin
			if rising_edge(phy_sclk) then
				if phy_rst='1' then
					q := (others => '0');
				elsif wlr='1' and wlr_edge='0' then
					q := (others => '0');
				elsif q(0)='0' then
					if lock='1' then
						q := inc(gray(q));
					elsif wlr='1' then
						q := inc(gray(q));
					end if;
				end if;
				wlr_edge := wlr;
			end if;
			uddcntln <= not q(2);
			clkstart_rst <= not q(0);
		end process;

		process (phy_sclk2x)
		begin
			if rising_edge(phy_sclk2x) then
				dqsdllb_uddcntln <= uddcntln;
			end if;
		end process;
	end block;

	clk_start_i : entity hdl4fpga.clk_start
	port map (
		rst  => clkstart_rst,
		sclk => phy_sclk,
		eclk => phy_eclk,
		eclksynca_start => eclksynca_start,
		dqsbufd_rst => dqsbufd_rst);
	eclksynca_stop <= not eclksynca_start;

	dqclk_b : block
		signal dqclk1bar_ff_q : std_logic;
		signal dqclk1bar_ff_d : std_logic;

		attribute pbbox  of dqclk1bar_ff_i : label is "1,1";
		attribute hgroup of dqclk1bar_ff_i : label is "clk_phase1a";
		attribute pbbox  of phase_ff_1_i   : label is "1,1";
		attribute hgroup of phase_ff_1_i   : label is "clk_phase1b";

	begin
		dqclk1bar_ff_d <= not dqclk1bar_ff_q;
		dqclk1bar_ff_i : entity hdl4fpga.aff
		port map(
			ar => dqsbufd_rst,
			clk => yyy,
			d => dqclk1bar_ff_d,
			q => dqclk1bar_ff_q);

		phase_ff_1_i : entity hdl4fpga.ff
		port map(
			clk => phy_sclk,
			d => dqclk1bar_ff_q,
			q => xxx);
	end block;

	eclksynca_i : eclksynca
	port map (
		stop  => eclksynca_stop,
		eclki => phy_eclk,
		eclko => eclksynca_eclk);
	yyy <= eclksynca_eclk after (integer(tcp*2.0)/16.0) * 1 ps;

	process (phy_sclk)
		variable aux : std_logic;
	begin
		if rising_edge(phy_sclk) then
			aux := '1';
			for i in wlrdy'range loop
				aux := aux and wlrdy(i);
			end loop;
			wlr<= aux;
		end if;
	end process;
	sys_wlrdy <= wlr;

	sys_pll <= wlpha(0)(7 downto 7) & xxx & wlpha(0)(5 downto 0);
	wlreq <= sys_wlreq;

	byte_g : for i in 0 to word_size/byte_size-1 generate
		ddr3phy_i : entity hdl4fpga.ecp5_ddrdqphy
		generic map (
			tcp => tcp,
			data_gear => data_gear,
			byte_size => byte_size)
		port map (
			dqsbufd_rst => dqsbufd_rst,
			phy_sclk => phy_sclk,
			phy_sclk2x => phy_sclk2x,
			phy_eclk => phy_eclk,
			phy_eclkw => yyy,
			sys_dqsdel => dqsdllb_dqsdel,
			sys_rw => sys_sti(i*data_gear+0),
			sys_wlreq => wlreq,
			sys_wlrdy => wlrdy(i),
			sys_wlpha => wlpha(i),

			sys_dmt => sdmt(i),
			sys_dmi => sdmi(i),
			sys_dmo => sdmo(i),

			sys_dqi => sdqi(i),
			sys_dqt => sdqt(i),
			sys_dqo => sdqo(i),

			sys_dqso => sdqsi(i),
			sys_dqst => sdqst(i),

			ddr_dqi => ddqi(i),
			ddr_dqt => ddqt(i),
			ddr_dqo => ddqo(i),

--			ddr_dmi => ddr_dm(i),
			ddr_dmt => ddmt(i),
			ddr_dmo => ddmo(i),

			ddr_dqsi => ddr_dqs(i),
			ddr_dqst => ddqst(i),
			ddr_dqso => ddqsi(i));


	end generate;

	sto_i : entity hdl4fpga.align
	generic map (
		n => 2*data_gear,
		d => (0 to 2*data_gear-1 => 3))
	port map (
		clk => phy_sclk,
		di  => sys_sti,
		do  => sys_sto);

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

	sys_dqso <= (others => phy_sclk);
	sys_dmo  <= to_stdlogicvector(sdmo);
	sys_dqo  <= to_stdlogicvector(sdqo);
end;
