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

library ecp5u;
use ecp5u.components.all;

architecture graphics of rgmii is

		signal dhcpcd_req : std_logic := '0';
		signal dhcpcd_rdy : std_logic := '0';

		signal miirx_frm  : std_logic;
		signal miirx_irdy : std_logic;
		signal miirx_trdy : std_logic;
		signal miirx_data : std_logic_vector(mii_rxd'range);

		signal miitx_frm  : std_logic;
		signal miitx_irdy : std_logic;
		signal miitx_trdy : std_logic;
		signal miitx_end  : std_logic;
		signal miitx_data : std_logic_vector(si_data'range);

	begin

		sync_b : block

			signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
			signal dst_irdy  : std_logic;
			signal dst_trdy  : std_logic;

		begin

			rgmii_b : block

				component rxdll_sync
					port (
						rst       : in std_logic;
						sync_clk  : in std_logic;
						update    : in std_logic;
						dll_lock  : in  std_logic;
						dll_reset : out std_logic;
						uddcntln  : out std_logic;
						freeze    : out std_logic;
						stop      : out std_logic;
						ddr_reset : out std_logic;
						ready     : out std_logic);
				end component;

				signal dll_reset : std_logic;
				signal ddr_reset : std_logic;
				signal sync_rst  : std_logic;
				signal sclk      : std_logic;
				signal ddrdel    : std_logic;
				signal uddcntln  : std_logic;
				signal freeze    : std_logic;
				signal dll_lock  : std_logic;

			begin

				sync_rst  <= not ddram_clklck;
				eth_reset <= not sync_rst;
				sync_i : rxdll_sync
				port map (
					rst       => sync_rst,
					sync_clk  => clk_25mhz,
					update    => '0',
					dll_lock  => dll_lock,
					dll_reset => dll_reset,
					uddcntln  => uddcntln,
					freeze    => freeze,
					stop      => open,
					ddr_reset => ddr_reset,
					ready     => open);

				dlldel_i : dlldeld
				port map(
					move      => '0',
					loadn     => '0',
					direction => '0',
					ddrdel    => ddrdel,
					a         => rgmii_rx_clk,
					z         => sclk);

				ddrdll_i : ddrdlla
				port map (
					rst      => dll_reset,
					clk      => sclk,
					uddcntln => uddcntln,
					freeze   => freeze,
					lock     => dll_lock,
					ddrdel   => ddrdel);

--				sclk <= rgmii_rx_clk;
				rmgmii_rxdv_b : block
					signal d : std_logic;
				begin
					delay_i : delayg
					generic map (
						del_mode => "SCLK_ALIGNED")
					port map (
						a => rgmii_rx_dv,
						z => d);

					rmgmii_rxdv_i : iddrx1f
					port map (
						rst  => sync_rst,
						sclk => sclk,
						d    => d,
						q0   => mii_rxdv,
						q1   => open);
				end block;
	
				rmgmii_rxd_g : for i in rgmii_rxd'range generate
					signal d : std_logic;
				begin
					delay_i : delayg
					generic map (
						del_mode => "SCLK_ALIGNED")
					port map (
						a => rgmii_rxd(i),
						z => d);

					iddr_i : iddrx1f
					port map (
						rst  => sync_rst,
						sclk => sclk,
						d    => d,
						q0   => mii_rxd(rgmii_rxd'length*0+i),
						q1   => mii_rxd(rgmii_rxd'length*1+i));
				end generate;
				
				rmgmii_txd_i : oddrx1f
				port map (
					rst  => ddr_reset,
					sclk => rgmii_rx_clk, --sclk,
					d0   => mii_txen,
					d1   => '0',
					q    => rgmii_tx_en);

				rmgmii_txd_g : for i in rgmii_txd'range generate
					signal d : std_logic;
				begin
					oddr_i : oddrx1f
					port map (
						rst  => ddr_reset,
						sclk => rgmii_rx_clk, --sclk,
						d0   => mii_txd(rgmii_txd'length*0+i),
						d1   => mii_txd(rgmii_txd'length*1+i),
						q    => d);

					delay_i : delayg
					generic map (
						del_mode => "SCLK_ALIGNED")
					port map (
						a => d,
						z => rgmii_txd(i));
		
					end generate;
					

			end block;

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					rxc_rxbus <= mii_rxdv & mii_rxd;
				end if;
			end process;

			rxc2txc_e : entity hdl4fpga.fifo
			generic map (
				max_depth  => 4,
				latency    => 0,
				dst_offset => 0,
				src_offset => 2,
				check_sov  => false,
				check_dov  => true,
				gray_code  => false)
			port map (
				src_clk  => mii_rxc,
				src_data => rxc_rxbus,
				dst_clk  => mii_txc,
				dst_irdy => dst_irdy,
				dst_trdy => dst_trdy,
				dst_data => txc_rxbus);

			process (mii_txc)
			begin
				if rising_edge(mii_txc) then
					dst_trdy   <= to_stdulogic(to_bit(dst_irdy));
					miirx_frm  <= txc_rxbus(0);
					miirx_irdy <= txc_rxbus(0);
					miirx_data <= txc_rxbus(1 to mii_rxd'length);
				end if;
			end process;
		end block;
 
end;