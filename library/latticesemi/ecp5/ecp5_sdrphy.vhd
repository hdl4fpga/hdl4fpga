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
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;

entity ecp5_sdrphy is
	generic (
		debug     : boolean := false;
		sdram_tcp   : real;
		cmmd_gear : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13;
		data_gear : natural := 32;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		tpin      : in std_logic;
		rst       : in std_logic;
		sync_clk  : in std_logic;
		sclk      : in std_logic;
		eclk      : in std_logic;
		ddrdel    : in std_logic;
		ms_pause  : in  std_logic;

		phy_frm    : buffer std_logic;
		phy_trdy   : in  std_logic;
		phy_rw     : out std_logic := '1';
		phy_cmd    : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini    : out std_logic;
		phy_locked : out std_logic;

		phy_wlreq  : in  std_logic := '0';
		phy_wlrdy  : buffer std_logic;
		phy_rlreq  : in  std_logic := '0';
		phy_rlrdy  : buffer std_logic;

		sys_rst    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_cs     : in  std_logic_vector(cmmd_gear-1 downto 0) := (others => '0');
		sys_cke    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_ras    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_cas    : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_we     : in  std_logic_vector(cmmd_gear-1 downto 0);
		sys_b      : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		sys_a      : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		sys_odt    : in  std_logic_vector(cmmd_gear-1 downto 0);
		
		sys_dmi    : in  std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		sys_dqv    : in  std_logic_vector(data_gear-1 downto 0) := (others => '0');
		sys_dqt    : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqi    : in  std_logic_vector(data_gear*word_size-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*word_size-1 downto 0);

		sys_dqsi   : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_dqst   : in  std_logic_vector(data_gear-1 downto 0);

		sys_dqc    : out std_logic_vector(data_gear*word_size/byte_size-1 downto 0);
		sys_sti    : in  std_logic_vector(data_gear-1 downto 0);
		sys_sto    : buffer std_logic_vector(data_gear*word_size/byte_size-1 downto 0);

		sdram_rst  : out std_logic;
		sdram_cs   : out std_logic := '0';
		sdram_cke  : out std_logic := '1';
		sdram_clk  : out std_logic;
		sdram_odt  : out std_logic;
		sdram_ras  : out std_logic;
		sdram_cas  : out std_logic;
		sdram_we   : out std_logic;
		sdram_b    : out std_logic_vector(bank_size-1 downto 0);
		sdram_a    : out std_logic_vector(addr_size-1 downto 0);

		sdram_dqt  : buffer std_logic_vector(word_size-1 downto 0);
		sdram_dm   : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dmo  : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dq   : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqo  : buffer std_logic_vector(word_size-1 downto 0);

		sdram_dqs  : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqst : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqso : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		tp         : out std_logic_vector(1 to 32));
end;

architecture ecp5 of ecp5_sdrphy is

	signal rl_req   : std_logic_vector(sdram_dqs'range);
	signal rl_rdy   : std_logic_vector(sdram_dqs'range);
	signal wl_rdy   : std_logic_vector(0 to word_size/byte_size-1);

	signal sdrsys_b : std_logic_vector(sys_b'range);
	signal sdrsys_a : std_logic_vector(sys_a'range);

	signal read_req : std_logic_vector(sdram_dqs'range);
	signal read_rdy : std_logic_vector(sdram_dqs'range);

	signal dmi : std_logic_vector(sys_dmi'range);
	signal dqi : std_logic_vector(sys_dqi'range);
	signal dqo : std_logic_vector(sys_dqo'range);
	signal dqs_locked : std_logic_vector(sdram_dqs'range);
	signal tp_dq : std_logic_vector(1 to 32*sdram_dqs'length);

begin

	write_leveling_p : process (phy_wlreq, wl_rdy)
		variable z : std_logic;
	begin
		z := '1';
		for i in wl_rdy'range loop
			z := z and (wl_rdy(i) xor phy_wlreq);
		end loop;
		phy_wlrdy <= z xor phy_wlreq;
	end process;

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal sdram_act  : std_logic;
		signal sdram_idle : std_logic;

	begin

		sdrsys_b <= sys_b when leveling='0' else (others => '0');
		sdrsys_a <= sys_a when leveling='0' else (others => '0');

		process (phy_trdy, sclk)
			variable s_pre : std_logic;
		begin
			if rising_edge(sclk) then
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
						if sdram_act='1' then
							phy_frm <= '0';
							state   := s_stop;
						end if;
					when s_stop =>
						if sdram_idle='1' then
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

	sdrbaphy_i : entity hdl4fpga.ecp5_sdrbaphy
	generic map (
		cmmd_gear => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		rst     => rst,
		eclk    => eclk,
		sclk    => sclk,
          
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => sdrsys_b,
		sys_a   => sdrsys_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		sdram_rst => sdram_rst,
		sdram_ck => sdram_clk,
		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	dmi <= shuffle_vector(sys_dmi, gear => data_gear, size => 1);
	dqi <= shuffle_vector(sys_dqi, gear => data_gear, size => byte_size);

	tp <= multiplex(tp_dq, tpin);
	phy_locked <= '1' when dqs_locked=(dqs_locked'range => '1') else '0';
	byte_g : for i in word_size/byte_size-1 downto 0 generate
		sdrphy_i : entity hdl4fpga.ecp5_sdrdqphy
		generic map (
			debug      => debug,
			taps       => natural(ceil((sdram_tcp-25.0e-12)/25.0e-12)), -- FPGA-TN-02035-1-3-ECP5-ECP5-5G-HighSpeed-IO-Interface/3.11. Input/Output DELAY page 13
			data_gear  => data_gear,
			byte_size  => byte_size)
		port map (
			rst        => rst,
			sclk       => sclk,
			eclk       => eclk,
			ddrdel     => ddrdel,
			pause      => ms_pause,

			phy_wlreq  => phy_wlreq,
			phy_wlrdy  => wl_rdy(i),
			phy_rlreq  => rl_req(i),
			phy_rlrdy  => rl_rdy(i),
			read_req   => read_req(i),
			read_rdy   => read_rdy(i),
			phy_locked => dqs_locked(i),

			sys_sti    => sys_sti,
			sys_sto    => sys_sto((i+1)*data_gear-1 downto i*data_gear),
			sys_dmi    => dmi((i+1)*data_gear-1 downto i*data_gear),

			sys_dqv    => sys_dqv,
			sys_dqi    => dqi((i+1)*byte_size*data_gear-1 downto i*byte_size*data_gear),
			sys_dqt    => sys_dqt,
			sys_dqo    => dqo((i+1)*byte_size*data_gear-1 downto i*byte_size*data_gear),

			sys_dqst   => sys_dqst,
			sys_dqsi   => sys_dqsi,

			sdram_dqt  => sdram_dqt((i+1)*byte_size-1 downto i*byte_size),
			sdram_dqo  => sdram_dqo((i+1)*byte_size-1 downto i*byte_size),
			sdram_dq   => sdram_dq((i+1)*byte_size-1 downto i*byte_size),
			sdram_dm   => sdram_dm(i),
			sdram_dmo  => sdram_dmo(i),

			sdram_dqs  => sdram_dqs(i),
			sdram_dqst => sdram_dqst(i),
			sdram_dqso => sdram_dqso(i),
			tp         => tp_dq(i*32+1 to (i+1)*32));
	end generate;

	sys_dqo <= unshuffle_vector(dqo, gear => data_gear, size => byte_size);
end;