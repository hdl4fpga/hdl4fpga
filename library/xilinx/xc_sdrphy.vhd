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

entity xc_sdrphy is
	generic (
		bank_size   : natural := 2;
		addr_size   : natural := 13;
		word_size   : natural := 16;
		byte_size   : natural := 8;
		gear        : natural := 2;

		device      : fpga_devices;
		ba_latency  : natural := 0;
		rd_fifo     : boolean := true;
		rd_align    : boolean := true;
		wr_fifo     : boolean := true;
		bypass      : boolean := true;
		taps        : natural := 0;
		loopback    : boolean := false;
		dqs_highz   : boolean := true;
		bufio       : boolean := false);
		-- dqs_delay  : time_vector := (0 to 0 => 0 ns);
		-- dqi_delay  : time_vector := (0 to 0 => 0 ns);
	port (
		tp_sel      : in  std_logic_vector(2-1 downto 0) := "00";
		tp          : out std_logic_vector(1 to 32);

		rst         : in  std_logic;
		rst_shift   : in  std_logic := '-';
		iod_clk     : in  std_logic;
		clk         : in  std_logic := '-';
		clk_shift   : in  std_logic := '-';
		clkx2       : in  std_logic := '-';
		clkx2_shift : in  std_logic := '-';

		phy_frm     : buffer std_logic;
		phy_trdy    : in  std_logic := '-';
		phy_rw      : out std_logic;
		phy_cmd     : in  std_logic_vector(0 to 3-1) := (others => '-');
		phy_ini     : out std_logic;
		phy_locked  : buffer std_logic;

		phy_wlreq   : in  std_logic := '-';
		phy_wlrdy   : out std_logic;
		phy_rlreq   : in  std_logic := '-';
		phy_rlrdy   : buffer std_logic;

		sys_rst     : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '-');
		sys_cs      : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '0');
		sys_cke     : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_ras     : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_cas     : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_we      : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_b       : in  std_logic_vector((gear+1)/2*bank_size-1 downto 0);
		sys_a       : in  std_logic_vector((gear+1)/2*addr_size-1 downto 0);
		sys_odt     : in  std_logic_vector((gear+1)/2-1 downto 0);

		sys_dmt     : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dmi     : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_dmo     : out std_logic_vector(gear*word_size/byte_size-1 downto 0);

		sys_dqst    : in  std_logic_vector(gear-1 downto 0);
		sys_dqsi    : in  std_logic_vector(gear-1 downto 0);
		sys_dqso    : out std_logic_vector(gear*word_size/byte_size-1 downto 0);

		sys_dqt     : in  std_logic_vector(gear-1 downto 0);
		sys_dqi     : in  std_logic_vector(gear*word_size-1 downto 0);
		sys_dqo     : out std_logic_vector(gear*word_size-1 downto 0);

		sys_dqv     : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_dqc     : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_sti     : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sto     : out std_logic_vector(gear*word_size/byte_size-1 downto 0);

		sdram_rst   : out std_logic := '0';
		sdram_cs    : out std_logic_vector;
		sdram_cke   : out std_logic_vector;
		sdram_clk   : out std_logic_vector;
		sdram_odt   : out std_logic_vector;
		sdram_ras   : out std_logic;
		sdram_cas   : out std_logic;
		sdram_we    : out std_logic;
		sdram_b     : out std_logic_vector(bank_size-1 downto 0);
		sdram_a     : out std_logic_vector(addr_size-1 downto 0);

		sdram_sti   : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		sdram_sto   : out std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dm    : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dq    : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqs   : inout std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		sdram_dqst  : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqso  : buffer std_logic_vector(word_size/byte_size-1 downto 0));

end;

library hdl4fpga;
use hdl4fpga.base.all;

library unisim;
use unisim.vcomponents.all;

architecture xilinx of xc_sdrphy is
	signal sto_locked : std_logic_vector(sdram_dqs'range);
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

	signal dmt : std_logic_vector(sys_dmi'range);
	signal dmi : std_logic_vector(sys_dmi'range);
	signal dqi : std_logic_vector(sys_dqi'range);
	signal dqo : std_logic_vector(sys_dqo'range);
	signal dmo : std_logic_vector(word_size/byte_size-1 downto 0);

begin

	sdram_clk_g : for i in sdram_clk'range generate
		signal sdrclk : std_logic;
	begin
		sdrclk <= clk when gear=2 else clkx2;
		clk_i : entity hdl4fpga.ogbx
		generic map (
			device => device,
			size => 1,
			gear => 2)
		port map (
			clk  => sdrclk,
			d(0) => '0',
			d(1) => '1',
			q(0) => sdram_clk(i));
	end generate;

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
		signal swaddress  : std_logic;

	begin

		process (iod_clk)
		begin
			if rising_edge(iod_clk) then
				swaddress <= leveling;
			end if;
		end process;
		ddrphy_b <= sys_b when swaddress='0' else (others => '0');
		ddrphy_a <= sys_a when swaddress='0' else (others => '0');

		process (phy_trdy, clk)
			variable s_pre : std_logic;
		begin
			if rising_edge(clk) then
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

		readcycle_p : process (clk, rd_rdy)
			type states is (s_idle, s_init, s_run);
			variable state : states;
			variable burst : std_logic;
			variable sy_wr_req : std_logic_vector(wr_req'range);
			variable sy_rd_req : std_logic_vector(rd_req'range);
		begin
			if rising_edge(clk) then
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

		process (clk)
			type states is (s_init, s_w4all, s_4rdy);
			variable state : states;
		begin
			if rising_edge(clk) then
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
						phy_ini   <= phy_locked;
						phy_rlrdy <= phy_rlreq;
					end case;
				else
					state := s_init;
				end if;
			end if;
		end process;

	end block;

	phy_locked <= '1' when sto_locked=(sto_locked'range => '1') else '0';

	dmi <= shuffle_vector(sys_dmi, gear => gear, size => 1);
	dqi <= shuffle_vector(sys_dqi, gear => gear, size => byte_size);

	sdrbaphy_i : entity hdl4fpga.xc_sdrbaphy
	generic map (
		bank_size  => bank_size,
		addr_size  => addr_size,
		gear       => (gear+1)/2,
		device     => device,
		ba_latency => ba_latency)
	port map (
		clk       => clk,
	 	grst      => rst,
		sys_rst   => sys_rst,
		sys_cs    => sys_cs,
		sys_cke   => sys_cke,
		sys_b     => ddrphy_b,
		sys_a     => ddrphy_a,
		sys_ras   => sys_ras,
		sys_cas   => sys_cas,
		sys_we    => sys_we,
		sys_odt   => sys_odt,

		sdram_rst => sdram_rst,
		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	byte_g : for i in sdram_dqs'range generate
		signal tp_byte : std_logic_vector(1 to 8);
	begin
		tp_g : if i=0 generate
			tp(tp_byte'range) <= tp_byte;
		end generate;

		sdrdqphy_i : entity hdl4fpga.xc_sdrdqphy
		generic map (
			-- dqs_delay  => dqs_delay(i mod dqi_delay'length),
			-- dqi_delay  => dqi_delay(i mod dqi_delay'length),

			device    => device,
			byteno    => i,
			gear      => gear,
			byte_size => byte_size,
			dqs_highz => dqs_highz,
			loopback  => loopback,
			bypass    => bypass,
			bufio     => bufio,
			rd_fifo   => rd_fifo,
			rd_align  => rd_align,
			wr_fifo   => wr_fifo,
			taps      => taps)
		port map (
			tp_sel     => tp_sel,
			tp_delay   => tp_byte,

			rst       => rst,
			rst_shift => rst_shift,
			iod_clk   => iod_clk,
			clk       => clk,
			clk_shift => clk_shift,
			clkx2     => clkx2,
			clkx2_shift => clkx2_shift,

			phy_wlreq  => phy_wlreq,
			phy_wlrdy  => wl_rdy(i),
			phy_rlreq  => rl_req(i),
			phy_rlrdy  => rl_rdy(i),
			write_req  => wr_req(i),
			write_rdy  => wr_rdy(i),
			read_req   => rd_req(i),
			read_rdy   => rd_rdy(i),
			read_brst  => read_brst(i),
			phy_locked => sto_locked(i),

			sys_sti    => sys_sti,
			sys_sto    => sys_sto((i+1)*gear-1 downto i*gear),
			sys_dmt    => sys_dmt,
			sys_dmi    => dmi((i+1)*gear-1 downto i*gear),

		    sys_dqv    => sys_dqv,
			sys_dqi    => dqi((i+1)*byte_size*gear-1 downto i*byte_size*gear),
			sys_dqt    => sys_dqt,
			sys_dqo    => dqo((i+1)*byte_size*gear-1 downto i*byte_size*gear),

		    sys_dqc    => sys_dqc((i+1)*gear-1 downto i*gear),

			sys_dqst   => sys_dqst,
			sys_dqsi   => sys_dqsi,
			sys_dqso   => sys_dqso((i+1)*gear-1 downto i*gear),

			sdram_sti  => sdram_sti(i),
			sdram_sto  => sdram_sto(i),

			sdram_dq   => sdram_dq((i+1)*byte_size-1 downto i*byte_size),

			sdram_dm   => sdram_dm(i),

			sdram_dqs  => sdram_dqs(i),
			sdram_dqst => sdram_dqst(i),
			sdram_dqso => sdram_dqso(i));


		
	end generate;

	sys_dqo <= unshuffle_vector(dqo, gear => gear, size => byte_size);
end;