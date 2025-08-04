-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ecp3;
use ecp3.components.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;

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
		phy_locked    : out std_logic_vector(word_size/byte_size-1 downto 0);

		phy_frm   : buffer std_logic;
		phy_trdy  : in  std_logic;
		phy_rw    : out std_logic := '1';
		phy_cmd   : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini   : out std_logic;
		phy_wlreq : in  std_logic;
		phy_wlrdy : buffer std_logic;
		phy_rlreq : in  std_logic := '0';
		phy_rlrdy : buffer std_logic;

		sys_rst   : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_cs    : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '0');
		sys_sti   : in  std_logic_vector(gear-1 downto 0);
		sys_sto   : buffer std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_b     : in  std_logic_vector((gear+1)/2*bank_size-1 downto 0);
		sys_a     : in  std_logic_vector((gear+1)/2*addr_size-1 downto 0);
		sys_cke   : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_ras   : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_cas   : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_we    : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_odt   : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_dmt    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dmi   : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_dmo   : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_dqt   : in  std_logic_vector(gear-1 downto 0);
		sys_dqo   : out std_logic_vector(gear*word_size-1 downto 0);
		sys_dqi   : in  std_logic_vector(gear*word_size-1 downto 0);
		sys_dqso  : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_dqst  : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_dqsi  : in  std_logic_vector(gear*word_size/byte_size-1 downto 0) := (others => '-');

		sdram_rst   : out std_logic;
		sdram_ck    : out std_logic;
		sdram_cke   : out std_logic := '1';
		sdram_cs    : out std_logic := '0';
		sdram_ras   : out std_logic;
		sdram_cas   : out std_logic;
		sdram_we    : out std_logic;
		sdram_b     : out std_logic_vector(bank_size-1 downto 0);
		sdram_a     : out std_logic_vector(addr_size-1 downto 0);
		sdram_odt   : out std_logic;

		sdram_dm    : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dmo  : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqt  : buffer std_logic_vector(word_size-1 downto 0);
		sdram_dq    : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqi  : in std_logic_vector(word_size-1 downto 0) := (others => '-');
		sdram_dqo  : buffer std_logic_vector(word_size-1 downto 0);
		sdram_dqs   : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqst : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqso : buffer std_logic_vector(word_size/byte_size-1 downto 0));
end;

architecture ecp3 of ecp3_sdrphy is
	signal ddrdel    : std_logic;

	signal rl_req    : std_logic_vector(sdram_dqs'range);
	signal rl_rdy    : std_logic_vector(sdram_dqs'range);
	signal wl_rdy    : std_logic_vector(0 to word_size/byte_size-1);

	signal sdrphy_b  : std_logic_vector(sys_b'range);
	signal sdrphy_a  : std_logic_vector(sys_a'range);
	signal ms_pause  : std_logic;

	signal read_req  : std_logic_vector(sdram_dqs'range);
	signal read_rdy  : std_logic_vector(sdram_dqs'range);

	signal dmi : std_logic_vector(sys_dmi'range);
	signal dqi : std_logic_vector(sys_dqi'range);
	signal dqo : std_logic_vector(sys_dqo'range);
	signal dqs_locked : std_logic_vector(sdram_dqs'range);

begin

	sdr3baphy_i : entity hdl4fpga.ecp3_sdrbaphy
	generic map (
		cmmd_gear => (gear+1)/2,
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sclk    => sclk,
		sclk2x  => sclk2x,
          
		sys_rst => sys_rst,
		sys_cs  => sys_cs,
		sys_cke => sys_cke,
		sys_b   => sdrphy_b,
		sys_a   => sdrphy_a,
		sys_ras => sys_ras,
		sys_cas => sys_cas,
		sys_we  => sys_we,
		sys_odt => sys_odt,
        
		sdram_rst => sdram_rst,
		sdram_ck  => sdram_ck,
		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	read_leveling_l_b : block
		signal leveling : std_logic;

		signal sdram_act  : std_logic;
		signal sdram_idle : std_logic;

	begin

		sdrphy_b <= sys_b when leveling='0' else (others => '0');
		sdrphy_a <= sys_a when leveling='0' else (others => '0');

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
					if sdram_act='1' then
						phy_frm <= '0';
						state   := s_stop;
					end if;
				when s_stop =>
					if sdram_idle='1' then
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

	dmi <= shuffle_vector(sys_dmi, gear => gear, size => 1);
	dqi <= shuffle_vector(sys_dqi, gear => gear, size => byte_size);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		signal sto : std_logic;
	begin
		sys_sto(gear*(i+1)-1 downto gear*i) <= (others => sto);
		sdr3phy_i : entity hdl4fpga.ecp3_sdrdqphy
		generic map (
			taps      => taps,
			gear => gear,
			byte_size => byte_size)
		port map (
			rst       => rst,
			sclk      => sclk,
			eclk      => eclk,
			dqsdel    => dqsdel,
			pause     => ms_pause,

			phy_wlreq => phy_wlreq,
			phy_wlrdy => wl_rdy(i),
			phy_rlreq => rl_req(i),
			phy_rlrdy => rl_rdy(i),
			read_req  => read_req(i),
			read_rdy  => read_rdy(i),
			phy_locked  => phy_locked(i),

			sys_sti   => sys_sti,
			sys_sto   => sys_sto((i+1)*gear-1 downto i*gear),
			sys_dmt   => sys_dmt,
			sys_dmi   => dmi((i+1)*gear-1 downto i*gear),

			sys_dmo   => sys_dmo((i+1)*gear-1 downto i*gear),

			sys_dqi   => dqi((i+1)*byte_size*gear-1 downto i*byte_size*gear),
			sys_dqt   => sys_dqt,
			sys_dqo   => dqo((i+1)*byte_size*gear-1 downto i*byte_size*gear),

			sys_dqsi  => sys_dqsi,
			sys_dqst  => sys_dqst,

			sdram_dqt  => sdram_dqt((i+1)*byte_size-1 downto i*byte_size),
			sdram_dqo  => sdram_dqo((i+1)*byte_size-1 downto i*byte_size),
			sdram_dqi  => sdram_dqi((i+1)*byte_size-1 downto i*byte_size),

			sdram_dm   => sdram_dm(i),
			sdram_dmo  => sdram_dmo(i),

			sdram_dqs  => sdram_dqs(i),
			sdram_dqst => sdram_dqst(i),
			sdram_dqso => sdram_dqso(i));
			sdram_dqs(i) <= sdram_dqso(i) when sdram_dqst(i)='0' else 'Z';
	end generate;

end;
