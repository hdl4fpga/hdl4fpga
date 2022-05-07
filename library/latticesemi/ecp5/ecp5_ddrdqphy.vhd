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

library ecp5u;
use ecp5u.components.all;

entity ecp5_ddrdqphy is
	generic (
		taps        : natural;
		data_gear   : natural;
		byte_size   : natural);
	port (
		rst         : in  std_logic;
		read        : in  std_logic_vector(2-1 downto 0);
		readclksel  : in  std_logic_vector(3-1 downto 0);
		sclk        : in  std_logic;
		eclk        : in  std_logic;
		ddrdel      : in  std_logic;

		phy_rw      : in  std_logic;
		phy_wlreq   : in  std_logic;
		phy_wlrdy   : buffer std_logic;
		phy_dmt     : in  std_logic_vector(0 to data_gear-1) := (others => '-');
		phy_dmi     : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		phy_dmo     : out std_logic_vector(data_gear-1 downto 0);
		phy_dqo     : out std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqt     : in  std_logic_vector(0 to data_gear-1);
		phy_dqi     : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		phy_dqso    : in  std_logic_vector(0 to data_gear-1);
		phy_dqst    : in  std_logic_vector(0 to data_gear-1);
		phy_wlpha   : buffer std_logic_vector(8-1 downto 0);

		ddr_dmt     : out std_logic;
		ddr_dmi     : in  std_logic := '-';
		ddr_dmo     : out std_logic;
		ddr_dqi     : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt     : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo     : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqsi    : in  std_logic;
		ddr_dqst    : out std_logic;
		ddr_dqso    : out std_logic);

end;

library hdl4fpga;

architecture lscc of ecp5_ddrdqphy is

	signal dqsr90  : std_logic;
	signal dqsw270 : std_logic;
	signal dqsw    : std_logic;
	
	
	signal dqi    : std_logic_vector(phy_dqi'range);

	signal dqt    : std_logic_vector(phy_dqt'range);
	signal dqst   : std_logic_vector(phy_dqst'range);
	signal dqso   : std_logic_vector(phy_dqso'range);
	signal wle    : std_logic;

	signal rdpntr : std_logic_vector(3-1 downto 0);
	signal wrpntr : std_logic_vector(3-1 downto 0);

begin

	wl_b : block
		signal step_rdy : std_logic;
		signal step_req : std_logic;
	begin

		step_delay_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 4))
		port map (
			clk => sclk,
			di(0) => step_req,
			do(0) => step_rdy);
	
		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			taps     => taps)
		port map (
			edge     => std_logic'('1'),
			clk      => sclk,
			req      => phy_wlreq,
			rdy      => phy_wlrdy,
			step_req => step_req,
			step_rdy => step_rdy,
			smp      => ddr_dqi(0 downto 0),
			delay    => phy_wlpha);

		dqsbufm_i : dqsbufm 
		port map (
			rst       => rst,
			sclk      => sclk,
			eclk      => eclk,

			ddrdel    => ddrdel,
			dqsi      => ddr_dqsi,
			dqsr90    => dqsr90,
	
			read0     => read(0),
			read1     => read(1),
			readclksel0 => readclksel(0),
			readclksel1 => readclksel(1),
			readclksel2 => readclksel(2),

			rdpntr0   => rdpntr(0),
			rdpntr1   => rdpntr(1),
			rdpntr2   => rdpntr(2),
			wrpntr0   => wrpntr(0),
			wrpntr1   => wrpntr(1),
			wrpntr2   => wrpntr(2),
	

			datavalid => open,
			burstdet  => open,
			rdcflag   => open,
			wrcflag   => open,
	
			rdloadn   => '0',
			rddirection => '0',
			wrloadn   => '0',
			wrdirection => '0',
			pause => '0',
			dyndelay0 => '0', --phy_wlpha(0),
			dyndelay1 => '0', --phy_wlpha(1),
			dyndelay2 => '0', --phy_wlpha(2),
			dyndelay3 => '0', --phy_wlpha(3),
			dyndelay4 => '0', --phy_wlpha(4),
			dyndelay5 => '0', --phy_wlpha(5),
			dyndelay6 => '0', --phy_wlpha(6),
			dyndelay7 => '0', --phy_wlpha(7),
	
			dqsw      => dqsw,
			dqsw270   => dqsw270);

	end block;

	iddr_g : for i in 0 to byte_size-1 generate
		attribute iddrapps : string;
		attribute iddrapps of iddrx2_i : label is "DQS_ALIGNED";
	begin
		iddrx2_i : iddrx2dqa
		port map (
			sclk    => sclk,
			eclk    => eclk,
			dqsr90  => dqsr90,
			rdpntr0 => rdpntr(0),
			rdpntr1 => rdpntr(1),
			rdpntr2 => rdpntr(2),
			wrpntr0 => wrpntr(0),
			wrpntr1 => wrpntr(1),
			wrpntr2 => wrpntr(2),
			d       => ddr_dqi(i),
			q0      => phy_dqo(0*byte_size+i),
			q1      => phy_dqo(1*byte_size+i),
			q2      => phy_dqo(2*byte_size+i),
			q3      => phy_dqo(3*byte_size+i));
	end generate;

	dmi_g : block
		attribute iddrapps : string;
		attribute iddrapps of iddrx2_i : label is "DQS_ALIGNED";
	begin
		iddrx2_i : iddrx2dqa
		port map (
			sclk => sclk,
			eclk => eclk,
			dqsr90 => dqsr90,
			d    => ddr_dmi,
			q0   => phy_dmo(0),
			q1   => phy_dmo(1),
			q2   => phy_dmo(2),
			q3   => phy_dmo(3));
	end block;

	process (sclk)
	begin
		if rising_edge(sclk) then
			wle <= phy_wlrdy xor phy_wlreq;
		end if;
	end process;
	dqt <= phy_dqt when wle='0' else (others => '1');
	oddr_g : for i in 0 to byte_size-1 generate
		attribute oddrapps : string;
		attribute oddrapps of tshx2dqa_i : label is "DQS_ALIGNED";
	begin
		tshx2dqa_i : tshx2dqa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			t0  => dqt(0),
			t1  => dqt(0),
			q   => ddr_dqt(i));

		oddrx2dqa_i : oddrx2dqa
		port map (
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
		attribute oddrapps : string;
		attribute oddrapps of oddrx2dqa_i : label is "DQS_ALIGNED";
	begin
		tshx2dqa_i : tshx2dqa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw270 => dqsw270,
			t0  => dqt(0),
			t1  => dqt(0),
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
		signal dqstclk : std_logic;
		attribute oddrapps : string;
		attribute oddrapps of tshx2dqsa_i : label is "DQS_CENTERED";
	begin

		tshx2dqsa_i : tshx2dqsa
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw => dqsw270,
			t0   => dqst(0),
			t1   => dqst(0),
			q    => ddr_dqst);

		oddrx2dqsb_i : oddrx2dqsb
		port map (
			rst  => rst,
			sclk => sclk,
			eclk => eclk,
			dqsw => dqsw270,
			d0   => '0',
			d1   => dqso(2*0),
			d2   => '0',
			d3   => dqso(2*1),
			q    => ddr_dqso);

	end block;
end;
