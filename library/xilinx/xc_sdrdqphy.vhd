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

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.profiles.all;

library unisim;
use unisim.vcomponents.all;

entity xc_sdrdqphy is
	generic (
		dqs_delay  : time := 1.65*1.25 ns;
		dqi_delay  : time := 1.65*1.25 ns;

		loopback   : boolean := false;
		bypass     : boolean := false;
		bufio      : boolean;
		device     : fpga_devices;
		taps       : natural;
		data_gear  : natural;
		data_edge  : boolean;
		byte_size  : natural);
	port (
		tp_sel     : in  std_logic := '-';
		tp_delay   : out std_logic_vector(1 to 8);

		rst        : in  std_logic;
		iod_clk    : in  std_logic;
		clk0       : in  std_logic := '-';
		clk90      : in  std_logic := '-';
		clk0x2     : in  std_logic := '-';
		clk90x2    : in  std_logic := '-';

		sys_wlreq  : in  std_logic := '-';
		sys_wlrdy  : out std_logic;

		sys_rlreq  : in  std_logic;
		sys_rlrdy  : buffer std_logic;
		read_rdy   : in  std_logic;
		read_req   : buffer std_logic;
		read_brst  : out std_logic;
		write_rdy  : in  std_logic;
		write_req  : buffer std_logic;
		sys_dmt    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sti    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_sto    : buffer std_logic_vector(data_gear-1 downto 0);
		sys_dmi    : in  std_logic_vector(data_gear-1 downto 0) := (others => '-');
		sys_dqi    : in  std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqt    : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqo    : out std_logic_vector(data_gear*byte_size-1 downto 0);
		sys_dqsi   : in  std_logic_vector(data_gear-1 downto 0);
		sys_dqso   : buffer std_logic_vector(data_gear-1 downto 0);
		sys_dqst   : in  std_logic_vector(data_gear-1 downto 0);
		sto_synced : buffer std_logic;

		sdram_dmi  : in  std_logic := '-';
		sdram_sti  : in  std_logic := '-';
		sdram_sto  : out std_logic;
		sdram_dmt  : out std_logic;
		sdram_dmo  : out std_logic;
		sdram_dqsi : in  std_logic;
		sdram_dqi  : in  std_logic_vector(byte_size-1 downto 0);
		sdram_dqt  : out std_logic_vector(byte_size-1 downto 0);
		sdram_dqo  : out std_logic_vector(byte_size-1 downto 0);

		sdram_dqst : out std_logic;
		sdram_dqso : out std_logic);
end;

architecture xilinx of xc_sdrdqphy is

	signal adjdqs_req   : std_logic;
	signal adjdqs_rdy   : std_logic;
	signal adjdqi_req   : std_logic_vector(sdram_dqi'range);
	signal adjdqi_rdy   : std_logic_vector(sdram_dqi'range);
	signal adjsto_req   : std_logic;
	signal adjsto_rdy   : std_logic;

	signal dqspau_req   : std_logic;
	signal dqspau_rdy   : std_logic;
	signal dqs180       : std_logic;
	signal dqspre       : std_logic;
	signal dqssto       : std_logic;

	signal dq           : std_logic_vector(sys_dqo'range);
	signal dqi          : std_logic_vector(sdram_dqi'range);

	signal dqipause_req : std_logic;
	signal dqipause_rdy : std_logic;
	signal dqipau_req   : std_logic_vector(sdram_dqi'range);
	signal dqipau_rdy   : std_logic_vector(sdram_dqi'range);

	signal pause_req    : std_logic;
	signal pause_rdy    : std_logic;

	signal dqsi_delay   : std_logic_vector(0 to setif(device=xc7a,5,6)-1);
	signal tp_dqidly    : std_logic_vector(6-1 downto 0);
	signal tp_dqsdly    : std_logic_vector(6-1 downto 0);
	signal tp_dqssel    : std_logic_vector(3-1 downto 0);

	signal step_req : std_logic;
	signal step_rdy : std_logic;

	signal data_align : std_logic_vector(sys_sti'range);
begin

	with tp_sel select
	tp_delay <= 
		dqs180 & dqspre & tp_dqidly when '1',
		tp_dqssel(2-1 downto 0) & tp_dqsdly(6-1 downto 0) when others;
		-- sys_rlrdy & sys_rlreq & adjsto_req & adjsto_rdy & step_rdy & step_req & (read_rdy xor read_req) & sto_synced when others;
		-- adjdqs_req & adjdqs_rdy & adjdqi_req(0) & adjdqi_rdy(0) & adjsto_req & adjsto_rdy & (read_rdy xor read_req) & sto_synced when others;

	sys_wlrdy <= to_stdulogic(to_bit(sys_wlreq));
	rl_b : block
	begin

		process (pause_rdy, pause_req, iod_clk)
			type states is (s_init, s_write, s_dqs, s_w4dqi, s_dqi4rdy, s_sto);
			variable state : states;
			variable sy_write_rdy : std_logic;
			variable sy_read_rdy  : std_logic;
		begin
			if rising_edge(iod_clk) then
				if rst='1' then
					sys_rlrdy <= to_stdulogic(to_bit(sys_rlreq));
					adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
					adjdqi_req <= to_stdlogicvector(to_bitvector(adjdqi_rdy));
					adjsto_req <= to_stdulogic(to_bit(adjsto_rdy));
					state      := s_init;
				elsif (sys_rlrdy xor to_stdulogic(to_bit(sys_rlreq)))='0' then
					adjdqs_req <= to_stdulogic(to_bit(adjdqs_rdy));
					adjdqi_req <= to_stdlogicvector(to_bitvector(adjdqi_rdy));
					adjsto_req <= to_stdulogic(to_bit(adjsto_rdy));
					state      := s_init;
				else
					case state is
					when s_init =>
						write_req <= not to_stdulogic(to_bit(sy_write_rdy));
						read_brst <= '0';
						state     := s_write;
					when s_write =>
						if (sy_write_rdy xor to_stdulogic(to_bit(write_req)))='0' then
							read_req <= not to_stdulogic(to_bit(sy_read_rdy));
							read_brst <= '1';
							if sys_sti(0)='1' then
								adjdqs_req <= not to_stdulogic(to_bit(adjdqs_rdy));
								state      := s_dqs;
							end if;
						end if;
					when s_dqs =>
						if (adjdqs_rdy xor to_stdulogic(to_bit(adjdqs_req)))='0' then
							adjdqi_req <= not adjdqi_rdy;
							state      := s_w4dqi;
						end if;
					when s_w4dqi =>
						state := s_dqi4rdy;
						for i in adjdqi_rdy'range loop
							if (adjdqi_rdy(i) xor adjdqi_req(i))='1' then
								state := s_w4dqi;
							end if;
						end loop;
					when s_dqi4rdy =>
						read_brst <= '0';
						if (sy_read_rdy xor to_stdulogic(to_bit(read_req)))='0' then
							read_req   <= not sy_read_rdy;
							adjsto_req <= not adjsto_rdy;
							state      := s_sto;
						end if;
					when s_sto =>
						if (sy_read_rdy xor to_stdulogic(to_bit(read_req)))='0' then
							if (adjsto_rdy xor to_stdulogic(to_bit(adjsto_req)))='0' then
								sys_rlrdy <= to_stdulogic(to_bit(sys_rlreq));
							else
								read_req <= not sy_read_rdy;
							end if;
						end if;
						read_brst <= '0';
					end case;
				end if;
				sy_write_rdy := write_rdy;
				sy_read_rdy  := read_rdy;
			end if;
		end process;

		dqipause_p : process (iod_clk)
			type states is (s_init, s_wait, s_idle);
			variable state : states;
			variable sy_dqipau_req : std_logic_vector(dqipau_req'range);
		begin
			if rising_edge(iod_clk) then
				if rst='1' then
					dqipau_rdy <= to_stdlogicvector(to_bitvector(dqipau_req));
					state := s_idle;
				else
					case state is
					when s_init =>
						dqipause_req <= not dqipause_rdy;
						state := s_wait;
					when s_wait =>
						if (dqipause_rdy xor to_stdulogic(to_bit(dqipause_req)))='0' then
							dqipau_rdy <= to_stdlogicvector(to_bitvector(sy_dqipau_req));
							state := s_idle;
						end if;
					when s_idle =>
						state := s_init;
						for i in dqipau_req'range loop
							if (dqipau_rdy(i) xor to_stdulogic(to_bit(sy_dqipau_req(i))))='0' then
								state := s_idle;
							end if;
						end loop;
					end case;
				end if;
				sy_dqipau_req := dqipau_req;
			end if;
		end process;

	end block;

	process (iod_clk, pause_rdy)
		type states is (s_init, s_wait, s_idle);
		variable state : states;
		variable cntr  : unsigned(0 to unsigned_num_bits(63));
		variable sy_dqspau_req : std_logic;
	begin
		if rising_edge(iod_clk) then
			if rst='1' then
				dqipause_rdy <= to_stdulogic(to_bit(dqipause_req));
				dqspau_rdy   <= to_stdulogic(to_bit(dqspau_req));
				state := s_idle;
			else
				case state is
				when s_init =>
					if (pause_rdy xor to_stdulogic(to_bit(pause_req)))='0' then
						pause_req <= not pause_rdy;
						state := s_wait;
					end if;
				when s_wait =>
					if (pause_rdy xor to_stdulogic(to_bit(pause_req)))='0' then
						dqipause_rdy <= to_stdulogic(to_bit(dqipause_req));
						dqspau_rdy   <= to_stdulogic(to_bit(sy_dqspau_req));
						state        := s_idle;
					end if;
				when s_idle =>
					if (dqipause_rdy xor to_stdulogic(to_bit(dqipause_req)))='1' then
						state := s_init;
					elsif (dqspau_rdy xor to_stdulogic(to_bit(sy_dqspau_req)))='1' then
						state := s_init;
					end if;
				end case;
			end if;
			sy_dqspau_req := dqspau_req;
		end if;
	end process;

	process (iod_clk, pause_req)
		variable cntr : unsigned(0 to unsigned_num_bits(64-1));
	begin
		if rising_edge(iod_clk) then
			if rst='1' then
				pause_rdy <= to_stdulogic(to_bit(pause_req));
				cntr := (others => '0');
			elsif (pause_rdy xor to_stdulogic(to_bit(pause_req)))='1' then
				if cntr(0)='0' then
					cntr := cntr + 1;
				else
					pause_rdy <= to_stdulogic(to_bit(pause_req));
					cntr := (others => '0');
				end if;
			else
				cntr := (others => '0');
			end if;
		end if;
	end process;

	dqsi_b : block
		signal dqsi      : std_logic;
		signal dqsi_buf  : std_logic;
		signal dqs_smp   : std_logic_vector(0 to data_gear-1);
		signal clk90x2_n : std_logic;
	begin

		adjdqs_e : entity hdl4fpga.adjpha
		generic map (
			taps     => taps)
		port map (
			rst      => rst,
			edge     => std_logic'('1'),
			clk      => clk0,
			req      => adjdqs_req,
			rdy      => adjdqs_rdy,
			step_req => dqspau_req,
			step_rdy => dqspau_rdy,
			smp      => dqs_smp,
			ph180    => dqs180,
			delay    => dqsi_delay);

		dqsi <= transport sdram_dqsi after dqs_delay;
		dqsidelay_i : entity hdl4fpga.xc_dqsdelay 
		generic map (
			device => device,
			data_gear => data_gear)
		port map (
			rst    => rst,
			clk    => clk0,
			delay  => dqsi_delay,
			dqsi   => dqsi,
			dqso   => sys_dqso);
		dqsi_buf <= sys_dqso(0);

		clk90x2_n <= not clk90x2;
		igbx_i : entity hdl4fpga.igbx
		generic map (
			device => device,
			size   => 1,
			gear   => data_gear)
		port map (
			rst   => rst,
			sclk  => clk90x2_n,
			clkx2 => clk0x2,
			clk   => clk0,
			d(0)  => dqsi_buf,
			q     => dqs_smp);

		tp_dqsdly(dqsi_delay'length-1 downto 0) <= dqsi_delay;

		adjsto_e : entity hdl4fpga.adjsto
		generic map (
			gear      => data_gear)
		port map (
			tp        => tp_dqssel,
			rst       => rst,
			sdram_clk => clk0,
			edge      => std_logic'('0'),
			sdram_sti => sys_sti(0),
			sdram_sto => dqssto,
			dqs_smp   => dqs_smp,
			dqs_pre   => dqspre,
			step_req  => step_req,
			step_rdy  => step_rdy,
			sys_req   => adjsto_req,
			sys_rdy   => adjsto_rdy,
			synced    => sto_synced);

	end block;

	datai_b : block
	begin
		i_igbx : for i in sdram_dqi'range generate
		begin
			adjdqi_b : block
				signal delay  : std_logic_vector(0 to setif(device=xc7a,5,6)-1);
				signal dq_smp : std_logic_vector(data_gear-1 downto 0);
				signal ddqi   : std_logic;
			begin
	
				dqismp_p : process (dq)
				begin
					for j in dq_smp'range loop
						dq_smp(j) <= dq(j*byte_size+i);
					end loop;
				end process;
	
				adjdqi_e : entity hdl4fpga.adjpha
				generic map (
					taps     => taps)
				port map (
					rst      => rst,
					edge     => std_logic'('1'),
					clk      => clk90,
					req      => adjdqi_req(i),
					rdy      => adjdqi_rdy(i),
					step_req => dqipau_req(i),
					step_rdy => dqipau_rdy(i),
					smp      => dq_smp,
					delay    => delay);
	
				tp_g : if i=0 generate
					tp_dqidly(delay'length-1 downto 0) <= delay;
				end generate;
	
				ddqi <= transport sdram_dqi(i) after dqi_delay;
				dqi_i : entity hdl4fpga.xc_idelay
				generic map (
					device => device,
					signal_pattern => "DATA")
				port map(
					rst     => rst,
					clk     => clk90,
					delay   => delay,
					-- delay   => dqsi_delay,
					idatain => ddqi,
					dataout => dqi(i));
			end block;
	
			bypass_g : if bypass generate
				phases_g : for j in 0 to data_gear-1 generate
					sys_dqo(j*byte_size+i) <= sdram_dqi(i);
				end generate;
			end generate;
	
			igbx_g : if not bypass generate
				data_gear2_g : if data_gear=2 generate
					igbx_i : entity hdl4fpga.igbx
					generic map (
						device => device,
						size => 1,
						gear => data_gear)
					port map (
						rst  => rst,
						clk  => clk0,
						d(0) => dqi(i),
						q(0) => dq(0*byte_size+i),
						q(1) => dq(1*byte_size+i));

					shuffle_g : for j in 0 to data_gear-1 generate
						sys_dqo(j*byte_size+i) <= dq(j*byte_size+i);
					end generate;
				end generate;
	
				data_gear4_g : if data_gear=4 generate
					signal clk90x2_n : std_logic;
					signal q1 : std_logic_vector(data_gear-1 downto 0);
					signal q2 : std_logic_vector(data_gear-1 downto 0);
					
				begin

					clk90x2_n <= not clk90x2;
					igbx_i : entity hdl4fpga.igbx
					generic map (
						device => device,
						size => 1,
						gear => data_gear)
					port map (
						rst   => rst,
						-- sclk  => clk90x2_n,
						sclk  => clk0x2,
						clkx2 => clk90x2,
						clk   => clk90,
						d(0)  => dqi(i),
						q     => q1);
			
					process (q1, data_align)
						variable data : unsigned(q1'range);
					begin
						data := unsigned(q1);
						for j in data_align'range loop
							if data_align(j)='0' then
								data := data rol 1;
							else
								exit;
							end if;
						end loop;
						q2 <= std_logic_vector(data);
					end process;

					shuffle_g : for j in 0 to data_gear-1 generate
						dq(j*byte_size+i)      <= q1(j);
						sys_dqo(j*byte_size+i) <= q2(j);
					end generate;
				end generate;
			end generate;
		end generate;
	
		sto_b : block
		begin
			igbx_g : if not bypass generate
				data_gear4_g : if data_gear=4 generate
					signal clk90x2_n : std_logic;
				begin
					clk90x2_n <= not clk90x2;
					igbx_i : entity hdl4fpga.igbx
					generic map (
						device => device,
						size => 1,
						gear => data_gear)
					port map (
						rst   => rst,
						-- sclk  => clk90x2_n,
						sclk  => clk0x2,
						clkx2 => clk90x2,
						clk   => clk90,
						d(0)  => sdram_dmi);
				end generate;
			
				gbx4_g : if data_gear=4 generate
					signal sti : std_logic_vector(sys_sti'range);
				begin
					lat_e : entity hdl4fpga.latency
					generic map (
						n => data_gear,
						d => (0 to data_gear-1 => 2))
					port map (
						clk => clk90,
						di => sys_sti,
						do => sys_sto);

					process (clk90)
						variable ena : std_logic;
					begin
						if rising_edge(clk90) then
							if sys_sti=(sys_sti'range => '0') then
								ena := '1';
							elsif ena='1' then
								ena:= '0';
								data_align <= reverse(sys_sti);
							end if;
						end if;
					end process;

				end generate;

				gbx2_g : if data_gear=2 generate
					signal sti : std_logic;
					signal clk : std_logic;
				begin
					clk <= not sdram_dqsi;
					sti <= sdram_sti when loopback else sdram_dmi;
					sto_i : entity hdl4fpga.igbx
					generic map (
						device => hdl4fpga.profiles.xc3s,
						gear   => data_gear)
					port map (
						clk   => clk,
						sclk  => clk90x2,
						clkx2 => clk90x2,
						d(0)  => sti,
						q     => sys_sto);
				end generate;
			end generate;

			bypass_g : if bypass generate
				phases_g : for j in 0 to data_gear-1 generate
					sys_sto(j) <= sdram_sti when loopback else sdram_dmi;
				end generate;
			end generate;
		end block;
	
	end block;

	datao_b : block
		constant register_on : boolean := device=xc7a;
	begin
		oddr_g : for i in sdram_dqo'range generate

			signal dqo : std_logic_vector(data_gear-1 downto 0);
			signal dqt : std_logic_vector(sys_dqt'range);
			signal sw  : std_logic;
		begin

			process (iod_clk)
			begin
				if rising_edge(iod_clk) then
					sw <= sys_rlrdy xor to_stdulogic(to_bit(sys_rlreq));
				end if;
			end process;

			process (sw, sys_dqi, clk90)
			begin
				for j in dqo'range loop
					if sw='1' then
						if j mod 2=0 then
							dqo(j) <= '1';
						else
							dqo(j) <= '0';
						end if;
					elsif not register_on then
						dqo(j) <= sys_dqi(byte_size*j+i);
					elsif rising_edge(clk90) then
						dqo(j) <= sys_dqi(byte_size*j+i);
					end if;
				end loop;
			end process;

			process (sys_dqt, clk90)
			begin
				if not register_on then
					dqt <= reverse(sys_dqt);
				elsif rising_edge(clk90) then
					dqt <= reverse(sys_dqt);
				end if;
			end process;
	
			ogbx_i : entity hdl4fpga.ogbx
			generic map (
				device => device,
				size => 1,
				data_edge => setif(data_edge, string'("OPPOSITE_EDGE"), string'("SAME_EDGE")),
				gear => data_gear)
			port map (
				rst   => rst,
				clk   => clk90,
				clkx2 => clk90x2,
				t     => dqt,
				tq(0) => sdram_dqt(i),
				d     => dqo,
				q(0)  => sdram_dqo(i));
	
		end generate;
	
		dmo_g : block
			signal dmt : std_logic_vector(sys_dmt'range);
			signal dmd : std_logic_vector(sys_dmi'range);
			signal dmi : std_logic_vector(dmd'range);
		begin
	
			process (sys_sti, sys_dmt, sys_dmi)
			begin
				for i in dmi'range loop
					if loopback then
						dmd(i) <= reverse(sys_sti)(i);
					elsif sys_dmt(i)='1' then
						dmd(i) <= reverse(sys_dmi)(i);
					else
						dmd(i) <= reverse(sys_dmi)(i);
					end if;
				end loop;
			end process;

			process (dmd, clk90)
			begin
				if not register_on then
					dmi <= dmd;
				elsif rising_edge(clk90) then
					dmi <= dmd;
				end if;
			end process;

			process (sys_dmt, clk90)
			begin
				if not register_on then
					if loopback then
						dmt <= (others => '0');
					else
						dmt <= sys_dmt;
					end if;
				elsif rising_edge(clk90) then
					if loopback then
						dmt <= (others => '0');
					else
						dmt <= sys_dmt;
					end if;
				end if;
			end process;
	
			ogbx_i : entity hdl4fpga.ogbx
			generic map (
				device => device,
				size => 1,
				data_edge => setif(data_edge, string'("OPPOSITE_EDGE"), string'("SAME_EDGE")),
				gear => data_gear)
			port map (
				rst   => rst,
				clk   => clk90,
				clkx2 => clk90x2,
				t     => dmt,
				tq(0) => sdram_dmt,
				d     => dmi,
				q(0)  => sdram_dmo);
	
		end block;

		sto_g : block
			signal d : std_logic_vector(0 to data_gear-1);
		begin
	
			d <= reverse(sys_sti);
			ogbx_i : entity hdl4fpga.ogbx
			generic map (
				device => device,
				size => 1,
				data_edge => setif(data_edge, string'("OPPOSITE_EDGE"), string'("SAME_EDGE")),
				gear => data_gear)
			port map (
				rst   => rst,
				clk   => clk90,
				clkx2 => clk90x2,
				d     => d,
				q(0)  => sdram_sto);
	
		end block;

	end block;

	dqso_b : block
		signal dqsi : std_logic_vector(sys_dqsi'reverse_range);
		signal dqst : std_logic_vector(sys_dqst'range);
	begin

		process (sys_dqsi)
		begin
			dqsi <= (others => '0');
			for i in dqsi'range loop
				if i mod 2 = 1 then
					dqsi(i) <= sys_dqsi(i);
				end if;
			end loop;
		end process;
		dqst <= reverse(sys_dqst);

		ogbx_i : entity hdl4fpga.ogbx
		generic map (
			device => device,
			size => 1,
			data_edge => setif(data_edge, string'("OPPOSITE_EDGE"), string'("SAME_EDGE")),
			gear => data_gear)
		port map (
			rst   => rst,
			clk   => clk0,
			clkx2 => clk0x2,
			t     => dqst,
			tq(0) => sdram_dqst,
			d     => dqsi,
			q(0)  => sdram_dqso);

	end block;
end;
