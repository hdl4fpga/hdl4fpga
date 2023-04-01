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

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;

entity ecp3_sdrphy is
	generic (
		taps      : natural := 0;
		gear : natural := 4;
		bank_size : natural := 2;
		addr_size : natural := 13;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		rst       : in  std_logic;

		sclk      : in  std_logic;
		sclk2x    : in  std_logic;
		eclk      : in  std_logic;
		dqsdel    : in  std_logic;
		locked    : out std_logic_vector(word_size/byte_size-1 downto 0);

		phy_rst   : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_frm   : buffer std_logic;
		phy_trdy  : in  std_logic;
		phy_rw    : out std_logic := '1';
		phy_cmd   : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini   : out std_logic;
		phy_wlreq : in  std_logic;
		phy_wlrdy : buffer std_logic;
		phy_rlreq : in  std_logic := '0';
		phy_rlrdy : buffer std_logic;
		phy_cs    : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '0');
		phy_sti   : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_sto   : buffer std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_b     : in  std_logic_vector((gear+1)/2*bank_size-1 downto 0);
		phy_a     : in  std_logic_vector((gear+1)/2*addr_size-1 downto 0);
		phy_cke   : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_ras   : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_cas   : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_we    : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_odt   : in  std_logic_vector((gear+1)/2-1 downto 0);
		phy_dmi   : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dmo   : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dqt   : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dqo   : out std_logic_vector(gear*word_size-1 downto 0);
		phy_dqi   : in  std_logic_vector(gear*word_size-1 downto 0);
		phy_dqso  : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dqst  : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dqsi  : in  std_logic_vector(gear*word_size/byte_size-1 downto 0) := (others => '-');

		sdr_rst   : out std_logic;
		sdr_ck    : out std_logic;
		sdr_cke   : out std_logic := '1';
		sdr_cs    : out std_logic := '0';
		sdr_ras   : out std_logic;
		sdr_cas   : out std_logic;
		sdr_we    : out std_logic;
		sdr_b     : out std_logic_vector(bank_size-1 downto 0);
		sdr_a     : out std_logic_vector(addr_size-1 downto 0);
		sdr_odt   : out std_logic;

		sdr_dm    : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdr_dq    : inout std_logic_vector(word_size-1 downto 0);
		sdr_dqs   : inout std_logic_vector(word_size/byte_size-1 downto 0));
end;

architecture ecp3 of ecp3_sdrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(byte_size*gear*word_size/word_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(gear*word_size/word_size-1 downto 0);
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
			for j in gear*word_size/word_size-1 downto 0 loop
				val(i*gear*word_size/word_size+j) := dat(j*word_size/byte_size+i);
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
--			for j in gear*word_size/word_size-1 downto 0 loop
--				val(i*gear*word_size/word_size+j) := dat(j*word_size/byte_size+i);
--			end loop;
--		end loop;
--		return to_dlinevector(to_stdlogicvector(val));
--	end;

	signal sdmi      : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmo      : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt      : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi      : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo      : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi     : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst     : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt      : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqst     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqsi     : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddqi      : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt      : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo      : byte_vector(word_size/byte_size-1 downto 0);

	signal ddrdel    : std_logic;

	signal rl_req    : std_logic_vector(sdr_dqs'range);
	signal rl_rdy    : std_logic_vector(sdr_dqs'range);
	signal wl_rdy    : std_logic_vector(0 to word_size/byte_size-1);

	signal ddrphy_b  : std_logic_vector(phy_b'range);
	signal ddrphy_a  : std_logic_vector(phy_a'range);
	signal ms_pause  : std_logic;

	signal read_req  : std_logic_vector(sdr_dqs'range);
	signal read_rdy  : std_logic_vector(sdr_dqs'range);

begin

	sdr3baphy_i : entity hdl4fpga.ecp3_sdrbaphy
	generic map (
		cmmd_gear => (gear+1)/2,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sclk    => sclk,
		sclk2x  => sclk2x,
          
		phy_rst => phy_rst,
		phy_cs  => phy_cs,
		phy_cke => phy_cke,
		phy_b   => ddrphy_b,
		phy_a   => ddrphy_a,
		phy_ras => phy_ras,
		phy_cas => phy_cas,
		phy_we  => phy_we,
		phy_odt => phy_odt,
        
		sdr_rst => sdr_rst,
		sdr_ck  => sdr_ck,
		sdr_cke => sdr_cke,
		sdr_odt => sdr_odt,
		sdr_cs  => sdr_cs,
		sdr_ras => sdr_ras,
		sdr_cas => sdr_cas,
		sdr_we  => sdr_we,
		sdr_b   => sdr_b,
		sdr_a   => sdr_a);

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal sdr_act  : std_logic;
		signal sdr_idle : std_logic;

	begin

		ddrphy_b <= phy_b when leveling='0' else (others => '0');
		ddrphy_a <= phy_a when leveling='0' else (others => '0');

		process (phy_trdy, sclk)
			variable s_pre : std_logic;
		begin
			if rising_edge(sclk) then
				if phy_trdy='1' then
					sdr_idle <= s_pre;
					case phy_cmd is
					when mpu_pre =>
						sdr_act <= '0';
						s_pre := '1';
					when mpu_act =>
						sdr_act <= '1';
						s_pre := '0';
					when others =>
						sdr_act <= '0';
						s_pre := '0';
					end case;
				end if;
			end if;
		end process;

		readcycle_p : process (sclk, read_rdy)
			type states is (s_idle, s_start, s_stop);
			variable state : states;
			variable z     : std_logic;
		begin
			if rising_edge(sclk) then
				z := '0';
				for i in read_req'reverse_range loop
					if (to_bit(read_req(i)) xor to_bit(read_rdy(i)))='1' then
						z := '1';
					end if;
				end loop;

				case state is
				when s_start =>
					phy_frm  <= '1';
					leveling <= '1';
					if sdr_act='1' then
						phy_frm <= '0';
						state   := s_stop;
					end if;
				when s_stop =>
					if sdr_idle='1' then
						phy_frm  <= '0';
						leveling <= '0';
						read_rdy <= read_req;
						state    := s_idle;
					end if;
				when s_idle =>
					leveling <= '0';
					phy_frm  <= '0';
					if z='1' then
						phy_frm  <= '1';
						leveling <= '1';
						state := s_start;
					end if;
				end case;
				phy_rw <= '1';

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

	process (phy_wlreq, wl_rdy)
		variable z : std_logic;
	begin
		z := '1';
		for i in wl_rdy'range loop
			z := z and (wl_rdy(i) xor to_stdulogic(to_bit(phy_wlreq)));
		end loop;
		phy_wlrdy <= z xor to_stdulogic(to_bit(phy_wlreq));
	end process;

	sdmi  <= to_blinevector(phy_dmi);
	sdqt  <= to_blinevector(not phy_dqt);
	sdqi  <= shuffle_dlinevector(phy_dqi);
	ddqi  <= to_bytevector(sdr_dq);
	sdqsi <= to_blinevector(phy_dqsi);
	sdqst <= to_blinevector(phy_dqst);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		signal sto : std_logic;
	begin
		phy_sto(gear*(i+1)-1 downto gear*i) <= (others => sto);
		sdr3phy_i : entity hdl4fpga.ecp3_sdrdqphy
		generic map (
			taps      => taps,
			data_gear => gear,
			byte_size => byte_size)
		port map (
			rst       => rst,
			sclk      => sclk,
			eclk      => eclk,
			dqsdel    => dqsdel,

			pause     => ms_pause,
			locked    => locked(i),
			read_req  => read_req(i),
			read_rdy  => read_rdy(i),
			phy_wlreq => phy_wlreq,
			phy_wlrdy => wl_rdy(i),
			phy_rlreq => rl_req(i),
			phy_rlrdy => rl_rdy(i),

			phy_sti   => phy_sti(0),
			phy_sto   => sto,
			phy_dmi   => sdmi(i),
			phy_dmo   => sdmo(i),
			phy_dqi   => sdqi(i),
			phy_dqt   => sdqt(i),
			phy_dqo   => sdqo(i),
			phy_dqso  => sdqsi(i),
			phy_dqst  => sdqst(i),

			sdr_dqi   => ddqi(i),
			sdr_dqt   => ddqt(i),
			sdr_dqo   => ddqo(i),

			sdr_dmi   => sdr_dm(i),
			sdr_dmt   => ddmt(i),
			sdr_dmo   => ddmo(i),

			sdr_dqsi  => sdr_dqs(i),
			sdr_dqst  => ddqst(i),
			sdr_dqso  => ddqsi(i));
	end generate;

	process (ddqsi, ddqst)
	begin
		for i in ddqsi'range loop
			if ddqst(i)='1' then
				sdr_dqs(i) <= 'Z';
			else
				sdr_dqs(i) <= ddqsi(i);
			end if;
		end loop;
	end process;

	process (ddqo, ddqt)
		variable dqt : std_logic_vector(sdr_dq'range);
		variable dqo : std_logic_vector(sdr_dq'range);
	begin
		dqt := to_stdlogicvector(ddqt);
		dqo := to_stdlogicvector(ddqo);
		for i in dqo'range loop
			if dqt(i)='0' then
				sdr_dq(i) <= 'Z';
			else
				sdr_dq(i) <= dqo(i);
			end if;
		end loop;
	end process;

	process (ddmo, ddmt)
	begin
		for i in ddmo'range loop
			if ddmt(i)='0' then
				sdr_dm(i) <= 'Z';
			else
				sdr_dm(i) <= ddmo(i);
			end if;
		end loop;
	end process;

	phy_dqso <= (others => sclk);
	phy_dmo  <= to_stdlogicvector(sdmo);
	phy_dqo  <= to_stdlogicvector(sdqo);
end;
