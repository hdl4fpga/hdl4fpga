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
use ieee.math_real.all;

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

entity ecp5_ddrphy is
	generic (
		ddr_tcp   : real;
		cmmd_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13;
		data_gear : natural := 32;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		rst       : in std_logic;
		sync_clk  : in std_logic;
		clkop     : in std_logic;
		sclk      : buffer std_logic;
		eclk      : buffer std_logic;

		phy_rst   : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_frm   : buffer std_logic;
		phy_trdy  : in  std_logic;
		phy_rw    : out std_logic := '1';
		phy_cmd   : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini   : out std_logic;

		phy_wlreq : in  std_logic := '0';
		phy_wlrdy : buffer std_logic;
		phy_rlreq : in  std_logic := '0';
		phy_rlrdy : buffer std_logic;

		phy_cs    : in  std_logic_vector(cmmd_gear-1 downto 0) := (others => '0');
		phy_sti   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		phy_sto   : buffer std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
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

		ddr_rst   : out std_logic;
		ddr_ck    : out std_logic;
		ddr_cke   : out std_logic := '1';
		ddr_cs    : out std_logic := '0';
		ddr_ras   : out std_logic;
		ddr_cas   : out std_logic;
		ddr_we    : out std_logic;
		ddr_b     : out std_logic_vector(bank_size-1 downto 0);
		ddr_a     : out std_logic_vector(addr_size-1 downto 0);
		ddr_odt   : out std_logic;

		ddr_dm    : inout std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dq    : inout std_logic_vector(word_size-1 downto 0);
		ddr_dqs   : inout std_logic_vector(word_size/byte_size-1 downto 0);
		tp        : out std_logic_vector(1 to 32));
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

--	function unshuffle_dlinevector (
--		constant arg : dline_vector) 
--		return std_logic_vectoris
--		variable dat : byte_vector(arg'length/byte'length-1 downto 0);
--		variable val : byte_vector(dat'range);
--	begin	
--		dat := to_bytevector(arg);
--		for i in word_size/byte_size-1 downto 0 loop
--			for j in data_gear*word_size/word_size-1 downto 0 loop
--				val(i*data_gear*word_size/word_size+j) := dat(j*word_size/byte_size+i);
--			end loop;
--		end loop;
--		return to_dlinevector(to_stdlogicvector(val));
--	end;


	signal sdmt   : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi   : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmo   : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt   : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi   : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo   : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi  : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst  : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo   : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt   : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqst  : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqsi  : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqi   : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt   : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo   : byte_vector(word_size/byte_size-1 downto 0);

	signal ddr_reset  : std_logic;
	signal ddrdel     : std_logic;

	signal rl_req     : std_logic_vector(ddr_dqs'range);
	signal rl_rdy     : std_logic_vector(ddr_dqs'range);
	signal wl_rdy     : std_logic_vector(0 to word_size/byte_size-1);

	signal ddrphy_b   : std_logic_vector(phy_b'range);
	signal ddrphy_a   : std_logic_vector(phy_a'range);
	signal ms_pause   : std_logic;

	signal read_req   : std_logic_vector(ddr_dqs'range);
	signal read_rdy   : std_logic_vector(ddr_dqs'range);

begin

	mem_sync_b : block
		component mem_sync
			port (
				rst       : in  std_logic;
				start_clk : in  std_logic;
				pll_lock  : in  std_logic;
				dll_lock  : in  std_logic;
				update    : in  std_logic;
				pause     : out std_logic;
				stop      : out std_logic;
				freeze    : out std_logic;
				uddcntln  : out std_logic;
				dll_rst   : out std_logic;
				ddr_rst   : out std_logic;
				ready     : out std_logic);
		end component;

		signal uddcntln : std_logic;
		signal freeze   : std_logic;
		signal stop     : std_logic;
		signal dll_rst  : std_logic;
		signal dll_lock : std_logic;
		signal pll_lock : std_logic;
		signal update   : std_logic;

		attribute FREQUENCY_PIN_CDIVX : string;
		attribute FREQUENCY_PIN_CDIVX of clkdivf_i : label is ftoa(1.0e-6/(ddr_tcp*2.0), 10);
	begin

		pll_lock <= '1';
		update   <= '0';

		mem_sync_i : mem_sync
		port map (
			rst => rst,
			start_clk => sync_clk,
			pll_lock  => pll_lock,
			dll_lock  => dll_lock,
			update    => update,
			pause     => ms_pause,
			stop      => stop,
			freeze    => freeze,
			uddcntln  => uddcntln,
			dll_rst   => dll_rst,
			ddr_rst   => ddr_reset,
			ready => open);

		eclksyncb_i : eclksyncb
		port map (
			stop  => stop,
			eclki => clkop,
			eclko => eclk);
	
		clkdivf_i : clkdivf
		port map (
			rst     => ddr_reset,
			alignwd => '0',
			clki    => eclk,
			cdivx   => sclk);
	
		ddrdll_i : ddrdlla
		port map (
			rst      => dll_rst,
			clk      => eclk,
			freeze   => freeze,
			uddcntln => uddcntln,
			ddrdel   => ddrdel,
			lock     => dll_lock);
	end block;

	ddr3baphy_i : entity hdl4fpga.ecp5_ddrbaphy
	generic map (
		cmmd_gear => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		rst     => ddr_reset,
		eclk    => eclk,
		sclk    => sclk,
          
		phy_rst => phy_rst,
		phy_cs  => phy_cs,
		phy_cke => phy_cke,
		phy_b   => ddrphy_b,
		phy_a   => ddrphy_a,
		phy_ras => phy_ras,
		phy_cas => phy_cas,
		phy_we  => phy_we,
		phy_odt => phy_odt,
        
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

	write_leveling_p : process (phy_wlreq, wl_rdy)
		variable aux : bit;
	begin
		aux := '1';
		for i in wl_rdy'range loop
			aux := aux and (to_bit(wl_rdy(i)) xor to_bit(phy_wlreq));
		end loop;
		phy_wlrdy <= to_stdulogic(aux) xor phy_wlreq;
	end process;

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal ddr_act  : std_logic;
		signal ddr_idle : std_logic;

	begin

		ddrphy_b <= phy_b when leveling='0' else (others => '0');
		ddrphy_a <= phy_a when leveling='0' else (others => '0');

		process (phy_trdy, sclk)
			variable s_pre : std_logic;
		begin
			if rising_edge(sclk) then
				if phy_trdy='1' then
					ddr_idle <= s_pre;
					case phy_cmd is
					when mpu_pre =>
						ddr_act <= '0';
						s_pre := '1';
					when mpu_act =>
						ddr_act <= '1';
						s_pre := '0';
					when others =>
						ddr_act <= '0';
						s_pre := '0';
					end case;
				end if;
			end if;
		end process;

		readcycle_p : process (sclk, read_rdy)
			type states is (s_idle, s_start, s_stop);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if rst='1' then
					read_rdy <= to_stdlogicvector(to_bitvector(read_req));
					state := s_idle;
				else
					case state is
					when s_start =>
						phy_frm  <= '1';
						leveling <= '1';
						if ddr_act='1' then
							phy_frm <= '0';
							state   := s_stop;
						end if;
					when s_stop =>
						if ddr_idle='1' then
							phy_frm  <= '0';
							leveling <= '0';
							read_rdy <= to_stdlogicvector(to_bitvector(read_req));
							state    := s_idle;
						end if;
					when s_idle =>
						leveling <= '0';
						phy_frm  <= '0';
						for i in read_req'reverse_range loop
							if (read_rdy(i) xor to_stdulogic(to_bit(read_req(i))))='1' then
								phy_frm  <= '1';
								leveling <= '1';
								state := s_start;
							end if;
						end loop;
					end case;
					phy_rw <= '1';
				end if;
			end if;
		end process;

		process (rst, sclk)
			variable z : std_logic;
		begin
			if rising_edge(sclk) then
				if rst='1' then
					phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
					phy_ini <= '0';
				elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
					z := '1';
					for i in rl_req'reverse_range loop
						if (rl_rdy(i) xor to_stdulogic(to_bit(phy_rlreq)))='1' then
							z := '0';
						end if;
					end loop;
					if z='1' then
						phy_ini   <= '1';
						phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
					end if;
				end if;
			end if;
		end process;
		rl_req <= (others => phy_rlreq);

	end block;

	sdmi  <= to_blinevector(phy_dmi);
	sdmt  <= to_blinevector(not phy_dmt);
	sdqt  <= to_blinevector(not phy_dqt);
	sdqi  <= shuffle_dlinevector(phy_dqi);
	ddqi  <= to_bytevector(ddr_dq);
	sdqsi <= to_blinevector(phy_dqsi);
	sdqst <= to_blinevector(phy_dqst);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		signal sto : std_logic;
		signal tp_dq : std_logic_vector(1 to 32);
	begin
		phy_sto(data_gear*(i+1)-1 downto data_gear*i) <= (others => sto);
		tp_g : if i=0 generate
			tp <= tp_dq;
		end generate;
		ddr3phy_i : entity hdl4fpga.ecp5_ddrdqphy
		generic map (
			taps => natural(floor(ddr_tcp/27.0e-12)),
			data_gear => data_gear,
			byte_size => byte_size)
		port map (
			rst       => ddr_reset,
			sclk      => sclk,
			eclk      => eclk,
			ddrdel    => ddrdel,
			pause     => ms_pause,
			read_req  => read_req(i),
			read_rdy  => read_rdy(i),
			phy_wlreq => phy_wlreq,
			phy_wlrdy => wl_rdy(i),
			phy_rlreq => rl_req(i),
			phy_rlrdy => rl_rdy(i),

			phy_sti   => phy_sti(0),
			phy_sto   => sto,
			phy_dmt   => sdmt(i),
			phy_dmi   => sdmi(i),
			phy_dmo   => sdmo(i),
			phy_dqi   => sdqi(i),
			phy_dqt   => sdqt(i),
			phy_dqo   => sdqo(i),
			phy_dqso  => sdqsi(i),
			phy_dqst  => sdqst(i),

			ddr_dqi   => ddqi(i),
			ddr_dqt   => ddqt(i),
			ddr_dqo   => ddqo(i),

			ddr_dmi   => ddr_dm(i),
			ddr_dmt   => ddmt(i),
			ddr_dmo   => ddmo(i),

			ddr_dqsi  => ddr_dqs(i),
			ddr_dqst  => ddqst(i),
			ddr_dqso  => ddqsi(i),
			tp  => tp_dq);
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

	phy_dqso <= (others => sclk);
	phy_dmo  <= to_stdlogicvector(sdmo);
	phy_dqo  <= to_stdlogicvector(sdqo);
end;
