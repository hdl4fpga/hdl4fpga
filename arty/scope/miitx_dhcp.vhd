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
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

library unisim;
use unisim.vcomponents.all;

architecture miitx_dhcp of arty is
	signal sys_clk        : std_logic;
	signal mii_treq       : std_logic;
	signal eth_txclk_bufg : std_logic;
	signal eth_rxclk_bufg : std_logic;

	signal video_clk      : std_logic;
	signal video_hs       : std_logic;
	signal video_vs       : std_logic;
	signal video_frm      : std_logic;
	signal video_hon      : std_logic;
	signal video_nhl      : std_logic;
	signal video_vld      : std_logic;
	signal video_vcntr    : std_logic_vector(11-1 downto 0);
	signal video_hcntr    : std_logic_vector(11-1 downto 0);
	signal video_dot      : std_logic;
begin

	clkin_ibufg : ibufg
	port map (
		I => gclk100,
		O => sys_clk);

	eth_rx_clk_ibufg : ibufg
	port map (
		I => eth_rx_clk,
		O => eth_rxclk_bufg);

	video_dcm_e : entity hdl4fpga.dfs
	generic map (
		dcm_per => 10.0,
		dfs_div => 2,
		dfs_mul => 3)
	port map (
		dcm_rst => '0',
		dcm_clk => sys_clk,
		dfs_clk => video_clk,
		dcm_lck => open);

	cgaadapter_b : block
		signal font_col  : std_logic_vector(3-1 downto 0);
		signal font_row  : std_logic_vector(4-1 downto 0);
		signal font_addr : std_logic_vector(4+4-1 downto 0);
		signal font_line : std_logic_vector(8-1 downto 0);
		signal cga_code  : std_logic_vector(4-1 downto 0);
	begin
	
		video_e : entity hdl4fpga.video_vga
		generic map (
			mode => 7,
			n    => 11)
		port map (
			clk   => video_clk,
			hsync => video_hs,
			vsync => video_vs,
			hcntr => video_hcntr,
			vcntr => video_vcntr,
			don   => video_hon,
			frm   => video_frm,
			nhl   => video_nhl);

		cgabram_b : block
			signal cga_clk    : std_logic;
			signal cga_ena    : std_logic;
			signal cga_addr   : std_logic_vector(14-1 downto 0);
			signal cga_data   : std_logic_vector(cga_code'range);

			signal video_addr : std_logic_vector(cga_addr'range);
			signal rd_addr    : std_logic_vector(cga_code'range);
			signal rd_data    : std_logic_vector(cga_code'range);
		begin

			process (eth_rxclk_bufg)
			begin
				if rising_edge(eth_rxclk_bufg) then
					if cga_ena='1' then
						cga_addr <= (others => '0');
					else
						cga_addr <= std_logic_vector(unsigned(cga_addr) + 1);
					end if;
				end if;
			end process;

			cga_clk  <= eth_rxclk_bufg;
			cga_ena  <= eth_rx_dv;
			cga_data <= eth_rxd;

			process (video_vcntr, video_hcntr)
				variable aux : unsigned(video_addr'range);
			begin
				aux := resize(unsigned(video_vcntr), video_addr'length) srl 4;
				aux := (aux sll 4) - aux;
				aux := aux sll 4;
				aux := aux + unsigned(video_hcntr) srl 3;
				video_addr <= std_logic_vector(aux);
			end process;

			rdaddr_e : entity hdl4fpga.align
			generic map (
				n => font_col'length,
				d => (font_col'range => 1))
			port map (
				clk => video_clk,
				di  => video_addr,
				do  => rd_addr);

			cgaram_e : entity hdl4fpga.dpram
			port map (
				wr_clk  => cga_clk,
				wr_ena  => cga_ena,
				wr_addr => cga_addr,
				wr_data => cga_data,
				rd_addr => rd_addr,
				rd_data => rd_data);

			rddata_e : entity hdl4fpga.align
			generic map (
				n => cga_code'length,
				d => (cga_code'range => 1))
			port map (
				clk => video_clk,
				di  => rd_data,
				do  => cga_code);

		end block;

		vsync_e : entity hdl4fpga.align
		generic map (
			n => font_row'length,
			d => (font_row'range => 2))
		port map (
			clk => video_clk,
			di  => video_vcntr(4-1 downto 0),
			do  => font_row);

		hsync_e : entity hdl4fpga.align
		generic map (
			n => font_col'length,
			d => (font_col'range => 4))
		port map (
			clk => video_clk,
			di  => video_hcntr(font_col'range),
			do  => font_col);

		font_addr <= cga_code & font_row;

		cgarom_e : entity hdl4fpga.rom
		generic map (
			synchronous => 2,
			bitrom => psf1hex8x16)
		port map (
			clk  => video_clk,
			addr => font_addr,
			data => font_line);

		video_dot <= word2byte(font_line, font_col)(0);

	end block;


	process (sys_clk)
		variable div : unsigned(0 to 1) := (others => '0');
	begin
		if rising_edge(sys_clk) then
			div := div + 1;
			eth_ref_clk <= div(0);
		end if;
	end process;

	eth_tx_clk_ibufg : ibufg
	port map (
		I => eth_tx_clk,
		O => eth_txclk_bufg);

	process (btn(0), eth_txclk_bufg)
	begin
		if btn(0)='1' then
			mii_treq <= '0';
		elsif rising_edge(eth_txclk_bufg) then
			mii_treq <= '1';
		end if;
	end process;

	du : entity hdl4fpga.miitx_dhcp
	port map (
        mii_txc  => eth_txclk_bufg,
		mii_treq => mii_treq,
		mii_trdy => led(0),
		mii_txdv => eth_tx_en,
		mii_txd  => eth_txd);

	eth_rstn <= '1';
	eth_mdc  <= '0';
	eth_mdio <= '0';
end;
