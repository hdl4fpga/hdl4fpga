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
		DATA_GEAR    : natural;
		DATA_EDGE    : boolean;
		BYTE_SIZE    : natural);
	port (
		sys_tp       : out std_logic_vector(BYTE_SIZE-1 downto 0);

		sys_rst      : in  std_logic;
		sys_iodclk   : in  std_logic;
		sys_clk0     : in  std_logic;
		sys_clk0div  : in  std_logic;
		sys_clk90    : in  std_logic;
		sys_clk90div : in  std_logic;
		sys_rdsel    : out std_logic;
		sys_rdclk    : in  std_logic;
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
	signal rdsel      : std_logic;
	signal dqs_clk    : std_logic;
	signal imdr_clk   : std_logic_vector(0 to 3-1);
	signal omdr_clk   : std_logic_vector(0 to 2-1);

begin

	imdr_clk <= (0 => dqs_clk, 1 => sys_clk0, 2 => sys_clk0div);
	omdr_clk <= (0 => sys_clk0div, 1 => sys_clk0);
	sys_wlrdy <= sys_wlreq;
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
	dqs_clk <= not dqsi;
	iddr_g : for i in ddr_dqi'range generate
		signal t : std_logic;
		signal dq        : std_logic_vector(0 to DATA_GEAR-1);
		signal dqiod_inc : std_logic;
		signal dqiod_ce  : std_logic;
		signal iod_inc   : std_logic;
		signal iod_ce    : std_logic;
	begin
		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys_rst,
			clk  => imdr_clk,
			d(0) => dqi(i),
			q    => dq);

		process (dq)
		begin
			for i in dq'range loop
				sys_dqo(i*BYTE_SIZE+i) <= dq(i);
			end loop;
		end process;

		adjdqi_req <= adjdqs_rdy;
		adjdqi_e : entity hdl4fpga.adjdqi
		port map (
			din => dq(0),
			req => adjdqi_req,
			rdy => adjdqi_rdy(i),
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
	begin
		clks <= (0 => sys_clk90, 1 => not sys_clk90);

		edge_g : if DATA_EDGE generate
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
		end generate;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys_rst,
			clk  => omdr_clk,
			d    => dqo,
			q(0) => ddr_dqo(i));

	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to 2-1);
	begin

		clks <= (0 => sys_clk90, 1 => not sys_clk90);
		edge_g : if DATA_EDGE generate
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
			rst  => sys_rst,
			clk  => omdr_clk,
			d    => dmi,
			q(0) => ddr_dmo);

	end block;

	dqso_b : block 
		signal sto  : std_logic;
		signal sti  : std_logic;
		signal st   : std_logic;
		signal mclk : std_logic_vector(0 to 3-1);
		signal dqso : std_logic_vector(sys_dqso'range);
	begin

		dqsidelay_i : idelaye2 
		generic map (
			DELAY_SRC => "IDATAIN",
			SIGNAL_PATTERN => "CLOCK",
			IDELAY_VALUE => 31,
			IDELAY_TYPE => "VARIABLE")
		port map (
			regrst => iod_rst,
			cinvctrl => '0',
			c   => sys_iodclk,
			ce  => dqsiod_ce,
			inc => dqsiod_inc,
			ld  => '0',
			cntvaluein => (others => '-'),
			ldpipeen => '0',
			datain => '-',
			idatain => ddr_dqsi,
			dataout => dqsi);

		mclk <= (0 => dqs_clk, 1 => sys_clk0, 2 => sys_clk0div);
		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys_rst,
			clk  => mclk,
			d(0) => dqsi,
			q    => smp);

		process (sys_rlreq, sys_iodclk)
			variable q : std_logic;
		begin
			if sys_rlreq='0' then
				adjdqs_req <= '0';
				q := '0';
			elsif rising_edge(sys_iodclk) then
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
			rdsel => rdsel,
			iod_clk => sys_iodclk,
			iod_ce  => dqsiod_ce,
			iod_inc => dqsiod_inc);
		sys_rdsel <= rdsel;

		sti <= sys_sti(0) when rdsel='0' else sys_sti(1);
		st <= smp(0) or smp(1);
		adjsto_e : entity hdl4fpga.adjsto
		port map (
			sys_clk0 => sys_rdclk,
			iod_clk => sys_iodclk,
			sti => sti,
			sto => sto,
			smp => st,
			req => adjsto_req,
			rdy => adjsto_rdy);

		sys_sto <= (others => sto);
	
		process (sys_dqso)
		begin
			dqso <= (others => '0');
			for i in dqso'range loop
				if i mod 2 = 0 then
					dqso(i) <= sys_dqso(i);
				end if;
			end loop;
		end process;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => sys_rst,
			clk  => omdr_clk,
			t    => sys_dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

	end block;
end;
