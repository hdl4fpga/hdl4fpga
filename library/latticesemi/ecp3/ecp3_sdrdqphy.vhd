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

library ecp3;
use ecp3.components.all;

entity ecp3_sdrdqphy is
	generic (
		taps      : natural := 0;
		data_gear : natural;
		byte_size : natural);
	port (
		rst       : in  std_logic;
		sclk      : in  std_logic;
		eclk      : in  std_logic;
		dqsdel    : in  std_logic;
		pause     : in  std_logic;

		phy_wlreq : in  std_logic;
		phy_wlrdy : buffer std_logic;
		phy_rlreq : in  std_logic := 'U';
		phy_rlrdy : buffer std_logic;
		read_rdy  : in  std_logic;
		read_req  : buffer std_logic;
		burst     : out std_logic;
		locked    : out std_logic;
		phy_sti   : in  std_logic;
		phy_sto   : out std_logic;
		phy_dmi   : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		phy_dmo   : out std_logic_vector(data_gear-1 downto 0);
		phy_dqo   : out std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqt   : in  std_logic_vector(data_gear-1 downto 0);
		phy_dqi   : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqso  : in  std_logic_vector(data_gear-1 downto 0);
		phy_dqst  : in  std_logic_vector(data_gear-1 downto 0);

		sdr_dmt   : out std_logic;
		sdr_dmi   : in  std_logic := '-';
		sdr_dmo   : out std_logic;
		sdr_dqi   : in  std_logic_vector(byte_size-1 downto 0);
		sdr_dqt   : out std_logic_vector(byte_size-1 downto 0);
		sdr_dqo   : out std_logic_vector(byte_size-1 downto 0);

		sdr_dqsi  : in  std_logic;
		sdr_dqst  : out std_logic;
		sdr_dqso  : out std_logic);

end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture ecp3 of ecp3_sdrdqphy is
	
	signal dqsw         : std_logic;
	signal dqclk0       : std_logic;
	signal dqclk1       : std_logic;

	signal dqi          : std_logic_vector(sdr_dqi'range);

	signal dqt          : std_logic_vector(phy_dqt'range);
	signal dqst         : std_logic_vector(phy_dqst'range);
	signal dqso         : std_logic_vector(phy_dqso'range);
	signal wle          : std_logic;

	signal dyndelay     : std_logic_vector(8-1 downto 0);
	signal read         : std_logic;

	signal eclkdqsr     : std_logic;
	signal prmbdet      : std_logic;
	signal dqs_pause    : std_logic;
	signal ddrclkpol    : std_logic;
	signal ddrlat       : std_logic;
	signal datavalid    : std_logic;

	signal adjstep_req  : bit;
	signal adjstep_rdy  : bit;

	signal wlpause_rdy  : bit;
	signal wlpause_req  : bit;
	signal lv_pause     : std_logic;

	signal wlstep_req   : std_logic;
	signal wlstep_rdy   : std_logic;
	signal dqi0         : std_logic;

	constant delay      : time := 5 ns;
	signal dqsi         : std_logic;

begin

	rl_b : block
		signal lat     : unsigned(3-1 downto 0);
		signal read_r  : std_logic;
		signal read_f  : std_logic;
		signal prmb_r  : std_logic;
		signal prmb_f  : std_logic;
	begin

		process (sclk)
			variable q : unsigned(0 to 8-1);
		begin
			if rising_edge(sclk) then
				q      := shift_right(q, 1);
				q(0)   := phy_sti;
				read_r <= not multiplex(q, shift_right(lat, 1));
				prmb_r <= prmbdet;
				phy_sto <= multiplex(
					multiplex(shift_left(q,2) & shift_left(q,3), lat(0)),
					shift_right(lat,1));
			end if;
		end process;

		process (sclk)
			variable q : std_logic_vector(0 to 4-1);
		begin
			if falling_edge(sclk) then
				read_f <= read_r;
				prmb_f <= prmbdet;
			end if;
		end process;
		read <= multiplex(read_r & read_f, lat(0));

		adjsto_b : block
			signal det : std_logic;
		begin
			process (sclk)
			begin
				if rising_edge(sclk) then
					det <= '0';
					if lat(0)='0' then
						if read_r='0' then
							if datavalid='1' then
								det <= '1';
							end if;
						end if;
					elsif read_r='1' then
						if datavalid='1' then
							det <= '1';
						end if;
					end if;
				end if;
			end process;
	
			process (phy_rlrdy, sclk)
				type states is (s_init, s_prmb, s_wait);
				variable state : states;
				variable cntr  : unsigned(0 to 8);
			begin
				if rising_edge(sclk) then
					if rst='1' then
						phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
						locked    <= '0';
						state     := s_init;
					elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
						case state is
						when s_init =>
							lat      <= (others => '0');
							cntr     := (others => '0');
							locked   <= '0';
							read_req <= not to_stdulogic(to_bit(read_rdy));
							state    := s_prmb;
						when s_prmb =>
							if (read_req xor read_rdy)='0' then
								if det='1' then
									if cntr(0)='1' then
										state := s_wait;
									else
										cntr  := cntr + 1;
									end if;
								else
									cntr  := (others => '0');
									lat   <= lat + 1;
									state := s_prmb;
								end if;
								read_req <= not to_stdulogic(to_bit(read_rdy));
							end if;
						when s_wait =>
							cntr := (others => '-');
							locked <= '1';
							if (read_req xor read_rdy)='0' then
								phy_rlrdy <= to_stdulogic(to_bit(phy_rlreq));
								state     := s_init;
							end if;
						end case;
					else
						cntr  := (others => '-');
						state := s_init;
					end if;
				end if;
			end process;
		end block;


	end block;

	wl_b : block
		signal d : std_logic_vector(0 to 0);
	begin

		d(0) <= to_stdulogic(to_bit(dqi(0)));
		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			dtaps    => 1,
			taps     => taps)
		port map (
			rst      => rst,
			edge     => std_logic'('1'),
			clk      => sclk,
			req      => phy_wlreq,
			rdy      => phy_wlrdy,
			step_req => wlstep_req,
			step_rdy => wlstep_rdy,
			smp      => d,
			delay    => dyndelay);

	end block;
	wlpause_req <= to_bit(wlstep_req);
	wlstep_rdy  <= to_stdulogic(wlpause_rdy);

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

		pause_req   <= wlpause_req;
		wlpause_rdy <= pause_rdy;

	end block;

	dqs_pause <= pause or lv_pause;
	dqsi <= transport sdr_dqsi after delay;
	dqsbufd_i : dqsbufd 
--	generic map (
--		nrzmode => "ENABLED")
	port map (
		rst       => rst,
		sclk      => sclk,
		eclk      => eclk,
		eclkw     => eclk,
		dqsdel    => dqsdel,

		read      => read,
		dqsi      => dqsi,
		eclkdqsr  => eclkdqsr,

		prmbdet   => prmbdet,
		ddrclkpol => ddrclkpol,
		ddrlat    => ddrlat,
		datavalid => datavalid,

		dyndelay0 => dyndelay(0),
		dyndelay1 => dyndelay(1),
		dyndelay2 => dyndelay(2),
		dyndelay3 => dyndelay(3),
		dyndelay4 => dyndelay(4),
		dyndelay5 => dyndelay(5),
		dyndelay6 => dyndelay(6),
		dyndelpol => dyndelay(7),

		dqsw      => dqsw,
		dqclk0    => dqclk0,
		dqclk1    => dqclk1);

	dqi <= transport sdr_dqi after delay;
	iddr_g : for i in sdr_dqi'range generate
		attribute iddrapps : string;
		attribute iddrapps of iddrx2d_i : label is "DQS_ALIGNED";
	begin

		iddrx2d_i : iddrx2d
		port map (
			sclk      => sclk,
			eclk      => eclk,
			eclkdqsr  => eclkdqsr,
			ddrclkpol => ddrclkpol,
			ddrlat    => ddrlat,
			d         => dqi(i),
			qa0       => phy_dqo(0*byte_size+i),
			qb0       => phy_dqo(1*byte_size+i),
			qa1       => phy_dqo(2*byte_size+i),
			qb1       => phy_dqo(3*byte_size+i));
	end generate;

	dmi_g : block
		attribute iddrapps : string;
		attribute iddrapps of iddrx2d_i : label is "DQS_ALIGNED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk      => sclk,
			eclk      => eclk,
			eclkdqsr  => eclkdqsr,
			ddrclkpol => ddrclkpol,
			ddrlat    => ddrlat,
			d         => sdr_dmi,
			qa0       => phy_dmo(0),
			qb0       => phy_dmo(1),
			qa1       => phy_dmo(2),
			qb1       => phy_dmo(3));
	end block;

	wle <= to_stdulogic(to_bit(phy_wlrdy)) xor phy_wlreq;
	dqt <= phy_dqt when wle='0' else (others => '1');

	oddr_g : for i in 0 to byte_size-1 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk   => sclk,
			ta     => dqt(3),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q      => sdr_dqt(i));

		oddrx2d_i : oddrx2d
		port map (
			sclk   => sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0    => phy_dqi(3*byte_size+i),
			db0    => phy_dqi(2*byte_size+i),
			da1    => phy_dqi(1*byte_size+i),
			db1    => phy_dqi(0*byte_size+i),
			q      => sdr_dqo(i));
	end generate;

	dm_b : block
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk   => sclk,
			ta     => dqt(3),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q      => sdr_dmt);

		oddrx2d_i : oddrx2d
		port map (
			sclk   => sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0    => phy_dmi(3),
			db0    => phy_dmi(2),
			da1    => phy_dmi(1),
			db1    => phy_dmi(0),
			q      => sdr_dmo);
	end block;

	dqst <= phy_dqst when wle='0' else (others => '0');
	dqso <= phy_dqso when wle='0' else (others => '1');

	dqso_b : block 
		attribute oddrapps : string;
		attribute oddrapps of oddrx2dqsa_i : label is "DQS_CENTERED";

		signal dqstclk : std_logic;
	begin
		oddrtdqsa_i : oddrtdqsa
		port map (
			sclk    => sclk,
			db      => dqst(2),
			ta      => dqst(0),
			dqstclk => dqstclk,
			dqsw    => dqsw,
			q       => sdr_dqst);

		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk    => sclk,
			db0     => dqso(0),
			db1     => dqso(2),
			dqsw    => dqsw,
			dqclk0  => dqclk0,
			dqclk1  => dqclk1,
			dqstclk => dqstclk,
			q       => sdr_dqso);
	end block;
end;
