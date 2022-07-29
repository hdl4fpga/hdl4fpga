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

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

entity xc7a_ddrphy is
	generic (
		taps         : natural;
		cmmd_gear    : natural   :=  1;
		data_edge    : boolean   := false;
		data_gear    : natural   :=  2;
		bank_size    : natural   :=  2;
		addr_size    : natural   := 13;
		word_size    : natural   := 16;
		byte_size    : natural   :=  8;
		clkinv       : std_logic := '0');
	port (
	   	tp_delay     : out std_logic_vector(word_size/byte_size*8-1 downto 0);
		tp_sel       : in  std_logic := '0';
		tp1          : out std_logic_vector(6-1 downto 0);

		rst      : in  std_logic;
		iod_clk      : in  std_logic;
		clk0         : in  std_logic := '-';
		clk90        : in  std_logic := '-';
		clk0x2       : in  std_logic := '-';
		clk90x2      : in  std_logic := '-';

		phy_rsts     : in  std_logic_vector(0 to 3-1) := (others => '1');
		phy_frm      : buffer std_logic;
		phy_trdy     : in  std_logic;
		phy_rw       : out std_logic;
		phy_cmd      : in  std_logic_vector(0 to 3-1);
		phy_ini      : out std_logic;

		phy_wlreq    : in  std_logic;
		phy_wlrdy    : out std_logic;
		phy_rlreq    : in  std_logic;
		phy_rlrdy    : buffer std_logic;

		sys_rst      : in  std_logic_vector(0 to cmmd_gear-1) := (others => '-');
		sys_cke      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_cs       : in  std_logic_vector(0 to cmmd_gear-1) := (others => '0');
		sys_ras      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_cas      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_we       : in  std_logic_vector(0 to cmmd_gear-1);
		sys_ba       : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		sys_a        : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		sys_odt      : in  std_logic_vector(0 to cmmd_gear-1);

		sys_dmt      : in  std_logic_vector(0 to data_gear*word_size/byte_size-1);
		sys_dmi      : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dmo      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqt      : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqi      : in  std_logic_vector(data_gear*word_size-1 downto 0);
		sys_dqo      : out std_logic_vector(data_gear*word_size-1 downto 0);

		sys_dqso     : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqst     : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_sti      : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		sys_sto      : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		ddr_rst      : out std_logic := '0';
		ddr_cs       : out std_logic := '0';
		ddr_cke      : out std_logic := '1';
		ddr_clk      : out std_logic_vector;
		ddr_odt      : out std_logic;
		ddr_ras      : out std_logic;
		ddr_cas      : out std_logic;
		ddr_we       : out std_logic;
		ddr_b        : out std_logic_vector(bank_size-1 downto 0);
		ddr_a        : out std_logic_vector(addr_size-1 downto 0);

		ddr_dm       : inout std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqt      : out std_logic_vector(word_size-1 downto 0);
		ddr_dqi      : in  std_logic_vector(word_size-1 downto 0);
		ddr_dqo      : out std_logic_vector(word_size-1 downto 0);
		ddr_dqst     : out std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqsi     : in  std_logic_vector(word_size/byte_size-1 downto 0);
		ddr_dqso     : out std_logic_vector(word_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.std.all;

library unisim;
use unisim.vcomponents.all;

architecture virtex7 of xc7a_ddrphy is


	subtype tapsw is std_logic_vector(6-1 downto 0);
	type tapsw_vector is array (natural range <>) of tapsw;

	function to_stdlogicvector (
		constant arg : tapsw_vector)
		return std_logic_vector is
		variable dat : tapsw_vector(arg'length-1 downto 0);
		variable val : std_logic_vector(arg'length*arg(arg'left)'length-1 downto 0);
	begin
		dat := arg;
		for i in dat'range loop
			val := std_logic_vector(unsigned(val) sll arg(arg'left)'length);
			val(arg(arg'left)'range) := dat(i);
		end loop;
		return val;
	end;

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

	impure function unshuffle(
		constant arg : dline_vector)
		return byte_vector is
		variable val : byte_vector(sys_dqo'length/byte_size-1 downto 0);
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

	signal sdmt      : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi      : bline_vector(word_size/byte_size-1 downto 0);
	signal ssti      : bline_vector(word_size/byte_size-1 downto 0);
	signal ssto      : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt      : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi      : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo      : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi     : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst     : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo      : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt      : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqi      : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt      : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo      : byte_vector(word_size/byte_size-1 downto 0);

	signal wl_rdy    : std_logic_vector(ddr_dqsi'range);
	signal rl_req    : std_logic_vector(ddr_dqsi'range);
	signal rl_rdy    : std_logic_vector(ddr_dqsi'range);
	signal wr_req    : std_logic_vector(ddr_dqsi'range);
	signal wr_rdy    : std_logic_vector(rl_req'range);
	signal rd_req    : std_logic_vector(ddr_dqsi'range);
	signal rd_rdy    : std_logic_vector(rd_req'range);

	signal read_brst : std_logic_vector(rd_req'range);
	signal write_req : std_logic;
	signal write_rdy : std_logic;
	signal read_req  : std_logic_vector(ddr_dqsi'range);
	signal read_rdy  : std_logic_vector(ddr_dqsi'range);

	signal ddrphy_ba : std_logic_vector(sys_ba'range);
	signal ddrphy_a  : std_logic_vector(sys_a'range);

	signal leveling  : std_logic;
	signal dqsdly    : std_logic_vector(2*6-1 downto 0);
	signal dqidly    : std_logic_vector(2*6-1 downto 0);

begin

	ddr_clk_g : for i in ddr_clk'range generate
		ck_i : entity hdl4fpga.ddro
		port map (
			clk => clk0x2,
			dr => '0' xor clkinv,
			df => '1' xor clkinv,
			q  => ddr_clk(i));
	end generate;

	ddrbaphy_i : entity hdl4fpga.xc7a_ddrbaphy
	generic map (
		data_edge => "same_edge",
		gear      => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		clk0    => clk0,
     	rst     => rst,
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => ddrphy_ba,
		sys_a   => ddrphy_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,

		ddr_rst => ddr_rst,
		ddr_cke => ddr_cke,
		ddr_odt => ddr_odt,
		ddr_cs  => ddr_cs,
		ddr_ras => ddr_ras,
		ddr_cas => ddr_cas,
		ddr_we  => ddr_we,
		ddr_b   => ddr_b,
		ddr_a   => ddr_a);

	write_leveling_p : process (phy_wlreq, wl_rdy)
		variable z : std_logic;
	begin
		z := '0';
		for i in wl_rdy'range loop
			z := z and (wl_rdy(i) xor phy_wlreq);
		end loop;
		phy_wlrdy <= z;
	end process;

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal ddr_act  : std_logic;
		signal ddr_idle : std_logic;

	begin

		ddrphy_ba <= sys_ba when leveling='0' else (others => '0');
		ddrphy_a  <= sys_a  when leveling='0' else (others => '0');

		process (phy_trdy, clk0)
			variable s_pre : std_logic;
		begin
			if rising_edge(clk0) then
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

		readcycle_p : process (clk0, rd_rdy)
			type states is (s_idle, s_start, s_run);
			variable state : states;
			variable burst : std_logic;
			variable z     : std_logic;
		begin
			if rising_edge(clk0) then

				case state is
				when s_start =>
					phy_frm  <= '1';
					leveling <= '1';
					if ddr_act='1' then
						if burst='0' then
							phy_frm <= '0';
						end if;
						state   := s_run;
					end if;
				when s_run =>
					if ddr_idle='1' then
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

					z := '0';
					for i in read_req'reverse_range loop
						if (read_rdy(i) xor to_stdulogic(to_bit(read_req(i))))='1' then
							z := '1';
						end if;
					end loop;

					if z='1' then
						phy_frm  <= '1';
						phy_rw   <= '1';
						leveling <= '1';
						state    := s_start;
					elsif (write_rdy xor to_stdulogic(to_bit(write_req)))='1' then
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

				if (write_rdy xor to_stdulogic(to_bit(write_req)))='0' then
					if wr_rdy = not to_stdlogicvector(to_bitvector(wr_req)) then
						write_req <= not write_rdy;
					end if;
				end if;

			end if;
		end process;

		process (rst, clk0)
			variable z : std_logic;
		begin
			if rising_edge(clk0) then
				if rst='1' then
					phy_ini <= '0';
					phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
				elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
					z := '0';
					for i in rl_req'range loop
						if (phy_rlreq xor to_stdulogic(to_bit(rl_rdy(i))))='1' then
							z := '1';
							rl_req(i) <= phy_rlreq;
						end if;
					end loop;
					if z='0' then
						phy_ini   <= '1';
						phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
					end if;
				end if;
			end if;
		end process;

	end block;

	sdmi  <= to_blinevector(shuffle_stdlogicvector(sys_dmi));
	ssti  <= to_blinevector(sys_sti);
	sdmt  <= to_blinevector(not sys_dmt);
	sdqt  <= to_blinevector(not sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqi);
	ddqi  <= to_bytevector(ddr_dqi);
	sdqsi <= to_blinevector(sys_dqso);
	sdqst <= to_blinevector(sys_dqst);

	byte_g : for i in ddr_dqsi'range generate
		ddrdqphy_i : entity hdl4fpga.xc7a_ddrdqphy
		generic map (
			taps       => taps,
			data_gear  => data_gear,
			data_edge  => data_edge,
			byte_size  => byte_size)
		port map (
			tp_sel     => tp_sel,
			tp_delay   => tp_delay(8*(i+1)-1 downto 8*i),

			rst        => rst,
			iod_clk    => iod_clk,
			clk0       => clk0,
			clk90      => clk90,
			clk0x2     => clk0x2,
			clk90x2    => clk90x2,
			sys_wlreq  => phy_wlreq,
			sys_wlrdy  => wl_rdy(i),
			sys_rlreq  => rl_req(i),
			sys_rlrdy  => rl_rdy(i),
			write_req  => wr_req(i),
			write_rdy  => wr_rdy(i),
			read_req   => read_req(i),
			read_rdy   => read_rdy(i),
			read_brst  => read_brst(i),

			sys_sti    => ssti(i),
			sys_dmt    => sdmt(i),
			sys_dmi    => sdmi(i),

			sys_dqi    => sdqi(i),
			sys_dqt    => sdqt(i),
			sys_dqo    => sdqo(i),

			sys_dqso   => sdqsi(i),
			sys_dqst   => sdqst(i),

			sys_sto    => ssto(i),

			ddr_dqsi   => ddr_dqsi(i),
			ddr_dqi    => ddqi(i),
			ddr_dqt    => ddqt(i),
			ddr_dqo    => ddqo(i),

			ddr_dmt    => ddmt(i),
			ddr_dmo    => ddmo(i),

			ddr_dqst   => ddr_dqst(i),
			ddr_dqso   => ddr_dqso(i));

		sys_sto((i+1)*data_gear-1 downto i*data_gear) <= ssto(i);
	end generate;

	ddr_dqt <= to_stdlogicvector(ddqt);
	ddr_dqo <= to_stdlogicvector(ddqo);

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

	sys_dqo <= to_stdlogicvector(sdqo);
end;
