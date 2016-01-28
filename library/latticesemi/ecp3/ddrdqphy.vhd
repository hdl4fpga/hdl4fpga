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

entity ddrdqphy is
	generic (
		line_size : natural;
		byte_size : natural);
	port (
		dqsbufd_rst : in  std_logic;
		sys_sclk : in  std_logic;
		sys_eclk1 : in std_logic;
		sys_eclk : in  std_logic;
		sys_eclkw : in  std_logic;
		sys_dqsdel : in  std_logic;
		sys_rw : in  std_logic;
		sys_wlreq : in  std_logic;
		sys_wlrdy : out std_logic;
		sys_dmt  : in  std_logic_vector(0 to line_size/byte_size-1) := (others => '-');
		sys_dmi  : in  std_logic_vector(line_size/byte_size-1 downto 0) := (others => '-');
		sys_dmo  : out std_logic_vector(line_size/byte_size-1 downto 0);
		sys_dqo  : in  std_logic_vector(line_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(0 to line_size/byte_size-1);
		sys_dqi  : out std_logic_vector(line_size-1 downto 0);
		sys_dqso : in  std_logic_vector(0 to line_size/byte_size-1);
		sys_dqst : in  std_logic_vector(0 to line_size/byte_size-1);
		sys_wlpha : out std_logic_vector(8-1 downto 0);
		sys_test : out std_logic;

		sys_pll  : out std_logic_vector(0 to 4-1);
		ddr_dmt  : out std_logic;
		ddr_dmi  : in  std_logic := '-';
		ddr_dmo  : out std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqsi : in  std_logic;
		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

	constant test : boolean := true;
end;

library ecp3;
use ecp3.components.all;

library hdl4fpga;

architecture ecp3 of ddrdqphy is

	signal idqs_eclk  : std_logic;
	signal dqsw  : std_logic;
	signal dqclk0 : std_logic;
	signal dqclk1 : std_logic;
	
	signal prmbdet : std_logic;
	signal ddrclkpol : std_logic := '1';
	signal ddrlat : std_logic;
	signal rw : std_logic;
	
	signal wlpha : std_logic_vector(8-1 downto 0);
	signal dyndelay : std_logic_vector(8-1 downto 0);
	signal wlok : std_logic;

	signal dqt : std_logic_vector(sys_dqt'range);
	signal dqst : std_logic_vector(sys_dqst'range);
	signal dqso : std_logic_vector(sys_dqso'range);
	signal wle : std_logic;
	signal wlrdy : std_logic;
	signal dqsbufd_rsto : std_logic;

begin

	process (sys_sclk, sys_rw)
		variable q : std_logic := '0';
	begin
		if rising_edge(sys_sclk) then
			q := not q;
		end if;
		if test then
			rw <= q;
		else
			rw <= sys_rw;
		end if;
	end process;
	sys_test <= rw;

	sys_wlpha <= wlpha;
	sys_wlrdy <= wlrdy;
	adjpha_e : entity hdl4fpga.adjdqs
	port map (
		clk => sys_sclk,
		rdy => wlrdy,
		req => sys_wlreq,
		smp => wlok,
		pha => wlpha);

	dqsbuf_b : block
		signal q1, q2 : std_logic;
		signal sys_eclk_n : std_logic;
		signal sys_sclk_n : std_logic;
		signal rst : std_logic;

	begin
		sys_sclk_n <= not sys_sclk;
		ff0 : entity hdl4fpga.ff
		port map (
			clk => sys_sclk_n,
			d   => dqsbufd_rst,
			q   => rst);

		sys_eclk_n <= not sys_eclk1;
		ff1 : entity hdl4fpga.ff
		port map (
			clk => sys_eclk1,
			d   => rst,
			q   => q1);

		ff2 : entity hdl4fpga.ff
		port map (
			clk => sys_eclk_n,
			d   => q1,
			q   => q2);

		ff3 : entity hdl4fpga.ff
		port map (
			clk => sys_eclk1,
			d   => q2,
			q   => dqsbufd_rsto);

	end block;

	dyndelay <= wlpha;
	dqsbufd_i : dqsbufd 
	port map (
		dqsdel => sys_dqsdel,
		dqsi   => ddr_dqsi,
		eclkdqsr => idqs_eclk,

		sclk => sys_sclk,
		read => rw,
		ddrclkpol => ddrclkpol,
		ddrlat  => ddrlat,
		prmbdet => prmbdet,

		eclk => sys_eclk,
		datavalid => open,

		rst  => dqsbufd_rsto,
		dyndelay0 => '0', --dyndelay(0),
		dyndelay1 => '0', --dyndelay(1),
		dyndelay2 => '0', --dyndelay(2),
		dyndelay3 => '0', --dyndelay(3),
		dyndelay4 => '0', --dyndelay(4),
		dyndelay5 => '0', --dyndelay(5),
		dyndelay6 => '0', --dyndelay(6),
		dyndelpol => '0', --dyndelay(7),
		eclkw => sys_eclkw,

		dqsw => dqsw,
		dqclk0 => dqclk0,
		dqclk1 => dqclk1);


	iddr_g : for i in 0 to byte_size-1 generate
		attribute iddrapps : string;
--		attribute iddrapps of iddrx2d_i : label is "DQS_ALIGNED";
		attribute iddrapps of iddrx2d_i : label is "DQS_CENTERED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_sclk,
			eclk => sys_eclk,
			eclkdqsr => idqs_eclk,
			ddrclkpol => ddrclkpol,
			ddrlat => ddrlat,
			d   => ddr_dqi(i),
			qa0 => sys_dqi(0*byte_size+i),
			qb0 => sys_dqi(1*byte_size+i),
			qa1 => sys_dqi(2*byte_size+i),
			qb1 => sys_dqi(3*byte_size+i));
	end generate;
	wlok <= ddr_dqi(0);

	dmi_g : block
		attribute iddrapps : string;
--		attribute iddrapps of iddrx2d_i : label is "DQS_ALIGNED";
		attribute iddrapps of iddrx2d_i : label is "DQS_CENTERED";
	begin
		iddrx2d_i : iddrx2d
		port map (
			sclk => sys_sclk,
			eclk => sys_eclk,
			eclkdqsr => idqs_eclk,
			ddrclkpol => ddrclkpol,
			ddrlat => ddrlat,
			d   => ddr_dmi,
			qa0 => sys_dmo(0),
			qb0 => sys_dmo(1),
			qa1 => sys_dmo(2),
			qb1 => sys_dmo(3));
	end block;

	wle <= not wlrdy and sys_wlreq;
	dqt <= sys_dqt when wle='0' else (others => '1');
	oddr_g : for i in 0 to byte_size-1 generate
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
		signal ta : std_logic;
		signal da0, db0, da1, db1 : std_logic;
		signal dat : std_logic;
	begin
		ta  <= dqt(0) when wle='0' and not test else '0';

		oddrtdqa_i : oddrtdqa
		port map (
			sclk => sys_sclk,
			ta => ta, --dqt(0),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q  => ddr_dqt(i));

		process (sys_sclk)
		begin
			if rising_edge(sys_sclk) then
				if wle='0' and not test then
					dat <= '1';
				else
					dat <= not dat;
				end if;
--				dat <= '1';
			end if;
		end process;

		da0 <= sys_dqo(0*byte_size+i) when wle='0' and not test else not dat;
		db0 <= sys_dqo(1*byte_size+i) when wle='0' and not test else dat;
		da1 <= sys_dqo(2*byte_size+i) when wle='0' and not test else dat;
		db1 <= sys_dqo(3*byte_size+i) when wle='0' and not test else not dat;

		oddrx2d_i : oddrx2d
		port map (
			sclk => sys_sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0 => da0,
			db0 => db0,
			da1 => da1,
			db1 => db1,
			q   => ddr_dqo(i));
	end generate;

	dm_b : block
		attribute oddrapps : string;
		attribute oddrapps of oddrx2d_i : label is "DQS_ALIGNED";
	begin
		oddrtdqa_i : oddrtdqa
		port map (
			sclk => sys_sclk,
			ta => sys_dmt(0),
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			q  => ddr_dmt);

		oddrx2d_i : oddrx2d
		port map (
			sclk => sys_sclk,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			da0 => sys_dmi(0),
			db0 => sys_dmi(1),
			da1 => sys_dmi(2),
			db1 => sys_dmi(3),
			q   => ddr_dmo);
	end block;

	dqst <= sys_dqst when wle='0' and not test else (others => '0');
	dqso <= sys_dqso when wle='0' and not test else (others => '1');
	dqso_b : block 
		signal dqstclk : std_logic;
		attribute oddrapps : string;
		attribute oddrapps of oddrx2dqsa_i : label is "DQS_CENTERED";
	begin

		oddrtdqsa_i : oddrtdqsa
		port map (
			sclk => sys_sclk,
			db => dqst(0),
			ta => dqst(2),
			dqstclk => dqstclk,
			dqsw => dqsw,
			q => ddr_dqst);

		oddrx2dqsa_i : oddrx2dqsa
		port map (
			sclk => sys_sclk,
			db0 => dqso(2*1),
			db1 => dqso(2*0),
			dqsw => dqsw,
			dqclk0 => dqclk0,
			dqclk1 => dqclk1,
			dqstclk => dqstclk,
			q => ddr_dqso);

	end block;
end;
