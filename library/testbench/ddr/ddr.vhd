--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

architecture ddr of testbench is
	constant clock_cycle : time := 7.5 ns;
	constant addr_bits  : natural := 13;
	constant data_bytes : natural := 2;
	constant byte_bits  : natural := 8;
	constant data_bits  : natural := 2*byte_bits;
	constant cols_bits  : natural := 9;

	subtype byte is std_logic_vector(byte_bits-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal clk0   : std_logic := '0';
	signal clk90  : std_logic := '0';
	signal clk180 : std_logic := '1';
	signal clk270 : std_logic := '1';

	signal dq    : std_logic_vector (data_bits - 1 downto 0) := (others => 'Z');
	signal dqs   : std_logic_vector (1 downto 0) := "00";
	signal addr  : std_logic_vector (addr_bits - 1 downto 0);
	signal ba    : std_logic_vector (1 downto 0);
	signal rst   : std_logic := '1';
	signal clk   : std_logic := '0';
	signal clk_n : std_logic := '0';
	signal cke   : std_logic := '1';
	signal cs_n  : std_logic := '1';
	signal ras_n : std_logic;
	signal cas_n : std_logic;
	signal we_n  : std_logic;
	signal dm    : std_logic_vector(1 downto 0);

	signal ddr_rst : std_logic := '1';
	signal ddr_as  : std_logic;
	signal ddr_dw  : std_logic;
	signal ddr_rw  : std_logic;
	signal ddr_a : std_logic_vector(addr_bits-1 downto 0) := (others => '1');
	signal ddr_b : std_logic_vector( 1 downto 0) := (others => '1');
	signal ddr_dql : std_logic_vector(data_bits-1 downto 0) := (others => '0');
	signal ddr_dqh : std_logic_vector(data_bits-1 downto 0) := (others => '0');

	function resize0 (
		arg1 : std_logic_vector;
		arg2 : natural)
		return std_logic_vector is
	begin
		return std_logic_vector(resize(unsigned(arg1),arg2));
	end function;

begin
	ddr_rst <= rst;
	ddr_timer_du : entity hdl4fpga.ddr_timer
	generic map (
		q200u => 9,
		qdll  => 8)
	port map (
		ddr_timer_clk => clk,
		ddr_timer_sel  => ddr_timer_sel,
		ddr_timer_req  => ddr_timer_req, 
		ddr_timer_dll  => ddr_timer_dll,
		ddr_timer_200u => ddr_timer_200u,
		ddr_timer_ref  => ddr_timer_ref);

	ddr_init_du : entity hdl4fpga.ddr_init
	generic map (
		a => addr_bits)
	port map (
		ddr_init_clk => clk,
		ddr_init_req => ddr_init_req,
		ddr_init_rdy => ddr_init_rdy,
		ddr_init_ras => ddr_init_ras,
		ddr_init_cas => ddr_init_cas,
		ddr_init_we  => ddr_init_we,
		ddr_init_a   => ddr_init_a,
		ddr_init_b   => ddr_init_b);

	process (
		ddr_rst,
		ddr_init_rdy,
		ddr_timer_200u,
		ddr_timer_dll)
	begin
		ddr_init_req  <= '0';
		ddr_timer_sel <= '0';
		ddr_timer_req <= '0';
		if ddr_rst='0' then
			ddr_timer_req <= '1';
			if ddr_init_rdy='0' then
				if ddr_timer_200u='1' then
					ddr_init_req  <= '1';
					ddr_timer_sel <= '1';
					ddr_timer_req <= '0';
				end if;
			else
				ddr_init_req  <= '1';
				ddr_timer_sel <= '1';
				ddr_timer_req <= '1';
			end if;
		end if;
	end process;

	ddr_acc_du : entity hdl4fpga.ddr_acc
	generic map (
		tRFC => 8,
		tWR  => 3)
	port map (
		ddr_acc_bl  => "01",
		ddr_acc_cl  => "10",
		ddr_acc_clk => clk,
		ddr_acc_rst => ddr_rst,
		ddr_acc_ref => '0', --ddr_timer_ref,
		ddr_acc_as  => ddr_as,
		ddr_acc_rw  => ddr_rw,
		ddr_acc_rca => ddr_acc_mae,
		ddr_acc_ras => ddr_acc_ras,
		ddr_acc_cas => ddr_acc_cas,
		ddr_acc_we  => ddr_acc_we,
		ddr_acc_dwe => ddr_acc_dwe,
		ddr_acc_dqz => ddr_acc_dqz);

	ddr_dql <= resize0(addr(addr_bits-1 downto 1) & '0', data_bits);
	ddr_dqh <= resize0(addr(addr_bits-1 downto 1) & '1', data_bits);

	ddr_io_du : entity hdl4fpga.ddr_io_dq
	generic map (
		n => data_bits)
	port map (
		ddr_io_clk => clk180,
		ddr_io_dqh => ddr_dqh,
		ddr_io_dql => ddr_dql,
		ddr_io_dqz => ddr_acc_dqz,
		ddr_io_dqo => dq);

	ddr_io_dqs_e : entity hdl4fpga.ddr_io_dqs
	generic map (
		n => 2)
	port map (
		ddr_io_clk => clk,
		ddr_io_dqz => ddr_acc_dqz,
		ddr_io_dqs => dqs);

	ddr_fifo_b: block 
		signal ddr_fifo_ari_r : std_logic;
		signal ddr_fifo_ari_f : std_logic;
		signal ddr_fifo_enai_r : std_logic;
		signal ddr_fifo_enai_f : std_logic;
		signal ddr_fifo_di : byte_vector(0 to 1);
		signal ddr_byte_r  : byte_vector(0 to 1);
		signal ddr_byte_f  : byte_vector(0 to 1);
	begin
		process (clk180)
		begin
			if rising_edge(clk180) then
				ddr_fifo_enai_r <= ddr_acc_dwe;
				ddr_fifo_ari_r  <= not ddr_acc_dwe;
			end if;
		end process;
		process (clk0)
		begin
			if rising_edge(clk0) then
				ddr_fifo_enai_f <= ddr_acc_dwe;
				ddr_fifo_ari_f  <= not ddr_acc_dwe;
			end if;
		end process;

		ddr_fifo_di(0) <= dq(data_bits/2-1 downto 0);
		ddr_fifo_di(1) <= dq(data_bits-1   downto data_bits/2);
		
		fifo_bytes_g : for i in 0 to 1 generate
			signal ddr_dqs_r : std_logic;
			signal ddr_dqs_f : std_logic;
		begin
			ddr_dqs_r <= dqs(i);
			ddr_dqs_f <= not dqs(i);

			ddr_fifo_r_e : entity hdl4fpga.ddr_fifo
			generic map (
				n => byte_bits,
				m => 2)
			port map (
				ddr_fifo_ari  => ddr_fifo_ari_r,
				ddr_fifo_clki => clk90,
				ddr_fifo_enai => ddr_fifo_enai_r,
				ddr_fifo_di   => ddr_fifo_di(i),
			
				ddr_fifo_aro  => '1',
				ddr_fifo_clko => clk0,
				ddr_fifo_enao => ddr_acc_dwe,
				ddr_fifo_do   => ddr_byte_r(i)); 
		
			ddr_fifo_f_e : entity hdl4fpga.ddr_fifo
			generic map (
				n => byte_bits,
				m => 2)
			port map (
				ddr_fifo_ari  => ddr_fifo_ari_f,
				ddr_fifo_clki => clk270,
				ddr_fifo_enai => ddr_fifo_enai_f,
				ddr_fifo_di   => ddr_fifo_di(i),
			
				ddr_fifo_aro  => '1',
				ddr_fifo_clko => clk0,
				ddr_fifo_enao => ddr_acc_dwe,
				ddr_fifo_do   => ddr_byte_f(i)); 
		end generate;
	end block;

	ddr_io_dm_e : entity hdl4fpga.ddr_io_dm
	generic map (
		n => 2)
	port map (
		ddr_io_clk => clk270,
		ddr_io_dqz => ddr_acc_dqz,
		ddr_io_dml => "00",
		ddr_io_dmh => "10",
		ddr_io_dm  => dm);

	-- testbench --
	---------------

	clk0   <= not clk0 after clock_cycle/2;
	clk90  <= clk0     after clock_cycle/4;
	clk180 <= clk90    after clock_cycle/4;
	clk270 <= clk180   after clock_cycle/4;

	rst   <= '0' after 10 ns;
	cs_n  <= '0' when ddr_timer_200u='1' else '1';
	clk   <= clk0;
	clk_n <= clk180;
	cke   <= '1' when ddr_timer_200u='1' else '0';

	ras_n <= (ddr_init_ras and ddr_acc_ras);
	cas_n <= (ddr_init_cas and ddr_acc_cas);
	we_n  <= (ddr_init_we  and ddr_acc_we);
	addr  <= (ddr_init_a   and ddr_a);
	ba    <= (ddr_init_b   and ddr_b);

	genpat_du: process (clk)
		variable row_a : unsigned(0 to addr_bits);
		variable col_a : unsigned(0 to addr_bits);
		variable bnk_a : unsigned(0 to 2);
		variable write_rdy : std_logic;
		variable inc_data : std_logic;
	begin
		if rising_edge(clk) then
			if ddr_timer_dll='1' then
				ddr_as <= '1';
				if ddr_acc_mae='1' then
					ddr_a <= std_logic_vector(row_a(1 to addr_bits));
				else
					ddr_a <= std_logic_vector(col_a(1 to addr_bits));
				end if;
				if write_rdy='1' then
					ddr_dw <= '0';
					if ddr_dw/='1' then
						ddr_rw <= '1';
					end if;
				else
					ddr_rw <= '0';
				end if;

				if bnk_a(0)='1' then
					bnk_a := bnk_a + 1;
				end if;
				if row_a(0)='1' then
					row_a := resize(row_a(1 to addr_bits) + 1, row_a'length);
				elsif col_a(0)='1' then
					row_a := row_a + 1;
				end if;
				if ras_n='0' and cas_n='1' and we_n='0' then
					if col_a(11 to 12)="11" then
						col_a := (others => '0');
						write_rdy := '1';
					else
						col_a := col_a + 2;
					end if;
				end if;
			else
				ddr_as <= '0';
				row_a := (others => '0');
				col_a := (others => '0');
				bnk_a := (others => '0');
			end if;
		end if;
	end process;

	mt_u : entity hdl4fpga.mt46v16m16
	generic map (               
        tCK  =>  7.500 ns, -- Timing for -6T CL2
        tCH  =>  3.375 ns, -- 0.45*tCK
        tCL  =>  3.375 ns, -- 0.45*tCK
        tDH  =>  0.450 ns,
        tDS  =>  0.450 ns,
        tIH  =>  0.750 ns,
        tIS  =>  0.900 ns,
        tMRD => 12.000 ns,
        tRAS => 42.000 ns,
        tRAP => 15.000 ns,
        tRC  => 60.000 ns,
        tRFC => 72.000 ns,
        tRCD => 15.000 ns,
        tRP  => 15.000 ns,
        tRRD => 12.000 ns,
        tWR  => 15.000 ns,
        addr_bits => addr_bits,
        data_bits => data_bits,
        cols_bits => cols_bits)
	port map (
        Dq    => dq,
        Dqs   => dqs,
        Addr  => addr,
        Ba    => ba,
        Clk   => clk,
        Clk_n => clk_n,
        Cke   => cke,
        Cs_n  => cs_n,
        Ras_n => ras_n,
        Cas_n => cas_n,
        We_n  => we_n,
        Dm    => dm);
end;
