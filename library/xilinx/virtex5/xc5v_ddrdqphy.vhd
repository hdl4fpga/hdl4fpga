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

entity adjser is
	port (
		clk   : in  std_logic;
		rst   : in  std_logic;
		delay : in std_logic_vector;
		ce    : out std_logic;
		inc   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture beh of adjser is
begin
	process (clk)
		variable dgtn : unsigned(unsigned_num_bits(delay'length)-1 downto 0);
		variable taps : unsigned(2**dgtn'length-1 downto 0);
		variable acc  : unsigned(taps'range);
		variable cntr : unsigned(delay'length-1 downto 0);
	begin
		if rising_edge(clk) then
			acc := (others => '1');
			acc(cntr'range) := cntr;
			if rst='1' then
				taps := (others => '0');
				dgtn := (others => '0');
				cntr := (others => '1');
			elsif acc(to_integer(dgtn))='0' then
				cntr := cntr + 1;
			else
				acc  := taps xor resize(unsigned(delay), delay'length);
				if acc(to_integer(dgtn))='1' then
					taps(to_integer(dgtn)) := delay(to_integer(dgtn));
					cntr := (others => '0');
					dgtn := dgtn + 1;
				end if;
			end if;
			ce  <= not cntr(to_integer(dgtn));
			acc := resize(unsigned(delay), acc'length);
			inc <= acc(to_integer(dgtn));
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iodelay15 is
	port (
		clk     : in  std_logic;
		rst     : in  std_logic;
		delay   : in  std_logic_vector;
		t       : in std_logic;
		datain  : in std_logic;
		odatain : in std_logic;
		idatain : in std_logic;
		dataout : out std_logic);
end;

library hdl4fpga;

library unisim;
use unisim.vcomponents.all;

architecture def of iodelay15 is

	signal ce    : std_logic;
	signal inc   : std_logic;
	
begin

	adjser_i : entity hdl4fpga.adjser
	port map (
		clk   => clk,
		rst   => rst,
		delay => delay,
		ce    => ce,
		inc   => inc);

	dqi_i : iodelay
	generic map (
		delay_src        => "io",
		high_performance_mode => true,
		idelay_type      => "variable",
		idelay_value     => 0,
		odelay_value     => 0,
		refclk_frequency => 200.0, -- frequency used for idelayctrl 175.0 to 225.0
		signal_pattern   => "data") 
	port map (
		c       => clk,
		rst     => rst,
		ce      => ce,
		inc     => inc,
		t       => t,
		datain  => datain,
		odatain => odatain,
		idatain => idatain,
		dataout => dataout);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity ddrdqphy is
	generic (
		registered_dout : boolean;
		loopback   : boolean;
		DATA_GEAR       : natural;
		byte_size  : natural);
	port (
		iod_clk    : in std_logic;
		sys_clks   : in  std_logic_vector(0 to 2-1);
		sys_wlreq : in  std_logic;
		sys_wlrdy : out std_logic;
		sys_rlreq : in  std_logic;
		sys_rlrdy : buffer std_logic;
		sys_rlcal : out std_logic;
		sys_wrseq  : in  std_logic := '0';
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
		ddr_sto    : out std_logic;
		ddr_dqi    : in  std_logic_vector(byte_size-1 downto 0);
		ddr_dqt    : buffer std_logic_vector(byte_size-1 downto 0);
		ddr_dqo    : out std_logic_vector(byte_size-1 downto 0);

		ddr_dqst   : out std_logic;
		ddr_dqso   : out std_logic);

	constant clk0  : natural := 0;
	constant clk90 : natural := 1;
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

	signal iod_rst : std_logic;
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

	iod_rst <= not adjdqs_req;
	iddr_g : for i in 0 to byte_size-1 generate
		signal delay : std_logic_vector(6-1 downto 0);
	begin
		phase_g : for j in  DATA_GEAR-1 downto 0 generate
			iodelay15_b : block
				port (
					clk     : in  std_logic;
					rst     : in  std_logic;
					delay   : in  std_logic_vector;
					datain  : in std_logic;
					odatain : in std_logic;
					idatain : in std_logic;
					dataout : out std_logic);
				port map(
					clk   => iod_clk,
					rst   => iod_rst,
					delay => delay,
					datain  => '0',
					odatain => '0',
					idatain => ddr_dqi(i),
					dataout => sys_dqo(j*byte_size+i));


				signal ce    : std_logic;
				signal inc   : std_logic;
			begin
				adjser_i : entity hdl4fpga.adjser
				port map (
					clk   => clk,
					rst   => rst,
					delay => delay,
					ce    => ce,
					inc   => inc);

				dqi_i : iodelay
				generic map (
					delay_src        => "io",
					high_performance_mode => true,
					idelay_type      => "variable",
					idelay_value     => 0,
					odelay_value     => 0,
					refclk_frequency => 200.0, -- frequency used for idelayctrl 175.0 to 225.0
					signal_pattern   => "data") 
				port map (
					c       => iod_clk,
					rst     => iod_rst,
					ce      => ce,
					inc     => inc,
					t       => ddr_dqt(i),
					datain  => '0',
					odatain => '0',
					idatain => ddr_dqi(i),
					dataout => sys_dqo(j*byte_size+i));
			end block;

		end generate;
	end generate;

	oddr_g : for i in 0 to byte_size-1 generate
		signal dqo  : std_logic_vector(0 to DATA_GEAR-1);
		signal dqt  : std_logic_vector(sys_dqt'range);
		signal rdqo : std_logic_vector(0 to DATA_GEAR-1);
		signal clks : std_logic_vector(0 to DATA_GEAR-1);
		signal sw   : std_logic;
	begin
		clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));

		registered_g : for j in clks'range generate
			signal sw : std_logic;
		begin

			process (clks(j))
			begin
				if rising_edge(clks(j)) then
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

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk90),
			d => dqt(0),
			q => ddr_dqt(i));

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk90),
			dr  => dqo(0),
			df  => dqo(1),
			q   => ddr_dqo(i));
	end generate;

	dmo_g : block
		signal dmt  : std_logic_vector(sys_dmt'range);
		signal dmi  : std_logic_vector(sys_dmi'range);
		signal rdmi : std_logic_vector(sys_dmi'range);
		signal clks : std_logic_vector(0 to DATA_GEAR-1);
	begin

		clks <= (0 => sys_clks(clk90), 1 => not sys_clks(clk90));
		registered_g : for i in clks'range generate
			signal d, t, s : std_logic;
		begin
			dmt(i) <= '0';

			--rdmi(i) <= s when t='1' and not loopback else d;
			process (clks(i))
			begin
				if rising_edge(clks(i)) then

					if t='1' and not loopback then
						rdmi(i) <= s;
					else
						rdmi(i) <= d;
					end if;

					t <= sys_dmt(i);
					d <= sys_dmi(i);
					s <= sys_sti(i);
				end if;
			end process;

			dmi(i) <=
				rdmi(i)    when registered_dout else
				sys_sti(i) when sys_dmt(i)='1' and not loopback else
				sys_dmi(i);

		end generate;

		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk90),
			d => dmt(0),
			q => ddr_dmt);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk90),
			dr  => dmi(0),
			df  => dmi(1),
			q   => ddr_dmo);
	end block;

	sto_i : entity hdl4fpga.ddro
	port map (
		clk => sys_clks(clk90),
		dr  => sys_sti(0),
		df  => sys_sti(1),
		q   => ddr_sto);

	dqso_b : block
		signal clk_n : std_logic;
		signal dt : std_logic;
		signal dqso_r : std_logic;
		signal dqso_f : std_logic;
	begin

		clk_n <= not sys_clks(clk0);
		ddrto_i : entity hdl4fpga.ddrto
		port map (
			clk => sys_clks(clk0),
			d => sys_dqst(1),
			q => ddr_dqst);

		ddro_i : entity hdl4fpga.ddro
		port map (
			clk => sys_clks(clk0),
			dr  => '0',
			df  => sys_dqsi(0),
			q   => ddr_dqso);

	end block;
end;
