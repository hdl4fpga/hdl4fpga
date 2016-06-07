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

entity ddrdqphy is
	generic (
		gear : natural;
		byte_size : natural);
	port (
		sys_rst : in std_logic;
		sys_clk0 : in  std_logic;
		sys_clk90 : in  std_logic;
		sys_wlreq : in std_logic;
		sys_wlrdy : out std_logic;
		sys_wlcal : out std_logic;
		sys_dmt  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_dmi  : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sti  : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_sto  : out std_logic_vector(0 to gear-1);
		sys_dqo  : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt  : in  std_logic_vector(gear-1 downto 0);
		sys_dqi  : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqso : in  std_logic_vector(0 to gear-1);
		sys_dqst : in  std_logic_vector(0 to gear-1);
		sysiod_clk : in std_logic;
		sys_tp : out std_logic_vector(byte_size-1 downto 0);

		ddr_dmt  : out std_logic;
		ddr_dmo  : out std_logic;
		ddr_dqsi : in  std_logic;
		ddr_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt  : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo  : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst : out std_logic;
		ddr_dqso : out std_logic);

end;

library hdl4fpga;

architecture virtex of ddrdqphy is

	signal dqi  : std_logic_vector(ddr_dqi'range);
	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);
	signal adjsto_req : std_logic;
	signal adjsto_rdy : std_logic;
	signal wlrdy : std_logic;

	signal tp : std_logic_vector(ddr_dqi'range);

	signal iod_rst : std_logic;
	signal dqsi : std_logic;
	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;
	signal smp : std_logic_vector(2-1 downto 0);
begin

	process (sysiod_clk)
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sysiod_clk) then
			for i in adjdqi_rdy'range loop
				aux := aux and adjdqi_rdy(i);
			end loop;
			adjsto_req <= aux;
		end if;
	end process;
	sys_wlcal <= adjsto_req;
	sys_wlrdy <= wlrdy;
	wlrdy <= adjsto_rdy;
	sys_tp <= tp;

	tp(0) <= smp(0);
	tp(1) <= adjdqs_rdy;
	tp(2) <= adjsto_req;
	tp(5) <= adjsto_rdy;

	iod_rst <= not adjdqs_req;
	iddr_g : for i in ddr_dqi'range generate
		signal q : std_logic_vector(2-1 downto 0);
		signal t : std_logic;
		signal dqs_clk   : std_logic;
		signal dqiod_inc : std_logic;
		signal dqiod_ce  : std_logic;
		signal iod_inc   : std_logic;
		signal iod_ce    : std_logic;
	begin
		dqs_clk <= not dqsi;
		iddr_i : iddr
		generic map (
			DDR_CLK_EDGE => "SAME_EDGE")
		port map (
			c  => dqs_clk,
			ce => '1',
			d  => dqi(i),
			q1 => q(0),
			q2 => q(1));

		sys_dqi(0*byte_size+i) <= q(1);
		sys_dqi(1*byte_size+i) <= q(0);
	
		adjdqi_req <= adjdqs_rdy;
		adjdqi_e : entity hdl4fpga.adjdqi
		port map (
			din => q(1),
			req => adjdqi_req,
			rdy => adjdqi_rdy(i),
			iod_clk => sysiod_clk,
			iod_ce  => dqiod_ce,
			iod_inc => dqiod_inc);

		iod_ce  <= dqiod_ce  or dqsiod_ce;
		iod_inc <= dqiod_inc when adjdqi_req='1' else dqsiod_inc;

		dqi_i : idelay 
		generic map (
			IOBDELAY_VALUE => 31,
			IOBDELAY_TYPE => "VARIABLE")
		port map (
			rst => iod_rst,
			c   => sysiod_clk,
			ce  => iod_ce,
			inc => iod_inc,
			i   => ddr_dqi(i),
			o   => dqi(i));

	end generate;

	oddr_g : for i in 0 to byte_size-1 generate
		signal dqo  : std_logic_vector(0 to gear-1);
		signal clks : std_logic_vector(0 to gear-1);
	begin
		clks <= (0 => sys_clk90, 1 => not sys_clk90);

		registered_g : for j in clks'range generate
			process (wlrdy, clks(j))
			begin
				if wlrdy='0' then
					if j mod 2=0 then
						dqo(j) <= '1';
					else
						dqo(j) <= '0';
					end if;
				elsif rising_edge(clks(j)) then
					dqo(j) <= sys_dqo(j*byte_size+i);
				end if;
			end process;

		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clk90,
			d => sys_dqt(0),
			q => ddr_dqt(i));

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => dqo(0),
			df  => dqo(1),
			q   => ddr_dqo(i));
	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to gear-1);
	begin

		clks <= (0 => sys_clk90, 1 => not sys_clk90);
		registered_g : for i in clks'range generate
			process (clks(i))
			begin
				if rising_edge(clks(i)) then
					dmi(i) <= sys_dmi(i);
				end if;
			end process;

		end generate;
		ddr_dmt <= '0';

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk90,
			dr  => dmi(0),
			df  => dmi(1),
			q   => ddr_dmo);
	end block;

	dqso_b : block 
		signal clk_n : std_logic;
		signal dqsi_buf : std_logic;
		signal sto : std_logic;
	begin

		dqsidelay_i : idelay 
		generic map (
			IOBDELAY_VALUE => 31,
			IOBDELAY_TYPE => "VARIABLE")
		port map (
			rst => iod_rst,
			c   => sysiod_clk,
			ce  => dqsiod_ce,
			inc => dqsiod_inc,
			i   => ddr_dqsi,
			o   => dqsi_buf);

		bufio_i : bufio
		port map (
			i => dqsi_buf,
			o => dqsi);

		tp(6) <= smp(1);
		iddr_i : iddr
		generic map (
			DDR_CLK_EDGE => "SAME_EDGE")
		port map (
			c  => sys_clk0,
			ce => '1',
			d  => dqsi_buf,
			q1 => smp(0),
			q2 => smp(1));

		process (sys_wlreq, sysiod_clk)
			variable q : std_logic;
		begin
			if sys_wlreq='0' then
				adjdqs_req <= '0';
				q := '0';
			elsif rising_edge(sysiod_clk) then
				if adjdqs_req='0' then
					adjdqs_req <= q;
				end if;
				q := sys_sti(0);
			end if;
		end process;

		adjdqs_e : entity hdl4fpga.adjdqs
		port map (
			smp => smp(0),
			req => adjdqs_req,
			rdy => adjdqs_rdy,
			iod_clk => sysiod_clk,
			iod_ce  => dqsiod_ce,
			iod_inc => dqsiod_inc);

		adjsto_e : entity hdl4fpga.adjsto
		port map (
			sys_clk0 => sys_clk0,
			iod_clk => sysiod_clk,
			sti => sys_sti(0),
			sto => sto,
			smp => smp(1),
			req => adjsto_req,
			rdy => adjsto_rdy);
		sys_sto <= (others => sto);

		clk_n  <= not sys_clk0;
		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => clk_n,
			d => sys_dqst(0),
			q => ddr_dqst);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clk0,
			dr  => '0',
			df  => sys_dqso(0),
			q   => ddr_dqso);

	end block;
end;
