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
		rdy       : out std_logic;
		sync_clk  : in std_logic;
		clkop     : in std_logic;
		sclk      : buffer std_logic;
		eclk      : buffer std_logic;

		phy_frm    : buffer std_logic;
		phy_trdy   : in  std_logic;
		phy_rw     : out std_logic := '1';
		phy_cmd    : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini    : out std_logic;
		phy_synced : out std_logic;

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
		
		sys_dmt    : in  std_logic_vector(data_gear-1 downto 0);
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

		sdram_dm   : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dq   : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqs  : inout std_logic_vector(word_size/byte_size-1 downto 0);
		tp         : out std_logic_vector(1 to 32));
end;

architecture ecp5 of ecp5_sdrphy is

	function shuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in gear-1 downto 0 loop
				for l in size-1 downto 0 loop
					val((i*gear+j)*size+l) := data(j*(data'length/gear)+i*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

	function unshuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in data_gear-1 downto 0 loop
				for l in byte_size-1 downto 0 loop
					val(j*(data'length/gear)+i*size+l) := data((i*gear+j)*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

	signal srst      : std_logic;

	signal sdmi      : std_logic_vector(sys_dmi'range);
	signal sdqi      : std_logic_vector(sys_dqi'range);
	signal sdqo      : std_logic_vector(sys_dqo'range);

	signal sdram_reset : std_logic;

	signal rl_req    : std_logic_vector(sdram_dqs'range);
	signal rl_rdy    : std_logic_vector(sdram_dqs'range);
	signal wl_rdy    : std_logic_vector(0 to word_size/byte_size-1);

	signal ddrsys_b  : std_logic_vector(sys_b'range);
	signal ddrsys_a  : std_logic_vector(sys_a'range);

	signal ms_pause  : std_logic;
	signal ddrdel    : std_logic;

	signal read_req  : std_logic_vector(sdram_dqs'range);
	signal read_rdy  : std_logic_vector(sdram_dqs'range);

	component mem_sync
		port (
			start_clk : in  std_logic;
			rst       : in  std_logic;
			dll_lock  : in  std_logic;
			pll_lock  : in  std_logic;
			update    : in  std_logic;
			pause     : out std_logic;
			stop      : out std_logic;
			freeze    : out std_logic;
			uddcntln  : out std_logic;
			dll_rst   : out std_logic;
			ddr_rst   : out std_logic;
			ready     : out std_logic);
	end component;

	signal tp_dq : std_logic_vector(1 to 32*sdram_dqs'length);
	signal dqs_locked : std_logic_vector(sdram_dqs'range);
begin

	mem_sync_b : block
		signal uddcntln : std_logic;
		signal freeze   : std_logic;
		signal stop     : std_logic;
		signal dll_rst  : std_logic;
		signal dll_lock : std_logic;
		signal pll_lock : std_logic;
		signal update   : std_logic;
		signal ready    : std_logic;

		attribute FREQUENCY_PIN_ECLKO : string;
		attribute FREQUENCY_PIN_ECLKO of  eclksyncb_i : label is ftoa(1.0e-6/sdram_tcp, 10);

		attribute FREQUENCY_PIN_CDIVX : string;
		attribute FREQUENCY_PIN_CDIVX of clkdivf_i : label is ftoa(1.0e-6/(sdram_tcp*2.0), 10);
		signal eclko : std_logic;
		signal cdivx : std_logic;
	begin

		pll_lock <= '1';
		update   <= '0';

		mem_sync_i : mem_sync
		port map (
			start_clk => sync_clk,
			rst       => rst,
			dll_lock  => dll_lock,
			pll_lock  => pll_lock,
			update    => update,
			pause     => ms_pause,
			stop      => stop,
			freeze    => freeze,
			uddcntln  => uddcntln,
			dll_rst   => dll_rst,
			ddr_rst   => sdram_reset,
			ready     => ready);
		rdy <= ready;

		eclksyncb_i : eclksyncb
		port map (
			stop  => stop,
			eclki => clkop,
			eclko => eclko);
	
		clkdivf_i : clkdivf
		generic map (
			div => "2.0")
		port map (
			rst     => sdram_reset,
			alignwd => '0',
			clki    => eclko,
			cdivx   => cdivx);
		eclk <= eclko;
		sclk <= transport cdivx after natural(sdram_tcp*1.0e12*(3.0/4.0))*1 ps;
-- 
		-- eclk <= transport eclko after natural(sdram_tcp*1.0e12*(3.0/4.0))*1 ps;
		-- sclk <= cdivx;
	
		ddrdll_i : ddrdlla
		port map (
			rst      => dll_rst,
			clk      => eclk,
			freeze   => freeze,
			uddcntln => uddcntln,
			ddrdel   => ddrdel,
			lock     => dll_lock);

	end block;

	process (sdram_reset, sclk)
	begin
		if sdram_reset='1' then
			srst <= '1';
		elsif rising_edge(sclk) then
			srst <= '0';
		end if;
	end process;

	sdr3baphy_i : entity hdl4fpga.ecp5_sdrbaphy
	generic map (
		cmmd_gear => cmmd_gear,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		rst     => sdram_reset,
		eclk    => eclk,
		sclk    => sclk,
          
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => ddrsys_b,
		sys_a   => ddrsys_a,
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

		ddrsys_b <= sys_b when leveling='0' else (others => '0');
		ddrsys_a <= sys_a when leveling='0' else (others => '0');

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
				if srst='1' then
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

		process (srst, sclk)
			variable z : std_logic;
		begin
			if rising_edge(sclk) then
				if srst='1' then
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

	sdmi  <= shuffle_vector(sys_dmi, gear => data_gear, size => 1);
	sdqi  <= shuffle_vector(sys_dqi, gear => data_gear, size => byte_size);

	tp <= multiplex(tp_dq, tpin);
	phy_synced <= '1' when dqs_locked=(dqs_locked'range => '1') else '0';
	byte_g : for i in word_size/byte_size-1 downto 0 generate
		sdr3phy_i : entity hdl4fpga.ecp5_sdrdqphy
		generic map (
			debug      => debug,
			taps       => natural(ceil((sdram_tcp-25.0e-12)/25.0e-12)), -- FPGA-TN-02035-1-3-ECP5-ECP5-5G-HighSpeed-IO-Interface/3.11. Input/Output DELAY page 13
			data_gear  => data_gear,
			byte_size  => byte_size)
		port map (
			rst        => sdram_reset,
			sclk       => sclk,
			eclk       => eclk,
			ddrdel     => ddrdel,
			pause      => ms_pause,

			phy_wlreq  => phy_wlreq,
			phy_wlrdy  => wl_rdy(i),
			phy_rlreq  => rl_req(i),
			phy_rlrdy  => rl_rdy(i),
			phy_locked => dqs_locked(i),

			read_req   => read_req(i),
			read_rdy   => read_rdy(i),

			sys_sti    => sys_sti,
			sys_sto    => sys_sto((i+1)*data_gear-1 downto i*data_gear),
			sys_dmt    => sys_dmt,
			sys_dmi    => sdmi((i+1)*data_gear-1 downto i*data_gear),

			sys_dqv    => sys_dqv,
			sys_dqi    => sdqi((i+1)*byte_size*data_gear-1 downto i*byte_size*data_gear),
			sys_dqt    => sys_dqt,
			sys_dqo    => sdqo((i+1)*byte_size*data_gear-1 downto i*byte_size*data_gear),

			sys_dqst   => sys_dqst,
			sys_dqsi   => sys_dqsi,

			sdram_dq   => sdram_dq((i+1)*byte_size-1 downto i*byte_size),
			sdram_dm   => sdram_dm(i),

			sdram_dqs  => sdram_dqs(i),
			tp         => tp_dq(i*32+1 to (i+1)*32));
	end generate;

	sys_dqo  <= unshuffle_vector(sdqo, gear => data_gear, size => byte_size);
end;