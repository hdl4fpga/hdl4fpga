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

		sys_clks     : in  std_logic_vector(0 to 5-1);
		phy_rsts     : in  std_logic_vector(0 to 3-1) := (others => '1');

		phy_ini      : buffer std_logic;
		phy_rw       : buffer std_logic;
		phy_frm      : buffer std_logic;
		phy_trdy     : in  std_logic;

		sys_cmd      : in  std_logic_vector(0 to 3-1);
		sys_wlreq    : in  std_logic;
		sys_wlrdy    : out std_logic;
		sys_rlreq    : in  std_logic;
		sys_rlrdy    : buffer std_logic;
		sys_rlcal    : buffer std_logic;
		sys_rlseq    : in  std_logic;

		sys_rst      : in  std_logic_vector(0 to cmmd_gear-1) := (others => '-');
		sys_cke      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_cs       : in  std_logic_vector(0 to cmmd_gear-1) := (others => '0');
		sys_ras      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_cas      : in  std_logic_vector(0 to cmmd_gear-1);
		sys_we       : in  std_logic_vector(0 to cmmd_gear-1);
		sys_b        : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
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

		constant clk0div  : natural := 0;
		constant clk90div : natural := 1;
		constant iodclk   : natural := 2;
		constant clk0     : natural := 3;
		constant clk90    : natural := 4;

		constant rst0div  : natural := 0;
		constant rst90div : natural := 1;
		constant rstiod   : natural := 2;
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

	signal sdmt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi : bline_vector(word_size/byte_size-1 downto 0);
	signal ssti : bline_vector(word_size/byte_size-1 downto 0);
	signal ssto : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst : bline_vector(word_size/byte_size-1 downto 0);

	signal ddmo : std_logic_vector(word_size/byte_size-1 downto 0);
	signal ddmt : std_logic_vector(word_size/byte_size-1 downto 0);

	signal ddqi : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqt : byte_vector(word_size/byte_size-1 downto 0);
	signal ddqo : byte_vector(word_size/byte_size-1 downto 0);
	signal byte_rlrdy : std_logic_vector(ddr_dqsi'range);
	signal byte_rlcal : std_logic_vector(ddr_dqsi'range);

	signal phy_ba : std_logic_vector(sys_b'range);
	signal phy_a  : std_logic_vector(sys_a'range);
	signal ba_ras : std_logic_vector(sys_ras'range);
	signal ba_cas : std_logic_vector(sys_cas'range);
	signal ba_we  : std_logic_vector(sys_we'range);
	signal rotba  : unsigned(0 to unsigned_num_bits(cmmd_gear-1)-1);

	signal wlrdy  : std_logic_vector(0 to word_size/byte_size-1);
	signal rlrdy  : std_logic;
	signal level  : std_logic;
	signal dqsdly : std_logic_vector(2*6-1 downto 0);
	signal dqidly : std_logic_vector(2*6-1 downto 0);
begin
	ddr_clk_g : for i in ddr_clk'range generate
		ck_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk0),
			dr => '0' xor clkinv,
			df => '1' xor clkinv,
			q  => ddr_clk(i));
	end generate;


	phy_ba  <= sys_b when level='0' else (others => '0');
	phy_a   <= sys_a when level='0' else (others => '0');

	read_leveling_l_b : block
		signal write_req : std_logic;
		signal write_rdy : std_logic;
		signal read_req  : std_logic;
		signal read_rdy  : std_logic;
		signal leveled   : std_logic;
	begin
		process (sys_clks(clk0div))
			variable ddr_idle : std_logic;
		begin
			if rising_edge(sys_clks(clk0div)) then
				if phy_rsts(clk0div)='1' then
					phy_ini   <= '0';
					phy_frm   <= '0';
					phy_rw    <= '0';
					level     <= '0';
					ddr_idle  := '0';
					read_req  <= '0';
					write_req <= '0';
				else
					if (write_req xor write_rdy)='1'  then
						phy_ini  <= '0';
						phy_frm  <= '1';
						phy_rw   <= '0';
						level    <= '1';
						if sys_cmd=mpu_act and phy_trdy='1' then
							phy_frm   <= '0';
							write_req <= write_rdy;
						end if;
					end if;

					if phy_ini='1' then
						phy_frm  <= '0';
						phy_rw   <= '-';
						phy_ini  <= '1';
						level    <= '0';
						read_req <= read_rdy;
					elsif leveled='1' then
						if (ddr_idle and phy_trdy)='1' then
							phy_ini  <= '1';
						elsif sys_cmd=mpu_pre and phy_trdy='1' then
							phy_ini  <= '0';
						end if;
						phy_frm <= '0';
						phy_rw  <= '1';
						level   <= '1';
					elsif (read_req xor read_rdy)='1' then
						if leveled='1' then
							phy_ini <= '1';
							phy_frm <= '0';
						elsif ddr_idle='1'  and phy_trdy='1' then
							phy_ini <= '0';
							phy_frm <= '1';
						end if;
						phy_rw   <= '1';
						level    <= '1';
					end if;

					if phy_trdy='1' then
						if sys_cmd=mpu_pre then
							ddr_idle := '1';
						else
							ddr_idle := '0';
						end if;
					end if;
				end if;
			end if;
		end process;

		process (sys_clks(iodclk))
			type states is (s_write, s_read);
			variable state : states;
		begin
			if rising_edge(sys_clks(iodclk)) then
				if phy_rsts(rstiod)='1' then
					tp1       <= (others => '0');
					read_rdy  <= '0';
					write_rdy <= '0';
					leveled   <= '0';
					state     := s_write;
				else
					case state is
					when s_write =>
						if sys_rlreq='1' then
							write_rdy <= not write_req;
							state     := s_read;
						end if;
					when s_read =>
						if (write_rdy xor write_req)='0' then
							read_rdy <= not read_req;
						end if;
					end case;
					if (sys_rlrdy and sys_rlcal)='1' then
						leveled <= '1';
					end if;
				end if;

				tp1(2) <= sys_rlcal;
				tp1(3) <= phy_rw;
				tp1(4) <= sys_rlrdy;
				tp1(5) <= level;
			end if;
		end process;
	end block;

	process (sys_clks(iodclk))
		variable aux : std_logic;
	begin
		if rising_edge(sys_clks(iodclk)) then
			aux := '1';
			for i in wlrdy'range loop
				aux := aux and wlrdy(i);
			end loop;
			sys_wlrdy <= aux;
		end if;
	end process;

	rotcmmd_g : if cmmd_gear > 1 generate
		process (sys_clks(clk0div))
		begin
			if rising_edge(sys_clks(clk0div)) then
				if sys_rlcal='0' then
					rotba <= (others => '0');
				elsif phy_ini='1' then
					rotba <= (others => '0');
				elsif sys_rlseq='1' then
					rotba <= rotba + 1;
				end if;
			end if;
		end process;

		rotras_i : entity hdl4fpga.barrel
		port map (
			shf => std_logic_vector(rotba),
			di  => sys_ras,
			do => ba_ras);

		rotcas_i : entity hdl4fpga.barrel
		port map (
			shf => std_logic_vector(rotba),
			di => sys_cas,
			do => ba_cas);

		rotwe_i : entity hdl4fpga.barrel
		port map (
			shf => std_logic_vector(rotba),
			di  => sys_we,
			do  => ba_we);
	end generate;

	dircmmd_g : if cmmd_gear=1 generate
		ba_ras <= sys_ras;
		ba_cas <= sys_cas;
		ba_we  <= sys_we;
	end generate;

	ddrbaphy_i : entity hdl4fpga.xc7a_ddrbaphy
	generic map (
		data_edge => "same_edge",
		gear      => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clks(0) => sys_clks(clk0div),
		sys_clks(1) => sys_clks(clk0),
     	phy_rst    => phy_rsts(rst0div),
		sys_rst    => sys_rst,
		sys_cs     => sys_cs,
		sys_cke    => sys_cke,
		sys_b      => phy_ba,
		sys_a      => phy_a,
		sys_ras    => ba_ras,
		sys_cas    => ba_cas,
		sys_we     => ba_we,
		sys_odt    => sys_odt,

		ddr_rst    => ddr_rst,
		ddr_cke    => ddr_cke,
		ddr_odt    => ddr_odt,
		ddr_cs     => ddr_cs,
		ddr_ras    => ddr_ras,
		ddr_cas    => ddr_cas,
		ddr_we     => ddr_we,
		ddr_b      => ddr_b,
		ddr_a      => ddr_a);

	sdmi  <= to_blinevector(shuffle_stdlogicvector(sys_dmi));
	ssti  <= to_blinevector(sys_sti);
	sdmt  <= to_blinevector(not sys_dmt);
	sdqt  <= to_blinevector(not sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqi);
	ddqi  <= to_bytevector(ddr_dqi);
	sdqsi <= to_blinevector(sys_dqso);
	sdqst <= to_blinevector(sys_dqst);

	process (sys_clks(iodclk))
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sys_clks(iodclk)) then
			for i in byte_rlcal'range loop
				aux := aux and byte_rlcal(i);
			end loop;
			sys_rlcal <= aux and not sys_rlrdy;
		end if;
	end process;

	process (sys_clks(iodclk))
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sys_clks(iodclk)) then
			for i in byte_rlrdy'range loop
				aux := aux and byte_rlrdy(i);
			end loop;
			sys_rlrdy <= aux;
		end if;
	end process;

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
			sys_clks   => sys_clks,
			sys_rsts   => phy_rsts,
			sys_wlreq  => sys_wlreq,
			sys_wlrdy  => wlrdy(i),
			sys_rlreq  => sys_rlreq,
			sys_rlrdy  => byte_rlrdy(i),
			sys_rlcal  => byte_rlcal(i),

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
