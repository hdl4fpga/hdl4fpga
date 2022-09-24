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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.sdram_param.all;

entity xc5v_sdrphy is
	generic (
		taps       : natural;
		gate_delay : natural := 1;
		CMMD_GEAR  : natural := 1;
		data_gear  : natural := 2;
		data_edge  : boolean := true;
		bank_size  : natural := 2;
		addr_size  : natural := 13;
		word_size  : natural := 16;
		byte_size  : natural := 8;
		clkinv     : std_logic := '0');
	port (
		tp        : out std_logic_vector(1 to 32);
		iod_rst   : in  std_logic;
		iod_clk   : in  std_logic;
		clk0      : in  std_logic := '-';
		clk90     : in  std_logic := '-';
		clk0x2    : in  std_logic := '-';
		clk90x2   : in  std_logic := '-';
		phy_rlreq : in  std_logic := '-';
		phy_rlrdy : buffer std_logic;

		phy_frm   : buffer std_logic;
		phy_trdy  : in  std_logic;
		phy_rw    : out std_logic := '1';
		phy_cmd   : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini   : out std_logic;

		sys_rst  : in  std_logic_vector(CMMD_GEAR-1 downto 0) := (others => '1');
		sys_cs   : in  std_logic_vector(CMMD_GEAR-1 downto 0) := (others => '0');
		sys_cke  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		sys_ras  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		sys_cas  : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		sys_we   : in  std_logic_vector(CMMD_GEAR-1 downto 0);
		sys_b    : in  std_logic_vector(CMMD_GEAR*bank_size-1 downto 0);
		sys_a    : in  std_logic_vector(CMMD_GEAR*addr_size-1 downto 0);
		sys_odt  : in  std_logic_vector(CMMD_GEAR-1 downto 0);

		sys_dmt  : in  std_logic_vector(0 to data_gear*word_size/byte_size-1);
		sys_dmi  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dmo  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqi  : in  std_logic_vector(data_gear*word_size-1 downto 0);
		sys_dqo  : out std_logic_vector(data_gear*word_size-1 downto 0);

		sys_dqsi : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqst : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqso : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		sys_sti  : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		sys_sto  : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		sdram_cs  : out std_logic := '0';
		sdram_cke : out std_logic := '1';
		sdram_clk : out std_logic_vector;
		sdram_odt : out std_logic;
		sdram_ras : out std_logic;
		sdram_cas : out std_logic;
		sdram_we  : out std_logic;
		sdram_b   : out std_logic_vector(bank_size-1 downto 0);
		sdram_a   : out std_logic_vector(addr_size-1 downto 0);

		sdram_sti  : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		sdram_sto  : out std_logic_vector(word_size/byte_size-1 downto 0);

		sdram_dmi  : in  std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dmo  : out  std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dmt  : out  std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqt  : out std_logic_vector(word_size-1 downto 0);
		sdram_dqi  : in  std_logic_vector(word_size-1 downto 0);
		sdram_dqo  : out std_logic_vector(word_size-1 downto 0);
		sdram_dqst : out std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqsi : in std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqso : out std_logic_vector(word_size/byte_size-1 downto 0));


end;

library hdl4fpga;
use hdl4fpga.std.all;

library unisim;
use unisim.vcomponents.all;

architecture xc5v of xc5v_sdrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	subtype dline_word is std_logic_vector(data_gear*byte_size-1 downto 0);
	type dline_vector is array (natural range <>) of dline_word;

	subtype bline_word is std_logic_vector(data_gear-1 downto 0);
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

	function shuffle_stdlogicvector (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable dat : std_logic_vector(0 to arg'length-1);
		variable val : std_logic_vector(dat'range);
	begin
		dat := arg;
		for i in word_size/byte_size-1 downto 0 loop
			for j in data_gear-1 downto 0 loop
				val(i*data_gear+j) := dat(j*word_size/byte_size+i);
			end loop;
		end loop;
		return val;
	end;

	function shuffle_dlinevector (
		constant arg : std_logic_vector)
		return dline_vector is
		variable dat : byte_vector(0 to arg'length/byte'length-1);
		variable val : byte_vector(dat'range);
	begin
		dat := to_bytevector(arg);
		for i in word_size/byte_size-1 downto 0 loop
			for j in data_gear-1 downto 0 loop
				val(i*data_gear+j) := dat(j*word_size/byte_size+i);
			end loop;
		end loop;
		return to_dlinevector(to_stdlogicvector(val));
	end;

	function unshuffle(
		constant arg : dline_vector)
		return byte_vector is
		variable val : byte_vector(sys_dqi'length/byte_size-1 downto 0);
		variable aux : byte_vector(0 to data_gear-1);
	begin
		for i in arg'range loop
			aux := to_bytevector(arg(i));
			for j in aux'range loop
				val(j*arg'length+i) := aux(j);
			end loop;
		end loop;
		return val;
	end;

	signal dqsdel : std_logic;
	signal sdmt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi : bline_vector(word_size/byte_size-1 downto 0);
	signal ssti : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt : std_logic_vector(word_size/byte_size-1 downto 0);
	signal dsto : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ssto : bline_vector(word_size/byte_size-1 downto 0);

	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);

	signal dqrst : std_logic;
	signal ph : std_logic_vector(0 to 6-1);

	signal rl_req     : std_logic_vector(sdram_dqsi'range);
	signal rl_rdy     : std_logic_vector(rl_req'range);
	signal wr_req     : std_logic_vector(sdram_dqsi'range);
	signal wr_rdy     : std_logic_vector(rl_req'range);
	signal rd_req     : std_logic_vector(sdram_dqsi'range);
	signal rd_rdy     : std_logic_vector(rd_req'range);
	signal read_req   : bit;
	signal read_rdy   : bit;
	signal read_brst  : std_logic_vector(rd_req'range);
	signal write_req  : bit;
	signal write_rdy  : bit;
	signal ddrphy_b   : std_logic_vector(sys_b'range);
	signal ddrphy_a   : std_logic_vector(sys_a'range);

begin

	sdram_clk_g : for i in sdram_clk'range generate
		ck_i : oddr
		port map (
			c => clk0,
			ce => '1',
			d1 => '0' xor clkinv,
			d2 => '1' xor clkinv,
			q  => sdram_clk(i));
	end generate;

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal sdram_act  : std_logic;
		signal sdram_idle : std_logic;

	begin

		ddrphy_b <= sys_b when leveling='0' else (others => '0');
		ddrphy_a <= sys_a when leveling='0' else (others => '0');

		process (phy_trdy, clk0)
			variable s_pre : std_logic;
		begin
			if rising_edge(clk0) then
				if phy_trdy='1' then
					sdram_idle <= s_pre;
					case phy_cmd is
					when mpu_pre =>
						sdram_act <= '0';
						s_pre := '1';
					when mpu_act =>
						sdram_act <= '1';
						s_pre := '0';
					when others =>
						sdram_act <= '0';
						s_pre := '0';
					end case;
				end if;
			end if;
		end process;

		readcycle_p : process (clk0, rd_rdy)
			type states is (s_idle, s_start, s_run);
			variable state : states;
			variable burst : std_logic;
		begin
			if rising_edge(clk0) then
				case state is
				when s_start =>
					phy_frm  <= '1';
					leveling <= '1';
					if sdram_act='1' then
						if burst='0' then
							phy_frm <= '0';
						end if;
						state   := s_run;
					end if;
				when s_run =>
					if sdram_idle='1' then
						leveling  <= '0';
						rd_rdy    <= rd_req;
						wr_rdy    <= wr_req;
						read_rdy  <= read_req;
						write_rdy <= write_req;
						state    := s_idle;
					end if;
					if burst='0' then
						phy_frm <= '0';
					end if;
				when s_idle =>
					leveling <= '0';
					phy_frm  <= '0';
					if (read_req xor read_rdy)='1' then
						phy_frm  <= '1';
						phy_rw   <= '1';
						leveling <= '1';
						state    := s_start;
					elsif (write_req xor write_rdy)='1' then
						phy_frm  <= '1';
						phy_rw   <= '0';
						leveling <= '1';
						state    := s_start;
					end if;
				end case;

				if read_brst=(read_brst'range  => '0') then
					burst := '0';
				else
					burst := '1';
				end if;

				if (read_req xor read_rdy)='0' then
					if to_bitvector(rd_req) = not to_bitvector(rd_rdy) then
						read_req <= not read_rdy;
					end if;
				end if;

				if (write_req xor write_rdy)='0' then
					if to_bitvector(wr_req) = not to_bitvector(wr_rdy) then
						write_req <= not write_rdy;
					end if;
				end if;

			end if;
		end process;

		process (iod_rst, clk0)
			variable z : std_logic;
		begin
			if rising_edge(clk0) then
				if iod_rst='1' then
					phy_ini <= '0';
					phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
				elsif (to_bit(phy_rlrdy) xor to_bit(phy_rlreq))='1' then
					if z='0' then
						phy_ini   <= '1';
						phy_rlrdy <= phy_rlreq;
					end if;
					z := '0';
					for i in rl_req'reverse_range loop
						if (to_bit(phy_rlreq) xor to_bit(rl_rdy(i)))='1' then
							z := '1';
							rl_req(i) <= phy_rlreq;
						end if;
					end loop;
				end if;
			end if;
		end process;

	end block;

	sdrbaphy_i : entity hdl4fpga.xc5v_sdrbaphy
	generic map (
		GEAR      => CMMD_GEAR,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		phy_rst => iod_rst,
		sys_clks(0) => clk0,
		sys_clks(1) => clk90,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,

		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	sdmi  <= to_blinevector(shuffle_stdlogicvector(sys_dmi));
	ssti  <= to_blinevector(sys_sti);
	sdmt  <= to_blinevector(not sys_dmt);
	sdqt  <= to_blinevector(not sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqi);
	ddqi  <= to_bytevector(sdram_dqi);
	sdqsi <= to_blinevector(sys_dqsi);
	sdqst <= to_blinevector(sys_dqst);

	byte_g : for i in sdram_dqsi'range  generate
		signal tp_byte : std_logic_vector(tp'range);
	begin

		tp_g : if i=0 generate
			tp <= tp_byte;
		end generate;

		sdrdqphy_i : entity hdl4fpga.xc5v_sdrdqphy
		generic map (
			taps      => taps,
			data_edge => data_edge,
			data_gear => data_gear,
			byte_size => byte_size)
		port map (
			tp        => tp_byte,
			iod_rst   => iod_rst,
			sys_rlreq => rl_req(i),
			sys_rlrdy => rl_rdy(i),
			read_req  => rd_req(i),
			read_rdy  => rd_rdy(i),
			read_brst => read_brst(i),
			write_req => wr_req(i),
			write_rdy => wr_rdy(i),
			iod_clk   => iod_clk,
			clk0      => clk0,
			clk90     => clk90,
			clk0x2    => clk0x2,
			clk90x2   => clk90x2,
			sys_sto   => ssto(i),
			sys_sti   => ssti(i),
			sys_dmt   => sdmt(i),
			sys_dmi   => sdmi(i),

			sys_dqi   => sdqi(i),
			sys_dqt   => sdqt(i),
			sys_dqo   => sdqo(i),

			sys_dqsi  => sdqsi(i),
			sys_dqst  => sdqst(i),

			sdram_dqi   => ddqi(i),
			sdram_dqt   => ddqt(i),
			sdram_dqo   => ddqo(i),
			sdram_sto   => sdram_sto(i),

			sdram_dmt   => ddmt(i),
			sdram_dmo   => ddmo(i),

			sdram_dqst  => sdram_dqst(i),
			sdram_dqsi  => sdram_dqsi(i),
			sdram_dqso  => sdram_dqso(i));


		sys_sto((i+1)*data_gear-1 downto i*data_gear) <= ssto(i);
	end generate;
	sys_dqso <= (others => clk0);

--	process(sdram_dmi, sdram_sti)
--	begin
--		for i in 0 to word_size/byte_size-1 loop
--			for j in 0 to data_gear-1 loop
--				if loopback then
--					sys_sto(data_gear*i+j) <= sdram_sti(i);
--				else
--					sys_sto(data_gear*i+j) <= sdram_dmi(i);
--				end if;
--			end loop;
--		end loop;
--	end process;

	sdram_dmt <= ddmt;
	sdram_dmo <= ddmo;
	sdram_dqt <= to_stdlogicvector(ddqt);
	sdram_dqo <= to_stdlogicvector(ddqo);

	sys_dqo <= to_stdlogicvector(sdqo);
end;
