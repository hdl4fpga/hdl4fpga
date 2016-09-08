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
		tcp        : natural;
		tap_dly    : natural;
		gear       : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		tp_bit     : out std_logic_vector(5-1 downto 0);
		tp_sel     : in std_logic_vector(0 to 1) := (others => '0');
		tp_delay   : out std_logic_vector(6-1 downto 0);
		sys_rsts   : in std_logic_vector;
		sys_clks   : in std_logic_vector;
		sys_rlreq  : in std_logic;
		sys_rlrdy  : out std_logic;
		sys_rlcal  : out std_logic;
		sys_dmt    : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_dmi    : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(0 to gear-1) := (others => '-');
		sys_sto    : out std_logic_vector(0 to gear-1);
		sys_dqo    : out std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(gear-1 downto 0);
		sys_dqi    : in  std_logic_vector(gear*byte_size-1 downto 0);
		sys_dqso   : in  std_logic_vector(0 to gear-1);
		sys_dqst   : in  std_logic_vector(0 to gear-1);

		ddr_dmt    : out std_logic;
		ddr_dmo    : out std_logic;
		ddr_dqsi   : in  std_logic;
		ddr_dqi    : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt    : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo    : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst   : out std_logic;
		ddr_dqso   : out std_logic);

		constant sys_clk0div  : natural := 0; 
		constant sys_clk90div : natural := 1;
		constant sys_iodclk   : natural := 2;
		constant sys_clk0     : natural := 3; 
		constant sys_clk90    : natural := 4;

		constant rst0div  : natural := 0;
		constant rst90div : natural := 1;
		constant rstiod   : natural := 2;
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
	signal dqs_buf   : std_logic;
	signal rlrdy : std_logic;

	signal tp_dqidly : std_logic_vector(0 to 6-1);
	signal tp_dqsdly : std_logic_vector(0 to 6-1);

	constant line_delay : time := 1.1 ns;
begin

	tp_delay <= tp_dqidly when tp_sel(0)='0' else tp_dqsdly;

	adjsto_req <= setif(adjdqi_rdy=(adjdqi_rdy'range => '1'));

	sys_rlcal <= adjsto_req;
	sys_rlrdy <= rlrdy;
	rlrdy     <= adjsto_rdy;

	tp_bit(1) <= adjdqi_req;
	tp_bit(2) <= adjsto_req;
	tp_bit(3) <= adjsto_rdy;

	process (sys_rsts(rstiod), sys_clks(sys_iodclk))
	begin
		if sys_rsts(rstiod)='1' then
			adjdqi_req <= '0';
		elsif rising_edge(sys_clks(sys_iodclk)) then
			adjdqi_req <= adjdqs_rdy;
		end if;
	end process;

	iddr_g : for i in ddr_dqi'range generate
		signal q         : std_logic_vector(0 to GEAR-1);
		signal imdr_clk  : std_logic_vector(0 to 5-1);
	begin
		imdr_clk <= (
			0 => sys_clks(sys_clk0div),
			1 => sys_clks(sys_clk0),
			2 => sys_clks(sys_clk90),
			3 => not sys_clks(sys_clk0),
			4 => not sys_clks(sys_clk90));

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => GEAR)
		port map (
			clk  => imdr_clk,
			d(0) => dqi(i),
			q    => q);

		sys_dqo(0*byte_size+i) <= q(0);
		sys_dqo(1*byte_size+i) <= q(1);
	
		adjdqi_b : block
			signal delay         : std_logic_vector(1 to 7-1);
			signal adjpha_dly    : std_logic_vector(0 to 7-1);
			signal adjdqi_dlyreq : std_logic;
			signal adjpha_dlyreq : std_logic;
			signal adjpha_rdy    : std_logic;
			signal dly_rdy       : std_logic;
			signal dly_req       : std_logic;
			signal iod_ce        : std_logic;
			signal iod_rst       : std_logic;
			signal ddqi : std_logic;
		begin
			process (sys_clks(sys_iodclk))
			begin
				if rising_edge(sys_clks(sys_iodclk)) then
					if adjpha_rdy='0'then
						adjdqi_dlyreq <= '0';
						adjdqi_rdy(i) <= '0';
					elsif dly_rdy='0' then
						adjdqi_dlyreq <= '1';
						adjdqi_rdy(i) <= '0';
					else
						adjdqi_rdy(i) <= '1';
					end if;
				end if;
			end process;

			dly_req <= adjpha_dlyreq           when adjpha_rdy='0' else adjdqi_dlyreq;
			delay   <= adjpha_dly(delay'range) when adjpha_rdy='0' else std_logic_vector(unsigned(adjpha_dly(delay'range))+3);

			xx_g : if i=0 generate
				tp_dqidly <= delay;
				tp_bit(4) <= q(1);
			end generate;

			adjdqi_e : entity hdl4fpga.adjpha
			generic map (
				TCP => 2*TCP,
				TAP_DLY => TAP_DLY)
			port map (
				edge    => '1',
				clk     => sys_clks(sys_iodclk),
				req     => adjdqi_req,
				rdy     => adjpha_rdy,
				dly_req => adjpha_dlyreq,
				dly_rdy => dly_rdy,
				smp     => q(0),
				dly     => adjpha_dly);

			dlyctlr : entity hdl4fpga.dlyctlr
			port map (
				clk     => sys_clks(sys_iodclk),
				req     => dly_req,
				rdy     => dly_rdy,
				dly     => delay(1 to delay'right),
				iod_rst => iod_rst,
				iod_ce  => iod_ce);

			ddqi <= transport ddr_dqi(i) after line_delay;
			dqi_i : iodelay 
			generic map (
				DELAY_SRC      => "I",
				IDELAY_VALUE   => 0,
				IDELAY_TYPE    => "VARIABLE",
				SIGNAL_PATTERN => "DATA")
			port map (
				rst     => iod_rst,
				c       => sys_clks(sys_iodclk),
				ce      => iod_ce,
				t       => '1',
				inc     => '1',
				idatain => ddqi,
				odatain => '0',
				dataout => dqi(i),
				datain  => '0');
		end block;

	end generate;

	oddr_g : for i in 0 to BYTE_SIZE-1 generate
		signal dqt  : std_logic_vector(0 to GEAR-1);
		signal dqo  : std_logic_vector(0 to GEAR-1);
		signal clks : std_logic_vector(0 to 2-1);
		signal dqclk : std_logic_vector(0 to 2-1);
	begin

		dqclk <= (0 => sys_clks(sys_clk90), 1 => sys_clks(sys_clk90div));

		clks <= 
			(0 => sys_clks(sys_clk90div), 1 => not sys_clks(sys_clk90div)) when DATA_EDGE else
			(0 => sys_clks(sys_clk90div), 1 => sys_clks(sys_clk90div));

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
		dqt <= reverse(sys_dqt);

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => GEAR)
		port map (
			rst   => sys_rsts(rst90div),
			clk   => dqclk,
			t     => dqt,
			tq(0) => ddr_dqt(i),
			d     => dqo,
			q(0)  => ddr_dqo(i));

	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to 2-1);
		signal dqclk : std_logic_vector(0 to 2-1);
	begin

		dqclk <= (0 => sys_clks(sys_clk90), 1 => sys_clks(sys_clk90div));

		clks <= 
			(0 => sys_clks(sys_clk90div), 1 => not sys_clks(sys_clk90div)) when DATA_EDGE else
			(0 => sys_clks(sys_clk90div), 1 => sys_clks(sys_clk90div));

		registered_g : for i in clks'range generate
			process (clks(i))
			begin
				if rising_edge(clks(i)) then
					dmi(i) <= sys_dmi(i);
				end if;
			end process;
		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => GEAR)
		port map (
			rst   => sys_rsts(rst90div),
			clk   => dqclk,
			t     => (1 to GEAR => '0'),
			tq(0) => ddr_dmt,
			d     => dmi,
			q(0)  => ddr_dmo);

	end block;

	dqso_b : block 
		signal clk_n    : std_logic;
		signal dqsclk   : std_logic_vector(0 to 2-1);
		signal dqsi     : std_logic;
		signal dqso     : std_logic_vector(sys_dqso'range);
		signal dqst     : std_logic_vector(sys_dqst'range);
		signal sto      : std_logic;
		signal smp : std_logic_vector(0 to GEAR-1);
		signal imdr_clk : std_logic_vector(0 to 5-1);
	begin

		adjdqs_b : block
			signal delay         : std_logic_vector(1 to 7-1);
			signal adjpha_dly    : std_logic_vector(0 to 7-1);
			signal adjsto_dlyreq : std_logic;
			signal adjpha_dlyreq : std_logic;
			signal dly_rdy       : std_logic;
			signal dly_req       : std_logic;
			signal iod_rst       : std_logic;
			signal iod_ce        : std_logic;
			signal ddqsi : std_logic;
		begin

			process (sys_clks(sys_iodclk))
			begin
				if rising_edge(sys_clks(sys_iodclk)) then
					if adjdqs_rdy='0'then
						adjsto_dlyreq <= '0';
					elsif dly_rdy='0' then
						adjsto_dlyreq <= '1';
					end if;
				end if;
			end process;

			dly_req <= adjpha_dlyreq when adjdqs_rdy='0' else adjsto_dlyreq;
			delay <= adjpha_dly(delay'range) when adjdqs_rdy='0' else std_logic_vector(unsigned(adjpha_dly(delay'range))+3);

			adjdqs_e : entity hdl4fpga.adjpha
			generic map (
				TCP => 2*TCP,
				TAP_DLY => TAP_DLY)
			port map (
				edge    => '0',
				clk     => sys_clks(sys_iodclk),
				req     => adjdqs_req,
				rdy     => adjdqs_rdy,
				dly_rdy => dly_rdy,
				dly_req => adjpha_dlyreq,
				smp     => smp(0),
				dly     => adjpha_dly);

			dlyctlr : entity hdl4fpga.dlyctlr
			port map (
				clk     => sys_clks(sys_iodclk),
				req     => dly_req,
				rdy     => dly_rdy,
				dly     => delay,
				iod_rst => iod_rst,
				iod_ce  => iod_ce);

			ddqsi <= transport ddr_dqsi after line_delay;
			dqsidelay_i : idelay 
			generic map (
				IOBDELAY_TYPE => "VARIABLE")
			port map (
				rst => iod_rst,
				c   => sys_clks(sys_iodclk),
				ce  => iod_ce,
				inc => '1',
				i   => ddqsi,
				o   => dqsi);

			tp_dqsdly <= delay;
		end block;

		buf_f : bufio 
		port map (
			i => dqsi,
			o => dqs_buf);

		tp_bit(0) <= smp(0);

		imdr_clk <= (
			0 => sys_clks(sys_clk0div),
			1 => sys_clks(sys_clk0),
			2 => sys_clks(sys_clk90),
			3 => not sys_clks(sys_clk0),
			4 => not sys_clks(sys_clk90));

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => GEAR)
		port map (
			clk  => imdr_clk,
			d(0) => dqsi,
			q    => smp);

		process (sys_rlreq, sys_clks(sys_iodclk))
			variable q : std_logic;
		begin
			if sys_rlreq='0' then
				adjdqs_req <= '0';
				q := '0';
			elsif rising_edge(sys_clks(sys_iodclk)) then
				if adjdqs_req='0' then
					adjdqs_req <= q;
				end if;
				q := sys_sti(0);
			end if;
		end process;

		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			GEAR => GEAR)
		port map (
			ddr_clk => sys_clks(sys_clk0),
			iod_clk => sys_clks(sys_iodclk),
			ddr_sti => sys_sti(0),
			ddr_sto => sto,
			ddr_smp => smp,
			sys_req => adjsto_req,
			sys_rdy => adjsto_rdy);

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

		sys_sto <= (others => sto);

		dqsclk <= (0 => sys_clks(sys_clk0div), 1 => sys_clks(sys_clk0));
		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => GEAR)
		port map (
			rst  => sys_rsts(rst0div),
			clk  => dqsclk,
			t    => dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

	end block;
end;
