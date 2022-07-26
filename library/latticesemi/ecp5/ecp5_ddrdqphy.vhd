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

library ecp5u;
use ecp5u.components.all;

entity ecp5_ddrdqphy is
	generic (
		taps      : natural;
		data_gear : natural;
		byte_size : natural);
	port (
		rst       : in  std_logic;
		sclk      : in  std_logic;
		eclk      : in  std_logic;
		ddrdel    : in  std_logic;
		pause     : in  std_logic;

		phy_wlreq : in  std_logic;
		phy_wlrdy : buffer std_logic;
		phy_rlreq : in  std_logic := 'U';
		phy_rlrdy : buffer std_logic;
		read_rdy  : in  std_logic;
		read_req  : buffer std_logic;
		phy_sti   : in  std_logic;
		phy_sto   : out std_logic;
		phy_dmt   : in  std_logic_vector(0 to data_gear-1) := (others => '-');
		phy_dmi   : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		phy_dmo   : out std_logic_vector(data_gear-1 downto 0);
		phy_dqo   : out std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqt   : in  std_logic_vector(0 to data_gear-1);
		phy_dqi   : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqso  : in  std_logic_vector(0 to data_gear-1);
		phy_dqst  : in  std_logic_vector(0 to data_gear-1);

		ddr_dmt   : out std_logic;
		ddr_dmi   : in  std_logic := '-';
		ddr_dmo   : out std_logic;
		ddr_dqi   : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt   : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo   : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqsi  : in  std_logic;
		ddr_dqst  : out std_logic;
		ddr_dqso  : out std_logic;
		tp : out std_logic_vector(1 to 32));

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture lscc of ecp5_ddrdqphy is

	signal dqsr90       : std_logic;
	signal dqsw         : std_logic;
	signal dqsw270      : std_logic;
	
	signal dqi          : std_logic_vector(phy_dqi'range);

	signal dqt          : std_logic_vector(phy_dqt'range);
	signal dqst         : std_logic_vector(phy_dqst'range);
	signal dqso         : std_logic_vector(phy_dqso'range);
	signal wle          : std_logic;

	signal rdpntr       : std_logic_vector(3-1 downto 0);
	signal wrpntr       : std_logic_vector(3-1 downto 0);

	signal read         : std_logic_vector(0 to 2-1);
	signal lat          : std_logic_vector(3-1 downto 0);
	signal readclksel   : std_logic_vector(3-1 downto 0);
	signal wlpha        : std_logic_vector(8-1 downto 0);
	signal burstdet     : std_logic;
	signal dqs_pause    : std_logic;
	signal datavalid    : std_logic;

	signal adjstep_req  : bit;
	signal adjstep_rdy  : bit;

	signal rlpause_rdy  : bit;
	signal rlpause_req  : bit;
	signal rlpause1_rdy : bit;
	signal rlpause1_req : bit;
	signal wlpause_rdy  : bit;
	signal wlpause_req  : bit;
	signal lv_pause     : std_logic;

	constant delay      : time := 0.5 ns;
	signal dqsi         : std_logic;

	signal wlstep_req   : std_logic;
	signal wlstep_rdy   : std_logic;
	signal dqi0         : std_logic;
begin

	rl_b : block
		signal step_req : std_logic;
		signal step_rdy : std_logic;
		signal adj_req  : std_logic;
		signal adj_rdy  : std_logic;

	begin

		lat_b : block
			signal q : std_logic_vector(0 to 5-1);
		begin
			q(0) <= phy_sti;
			process(sclk)
			begin
				if rising_edge(sclk) then
					q(1 to q'right) <= q(0 to q'right-1);
				end if;
			end process;
			read(1) <= word2byte(q(0 to q'right-1), lat, 1)(0);
			read(0) <= read(1);
		end block;

		adjbrst_e : entity hdl4fpga.adjbrst
		port map (
			sclk       => sclk,
			adj_req    => adj_req,
			adj_rdy    => adj_rdy,
			step_req   => step_req,
			step_rdy   => step_rdy,
			read       => read(1),
			datavalid  => datavalid,
			burstdet   => burstdet,
			lat        => lat,
			readclksel => readclksel);
		phy_sto <= datavalid;
		tp(1 to 6) <= lat & readclksel;

		process (sclk, read_req)
			type states is (s_start, s_adj, s_paused);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if (to_bit(phy_rlreq) xor to_bit(phy_rlrdy))='1' then
					case state is
					when s_start =>
						adj_req <= not to_stdulogic(to_bit(adj_rdy));
						state := s_adj;
					when s_adj =>
						if (to_bit(adj_req) xor to_bit(adj_rdy))='0' then
							rlpause1_req <= not rlpause1_rdy;
							state := s_paused;
						end if;
					when s_paused =>
						if (rlpause1_req xor rlpause1_rdy)='0' then
							phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
							state := s_start;
						end if;
					end case;
				else
					rlpause1_req <= rlpause1_rdy;
					state       := s_start;
				end if;
			end if;
		end process;

		process (sclk, read_req)
			type states is (s_start, s_pause, s_read);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if (to_bit(adj_req) xor to_bit(adj_rdy))='1' then
					if (to_bit(step_req) xor to_bit(step_rdy))='1' then
						case state is
						when s_start =>
							rlpause_req <= not rlpause_rdy;
							state := s_pause;
						when s_pause =>
							if (rlpause_req xor rlpause_rdy)='0' then
								read_req <= not to_stdulogic(to_bit(read_rdy));
								state    := s_read;
							end if;
						when s_read =>
							if (read_req xor to_stdulogic(to_bit(read_rdy)))='0' then
								step_rdy <= step_req;
								state    := s_start;
							end if;
						end case;
					end if;
				else
					rlpause_req <= rlpause_rdy;
					read_req    <= to_stdulogic(to_bit(read_rdy));
					state       := s_start;
				end if;
			end if;
		end process;

	end block;

	wl_b : block
		signal d : std_logic_vector(0 to 0);
	begin

		d(0) <= transport dqi0 after delay;
		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			dtaps => 1,
			taps     => taps)
		port map (
			edge     => std_logic'('0'),
			clk      => sclk,
			req      => phy_wlreq,
			rdy      => phy_wlrdy,
			step_req => wlstep_req,
			step_rdy => wlstep_rdy,
			smp      => d,
			delay    => wlpha);

	end block;
	wlpause_req <= to_bit(wlstep_req);
	wlstep_rdy <= to_stdulogic(wlpause_rdy);

	pause_b : block

		signal pause_req : bit;
		signal pause_rdy : bit;

	begin

		process (sclk)
			variable cntr : unsigned(0 to 6);
		begin
			if rising_edge(sclk) then
				if (pause_rdy xor pause_req)='0' then
					lv_pause <= '0';
					cntr := (others => '0');
				elsif cntr(0)='0' then
					if cntr(1)='0' then
						lv_pause <= '1';
					else
						lv_pause <= '0';
					end if;
					cntr := cntr + 1;
				else
					lv_pause  <= '0';
					pause_rdy <= pause_req;
				end if;
			end if;
		end process;

		process (sclk, pause_rdy )
			variable q : bit;
			variable y : bit;
		begin
			if rising_edge(sclk) then
				if (pause_rdy xor pause_req)='0' then
					if q='1' then
						pause_req <= not pause_rdy;
					end if;
					if y='1' then
						wlpause_rdy  <= wlpause_req;
						rlpause1_rdy <= rlpause1_req;
						rlpause_rdy  <= rlpause_req;
					else
						q := 
							(rlpause_req  xor rlpause_rdy)  or 
							(rlpause1_req xor rlpause1_rdy) or 
							(wlpause_req  xor wlpause_rdy);
					end if;
					y := '0';
				else
					q := '0';
					y := '1';
				end if;
			end if;
		end process;

	end block;

	dqs_pause <= pause or lv_pause;
	dqsi <= transport ddr_dqsi after delay;
	dqsbufm_i : dqsbufm 
	port map (
		rst       => rst,
		sclk      => sclk,
		eclk      => eclk,

		ddrdel    => ddrdel,
		pause     => dqs_pause,

		dqsi      => dqsi,
		dqsr90    => dqsr90,

		read1     => read(1),
		read0     => read(0),
		readclksel2 => readclksel(2),
		readclksel1 => readclksel(1),
		readclksel0 => readclksel(0),

		rdpntr2   => rdpntr(2),
		rdpntr1   => rdpntr(1),
		rdpntr0   => rdpntr(0),
		wrpntr2   => wrpntr(2),
		wrpntr1   => wrpntr(1),
		wrpntr0   => wrpntr(0),

		burstdet  => burstdet,
		datavalid => datavalid,
		rdmove    => '0',
		wrmove    => '0',
		rdcflag   => open,
		wrcflag   => open,

		rdloadn   => '0',
		rddirection => '0',
		wrloadn   => '0',
		wrdirection => '0',

		dyndelay0 => wlpha(0),
		dyndelay1 => wlpha(1),
		dyndelay2 => wlpha(2),
		dyndelay3 => wlpha(3),
		dyndelay4 => wlpha(4),
		dyndelay5 => wlpha(5),
		dyndelay6 => wlpha(6),
		dyndelay7 => wlpha(7),

		dqsw      => dqsw,
		dqsw270   => dqsw270);

	iddr_g : for i in 0 to byte_size-1 generate
		signal d : std_logic;
		signal z : std_logic;
	begin
		d <= transport ddr_dqi(i) after delay;
		dqi0_g : if i=0 generate
			dqi0 <= z;
		end generate;
		delay_i : delayg
		generic map (
			del_mode => "DQS_ALIGNED_X2")
		port map (
			a => d,
			z => z);

		iddrx2_i : iddrx2dqa
		port map (
			rst     => rst,
			sclk    => sclk,
			eclk    => eclk,
			dqsr90  => dqsr90,
			rdpntr2 => rdpntr(2),
			rdpntr1 => rdpntr(1),
			rdpntr0 => rdpntr(0),
			wrpntr2 => wrpntr(2),
			wrpntr1 => wrpntr(1),
			wrpntr0 => wrpntr(0),
			d       => z,
			q0      => phy_dqo(0*byte_size+i),
			q1      => phy_dqo(1*byte_size+i),
			q2      => phy_dqo(2*byte_size+i),
			q3      => phy_dqo(3*byte_size+i));
	end generate;

	dmi_g : block
		signal d : std_logic;
	begin
		delay_i : delayg
		generic map (
			del_mode => "DQS_ALIGNED_X2")
		port map (
			a => ddr_dmi,
			z => d);

		iddrx2_i : iddrx2dqa
		port map (
			rst     => rst,
			sclk    => sclk,
			eclk    => eclk,
			dqsr90  => dqsr90,
			rdpntr0 => rdpntr(0),
			rdpntr1 => rdpntr(1),
			rdpntr2 => rdpntr(2),
			wrpntr0 => wrpntr(0),
			wrpntr1 => wrpntr(1),
			wrpntr2 => wrpntr(2),
			d       => d,
			q0      => phy_dmo(0),
			q1      => phy_dmo(1),
			q2      => phy_dmo(2),
			q3      => phy_dmo(3));
	end block;

	wle <= to_stdulogic(to_bit(phy_wlrdy)) xor phy_wlreq;

	dqt <= phy_dqt when wle='0' else (others => '1');
	oddr_g : for i in 0 to byte_size-1 generate
		tshx2dqa_i : tshx2dqa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			t1  => dqt(2*0),
			t0  => dqt(2*1),
			q   => ddr_dqt(i));

		oddrx2dqa_i : oddrx2dqa
		port map (
			rst     => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			d0   => phy_dqi(0*byte_size+i),
			d1   => phy_dqi(1*byte_size+i),
			d2   => phy_dqi(2*byte_size+i),
			d3   => phy_dqi(3*byte_size+i),
			q    => ddr_dqo(i));
	end generate;

	dm_b : block
	begin
		tshx2dqa_i : tshx2dqa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			t0  => dqt(2*1),
			t1  => dqt(2*0),
			q   => ddr_dmt);

		oddrx2dqa_i : oddrx2dqa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			d0   => phy_dmi(0),
			d1   => phy_dmi(1),
			d2   => phy_dmi(2),
			d3   => phy_dmi(3),
			q    => ddr_dmo);
	end block;

	dqst <= phy_dqst when wle='0' else (others => '0');
	dqso <= phy_dqso when wle='0' else (others => '1');

	dqso_b : block 
	begin

		tshx2dqsa_i : tshx2dqsa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw => dqsw,
			t0   => dqst(2*1),
			t1   => dqst(2*0),
			q    => ddr_dqst);

		oddrx2dqsb_i : oddrx2dqsb
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw => dqsw,
			d0   => '0',
			d1   => dqso(2*1),
			d2   => '0',
			d3   => dqso(2*0),
			q    => ddr_dqso);

	end block;
end;