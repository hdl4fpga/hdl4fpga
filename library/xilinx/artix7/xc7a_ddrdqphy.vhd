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

entity xc7a_ddrdqphy is
	generic (
		TCP          : natural;
		TAP_DLY      : natural;
		DATA_GEAR    : natural;
		DATA_EDGE    : boolean;
		BYTE_SIZE    : natural);
	port (
		tp_bit       : out std_logic_vector(5-1 downto 0);
		tp_sel       : in  std_logic;
		tp_delay     : out std_logic_vector(5-1 downto 0);

		sys_rsts     : in std_logic_vector;
		sys_clks     : in std_logic_vector;
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

		constant clk0div   : natural := 0;
		constant clk90div  : natural := 1;
		constant iodclk    : natural := 2;
		constant clk0      : natural := 3;
		constant clk90     : natural := 4;

		constant rst0div  : natural := 0;
		constant rst90div : natural := 1;
		constant rstiod   : natural := 1;
		constant TCP4     : natural := (TCP/TAP_DLY+3)/4-1;
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture virtex7 of xc7a_ddrdqphy is

	signal dqi        : std_logic_vector(ddr_dqi'range);
	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);
	signal adjsto_req : std_logic;
	signal adjsto_rdy : std_logic;
	signal rlrdy      : std_logic;

	signal iod_rst    : std_logic;
	signal dqsi_buf   : std_logic;
	signal dqsi       : std_logic;
	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;
	signal imdr_inv   : std_logic;

	signal dq        : std_logic_vector(sys_dqo'range);
	signal tp_dqidly : std_logic_vector(0 to 5-1);
	signal tp_dqsdly : std_logic_vector(0 to 5-1);
	constant dqs_linedelay : time := (tcp * 1 ps)/3;
	constant dqi_linedelay : time := 27*(tcp * 1 ps)/32;
begin


	tp_delay <= tp_dqidly when tp_sel='1' else tp_dqsdly;
	sys_wlrdy <= sys_wlreq;
	process (sys_clks(iodclk))
		variable aux : std_logic;
	begin
		aux := '1';
		if rising_edge(sys_clks(iodclk)) then
			for i in adjdqi_rdy'range loop
				aux := aux and adjdqi_rdy(i);
			end loop;
			adjsto_req <= aux;
		end if;
	end process;
	sys_rlcal <= adjsto_req;
	sys_rlrdy <= rlrdy;
	rlrdy <= adjsto_rdy;

	tp_bit(1) <= adjdqs_rdy;
	tp_bit(2) <= adjsto_req;
	tp_bit(3) <= adjsto_rdy;

	iod_rst <= not adjdqs_req;
	iddr_g : for i in ddr_dqi'range generate
		signal imdr_rst  : std_logic;
		signal imdr_clk  : std_logic_vector(0 to 5-1);
		signal adjdqi_st : std_logic;
	begin

		process (sys_clks(clk90div))
			variable q : std_logic;
		begin
			if rising_edge(sys_clks(clk90div)) then
				imdr_rst <= q;
				q := sys_rsts(rst90div) or not adjdqs_req;
			end if;
		end process;

		imdr_clk <= (
			0 => sys_clks(clk90div),
			1 => sys_clks(clk90),
			2 => sys_clks(clk90),
			3 => not sys_clks(clk90),
			4 => not sys_clks(clk90));

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqi(i),
			q(0) => dq(0*BYTE_SIZE+i),
			q(1) => dq(1*BYTE_SIZE+i),
			q(2) => dq(2*BYTE_SIZE+i),
			q(3) => dq(3*BYTE_SIZE+i));

		dly_g : entity hdl4fpga.align
		generic map (
			n => 4,
			d => (1, 1, 1, 1))
		port map (
			clk => sys_clks(clk90div),
			di(0) => dq(2*BYTE_SIZE+i),
			di(1) => dq(3*BYTE_SIZE+i),
			di(2) => dq(0*BYTE_SIZE+i),
			di(3) => dq(1*BYTE_SIZE+i),
		    do(0) => sys_dqo(2*BYTE_SIZE+i),
		    do(1) => sys_dqo(3*BYTE_SIZE+i),
		    do(2) => sys_dqo(0*BYTE_SIZE+i),
		    do(3) => sys_dqo(1*BYTE_SIZE+i));

--		dly_g : entity hdl4fpga.align
--		generic map (
--			n => 4,
--			d => (1, 1, 0, 0))
--		port map (
--			clk => sys_clks(clk90div),
--			di(0) => dq(2*BYTE_SIZE+i),
--			di(1) => dq(3*BYTE_SIZE+i),
--			di(2) => dq(0*BYTE_SIZE+i),
--			di(3) => dq(1*BYTE_SIZE+i),
--			do(0) => sys_dqo(0*BYTE_SIZE+i),
--			do(1) => sys_dqo(1*BYTE_SIZE+i),
--			do(2) => sys_dqo(2*BYTE_SIZE+i),
--			do(3) => sys_dqo(3*BYTE_SIZE+i));

		adjdqi_req <= adjdqs_rdy;
		adjdqi_b : block
			signal delay         : std_logic_vector(1 to 6-1);
			signal adjpha_dly    : std_logic_vector(0 to 6-1);
			signal adjdqi_dlyreq : std_logic;
			signal adjpha_dlyreq : std_logic;
			signal adjpha_rdy    : std_logic;
			signal dly_rdy       : std_logic;
			signal dly_req       : std_logic;
			signal iod_ce        : std_logic;
			signal iod_rst       : std_logic;
			signal ddqi          : std_logic;
			signal dq1           : std_logic;
		begin
			process (sys_clks(iodclk))
				variable q : std_logic;
			begin
				if rising_edge(sys_clks(iodclk)) then
					if adjpha_rdy='0'then
						adjdqi_dlyreq <= '0';
						adjdqi_rdy(i) <= '0';
					elsif dly_rdy='0' then
						adjdqi_dlyreq <= '1';
						adjdqi_rdy(i) <= '0';
					else
						adjdqi_rdy(i) <= '1';
					end if;

					if dly_req='0' then
						dly_rdy <= '0';
					else
						dly_rdy <= q;
					end if;
					q := dly_req;
				end if;
			end process;

			dly_req <= adjpha_dlyreq when adjpha_rdy='0' else adjdqi_dlyreq;
			delay   <= adjpha_dly(delay'range) when adjpha_rdy='0' else std_logic_vector(unsigned(adjpha_dly(delay'range))+TCP4);

			tp_g : if i=0 generate
				tp_dqidly <= delay;
				tp_bit(4) <= dq1;
			end generate;

			dq1 <= to_stdulogic(to_bit(dq(3*BYTE_SIZE+i)));
			adjdqi_e : entity hdl4fpga.adjpha
			generic map (
				sever => warning,
				TCP => 2*TCP,
				TAP_DLY => TAP_DLY)
			port map (
				edge    => std_logic'('1'),
				clk     => sys_clks(iodclk),
				req     => adjdqi_req,
				rdy     => adjpha_rdy,
				dly_req => adjpha_dlyreq,
				dly_rdy => dly_rdy,
				smp     => dq1,
				dly     => adjpha_dly);


--			ddqi <= transport ddr_dqi(i) after (line_delay + (1 ps/10000));
			ddqi <= transport ddr_dqi(i) after dqi_linedelay;
			dqi_i : idelaye2
			generic map (
				DELAY_SRC    => "IDATAIN",
				IDELAY_TYPE  => "VAR_LOAD")
			port map (
				regrst      => iod_rst,
				c           => sys_clks(iodclk),
				ld          => '1',
				cntvaluein  => delay(1 to delay'right),
				idatain     => ddqi,
				dataout     => dqi(i),
				cinvctrl    => std_logic'('0'),
				ce          => std_logic'('0'),
				inc         => std_logic'('0'),
				ldpipeen    => std_logic'('0'),
				datain      => std_logic'('0'));

		end block;

	end generate;

	oddr_g : for i in 0 to BYTE_SIZE-1 generate
		signal dqo   : std_logic_vector(0 to DATA_GEAR-1);
		signal clks  : std_logic_vector(0 to 2-1);
		signal dqt   : std_logic_vector(sys_dqt'range);
		signal dqclk : std_logic_vector(0 to 2-1);
		signal dq000 : std_logic_vector(0 to 2*DATA_GEAR-1);
		signal dq270 : std_logic_vector(0 to 2*DATA_GEAR-1);
		signal dq180 : std_logic_vector(0 to 2*DATA_GEAR-1);
		signal dq090 : std_logic_vector(0 to 2*DATA_GEAR-1);
	begin

		dqclk <= (0 => sys_clks(clk90div), 1 => sys_clks(clk90));

		clks <=
			(0 => sys_clks(clk90div), 1 => not sys_clks(clk90div)) when DATA_EDGE else
			(0 => sys_clks(clk90div), 1 => sys_clks(clk90div));

		registered_g : for j in clks'range generate
			gear_g : for l in 0 to DATA_GEAR/clks'length-1 generate
				process (rlrdy, clks(j))
				begin
					if rlrdy='0' then
						if j mod 2=1 then
							dqo(l*DATA_GEAR/clks'length+j) <= '1';
						else
							dqo(l*DATA_GEAR/clks'length+j) <= '0';
						end if;
					elsif rising_edge(clks(j)) then
						dqo(l*DATA_GEAR/clks'length+j) <= sys_dqi((l*DATA_GEAR/clks'length+j)*BYTE_SIZE+i);
					end if;
					if rising_edge(clks(j)) then
						dqt(l*DATA_GEAR/clks'length+j) <= reverse(sys_dqt)(l*DATA_GEAR/clks'length+j);
					end if;
				end process;
			end generate;
		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst   => sys_rsts(rst90div),
			clk   => dqclk,
			t     => dqt,
			tq(0) => ddr_dqt(i),
			d     => dqo,
			q(0)  => ddr_dqo(i));

	end generate;

	dmo_g : block
		signal dmt   : std_logic_vector(sys_dmt'range);
		signal dmi   : std_logic_vector(sys_dmi'range);
		signal clks  : std_logic_vector(0 to 2-1);
		signal dqclk : std_logic_vector(0 to 2-1);
		signal dq270 : std_logic_vector(0 to DATA_GEAR-1);
		signal dq180 : std_logic_vector(0 to DATA_GEAR-1);
		signal dq090 : std_logic_vector(0 to DATA_GEAR-1);
	begin

		dqclk <= (0 => sys_clks(clk90div), 1 => sys_clks(clk90));

		clks <=
			(0 => sys_clks(clk90div), 1 => not sys_clks(clk90div)) when DATA_EDGE else
			(0 => sys_clks(clk90div), 1 => sys_clks(clk90div));

		registered_g : for i in clks'range generate
			gear_g : for l in 0 to DATA_GEAR/clks'length-1 generate
				process (clks(i))
				begin
					if rising_edge(clks(i)) then
						dmi(l*DATA_GEAR/clks'length+i) <= sys_dmi(l*DATA_GEAR/clks'length+i);
					end if;
				end process;
			end generate;
		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst   => sys_rsts(rst90div),
			clk   => dqclk,
			t     => (others => '0'),
			tq(0) => ddr_dmt,
			d     => dmi,
			q(0)  => ddr_dmo);

	end block;

	dqso_b : block
		signal edge      : std_logic;
		signal smp       : std_logic_vector(0 to DATA_GEAR-1);
		signal sto       : std_logic;
		signal imdr_clk  : std_logic_vector(0 to 5-1);
		signal dqso      : std_logic_vector(sys_dqso'range);
		signal dqst      : std_logic_vector(sys_dqst'range);
		signal dqsclk    : std_logic_vector(0 to 2-1);
		signal adjdly    : std_logic_vector(0 to 5);
		signal imdr_rst  : std_logic;
		signal adjdqs_st : std_logic;
		signal dqs_smp   : std_logic;
		signal sto_smp   : std_logic_vector(smp'range);
	begin

		adjdqs_b : block
			signal delay         : std_logic_vector(1 to 6-1);
			signal adjpha_dly    : std_logic_vector(0 to 6-1);
			signal adjsto_dlyreq : std_logic;
			signal adjpha_dlyreq : std_logic;
			signal dly_rdy       : std_logic;
			signal dly_req       : std_logic;
			signal iod_rst       : std_logic;
			signal iod_ce        : std_logic;
			signal ddqsi : std_logic;
		begin

			process (sys_clks(iodclk))
				variable q : std_logic;
			begin
				if rising_edge(sys_clks(iodclk)) then
					if adjdqs_rdy='0'then
						adjsto_dlyreq <= '0';
					elsif dly_rdy='0' then
						adjsto_dlyreq <= '1';
					end if;

					if dly_req='0' then
						dly_rdy <= '0';
					else
						dly_rdy <= q;
					end if;
					q := dly_req;
				end if;
			end process;

			dly_req <= adjpha_dlyreq when adjdqs_rdy='0' else adjsto_dlyreq;
			delay   <= adjpha_dly(delay'range) when adjdqs_rdy='0' else std_logic_vector(unsigned(adjpha_dly(delay'range))+TCP4);

			dqs_smp <= to_stdulogic(to_bit(smp(1)));
			adjdqs_e : entity hdl4fpga.adjpha
			generic map (
				sever => warning,
				TCP => 2*TCP,
				TAP_DLY => TAP_DLY)
			port map (
				edge    => std_logic'('0'),
				clk     => sys_clks(iodclk),
				req     => adjdqs_req,
				rdy     => adjdqs_rdy,
				dly_rdy => dly_rdy,
				dly_req => adjpha_dlyreq,
				smp     => dqs_smp,
				dly     => adjpha_dly);

			ddqsi <= transport ddr_dqsi after dqs_linedelay;
			tp_dqsdly <= delay;
			dqsidelay_i : idelaye2
			generic map (
				DELAY_SRC      => "IDATAIN",
				IDELAY_TYPE    => "VAR_LOAD",
				SIGNAL_PATTERN => "CLOCK")
			port map (
				regrst     => sys_rsts(rstiod),
				c          => sys_clks(iodclk),
				ld         => '1',
				cntvaluein => delay,
				idatain    => ddqsi,
				dataout    => dqsi_buf,
				cinvctrl   => '0',
				ce         => '0',
				inc        => '0',
				ldpipeen   => '0',
				datain     => '0');
--				dqsi <= to_stdulogic(to_bit(dqsi_buf));
				dqsi <= dqsi_buf;

		end block;

		process (sys_clks(clk0div))
			variable q : std_logic;
		begin
			if rising_edge(sys_clks(clk0div)) then
				imdr_rst <= q;
				q := sys_rsts(rst0div);
			end if;
		end process;

		imdr_clk <= (
			0 => sys_clks(clk0div),
			1 => sys_clks(clk0),
			2 => not sys_clks(clk90),
			3 => not sys_clks(clk0),
			4 => sys_clks(clk90));

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqsi,
			q    => smp);


		process (sys_rlreq, sys_clks(iodclk))
			variable q : std_logic;
		begin
			if sys_rlreq='0' then
				adjdqs_req <= '0';
				q := '0';
			elsif rising_edge(sys_clks(iodclk)) then
				if adjdqs_req='0' then
					adjdqs_req <= q;
				end if;
				q := sys_sti(0);
			end if;
		end process;

		process (sys_clks(iodclk))
		begin
			if rising_edge(sys_clks(iodclk)) then
				if adjdqs_req='0' then
					edge     <= to_stdulogic(to_bit(smp(0)));
					imdr_inv <= '0'; --not smp(0);
				end if;
			end if;
		end process;

		sto_smp <= smp;
		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			GEAR => DATA_GEAR)
		port map (
			ddr_clk  => sys_clks(clk0div),
			iod_clk  => sys_clks(iodclk),
			ddr_sti  => sys_sti(0),
			ddr_sto  => sto,
			ddr_smp  => sto_smp,
			sys_req  => adjsto_req,
			sys_rdy  => adjsto_rdy);

		process (sys_clks(clk90div))
			variable st : std_logic;
		begin
			if rising_edge(sys_clks(clk90div)) then
				sys_sto <= (others => sto);
				st := sto;
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

		dqsclk <= (0 => sys_clks(clk0div), 1 => sys_clks(clk0));
		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys_rsts(rst0div),
			clk  => dqsclk,
			t    => dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

		tp_bit(0) <= smp(0);
	end block;
end;
