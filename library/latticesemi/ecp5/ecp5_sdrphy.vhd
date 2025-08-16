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

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdrampkg.all;

entity ecp5_sdrphy is
	generic (
		ba_wldelay  : time := 0.0 ns;
		dq_wldelay  : time := 0.05 ns;
		debug     : boolean := false;
		bank_size : natural := 2;
		addr_size : natural := 13;
		word_size : natural := 16;
		byte_size : natural := 8;
		gear      : natural := 2;

		ba_latency : natural := 0;
		rd_fifo   : boolean := true;
		wr_fifo   : boolean := true;
		bypass    : boolean := false;
		taps      : natural := 0);
	port (
		tpin      : in std_logic := '-';
		phy_rst   : in std_logic := '0';
		ctlr_rst  : in std_logic := '0';
		sclk      : in std_logic;
		eclk      : in std_logic := '-';
		ddrdel    : in std_logic := '-';
		ms_pause  : in  std_logic := '-';

		phy_frm    : buffer std_logic;
		phy_trdy   : in  std_logic := '-';
		phy_rw     : out std_logic := '1';
		phy_cmd    : in  std_logic_vector(0 to 3-1) := (others => 'U');
		phy_ini    : out std_logic;
		phy_locked : out std_logic;

		phywl_req  : in  std_logic := '0';
		phywl_rdy  : buffer std_logic := '0';
		phyrl_req  : in  std_logic := '0';
		phyrl_rdy  : buffer std_logic := '0';

		sys_rst    : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '1');
		sys_cs     : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '1');
		sys_cke    : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_ras    : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_cas    : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_we     : in  std_logic_vector((gear+1)/2-1 downto 0);
		sys_b      : in  std_logic_vector((gear+1)/2*bank_size-1 downto 0);
		sys_a      : in  std_logic_vector((gear+1)/2*addr_size-1 downto 0);
		sys_odt    : in  std_logic_vector((gear+1)/2-1 downto 0) := (others => '0');
		
		sys_dmt    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dmi    : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);

		sys_dqv    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dqt    : in  std_logic_vector(gear-1 downto 0);
		sys_dqi    : in  std_logic_vector(gear*word_size-1 downto 0);
		sys_dqo    : out std_logic_vector(gear*word_size-1 downto 0);

		sys_dqst   : in  std_logic_vector(gear-1 downto 0) := (others => '1');
		sys_dqsi   : in  std_logic_vector(gear-1 downto 0) := (others => '0');

		sys_dqc    : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		sys_sti    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_sto    : buffer std_logic_vector(gear*word_size/byte_size-1 downto 0);

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
		sdram_dmo  : buffer std_logic_vector(word_size/byte_size-1 downto 0);
		sdram_dqt  : buffer std_logic_vector(word_size-1 downto 0);
		sdram_dq   : inout std_logic_vector(word_size-1 downto 0);
		sdram_dqi  : in std_logic_vector(word_size-1 downto 0) := (others => '-');
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
	signal read_rdy : std_logic_vector(sdram_dqs'range) := (others => '0');

	signal dmi : std_logic_vector(sys_dmi'range);
	signal dqi : std_logic_vector(sys_dqi'range);
	signal dqo : std_logic_vector(sys_dqo'range);
	signal dqs_locked : std_logic_vector(sdram_dqs'range);
	signal tp_dq : std_logic_vector(1 to 32*sdram_dqs'length);

begin

	ck_b : block
	begin
		gear1or2_g : if gear=1 or gear=2 generate 
			ck_i : oddrx1f
			port map (
				sclk => sclk,
				d0   => '0',
				d1   => '1',
				q    => sdram_clk);
		end generate;

		gear4_g : if gear=4 generate 
			signal ck : std_logic;
			signal nodelay_clk : std_logic;
		begin
    		ck_i : oddrx2f
    		port map (
    			rst  => phy_rst,
    			sclk => sclk,
    			eclk => eclk,
    			d0   => '0',
    			d1   => '1',
    			d2   => '0',
    			d3   => '1',
    			q    => ck);

    		delay_i : delayg
    		generic map (
    			del_mode => "DQS_CMD_CLK")
    		port map (
    			a => ck,
    			z => nodelay_clk);
			sdram_clk <= transport nodelay_clk after ba_wldelay;
		end generate;

	end block;

	write_leveling_p : process (phywl_req, wl_rdy)
		variable z : std_logic := '1';
	begin
		z := '1';
		for i in wl_rdy'range loop
			z := z and (wl_rdy(i) xor phywl_req);
		end loop;
		phywl_rdy <= z xor phywl_req;
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
				if ctlr_rst='1' then
					read_rdy <= read_req;
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
							read_rdy <= read_req;
							state    := s_idle;
						end if;
					when s_idle =>
						leveling <= '0';
						phy_frm  <= '0';
						for i in read_req'reverse_range loop
							if (read_rdy(i) xor read_req(i))='1' then
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

		process (ctlr_rst, sclk)
			variable z : std_logic;
		begin
			if rising_edge(sclk) then
				if ctlr_rst='1' then
					phyrl_rdy <= phyrl_req;
					phy_ini <= '0';
				elsif (phyrl_rdy xor phyrl_req)='1' then
					z := '1';
					for i in rl_req'reverse_range loop
						if (rl_rdy(i) xor phyrl_req)='1' then
							z := '0';
						end if;
					end loop;
					if z='1' then
						phy_ini   <= '1';
						phyrl_rdy <= phyrl_req;
					end if;
				end if;
			end if;
		end process;
		rl_req <= (others => phyrl_req);
	end block;

	sdrbaphy_i : entity hdl4fpga.ecp5_sdrbaphy
	generic map (
		wl_delay  => ba_wldelay,
		bank_size => bank_size,
		addr_size => addr_size,
		gear      => (gear+1)/2,
		ba_latency => ba_latency)
	port map (
		phy_rst => phy_rst,
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
		sdram_cke => sdram_cke,
		sdram_odt => sdram_odt,
		sdram_cs  => sdram_cs,
		sdram_ras => sdram_ras,
		sdram_cas => sdram_cas,
		sdram_we  => sdram_we,
		sdram_b   => sdram_b,
		sdram_a   => sdram_a);

	dmi <= shuffle_vector(sys_dmi, gear => gear, size => 1);
	dqi <= shuffle_vector(sys_dqi, gear => gear, size => byte_size);

	tp <= multiplex(tp_dq, tpin);
	byte_g : for i in word_size/byte_size-1 downto 0 generate
		sdrphy_i : entity hdl4fpga.ecp5_sdrdqphy
		generic map (
			wl_delay   => dq_wldelay,
			byteno     => i,
			debug      => debug,
			taps       => taps,
			gear       => gear,
			rd_fifo    => rd_fifo,
			wr_fifo    => wr_fifo,
			bypass     => bypass,
			byte_size  => byte_size)
		port map (
			phy_rst    => phy_rst,
			ctlr_rst   => ctlr_rst,
			sclk       => sclk,
			eclk       => eclk,
			ddrdel     => ddrdel,
			pause      => ms_pause,

			phywl_req  => phywl_req,
			phywl_rdy  => wl_rdy(i),
			phyrl_req  => rl_req(i),
			phyrl_rdy  => rl_rdy(i),
			read_req   => read_req(i),
			read_rdy   => read_rdy(i),
			phy_locked => dqs_locked(i),

			sys_sti    => sys_sti,
			sys_sto    => sys_sto((i+1)*gear-1 downto i*gear),
			sys_dmt    => sys_dmt,
			sys_dmi    => dmi((i+1)*gear-1 downto i*gear),

			sys_dqv    => sys_dqv,
			sys_dqt    => sys_dqt,
			sys_dqi    => dqi((i+1)*byte_size*gear-1 downto i*byte_size*gear),
			sys_dqo    => dqo((i+1)*byte_size*gear-1 downto i*byte_size*gear),

			sys_dqst   => sys_dqst,
			sys_dqsi   => sys_dqsi,

			sdram_dqs  => sdram_dqs(i),
			sdram_dqst => sdram_dqst(i),
			sdram_dqso => sdram_dqso(i),

			sdram_dm   => sdram_dm(i),
			sdram_dmo  => sdram_dmo(i),

			sdram_dqt  => sdram_dqt((i+1)*byte_size-1 downto i*byte_size),
			sdram_dqi  => sdram_dqi((i+1)*byte_size-1 downto i*byte_size),
			sdram_dqo  => sdram_dqo((i+1)*byte_size-1 downto i*byte_size),
			sdram_dq   => sdram_dq((i+1)*byte_size-1 downto i*byte_size),

			tp         => tp_dq(i*32+1 to (i+1)*32));
	end generate;
	phy_locked <= '1' when dqs_locked=(dqs_locked'range => '1') else '0';
	sys_dqo <= unshuffle_vector(dqo, gear => gear, size => byte_size);
end;
