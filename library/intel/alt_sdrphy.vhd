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
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;
use hdl4fpga.sdram_param.all;

entity alt_sdrphy is
	generic (
		-- dqs_delay  : time_vector := (0 to 0 => 0 ns);
		-- dqi_delay  : time_vector := (0 to 0 => 0 ns);
		device     : fpga_devices;
		loopback   : boolean   := false;
		bypass     : boolean   := true;
		bufio      : boolean   := false;
		taps       : natural   := 0;
		cmmd_gear  : natural   := 1;
		data_gear  : natural   := 2;
		data_edge  : boolean   := true;
		bank_size  : natural   := 2;
		addr_size  : natural   := 13;
		word_size  : natural   := 16;
		byte_size  : natural   := 8);
	port (
		tp_sel     : in  std_logic := '0';
		tp         : out std_logic_vector(1 to 32);

		rst        : in  std_logic;
		iod_clk    : in  std_logic;
		clk0       : in  std_logic := '-';
		clk90      : in  std_logic := '-';
		clk0x2     : in  std_logic := '-';
		clk90x2    : in  std_logic := '-';
		ctlr_clk   : in  std_logic := '-';

		phy_frm    : buffer std_logic;
		phy_trdy   : in  std_logic := '-';
		phy_rw     : out std_logic;
		phy_cmd    : in  std_logic_vector(0 to 3-1) := (others => '-');
		phy_ini    : out std_logic;
		phy_synced : buffer std_logic;

		phy_wlreq  : in  std_logic := '-';
		phy_wlrdy  : out std_logic;
		phy_rlreq  : in  std_logic := '-';
		phy_rlrdy  : buffer std_logic;

		parallelterminationcontrol : in	std_logic_vector (15 downto 0);
		seriesterminationcontrol   : in std_logic_vector (15 downto 0);
		dll_delayctrlout           : in  std_logic_vector (6 downto 0); 

		sys_rst    : in  std_logic_vector(cmmd_gear-1 downto 0) := (others => '-');
		sys_cs     : in  std_logic_vector(cmmd_gear-1 downto 0) := (others => '0');
		sys_cke    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_ras    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_cas    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_we     : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_b      : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		sys_a      : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		sys_odt    : in  std_logic_vector(cmmd_gear-1 downto 0);

		sys_dmt    : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dmi    : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dmo    : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqi    : in  std_logic_vector(data_gear*word_size-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*word_size-1 downto 0);

		sys_dqso   : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_dqst   : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_sti    : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0) := (others => '-');
		sys_sto    : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		sdram_rst  : out std_logic := '0';
		sdram_cs   : out std_logic_vector;
		sdram_cke  : out std_logic_vector;
		sdram_clk  : out std_logic_vector;
		sdram_odt  : out std_logic_vector;
		sdram_ras  : out std_logic;
		sdram_cas  : out std_logic;
		sdram_we   : out std_logic;
		sdram_b    : out std_logic_vector(bank_size-1 downto 0);
		sdram_a    : out std_logic_vector(addr_size-1 downto 0);

		sdram_sti  : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		sdram_sto  : out std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dm   : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dq   : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqs  : inout std_logic_vector(word_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.base.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

architecture xilinx of alt_sdrphy is
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

	signal sdmt       : bline_vector(word_size/byte_size-1 downto 0);
	signal sdmi       : bline_vector(word_size/byte_size-1 downto 0);
	signal ssti       : bline_vector(word_size/byte_size-1 downto 0);
	signal ssto       : bline_vector(word_size/byte_size-1 downto 0);

	signal sdqt       : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqi       : dline_vector(word_size/byte_size-1 downto 0);
	signal sdqo       : dline_vector(word_size/byte_size-1 downto 0);

	signal sdqsi      : bline_vector(word_size/byte_size-1 downto 0);
	signal sdqst      : bline_vector(word_size/byte_size-1 downto 0);

	signal sto_synced : std_logic_vector(sdram_dqs'range);
	signal rl_req     : std_logic_vector(sdram_dqs'range);
	signal rl_rdy     : std_logic_vector(rl_req'range);
	signal wr_req     : std_logic_vector(sdram_dqs'range);
	signal wr_rdy     : std_logic_vector(rl_req'range);
	signal wl_rdy     : std_logic_vector(sdram_dqs'range);

	signal rd_req     : std_logic_vector(sdram_dqs'range);
	signal rd_rdy     : std_logic_vector(rd_req'range);
	signal write_req  : std_logic;
	signal write_rdy  : std_logic;
	signal read_req   : std_logic;
	signal read_rdy   : std_logic;
	signal read_brst  : std_logic_vector(rd_req'range);

	signal ddrphy_b   : std_logic_vector(sys_b'range);
	signal ddrphy_a   : std_logic_vector(sys_a'range);

begin

	sdram_clk_g : for i in sdram_clk'range generate
		signal clk : std_logic;
	begin
		clk <= clk0 when data_gear=2 else clk0x2;
		clk_i : entity hdl4fpga.alt_ogbx
		generic map (
			device => device,
			size => 1,
			gear => 2)
		port map (
			clk  => ctlr_clk,
			d(0) => '0',
			d(1) => '1',
			q(0) => sdram_clk(i));
	end generate;

	sdrbaphy_i : entity hdl4fpga.alt_sdrbaphy
	generic map (
		device => device,
		data_edge => "SAME_EDGE",
		gear      => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		clk0    => ctlr_clk,
     	rst     => rst,
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => ddrphy_b,
		sys_a   => ddrphy_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,

		sdram_rst => sdram_rst,
		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	write_leveling_p : process (phy_wlreq, wl_rdy)
		variable z : std_logic;
	begin
		z := '0';
		for i in wl_rdy'range loop
			z := z or (wl_rdy(i) xor to_stdulogic(to_bit(phy_wlreq)));
		end loop;
		phy_wlrdy <= z xor to_stdulogic(to_bit(phy_wlreq));
	end process;

	read_leveling_l_b : block
		signal leveling   : std_logic;
		signal sdram_act  : std_logic;
		signal sdram_idle : std_logic;

	begin

		ddrphy_b <= sys_b when leveling='0' else (others => '0');
		ddrphy_a <= sys_a when leveling='0' else (others => '0');

		process (phy_trdy, ctlr_clk)
			variable s_pre : std_logic;
		begin
			if rising_edge(ctlr_clk) then
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

		readcycle_p : process (ctlr_clk, rd_rdy)
			type states is (s_idle, s_init, s_run);
			variable state : states;
			variable burst : std_logic;
			variable sy_wr_req : std_logic_vector(wr_req'range);
			variable sy_rd_req : std_logic_vector(rd_req'range);
		begin
			if rising_edge(ctlr_clk) then
				if rst='1' then
					write_rdy <= to_stdulogic(to_bit(write_req));
					read_rdy  <= to_stdulogic(to_bit(read_req));
					wr_rdy    <= to_stdlogicvector(to_bitvector(wr_req));
					rd_rdy    <= to_stdlogicvector(to_bitvector(rd_req));
					state     := s_idle;
					leveling  <= '0';
				else
					case state is
					when s_init =>
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
							wr_rdy    <= to_stdlogicvector(to_bitvector(sy_wr_req));
							rd_rdy    <= to_stdlogicvector(to_bitvector(sy_rd_req));
							read_rdy  <= to_stdulogic(to_bit(read_req));
							write_rdy <= to_stdulogic(to_bit(write_req));
							state     := s_idle;
						end if;
						if burst='0' then
							phy_frm <= '0';
						end if;
					when s_idle =>
						leveling <= '0';
						phy_frm  <= '0';
						if (read_rdy xor to_stdulogic(to_bit(read_req)))='1' then
							phy_frm  <= '1';
							phy_rw   <= '1';
							leveling <= '1';
							state    := s_init;
						elsif (write_rdy xor to_stdulogic(to_bit(write_req)))='1' then
							phy_frm  <= '1';
							phy_rw   <= '0';
							leveling <= '1';
							state    := s_init;
						end if;
					end case;

					if read_brst=(read_brst'range  => '0') then
						burst := '0';
					else
						burst := '1';
					end if;

					if (read_rdy xor to_stdulogic(to_bit(read_req)))='0' then
						if rd_rdy /= to_stdlogicvector(to_bitvector(sy_rd_req)) then
							read_req <= not read_rdy;
						end if;
					end if;

					if (write_rdy xor to_stdulogic(to_bit(write_req)))='0' then
						if wr_rdy = not to_stdlogicvector(to_bitvector(sy_wr_req)) then
							write_req <= not write_rdy;
						end if;
					end if;
				end if;
				sy_wr_req := wr_req;
				sy_rd_req := rd_req;
			end if;
		end process;

		process (ctlr_clk)
			type states is (s_init, s_w4all, s_4rdy);
			variable state : states;
		begin
			if rising_edge(ctlr_clk) then
				if rst='1' then
					phy_ini   <= '0';
					phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
					state := s_init;
				elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
					case state  is
					when s_init =>
						rl_req <= not to_stdlogicvector(to_bitvector(rl_rdy));
						state := s_w4all;
					when s_w4all =>	-- Wait for(4) All
						state := s_4rdy;
						for i in rl_req'range loop
							if (rl_rdy(i) xor to_stdulogic(to_bit(rl_req(i))))='1' then
								state := s_w4all;
							end if;
						end loop;
					when s_4rdy => -- All(4) ready
						phy_ini   <= phy_synced;
						phy_rlrdy <= phy_rlreq;
					end case;
				else
					state := s_init;
				end if;
			end if;
		end process;

	end block;

	sdmi  <= to_blinevector(shuffle_stdlogicvector(sys_dmi));
	ssti  <= to_blinevector(sys_sti);
	sdmt  <= to_blinevector(sys_dmt);
	sdqt  <= to_blinevector(sys_dqt);
	sdqi  <= shuffle_dlinevector(sys_dqi);
	sdqsi <= to_blinevector(sys_dqsi);
	sdqst <= to_blinevector(sys_dqst);

	phy_synced <= '1' when sto_synced=(sto_synced'range => '1') else '0';

	byte_g : for i in sdram_dqs'range generate
	-- byte_g : for i in 0 to 0 generate
		signal tp_byte : std_logic_vector(1 to 8);
	begin
		-- tp_g : if i=0 generate
		-- 	tp(tp_byte'range) <= tp_byte;
		-- end generate;

		sdrdqphy_i : entity hdl4fpga.alt_sdrdqphy
		generic map (
			-- dqs_delay  => dqs_delay(i mod dqi_delay'length),
			-- dqi_delay  => dqi_delay(i mod dqi_delay'length),
			loopback   => loopback,
			bypass     => bypass,
			bufio      => bufio,
			device     => device,
			taps       => taps,
			data_edge  => data_edge,
			data_gear  => data_gear,
			byte_size  => byte_size)
		port map (
			tp_sel     => tp_sel,
			tp_delay   => tp_byte,

			rst        => rst,
			iod_clk    => iod_clk,
			clk0       => clk0,
			clk90      => clk90,
			clk0x2     => clk0x2,
			clk90x2    => clk90x2,
			ctlr_clk   => ctlr_clk,

			sys_wlreq  => phy_wlreq,
			sys_wlrdy  => wl_rdy(i),
			sys_rlreq  => rl_req(i),
			sys_rlrdy  => rl_rdy(i),
			write_req  => wr_req(i),
			write_rdy  => wr_rdy(i),
			read_req   => rd_req(i),
			read_rdy   => rd_rdy(i),
			read_brst  => read_brst(i),

			dll_delayctrlout => dll_delayctrlout,
			parallelterminationcontrol => parallelterminationcontrol,
			seriesterminationcontrol   => seriesterminationcontrol,

			sys_sti    => ssti(i),
			sys_sto    => ssto(i),
			sys_dmt    => sdmt(i),
			sys_dmi    => sdmi(i),

			sys_dqi    => sdqi(i),
			sys_dqt    => sdqt(i),
			sys_dqo    => sdqo(i),

			sys_dqsi   => sdqsi(i),
			sys_dqst   => sdqst(i),
			sys_dqso   => sys_dqso(data_gear*(i+1)-1 downto data_gear*i),
			sto_synced => sto_synced(i),

			sdram_sti  => sdram_sti(i),
			sdram_sto  => sdram_sto(i),
			sdram_dq   => sdram_dq(byte_size*(i+1)-1 downto byte_size*i),

			sdram_dm   => sdram_dm(i),

			sdram_dqs => sdram_dqs(i));


		sys_sto((i+1)*data_gear-1 downto i*data_gear) <= ssto(i);
	end generate;

	sys_dqo <= to_stdlogicvector(sdqo);
end;
