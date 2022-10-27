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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;

library unisim;
use unisim.vcomponents.all;

architecture scopeio_debug of arty is
	signal sys_clk        : std_logic;
	signal mii_req        : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_rxclk_bufg : std_logic;
	signal video_rgb      : std_logic_vector(0 to 3-1);
	signal video_vs       : std_logic;
	signal video_hs       : std_logic;
	signal video_clk      : std_logic;
	signal pp : std_logic;

	signal rxc  : std_logic;
	signal rxd  : std_logic_vector(eth_rxd'range);
	signal rxdv : std_logic;

	signal txc  : std_logic;
	signal txd  : std_logic_vector(eth_txd'range);
	signal txdv : std_logic;

	function sintab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : natural)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(n*x0 to n*(x1+1)-1);
		constant freq : real := 4*8.0;
	begin
		for i in x0 to x1 loop
			y := real(2**(n-2)-1)*64.0*(8.0/freq);
			if i/=0 then
				y := y*sin((2.0*MATH_PI*real(i)*freq)/real(x1-x0+1))/real(i);
			else
				y := freq*y*(2.0*MATH_PI)/real(x1-x0+1);
			end if;
			y := y - (64.0+24.0);
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_signed(integer(trunc(y)),n));
--			y := real(2**(n-2)-1)*sin((2.0*MATH_PI*real(i)*8.0)/real(x1-x0+1));
--			aux(i*n to (i+1)*n-1) := std_logic_vector(to_signed(integer(trunc(y)),n));
		end loop;
		return aux;
	end;

	constant sample_size : natural := 9;
	signal sample     : std_logic_vector(0 to sample_size-1);
	signal input_addr : std_logic_vector(11-1 downto 0);

begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	dcm_e : block
		signal video_clkfb : std_logic;
	begin
		video_dcm_i : mmcme2_base
		generic map (
			clkin1_period    => 10.0,
			clkfbout_mult_f  => 12.0,		-- 200 MHz
			clkout0_divide_f => 8.0,
			bandwidth        => "LOW")
		port map (
			pwrdwn   => '0',
			rst      => '0',
			clkin1   => sys_clk,
			clkfbin  => video_clkfb,
			clkfbout => video_clkfb,
			clkout0  => video_clk);
	end block;

	rxc <= eth_rxclk_bufg;
	process (rxc)
	begin
		if rising_edge(rxc) then
			rxd  <= eth_rxd;
			rxdv <= eth_rx_dv;
		end if;
	end process;

--	axis_b : block
--		signal video_vcntr : std_logic_vector(11-1 downto 0);
--		signal video_hcntr : std_logic_vector(11-1 downto 0);
--		signal hz_req : std_logic;
--		signal hz_rdy : std_logic;
--		signal vt_req : std_logic;
--		signal vt_rdy : std_logic;
--		signal dot : std_logic;
--		signal video_on   : std_logic;
--	begin
--
--		video_e : entity hdl4fpga.video_vga
--		generic map (
--			mode => 7,
--			n    => 11)
--		port map (
--			clk   => video_clk,
--			hsync => video_hs,
--			vsync => video_vs,
--			hcntr => video_hcntr,
--			vcntr => video_vcntr,
--			don   => video_on);
--
--		process (rxc)
--		begin
--			if rising_edge(rxc) then
--				if btn(0)='1' then
--					hz_req <= sw(0);
--					vt_req <= not sw(0);
--				else
--					if hz_rdy='1' then
--						hz_req <= '0';
--					end if;
--					if vt_rdy='1' then
--						vt_req <= '0';
--					end if;
--				end if;
--			end if;
--		end process;
--
--		axis_e : entity hdl4fpga.scopeio_axis
--		port map (
--			in_clk  => rxc,
--			axis_sel => sw(1),
--
--			hz_req  => hz_req,
--			hz_rdy  => hz_rdy,
--			hz_pnt  => b"111",
--
--			vt_req  => vt_req,
--			vt_rdy  => vt_rdy,
--			vt_pnt  => b"110",
--
--			video_clk   => video_clk,
--			video_hcntr => video_hcntr,
--			video_vcntr => video_vcntr,
--			video_dot   => dot);
--		video_rgb(0) <= video_on and dot;
--	end block;

--	scopeio_debug_e : entity hdl4fpga.scopeio_debug
--	port map (
--		mii_req   => mii_req,
--		mii_rxc   => rxc,
--		mii_rxd   => rxd,
--		mii_rxdv  => rxdv,
--		mii_txc   => txc,
--		mii_txd   => txd,
--		mii_txdv  => txdv,
--
--		video_clk => video_clk,
--		video_dot => video_rgb(0),
--		video_hs  => video_hs,
--		video_vs  => video_vs);
--
--	video_rgb(1) <= video_rgb(0);
--	video_rgb(2) <= video_rgb(0);
		
	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			input_addr <= std_logic_vector(unsigned(input_addr) + 1);
		end if;
	end process;

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sintab(-1024, 1023, sample_size))
	port map (
		clk  => sys_clk,
		addr => input_addr,
		data => sample);

	scopeio_e : entity hdl4fpga.scopeio
	port map (
		si_clk      => rxc,
		si_dv       => rxdv,
		si_data     => rxd,

		so_clk      => txc,
		so_data     => txd,
		so_dv       => txdv,
		ipcfg_req   => mii_req,

		input_clk   => sys_clk,
		input_data  => sample,
		video_clk   => video_clk,
		video_pixel => video_rgb,
		video_hsync => video_hs,
		video_vsync => video_vs);

	txc <= eth_txclk_bufg;
	process (txc)
	begin
		if falling_edge(txc) then
			eth_txd   <= txd;
			eth_tx_en <= txdv;
		end if;
	end process;

	process (btn(0), txc)
	begin
		if btn(0)='1' then
			mii_req <= '0';
			led(0)  <= '1';
		elsif rising_edge(txc) then
			led(0)  <= '0';
			mii_req <= '1';
		end if;
	end process;

	process (btn(1), txc)
	begin
		if btn(1)='1' then
			pp <= '0';
			led(1)  <= '1';
		elsif rising_edge(txc) then
			led(1)  <= '0';
			pp <= '1';
		end if;
	end process;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			ja(1)  <= video_rgb(0);
			ja(2)  <= video_rgb(1);
			ja(3)  <= video_rgb(2);
			ja(4)  <= video_hs;
			ja(10) <= video_vs;
		end if;
	end process;

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';
end;
