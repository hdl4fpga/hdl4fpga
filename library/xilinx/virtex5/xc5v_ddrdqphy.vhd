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
		taps       : natural;
		DATA_GEAR  : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		iod_rst    : in  std_logic;
		iod_clk    : in  std_logic;
		sys_rsts   : in  std_logic_vector;
		sys_clks   : in  std_logic_vector;
		sys_rlreq  : in  std_logic;
		sys_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		sys_dmt    : in  std_logic_vector(0 to DATA_GEAR-1) := (others => '-');
		sys_dmi    : in  std_logic_vector(DATA_GEAR-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(0 to DATA_GEAR-1) := (others => '-');
		sys_sto    : out std_logic_vector(0 to DATA_GEAR-1);
		sys_dqi    : in  std_logic_vector(DATA_GEAR*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(DATA_GEAR-1 downto 0);
		sys_dqo    : out std_logic_vector(DATA_GEAR*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(0 to DATA_GEAR-1);
		sys_dqst   : in  std_logic_vector(0 to DATA_GEAR-1);

		ddr_dmt    : out std_logic;
		ddr_dmo    : out std_logic;
		ddr_dqsi   : in  std_logic;
		ddr_sto    : out std_logic;
		ddr_dqi    : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt    : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo    : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst   : out std_logic;
		ddr_dqso   : out std_logic);

	constant clk0div  : natural := 0;
	constant clk90div : natural := 1;
	constant iodclk   : natural := 2;
	constant clk0     : natural := 3;
	constant clk90    : natural := 4;

	constant rst0div  : natural := 0;
	constant rst90div : natural := 1;
	constant rstiod   : natural := 1;

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture virtex5 of ddrdqphy is

	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);
	signal adjsto_req : std_logic;
	signal adjsto_rdy : std_logic;

	signal dqsi_buf   : std_logic;
	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;

	signal dqs180     : std_logic;
	signal dqspre     : std_logic;
	signal dq         : std_logic_vector(sys_dqo'range);
	signal dqi        : std_logic_vector(ddr_dqi'range);
	signal dqh        : std_logic_vector(dq'range);
	signal dqf        : std_logic_vector(dq'range);

	signal imdr_rst : std_logic;
	signal omdr_rst : std_logic;
	signal tp_dqidly  : std_logic_vector(0 to 6-1);
	signal tp_dqsdly  : std_logic_vector(0 to 6-1);
	signal tp_dqssel  : std_logic_vector(0 to 3-1);

	constant dqs_linedelay : time := 1.35 ns;
	constant dqi_linedelay : time := 0 ns; --1.35 ns;

begin

	process (sys_clks(0))
		type states is (sync_start, sync_dqs, sync_dqi, sync_sto);
		variable state : states;
		variable aux : std_logic;
	begin
		if rising_edge(sys_clks(0)) then
			if (to_bit(sys_rlreq) xor to_bit(sys_rlrdy))='0' then
				adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
				adjdqi_req <= to_stdulogic(to_bit(adjsto_rdy));
				adjsto_req <= to_stdulogic(to_bit(adjsto_rdy));
				state := sync_start;
			else
				case state is
				when sync_start =>
					read_req <= not read_rdy;
					if sys_sti(0)='1' then
						adjdqs_req <= not to_stdulogic(to_bit(adjdqs_rdy));
						state := sync_dqs;
					end if;
				when sync_dqs =>
					if (to_bit(adjdqs_req) xor to_bit(adjdqs_rdy))='0' then
						adjdqi_req <= not to_stdulogic(to_bit(adjsto_req));
						state := sync_dqi;
					end if;
				when sync_dqi =>
					aux := '0';
					for i in adjdqi_rdy'range loop
						aux := aux or (adjdqi_rdy(i) xor adjdqi_req);
					end loop;
					if aux='0' then
						adjsto_req <= not adjsto_rdy;
						state := sync_sto;
					end if;
				when sync_sto =>
					if (adjsto_req xor adjsto_rdy)='0' then
						sys_rlrdy <= sys_rlreq;
						state := sync_start;
					end if;
				end case;
			end if;
		end if;
	end process;

	rl_b : block
		signal step_req : std_logic;
		signal step_rdy : std_logic;
		signal adj_req : std_logic;
		signal adj_rdy : std_logic;

	begin

		process (sys_clks(clk0div), read_req)
			type states is (s_start, s_adj, s_paused);
			variable state : states;
		begin
			if rising_edge(sys_clks(clk0div)) then
				if (to_bit(sys_rlreq) xor to_bit(sys_rlrdy))='1' then
					case state is
					when s_start =>
						adj_req <= not to_stdulogic(to_bit(adj_rdy));
						state := s_adj;
					when s_adj =>
						if (to_bit(adj_req) xor to_bit(adj_rdy))='0' then
							rlpause1_req <= not rlpause1_rdy;
							state := s_paused;
						end if;
					when s_paused =>
						if (rlpause1_req xor rlpause1_rdy)='0' then
							sys_rlrdy <= to_stdulogic(to_bit(sys_rlreq));
							state := s_start;
						end if;
					end case;
				else
					rlpause1_req <= rlpause1_rdy;
					state       := s_start;
				end if;
			end if;
		end process;

		process (sclk, read_req)
			type states is (s_start, s_pause, s_read);
			variable state : states;
		begin
			if rising_edge(sclk) then
				if (to_bit(adj_req) xor to_bit(adj_rdy))='1' then
					if (to_bit(step_req) xor to_bit(step_rdy))='1' then
						case state is
						when s_start =>
							rlpause_req <= not rlpause_rdy;
							state := s_pause;
						when s_pause =>
							if (rlpause_req xor rlpause_rdy)='0' then
								read_req <= not to_stdulogic(to_bit(read_rdy));
								state    := s_read;
							end if;
						when s_read =>
							if (read_req xor to_stdulogic(to_bit(read_rdy)))='0' then
								step_rdy <= step_req;
								state    := s_start;
							end if;
						end case;
					end if;
				else
					rlpause_req <= rlpause_rdy;
					read_req    <= to_stdulogic(to_bit(read_rdy));
					state       := s_start;
				end if;
			end if;
		end process;

	end block;

	dqsi_b : block
		signal pause_rdy : std_logic;
		signal pause_req : std_logic;
		signal delay    : std_logic_vector(0 to 6-1);
		signal dqsi     : std_logic;
		signal ddqsi    : std_logic;
		signal smp      : std_logic_vector(0 to DATA_GEAR-1);
		signal sto      : std_logic;
		signal imdr_rst : std_logic;
		signal imdr_clk : std_logic_vector(0 to 5-1);
	begin

		process (iod_clk)
			variable cntr : unsigned(0 to delay'length);
		begin
			if rising_edge(iod_clk) then
				if (pause_rdy xor pause_req)='0' then
					cntr := (others => '0');
				elsif cntr(0)='0' then
					cntr := cntr + 1;
				else
					pause_rdy <= pause_req;
				end if;
			end if;
		end process;

		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
--			dtaps   => (taps+7)/8,
--			dtaps   => (taps+3)/4,
			taps    => taps)
		port map (
			edge     => std_logic'('1'),
			clk      => sys_clks(iodclk),
			req      => adjdqs_req,
			rdy      => adjdqs_rdy,
			step_req => pause_req,
			step_rdy => pause_rdy,
			smp      => smp,
			ph180    => dqs180,
			delay    => delay);

		dqsidelay_i : entity hdl4fpga.xc5_idelay
		port map(
			clk     => iod_clk,
			rst     => iod_rst,
			delay   => delay,
			idatain => ddqsi,
			dataout => dqsi_buf);
		dqsi  <= dqsi_buf;

		process (sys_clks)
		begin
			case DATA_GEAR is
			when 2 =>
				imdr_clk(0 to 2-1) <= (0 => sys_clks(0), 1 => sys_clks(0));
			when 4 =>
				imdr_clk <= (
					0 => sys_clks(clk0div),
					1 => sys_clks(clk0),
					2 => not sys_clks(clk90),
					3 => not sys_clks(clk0),
					4 => sys_clks(clk90));
			when others =>
			end case;
		end process;

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqsi,
			q    => smp);

		tp_dqsdly <= delay;
		process (sys_clks(clk0div))
		begin
			if rising_edge(sys_clks(clk0div)) then
				imdr_rst <= sys_rsts(rst0div);
			end if;
		end process;

		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			GEAR => DATA_GEAR)
		port map (
			tp       => tp_dqssel,
			ddr_clk  => sys_clks(clk0div),
			edge     => '0',
			ddr_sti  => sys_sti(0),
			ddr_sto  => sto,
			dqs_smp  => smp,
			dqs_pre  => dqspre,
			sys_req  => adjsto_req,
			sys_rdy  => adjsto_rdy);

		process (sys_clks(clk90div))
			variable q : std_logic;
		begin
			if rising_edge(sys_clks(clk90div)) then
				if (not dqspre and dqs180)='1' then
					sys_sto <= (others => sto);
				elsif (not dqspre and not dqs180)='1' then
					sys_sto <= (others => sto);
				else
					sys_sto <= (others => q);
				end if;
				q := sto;
			end if;
		end process;

	end block;

	iddr_g : for i in 0 to byte_size-1 generate
		signal delay : std_logic_vector(6-1 downto 0);
		signal imdr_clk  : std_logic_vector(0 to 5-1);
		signal dqii      : std_logic_vector(0 to DATA_GEAR-1);
	begin
		adjdqi_b : block
			signal delay    : std_logic_vector(0 to 6-1);
			signal pause_req : std_logic;
			signal pause_rdy : std_logic;
			signal dq_smp   : std_logic_vector(0 to DATA_GEAR-1);
			signal ddqi     : std_logic;
		begin

			process (iod_clk)
				variable cntr : unsigned(0 to delay'length);
			begin
				if rising_edge(iod_clk) then
					if (pause_rdy xor pause_req)='0' then
						cntr := (others => '0');
					elsif cntr(0)='0' then
						cntr := cntr + 1;
					else
						pause_rdy <= pause_req;
					end if;
				end if;
			end process;

			smp_p : process (dq)
			begin
				for j in dq_smp'range loop
					dq_smp(i) <= dq(j*BYTE_SIZE+i);
				end loop;
			end process;

			adjdqi_e : entity hdl4fpga.adjpha
			generic map (
--				dtaps    => (taps+7)/8,
--				dtaps    => (taps+3)/4,
				taps     => taps)
			port map (
				edge     => std_logic'('0'),
				clk      => iod_clk,
				req      => adjdqi_req,
				rdy      => adjdqi_rdy(i),
				step_req => pause_req,
				step_rdy => pause_rdy,
				smp      => dq_smp,
				delay    => delay);

			tp_g : if i=0 generate
				tp_dqidly <= delay;
			end generate;

			ddqi <= transport ddr_dqi(i) after dqi_linedelay;
			dqi_p : process (dqii)
			begin
				for j in dqii'range loop
					dq(j*BYTE_SIZE+i) <= dqii(i);
				end loop;
			end process;

			dqi_i : entity hdl4fpga.xc5_idelay
			port map(
				clk     => iod_clk,
				rst     => iod_rst,
				delay   => delay,
				idatain => ddqi,
				dataout => dqi(i));

		end block;

		tp_dqsdly <= delay;
		process (sys_clks(0))
		begin
			if rising_edge(sys_clks(0)) then
				imdr_rst <= '0';
			end if;
		end process;

		process (sys_clks)
		begin
			case DATA_GEAR is
			when 2 =>
				imdr_clk(0 to 2-1) <= (0 => sys_clks(0), 1 => sys_clks(0));
			when 4 =>
				imdr_clk <= (
					0 => sys_clks(clk0div),
					1 => sys_clks(clk0),
					2 => not sys_clks(clk90),
					3 => not sys_clks(clk0),
					4 => sys_clks(clk90));
			when others =>
			end case;
		end process;

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqi(i),
			q    => dqii);

	end generate;

	oddr_g : for i in 0 to BYTE_SIZE-1 generate
		signal dqo   : std_logic_vector(0 to DATA_GEAR-1);
		signal clks  : std_logic_vector(0 to 2-1);
		signal dqt   : std_logic_vector(sys_dqt'range);
		signal dqclk : std_logic_vector(0 to 2-1);
	begin

		dqclk <= (0 => sys_clks(clk90), 1 => sys_clks(clk90));

		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				if data_edge then
					clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));
				else
					clks <= (0 => sys_clks(clk90), 1 => sys_clks(clk90));
				end if;
			when 4 =>
				if data_edge then
					clks <= (0 => sys_clks(clk90div), 1 => not sys_clks(clk90div));
				else
					clks <= (0 => sys_clks(clk90div), 1 => sys_clks(clk90div));
				end if;
			when others =>
			end case;
		end process;

		registered_g : for j in clks'range generate
			signal sw : std_logic;
		begin

			process (iod_clk)
			begin
				if rising_edge(iod_clk) then
					sw <= to_stdulogic(to_bit(sys_rlrdy) xor to_bit(sys_rlreq));
				end if;
			end process;

			gear_g : for l in 0 to DATA_GEAR/clks'length-1 generate
				process (sw, clks(j))
				begin
					if sw='1' then
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
			rst   => omdr_rst,
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
		signal omdr_rst  : std_logic;
	begin

		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				dqclk <= (0 => sys_clks(clk90), 1 => sys_clks(clk90));
				if data_edge then
					clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));
				else
					clks <= (0 => sys_clks(clk90), 1 => sys_clks(clk90));
				end if;
			when 4 =>
				dqclk <= (0 => sys_clks(clk90div), 1 => sys_clks(clk90));
				if data_edge then
					clks <= (0 => sys_clks(clk90div), 1 => not sys_clks(clk90div));
				else
					clks <= (0 => sys_clks(clk90div), 1 => sys_clks(clk90div));
				end if;
			when others =>
			end case;
		end process;

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
			rst   => omdr_rst,
			clk   => dqclk,
			t     => (others => '0'),
			tq(0) => ddr_dmt,
			d     => dmi,
			q(0)  => ddr_dmo);

	end block;

	dqso_b : block
		signal dqso      : std_logic_vector(sys_dqsi'range);
		signal dqst      : std_logic_vector(sys_dqst'range);
		signal dqsclk    : std_logic_vector(0 to 2-1);
		signal adjdqs_st : std_logic;
	begin

		process (sys_dqsi)
		begin
			dqso <= (others => '0');
			for i in dqso'range loop
				if i mod 2 = 1 then
					dqso(i) <= reverse(sys_dqsi)(i);
				end if;
			end loop;
		end process;
		dqst <= reverse(sys_dqst);

		dqsclk <= (0 => sys_clks(clk0), 1 => sys_clks(clk0));
		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			GEAR => DATA_GEAR)
		port map (
			rst  => omdr_rst,
			clk  => dqsclk,
			t    => dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

	end block;
end;
