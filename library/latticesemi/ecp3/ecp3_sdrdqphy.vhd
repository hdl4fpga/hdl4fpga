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

entity ecp3_sdrdqphy is
	generic (
		wl_delay   : time := 0 ns;

		taps      : natural := 0;
		gear      : natural;
		byte_size : natural);
	port (
		rst        : in  std_logic;
		sclk       : in  std_logic;
		eclk       : in  std_logic;
		dqsdel     : in  std_logic;
		pause      : in  std_logic;

		phy_wlreq  : in  std_logic;
		phy_wlrdy  : buffer std_logic;
		phy_rlreq  : in  std_logic := '-';
		phy_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		burst      : out std_logic;
		phy_locked : out std_logic;

		sys_sti    : in  std_logic_vector(gear-1 downto 0);
		sys_sto    : buffer std_logic_vector(gear-1 downto 0);
		sys_dmt    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dmi    : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_dmo    : out std_logic_vector(gear-1 downto 0);
		sys_dqo    : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(gear-1 downto 0);
		sys_dqv    : in  std_logic_vector(gear-1 downto 0) := (others => '0');
		sys_dqi    : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(gear-1 downto 0);
		sys_dqst   : in  std_logic_vector(gear-1 downto 0);

		sdram_dqs  : inout  std_logic;
		sdram_dqst : buffer std_logic;
		sdram_dqso : buffer std_logic;

		sdram_dm   : inout  std_logic;
		sdram_dmo  : buffer std_logic;

		sdram_dqt  : buffer std_logic_vector(byte_size-1 downto 0);
		sdram_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		sdram_dqo  : buffer std_logic_vector(byte_size-1 downto 0);
		sdram_dq   : inout std_logic_vector(byte_size-1 downto 0));


end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture ecp3 of ecp3_sdrdqphy is
	
	signal dqsw         : std_logic;
	signal dqclk0       : std_logic;
	signal dqclk1       : std_logic;

	signal dqi          : std_logic_vector(sdram_dq'range);

	signal dqt          : std_logic_vector(sys_dqt'range);
	signal dqst         : std_logic_vector(sys_dqst'range);
	signal dqsi         : std_logic_vector(sys_dqsi'range);
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

	signal sdram_dmt    : std_logic;
	constant delay      : time := 5 ns;

begin

	rl_b : block
		signal lat     : unsigned(3-1 downto 0);
		signal read_r  : std_logic;
		signal read_f  : std_logic;
		signal prmb_r  : std_logic;
		signal prmb_f  : std_logic;
		signal sto     : std_logic;
	begin

		process (sclk)
			variable q : unsigned(0 to 8-1);
		begin
			if rising_edge(sclk) then
				q      := shift_right(q, 1);
				q(0)   := sys_sti(sys_sti'right);
				read_r <= not multiplex(q, shift_right(lat, 1));
				prmb_r <= prmbdet;
				sto <= multiplex(
					multiplex(shift_left(q,2) & shift_left(q,3), lat(0)),
					shift_right(lat,1));
			end if;
		end process;
		sys_sto <= (others => sto);

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
						phy_rlrdy  <= to_stdulogic(to_bit(phy_rlreq));
						phy_locked <= '0';
						state     := s_init;
					elsif (phy_rlrdy xor to_stdulogic(to_bit(phy_rlreq)))='1' then
						case state is
						when s_init =>
							lat  <= (others => '0');
							cntr := (others => '0');
							phy_locked <= '0';
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
							phy_locked <= '1';
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
		dqsi      => sdram_dqs,
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

	dqi <= transport sdram_dq after delay;
	iddr_g : for i in sdram_dq'range generate
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
			qa0       => sys_dqo(0*byte_size+i),
			qb0       => sys_dqo(1*byte_size+i),
			qa1       => sys_dqo(2*byte_size+i),
			qb1       => sys_dqo(3*byte_size+i));
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
			d         => sdram_dm,
			qa0       => sys_dmo(0),
			qb0       => sys_dmo(1),
			qa1       => sys_dmo(2),
			qb1       => sys_dmo(3));
	end block;

	wle <= to_stdulogic(to_bit(phy_wlrdy)) xor phy_wlreq;
	dqt <= sys_dqt when wle='0' else (others => '1');

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
			q      => sdram_dqt(i));

		oddrx2d_i : oddrx2d
		port map (
			sclk   => sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0    => sys_dqi(3*byte_size+i),
			db0    => sys_dqi(2*byte_size+i),
			da1    => sys_dqi(1*byte_size+i),
			db1    => sys_dqi(0*byte_size+i),
			q      => sdram_dqo(i));

			sdram_dq(i) <= transport sdram_dqo(i) after wl_delay when sdram_dqt(i)='0' else 'Z' after wl_delay;
	end generate;

	dm_b : block
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk   => sclk,
			ta     => sys_dmt(0),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q      => sdram_dmt);

		oddrx2d_i : oddrx2d
		port map (
			sclk   => sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0    => sys_dmi(3),
			db0    => sys_dmi(2),
			da1    => sys_dmi(1),
			db1    => sys_dmi(0),
			q      => sdram_dmo);

		sdram_dm <= transport sdram_dmo after wl_delay when sdram_dmt='0' else 'Z' after wl_delay;
	end block;

	dqst <= sys_dqst when wle='0' else (others => '0');
	dqsi <= sys_dqsi when wle='0' else (others => '1');

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
			q       => sdram_dqst);

		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk    => sclk,
			db0     => dqsi(0),
			db1     => dqsi(2),
			dqsw    => dqsw,
			dqclk0  => dqclk0,
			dqclk1  => dqclk1,
			dqstclk => dqstclk,
			q       => sdram_dqso);
	end block;
end;
