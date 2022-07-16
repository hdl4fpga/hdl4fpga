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

library hdl4fpga;
use hdl4fpga.std.all;

entity ddrdqphy is
	generic (
		taps       : natural;
		data_gear  : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		iod_rst    : in  std_logic;
		sys_clks   : in  std_logic_vector;
		sys_rlreq  : in  std_logic;
		sys_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		read_brst  : out std_logic;
		write_rdy  : in  std_logic;
		write_req  : buffer std_logic;
		sys_dmt    : in  std_logic_vector(0 to data_gear-1) := (others => '-');
		sys_dmi    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(0 to data_gear-1) := (others => '-');
		sys_sto    : out std_logic_vector(0 to data_gear-1);
		sys_dqi    : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(0 to data_gear-1);
		sys_dqst   : in  std_logic_vector(0 to data_gear-1);

		ddr_dmt    : out std_logic;
		ddr_dmo    : out std_logic;
		ddr_dqsi   : in  std_logic;
		ddr_sto    : out std_logic;
		ddr_dqi    : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt    : out std_logic_vector(byte_size-1 downto 0);
		ddr_dqo    : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst   : out std_logic;
		ddr_dqso   : out std_logic);

	alias clk0     : std_logic is sys_clks(0);
	alias clk90    : std_logic is sys_clks(1);
	alias iod_clk  : std_logic is sys_clks(2);
	alias clk0x2   : std_logic is sys_clks(3);
	alias clk90x2  : std_logic is sys_clks(4);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture virtex5 of ddrdqphy is

	signal adjdqs_req : std_logic;
	signal adjdqs_rdy : std_logic;
	signal adjdqi_req : std_logic;
	signal adjdqi_rdy : std_logic_vector(ddr_dqi'range);
	signal adjsto_req : bit;
	signal adjsto_rdy : bit;
	signal adjbrt_req : std_logic;
	signal adjbrt_rdy : std_logic;

	signal dqsi_buf   : std_logic;
	signal dqsiod_inc : std_logic;
	signal dqsiod_ce  : std_logic;

	signal dqs180     : std_logic;
	signal dqspre     : std_logic;
	signal dq         : std_logic_vector(sys_dqo'range);
	signal dqi        : std_logic_vector(ddr_dqi'range);
	signal dqh        : std_logic_vector(dq'range);
	signal dqf        : std_logic_vector(dq'range);

	signal dqipau_req : std_logic_vector(ddr_dqi'range);
	signal dqipau_rdy : std_logic_vector(ddr_dqi'range);
	signal dqspau_req : std_logic;
	signal dqspau_rdy : std_logic;

	signal imdr_rst   : std_logic;
	signal omdr_rst   : std_logic;
	signal tp_dqidly  : std_logic_vector(0 to 6-1);
	signal tp_dqsdly  : std_logic_vector(0 to 6-1);
	signal tp_dqssel  : std_logic_vector(0 to 3-1);

	signal rlpause_req : bit;
	signal rlpause_rdy : bit;
	signal pause_req   : bit;
	signal pause_rdy   : bit;

	constant dqs_linedelay : time := 7 ns;
	constant dqi_linedelay : time := 0 ns; --1.35 ns;

begin

	rl_b : block
	begin

		process (pause_req, clk0)
			type states is (s_start, s_write, s_dqs, s_dqi, s_sto);
			variable state : states;
			variable aux : std_logic;
		begin
			if rising_edge(clk0) then
				if (to_bit(sys_rlreq) xor to_bit(sys_rlrdy))='0' then
					adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
					adjdqi_req <= to_stdulogic(adjsto_rdy);
					adjsto_req <= adjsto_rdy;
					state := s_start;
				else
					case state is
					when s_start =>
						write_req <= not to_stdulogic(to_bit(write_rdy));
						read_brst <= '0';
						state := s_write;
					when s_write =>
						if (to_bit(write_req) xor to_bit(write_rdy))='0' then
							read_req <= not to_stdulogic(to_bit(read_rdy));
							read_brst <= '1';
							if sys_sti(0)='1' then
								adjdqs_req <= not to_stdulogic(to_bit(adjdqs_rdy));
								state := s_dqs;
							end if;
						end if;
					when s_dqs =>
						if (to_bit(adjdqs_req) xor to_bit(adjdqs_rdy))='0' then
							adjdqi_req <= not to_stdulogic(adjsto_req);
							state := s_dqi;
						end if;
					when s_dqi =>
						aux := '0';
						for i in adjdqi_rdy'range loop
							aux := aux or (adjdqi_rdy(i) xor adjdqi_req);
						end loop;
						if aux='0' then
							read_brst <= '0';
							if (to_bit(read_req) xor to_bit(read_rdy))='0' then
								read_req   <= not read_rdy;
								adjsto_req <= not adjsto_rdy;
								state := s_sto;
							end if;
						end if;
					when s_sto =>
						if (read_req xor read_rdy)='0' then
							if (adjsto_req xor adjsto_rdy)='0' then
								sys_rlrdy <= sys_rlreq;
								state := s_start;
							else
								read_req <= not read_rdy;
							end if;
						end if;
						read_brst <= '0';
					end case;
				end if;
			end if;
		end process;

		rlpause_req <= to_bit(dqspau_req) xor setif((dqipau_req xor dqipau_rdy)=(dqipau_req'range => '1'));

		process (iod_clk)
		begin
			if rising_edge(iod_clk) then
				if (pause_rdy xor pause_req)='0' then
					dqspau_rdy <= dqspau_req;
					dqipau_rdy <= dqipau_req;
				end if;
			end if;
		end process;

	end block;

	pause_req <= rlpause_req;
	process (iod_clk, pause_rdy)
		variable cntr : unsigned(0 to unsigned_num_bits(63));
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

	process (clk0)
	begin
		if rising_edge(clk0) then
			imdr_rst <= iod_rst;
			omdr_rst <= iod_rst;
		end if;
	end process;

	dqsi_b : block
		signal delay    : std_logic_vector(0 to 6-1);
		signal dqsi     : std_logic;
		signal smp      : std_logic_vector(0 to data_gear-1);
		signal sto      : std_logic;
		signal imdr_clk : std_logic_vector(0 to 5-1);
	begin

		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			taps    => setif(taps > 0, taps, 2**delay'length-1))
		port map (
			edge     => std_logic'('1'),
			clk      => iod_clk,
			req      => adjdqs_req,
			rdy      => adjdqs_rdy,
			step_req => dqspau_req,
			step_rdy => dqspau_rdy,
			smp      => smp,
			ph180    => dqs180,
			delay    => delay);

		dqsi <= transport ddr_dqsi after dqs_linedelay;
		dqsidelay_i : entity hdl4fpga.xc5v_idelay
		port map(
			clk     => iod_clk,
			rst     => iod_rst,
			delay   => delay,
			idatain => dqsi,
			dataout => dqsi_buf);

		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				imdr_clk(0 to 2-1) <= (0 => clk0, 1 => clk0);
			when 4 =>
				imdr_clk <= (0 => clk0, 1 => clk0x2, 2 => not clk90x2, 3 => not clk0x2, 4 => clk90x2);
			when others =>
			end case;
		end process;

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => data_gear)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqsi_buf,
			q    => smp);

		tp_dqsdly <= delay;
		process (clk0)
		begin
			if rising_edge(clk0) then
				imdr_rst <= iod_rst;
			end if;
		end process;

		adjbrt_req <= to_stdulogic(adjsto_req);
		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			lat  => 1,
			GEAR => data_gear)
		port map (
			tp       => tp_dqssel,
			ddr_clk  => clk0,
			edge     => '0',
			ddr_sti  => sys_sti(0),
			ddr_sto  => sto,
			dqs_smp  => smp,
			dqs_pre  => dqspre,
			sys_req  => adjbrt_req,
			sys_rdy  => adjbrt_rdy);
		adjsto_rdy <= to_bit(adjbrt_rdy);

--		process (clk90)
--			variable q : std_logic;
--		begin
--			if rising_edge(clk90) then
--				if (not dqspre and dqs180)='1' then
--					sys_sto <= (others => sto);
--				elsif (not dqspre and not dqs180)='1' then
--					sys_sto <= (others => sto);
--				else
--					sys_sto <= (others => q);
--				end if;
--				q := sto;
--			end if;
--		end process;
		sys_sto <= (others => sto);

	end block;

	iddr_g : for i in 0 to byte_size-1 generate
		signal delay : std_logic_vector(6-1 downto 0);
		signal imdr_clk  : std_logic_vector(0 to 5-1);
		signal dqii      : std_logic_vector(0 to data_gear-1);
	begin
		adjdqi_b : block
			signal delay    : std_logic_vector(0 to 6-1);
			signal dq_smp   : std_logic_vector(0 to data_gear-1);
			signal ddqi     : std_logic;
		begin

			smp_p : process (dq)
			begin
				for j in dq_smp'range loop
					dq_smp(j) <= dq(j*BYTE_SIZE+i);
				end loop;
			end process;

			adjdqi_e : entity hdl4fpga.adjpha
			generic map (
				taps     => taps)
			port map (
				edge     => std_logic'('0'),
				clk      => iod_clk,
				req      => adjdqi_req,
				rdy      => adjdqi_rdy(i),
				step_req => dqipau_req(i),
				step_rdy => dqipau_rdy(i),
				smp      => dq_smp,
				delay    => delay);

			tp_g : if i=0 generate
				tp_dqidly <= delay;
			end generate;

			ddqi <= transport ddr_dqi(i) after dqi_linedelay;
			dqi_p : for j in dqii'range generate
				dq(j*BYTE_SIZE+i) <= dqii(j);
			end generate;

			dqi_i : entity hdl4fpga.xc5v_idelay
			port map(
				clk     => iod_clk,
				rst     => iod_rst,
				delay   => delay,
				idatain => ddqi,
				dataout => dqi(i));

		end block;

		tp_dqsdly <= delay;
		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				imdr_clk(0 to 2-1) <= (0 => clk0, 1 => clk0);
			when 4 =>
				imdr_clk <= (0 => clk90, 1 => clk90x2, 2 => clk90x2, 3 => not clk90x2, 4 => not clk90x2);
			when others =>
			end case;
		end process;

		imdr_i : entity hdl4fpga.imdr
		generic map (
			SIZE => 1,
			GEAR => data_gear)
		port map (
			rst  => imdr_rst,
			clk  => imdr_clk,
			d(0) => dqi(i),
			q    => dqii);

	end generate;

	datao_b : block
		signal clks  : std_logic_vector(0 to 2-1);
		signal dqclk : std_logic_vector(0 to 2-1);
	begin
		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				dqclk <= (0 => clk90, 1 => clk90);
				if data_edge then
					clks <= (0 => clk90, 1 => not clk90);
				else
					clks <= (0 => clk90, 1 => clk90);
				end if;
			when 4 =>
				dqclk <= (0 => clk90, 1 => clk90x2);
				if data_edge then
					clks <= (0 => clk90, 1 => not clk90);
				else
					clks <= (0 => clk90, 1 => clk90);
				end if;
			when others =>
			end case;
		end process;
	
		oddr_g : for i in 0 to BYTE_SIZE-1 generate
			signal dqo   : std_logic_vector(0 to data_gear-1);
			signal dqt   : std_logic_vector(sys_dqt'range);
		begin
	
			registered_g : for j in clks'range generate
				signal sw : std_logic;
			begin
	
				process (iod_clk)
				begin
					if rising_edge(iod_clk) then
						sw <= to_stdulogic(to_bit(sys_rlrdy) xor to_bit(sys_rlreq));
					end if;
				end process;
	
				gear_g : for l in 0 to data_gear/clks'length-1 generate
					process (sw, clks(j))
					begin
						if sw='1' then
							if j mod 2=1 then
								dqo(l*data_gear/clks'length+j) <= '1';
							else
								dqo(l*data_gear/clks'length+j) <= '0';
							end if;
						elsif rising_edge(clks(j)) then
							dqo(l*data_gear/clks'length+j) <= sys_dqi((l*data_gear/clks'length+j)*BYTE_SIZE+i);
						end if;
						if rising_edge(clks(j)) then
							dqt(l*data_gear/clks'length+j) <= reverse(sys_dqt)(l*data_gear/clks'length+j);
						end if;
					end process;
				end generate;
			end generate;
	
			omdr_i : entity hdl4fpga.omdr
			generic map (
				SIZE => 1,
				DATA_EDGE => setif(data_edge, "OPPOSITE_EDGE", "SAME_EDGE"),
				GEAR => data_gear)
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
			signal omdr_rst  : std_logic;
		begin
	
			registered_g : for i in clks'range generate
				gear_g : for l in 0 to data_gear/clks'length-1 generate
					process (clks(i))
					begin
						if rising_edge(clks(i)) then
							dmi(l*data_gear/clks'length+i) <= sys_dmi(l*data_gear/clks'length+i);
						end if;
					end process;
				end generate;
			end generate;
	
			omdr_i : entity hdl4fpga.omdr
			generic map (
				SIZE => 1,
				DATA_EDGE => setif(data_edge, "OPPOSITE_EDGE", "SAME_EDGE"),
				GEAR => data_gear)
			port map (
				rst   => omdr_rst,
				clk   => dqclk,
				tq(0) => ddr_dmt,
				d     => dmi,
				q(0)  => ddr_dmo);
	
		end block;
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

		process (sys_clks)
		begin
			case data_gear is
			when 2 =>
				dqsclk <= (0 => clk0, 1 => not clk0);
			when 4 =>
				dqsclk <= (0 => clk0, 1 => clk0x2);
			when others =>
			end case;
		end process;

		omdr_i : entity hdl4fpga.omdr
		generic map (
			SIZE => 1,
			DATA_EDGE => setif(data_edge, "OPPOSITE_EDGE", "SAME_EDGE"),
			GEAR => data_gear)
		port map (
			rst  => omdr_rst,
			clk  => dqsclk,
			t    => dqst,
			tq(0)=> ddr_dqst,
			d    => dqso,
			q(0) => ddr_dqso);

	end block;
	sys_dqo <= dq;
end;
