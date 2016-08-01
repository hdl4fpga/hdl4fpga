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
		TCP          : natural;
		TAP_DLY      : natural;
		DATA_GEAR    : natural;
		DATA_EDGE    : boolean;
		BYTE_SIZE    : natural);
	port (
		sys_tp       : out std_logic_vector(BYTE_SIZE-1 downto 0);
		tpdq      :  out std_logic_vector(0 to DATA_GEAR-1);
		tp_dqsdly    : out std_logic_vector(6-1 downto 0);

		sys0div_rst  : in  std_logic;
		sys90div_rst : in  std_logic;
		sys_iodclk   : in  std_logic;
		sys_clk0     : in  std_logic;
		sys_clk0div  : in  std_logic;
		sys_clk90    : in  std_logic;
		sys_clk90div : in  std_logic;
		sys_wlreq    : in  std_logic;
		sys_wlrdy    : out std_logic;
		sys_rlreq    : in  std_logic;
		sys_rlrdy    : out std_logic;
		sys_rlcal    : out std_logic;
		sys_dmt      : in  std_logic_vector(0 to DATA_GEAR-1) := (others => '-');
		sys_dmi      : in  std_logic_vector(DATA_GEAR-1 downto 0) := (others => '-');
		sys_sti      : in  std_logic_vector(0 to DATA_GEAR-1) := (others => '-');
		sys_sto      : out std_logic_vector(0 to DATA_GEAR-1);
		sys_dqi      : in  std_logic_vector(DATA_GEAR*BYTE_SIZE-1 downto 0);
		sys_dqt      : in  std_logic_vector(DATA_GEAR-1 downto 0);
		sys_dqo      : out std_logic_vector(DATA_GEAR*BYTE_SIZE-1 downto 0);
		sys_dqso     : in  std_logic_vector(0 to DATA_GEAR-1);
		sys_dqst     : in  std_logic_vector(0 to DATA_GEAR-1);

		ddr_dmt      : out std_logic;
		ddr_dmo      : out std_logic;
		ddr_dqsi     : in  std_logic;
		ddr_dqi      : in  std_logic_vector(BYTE_SIZE-1 downto 0);
		ddr_dqt      : out std_logic_vector(BYTE_SIZE-1 downto 0);
		ddr_dqo      : out std_logic_vector(BYTE_SIZE-1 downto 0);

		ddr_dqst     : out std_logic;
		ddr_dqso     : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture virtex of ddrdqphy is

	signal dqi        : std_logic_vector(ddr_dqi'range);
	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);
	signal adjsto_req : std_logic;
	signal adjsto_rdy : std_logic;
	signal rlrdy      : std_logic;

	signal tp : std_logic_vector(ddr_dqi'range);

	signal iod_rst    : std_logic;
	signal dqsi       : std_logic;
	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;
	signal smp        : std_logic_vector(DATA_GEAR-1 downto 0);
	signal dqsi_n    : std_logic;

begin

	sys_wlrdy <= sys_wlreq;
	dqsi_n <= not dqsi;
	process (sys_iodclk)
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sys_iodclk) then
			for i in adjdqi_rdy'range loop
				aux := aux and adjdqi_rdy(i);
			end loop;
			adjsto_req <= aux;
		end if;
	end process;
	sys_rlcal <= adjsto_req;
	sys_rlrdy <= rlrdy;
	rlrdy <= adjsto_rdy;
	sys_tp <= tp;

	tp(0) <= smp(0);
	tp(1) <= adjdqs_rdy;
	tp(2) <= adjsto_req;
	tp(5) <= adjsto_rdy;

	iod_rst <= not adjdqs_req;
	iddr_g : for i in ddr_dqi'range generate
		signal imdr_clk   : std_logic_vector(0 to 5-1);
		signal t : std_logic;
		signal dq        : std_logic_vector(0 to DATA_GEAR-1);
		signal dqiod_inc : std_logic;
		signal dqiod_ce  : std_logic;
		signal iod_inc   : std_logic;
		signal iod_ce    : std_logic;
		signal tpd       : std_logic_vector(0 to DATA_GEAR-1);
	begin
		imdr_clk <= (0 => not dqsi, 1 => dqsi, 2 => not sys_clk90, 3 => sys_clk90, 4 => sys_clk90div);

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys90div_rst,
			clk  => imdr_clk,
			d(0) => dqi(i),
			q    => dq);

		xxx_g : for j in dq'range generate
			reg_g : if j < 2 generate
				process (sys_clk90div)
				begin
					if rising_edge(sys_clk90div) then
					end if;
				end process;
			end generate;
			sys_dqo(j*BYTE_SIZE+i) <= dq(j);

			noreg_g : if j >= 2 generate
				sys_dqo(j*BYTE_SIZE+i) <= dq(j);
			end generate;
		end generate;
		tp_g : if i=0 generate
			tpdq <= tpd;
		end generate;
		adjdqi_req <= adjdqs_rdy;
		adjdqi_e : entity hdl4fpga.adjdqi
		port map (
			din => dq,
			req => adjdqi_req,
			rdy => adjdqi_rdy(i),
			tp => tpd,
			iod_clk => sys_iodclk,
			iod_ce  => dqiod_ce,
			iod_inc => dqiod_inc);

		iod_ce  <= dqiod_ce  or dqsiod_ce;
		iod_inc <= dqiod_inc when adjdqi_req='1' else dqsiod_inc;

		dqi_i : idelaye2 
		generic map (
			DELAY_SRC => "IDATAIN",
			IDELAY_VALUE => 31,
			IDELAY_TYPE => "VARIABLE")
		port map (
			regrst => iod_rst,
			cinvctrl => '0',
			cntvaluein => (others => '-'),
			ld => '0',
			ldpipeen => '0',
			c   => sys_iodclk,
			ce  => iod_ce,
			inc => iod_inc,
			datain => '-',
			idatain => ddr_dqi(i),
			dataout => dqi(i));

	end generate;

	oddr_g : for i in 0 to BYTE_SIZE-1 generate
		signal dqo  : std_logic_vector(0 to DATA_GEAR-1);
		signal clks : std_logic_vector(0 to 2-1);
		signal dqt  : std_logic_vector(sys_dqt'range);
	signal omdr_dqclk : std_logic_vector(0 to 2-1);
	begin

	omdr_dqclk  <= (0 => sys_clk90div, 1 => sys_clk90);
		edge_g : if DATA_EDGE generate
			clks <= (0 => sys_clk90div, 1 => not sys_clk90div);
			registered_g : for j in clks'range generate
				process (rlrdy, clks(j))
				begin
					if rlrdy='0' then
						if j mod 2=0 then
							dqo(j) <= '1';
						else
							dqo(j) <= '0';
						end if;
					elsif rising_edge(clks(j)) then
						dqo(j) <= sys_dqi(j*BYTE_SIZE+i);
					end if;
				end process;

			end generate;
		end generate;

		noedge_g : if not DATA_EDGE generate
			clks <= (0 => not sys_clk90div, 1 => sys_clk90div);
			registered_g : for j in 0 to DATA_GEAR-1 generate
				process (rlrdy, clks(0))
				begin
					if rlrdy='0' then
						if j mod 2=0 then
							dqo(j) <= '1';
						else
							dqo(j) <= '0';
						end if;
					elsif rising_edge(clks(0)) then
						dqo(j) <= sys_dqi(j*BYTE_SIZE+i);
					end if;
				end process;

			end generate;

			process (clks(0))
			begin
				if rising_edge(clks(0)) then
					dqt <= reverse(sys_dqt);
				end if;
			end process;
		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst   => sys90div_rst,
			clk   => omdr_dqclk,
			t     => dqt,
			tq(0) => ddr_dqt(i),
			d     => dqo,
			q(0)  => ddr_dqo(i));

	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to 2-1);
	signal omdr_dqclk : std_logic_vector(0 to 2-1);
	begin

	omdr_dqclk  <= (0 => sys_clk90div, 1 => sys_clk90);
		edge_g : if DATA_EDGE generate
			clks <= (0 => sys_clk90div, 1 => not sys_clk90div);
			registered_g : for i in clks'range generate
				process (clks(i))
				begin
					if rising_edge(clks(i)) then
						dmi(i) <= sys_dmi(i);
					end if;
				end process;

			end generate;
		end generate;

		noedge_g : if not DATA_EDGE generate
			clks <= (0 => not sys_clk90div, 1 => sys_clk90div);
			registered_g : for i in 0 to DATA_GEAR-1 generate
				process (clks(0))
				begin
					if rising_edge(clks(0)) then
						dmi(i) <= sys_dmi(i);
					end if;
				end process;

			end generate;

		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys90div_rst,
			clk  => omdr_dqclk,
			t     => (others => '0'),
			tq(0) => ddr_dmt,
			d    => dmi,
			q(0) => ddr_dmo);

	end block;

	dqso_b : block 
		signal sto       : std_logic;
		signal sti       : std_logic;
		signal mclk      : std_logic_vector(0 to 5-1);
		signal dqso      : std_logic_vector(sys_dqso'range);
		signal dqst      : std_logic_vector(sys_dqst'range);
		signal dqsclk    : std_logic_vector(0 to 2-1);
		signal iod_ld    : std_logic;
		signal dqsdly    : std_logic_vector(0 to 5);
		signal imdr_rst  : std_logic;
		signal adjdqs_st : std_logic;
	begin

		iod_ld <= adjdqs_req and not adjdqs_rdy;
		dqsidelay_i : idelaye2 
		generic map (
			DELAY_SRC => "IDATAIN",
			SIGNAL_PATTERN => "CLOCK",
			IDELAY_VALUE => 31,
			IDELAY_TYPE => "VAR_LOAD")
		port map (
			regrst     => iod_rst,
			cinvctrl   => '0',
			c          => sys_iodclk,
			ce         => '0',
			inc        => '0',
			ld         => iod_ld,
			cntvaluein => dqsdly(1 to 5),
			ldpipeen   => '0',
			datain     => '0',
			idatain    => ddr_dqsi,
			dataout    => dqsi);

		process (sys_iodclk)
		begin
			if rising_edge(sys_iodclk) then
				imdr_rst <= sys0div_rst or adjdqs_st;
			end if;
		end process;

		mclk <= (0 => sys_clk90, 1 => not sys_clk90, 2 => sys_clk0, 3 => not sys_clk0, 4 => sys_clk0div);
		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE    => 1,
			GEAR    => DATA_GEAR)
		port map (
			rst     => imdr_rst,
			clk     => mclk,
			ctrl(0) => '0',
			ctrl(1) => dqsdly(0),
			d(0)    => dqsi,
			q       => smp);

		process (sys_rlreq, sys_iodclk)
			variable q : std_logic;
		begin
			if sys_rlreq='0' then
				adjdqs_req <= '0';
				q          := '0';
			elsif rising_edge(sys_iodclk) then
				if adjdqs_req='0' then
					adjdqs_req <= q;
				end if;
				q := sys_sti(0);
			end if;
		end process;

		adjdqs_e : entity hdl4fpga.adjdqs
		generic map (
			TCP     => TCP,
			TAP_DLY => TAP_DLY)
		port map (
			clk => sys_iodclk,
			smp => smp(0),
			req => adjdqs_req,
			rdy => adjdqs_rdy,
			st  => adjdqs_st,
			dly => dqsdly);

		sti <= sys_sti(0);
		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			GEAR => DATA_GEAR)
		port map (
			ddr_clk  => sys_clk0div,
			iod_clk  => sys_iodclk,
			ddr_sti  => sti,
			ddr_sto  => sto,
			ddr_smp  => smp,
			sys_req  => adjsto_req,
			sys_rdy  => adjsto_rdy);

		process (sys_clk90div)
		begin
			if falling_edge(sys_clk90div) then
				sys_sto <= (others => sto);
			end if;
		end process;
	
		process (sys_dqso)
		begin
			dqso <= (others => '0');
			for i in dqso'range loop
				if i mod 2 = 1 then
					dqso(i) <= reverse(sys_dqso)(i);
				end if;
			end loop;
		end process;
		dqst <= reverse(sys_dqst);

		dqsclk <= (0 => sys_clk0div, 1 => sys_clk0);
		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys0div_rst,
			clk  => dqsclk,
			t    => dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

			tp_dqsdly <= dqsdly;
	end block;
end;
