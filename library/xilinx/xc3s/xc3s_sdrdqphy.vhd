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

library unisim;
use unisim.vcomponents.all;

entity xc3s_sdrdqphy is
	generic (
		latency     : natural := 0;
--		rgtr_dout   : boolean;
		loopback    : boolean;
		gear        : natural;
		byte_size   : natural);
	port (
		clk0        : in std_logic;
		clk90       : in std_logic;
		phy_calreq  : in std_logic := '0';
		phy_dmt     : in  std_logic_vector(0 to gear-1) := (others => '-');
		phy_dmi     : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		phy_sti     : in  std_logic_vector(0 to gear-1) := (others => '-');
		phy_sto     : out std_logic_vector(0 to gear-1);
		phy_dqi     : in  std_logic_vector(gear*byte_size-1 downto 0);
		phy_dqt     : in  std_logic_vector(gear-1 downto 0);
		phy_dqo     : out std_logic_vector(gear*byte_size-1 downto 0);
		phy_dqsi    : in  std_logic_vector(0 to gear-1);
		phy_dqst    : in  std_logic_vector(0 to gear-1);

		sdr_dmt     : out std_logic;
		sdr_dmo     : out std_logic;
		sdr_dmi     : in  std_logic;
		sdr_sti     : in  std_logic := '-';
		sdr_sto     : out std_logic;
		sdr_dqi     : in  std_logic_vector(byte_size-1 downto 0);
		sdr_dqt     : out std_logic_vector(byte_size-1 downto 0);
		sdr_dqo     : out std_logic_vector(byte_size-1 downto 0);

		sdr_dqst    : out std_logic;
		sdr_dqsi    : in  std_logic;
		sdr_dqso    : out std_logic);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture xilinx of xc3s_sdrdqphy is
	signal clk0_n   : std_logic;
	signal clk90_n  : std_logic;
	signal igbx_clk1 : std_logic_vector(0 to 0);
begin

	clk0_n  <= not clk0;
	clk90_n <= not clk90;

	iddr_g : for i in 0 to byte_size-1 generate
		signal igbx_clk : std_logic_vector(0 to 0);
	begin

		igbx_clk(0) <= not sdr_dqsi;
		igbx_i : entity hdl4fpga.igbx
		generic map (
			device => hdl4fpga.profiles.xc3s,
			gear   => 2)
		port map (
			clk  => igbx_clk,
			d(0) => sdr_dqi(i),
			q(0) => phy_dqo(0*byte_size+i),
			q(1) => phy_dqo(1*byte_size+i));

		-- phase_g : for j in  gear-1 downto 0 generate
			-- phy_dqo(j*byte_size+i) <= sdr_dqi(i);
		-- end generate;
	end generate;

	sto_b : block
		signal igbx_clk : std_logic_vector(0 to 0);
		signal sti      : std_logic;
	begin
		igbx_clk(0) <= sdr_dqsi;
		sti <= sdr_sti when loopback else sdr_dmi;
		sto_i : entity hdl4fpga.igbx
		generic map (
			device => hdl4fpga.profiles.xc3s,
			gear   => 2)
		port map (
			clk  => igbx_clk,
			d(0) => sti,
			q    => phy_sto);
	end block;

	oddr_g : for i in 0 to byte_size-1 generate
		signal dqo  : std_logic_vector(0 to gear-1);
		signal rdqo : std_logic_vector(0 to gear-1);
		signal clks : std_logic_vector(0 to gear-1);
	begin
		clks <= (0 => clk90, 1 => not clk90);

		registered_g : for j in clks'range generate
		begin
			lat_e : entity hdl4fpga.align
			generic map (
				style => "register",
				n     => 1,
				d     => (0 to 0 => latency))
			port map (
				clk   => clks(j),
				di(0) => phy_dqi(j*byte_size+i),
				do(0) => dqo(j));
		end generate;

		ddrto_i : fdce
		port map (
			clr => '0',
			c   => clk90,
			ce  => '1',
			d   => phy_dqt(0),
			q   => sdr_dqt(i));

		oddr_i : oddr2
		port map (
			c0 => clk90,
			c1 => clk90_n,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => dqo(0),
			d1 => dqo(1),
			q  => sdr_dqo(i));


	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(phy_dmt'range);
		signal dmi  : std_logic_vector(phy_dmi'range);
		signal rdmi : std_logic_vector(phy_dmi'range);
		signal clks : std_logic_vector(0 to gear-1);
	begin

		clks <= (0 => clk90, 1 => not clk90);
		registered_g : for i in clks'range generate
			signal d, t, s : std_logic;
		begin
			dmt(i) <= '0';

			lat_e : entity hdl4fpga.align
			generic map (
				style => "register",
				n     => 3,
				d     => (0 to 3-1 => LATENCY))
			port map (
				clk   => clks(i),
				di(0) => phy_dmt(i),
				di(1) => phy_dmi(i),
				di(2) => phy_sti(i),
				do(0) => t,
				do(1) => d,
				do(2) => s);

--			process (clks(i))
--			begin
--				if rising_edge(clks(i)) then
--					t <= phy_dmt(i);
--					d <= phy_dmi(i);
--					s <= phy_sti(i);
--				end if;
--			end process;
--			rdmi(i) <= s when t='1' and not loopback else d;

			dmi(i) <=
				rdmi(i)    when latency/=0 else
				phy_sti(i) when phy_dmt(i)='1' and not loopback else
				phy_dmi(i);

		end generate;

		ddrto_i : fdce
		port map (
			clr => '0',
			c   => clk90,
			ce  => '1',
			d   => dmt(0),
			q   => sdr_dmt);

		oddr_i : oddr2
		port map (
			c0 => clk90,
			c1 => clk90_n,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => dmi(0),
			d1 => dmi(1),
			q  => sdr_dmo);


	end block;

	oddr_i : oddr2
	port map (
		c0 => clk90,
		c1 => clk90_n,
		ce => '1',
		r  => '0',
		s  => '0',
		d0 => phy_sti(0),
		d1 => phy_sti(1),
		q  => sdr_sto);


	dqso_b : block
		signal dt     : std_logic;
		signal dqso_r : std_logic;
		signal dqso_f : std_logic;
	begin

		ddrto_i : fdce
		port map (
			clr => '0',
			c   => clk0,
			ce  => '1',
			d   => phy_dqst(1),
			q   => sdr_dqst);

		oddr_i : oddr2
		port map (
			c0 => clk0,
			c1 => clk0_n,
			ce => '1',
			r  => '0',
			s  => '0',
			d0 => '0',
			d1 => phy_dqsi(0),
			q  => sdr_dqso);

	end block;
end;
