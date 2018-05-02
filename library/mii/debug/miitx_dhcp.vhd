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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

library ecp3;
use ecp3.components.all;

architecture miitx_dhcp of ecp3versa is
	signal mii_treq : std_logic;

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
	signal mac_vld        : std_logic;
begin

	videodcm_b : block
		attribute FREQUENCY_PIN_CLKI  : string; 
		attribute FREQUENCY_PIN_CLKOP : string; 
		attribute FREQUENCY_PIN_CLKI  of PLL_I : label is "100.000000";
		attribute FREQUENCY_PIN_CLKOP of PLL_I : label is "150.000000";

		signal clkfb : std_logic;
		signal lock  : std_logic;
	begin
		pll_i : ehxpllf
        generic map (
			FEEDBK_PATH  => "INTERNAL", CLKOK_BYPASS=> "DISABLED", 
			CLKOS_BYPASS => "DISABLED", CLKOP_BYPASS=> "DISABLED", 
			CLKOK_INPUT  => "CLKOP", DELAY_PWD=> "DISABLED", DELAY_VAL=>  0, 
			CLKOS_TRIM_DELAY=> 0, CLKOS_TRIM_POL=> "RISING", 
			CLKOP_TRIM_DELAY=> 0, CLKOP_TRIM_POL=> "RISING", 
			PHASE_DELAY_CNTL=> "STATIC", DUTY=>  8, PHASEADJ=> "0.0", 
			CLKOK_DIV=>  2, CLKOP_DIV=>  4, CLKFB_DIV=>  3, CLKI_DIV=>  2, 
			FIN=> "100.000000")
		port map (
			rst         => '0' , 
			rstk        => '0',
			clki        => clk,
			wrdel       => '0',
			drpai3      => '0', drpai2 => '0', drpai1 => '0', drpai0 => '0', 
			dfpai3      => '0', dfpai2 => '0', dfpai1 => '0', dfpai0 => '0', 
			fda3        => '0', fda2   => '0', fda1   => '0', fda0   => '0', 
			clkintfb    => clkfb,
			clkfb       => clkfb,
			clkop       => video_clk, 
			clkos       => open,
			clkok       => open,
			clkok2      => open,
			lock        => lock);
	end block;

	xxx : block
		signal mii_rxc  : std_logic;
		signal mii_rxd  : std_logic_vector(phy1_rx_d'range);
		signal mii_rxdv : std_logic;
		signal pre_rdy : std_logic;
		signal mac_rdy : std_logic;
		signal mac_rxdv : std_logic;
		signal mac_rxd : std_logic_vector(phy1_rx_d'range);

		constant mii_mymac : std_logic_vector := reverse(x"00_40_00_01_02_03", 8);
	begin

		mii_rxc  <= phy1_rxc;
		mii_rxd  <= phy1_rx_d;
		mii_rxdv <= phy1_rx_dv;


		mii_pre_e : entity hdl4fpga.miirx_pre 
		port map (
			mii_rxc  => mii_rxc,
			mii_rxd  => mii_rxd,
			mii_rxdv => mii_rxdv,
			mii_rdy  => pre_rdy);


		miimymac_e  : entity hdl4fpga.mii_mem
		generic map (
			mem_data => mii_mymac)
		port map (
			mii_txc  => mii_rxc,
			mii_treq => pre_rdy,
			mii_trdy => mac_rdy,
			mii_txen => mac_rxdv,
			mii_txd  => mac_rxd);

		macvld_b : block
			signal vld : std_logic;
		begin
			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if pre_rdy='0' then
						vld <= '1';
					elsif mac_rdy='0' then
						vld <= vld and setif(mac_rxd=mii_rxd);
					end if;
				end if;
			end process;
			mac_vld <= vld and mac_rdy;
		end block;

		myip_b: block
			: std_logic_vector := (
				(  0, "0"),
				(128, "1"),
				(160, "0"),
				(188, "1"));

		begin
			miimymac_e  : entity hdl4fpga.mii_mem
			generic map (
				mem_data => mii_mymac)
			port map (
				mii_txc  => mii_rxc,
				mii_treq => pre_rdy,
				mii_trdy => mac_rdy,
				mii_txen => mac_rxdv,
				mii_txd  => mac_rxd);

			process (mii_rxc)
			begin
				if rising_edge(mii_rxc) then
					if ptr=
				end if;
			end process;
		end block;

	end block;
		
	cgaadapter_b : block
		signal font_col  : std_logic_vector(3-1 downto 0);
		signal font_row  : std_logic_vector(4-1 downto 0);
		signal font_addr : std_logic_vector(4+4-1 downto 0);
		signal font_line : std_logic_vector(8-1 downto 0);
		signal cga_code  : std_logic_vector(phy1_rx_d'range);
		signal code_sel  : std_logic_vector(3 to 3);
		signal dot_on     : std_logic;
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
			signal cga_addr   : std_logic_vector(13-1 downto 0);
			signal cga_data   : std_logic_vector(phy1_rx_d'range);

			signal video_addr : std_logic_vector(cga_addr'range);
			signal rd_addr    : std_logic_vector(cga_addr'range);
			signal rd_data    : std_logic_vector(cga_data'range);
		begin

			process (cga_clk)
			begin
				if rising_edge(cga_clk) then
					if cga_ena='0' then
						cga_addr <= (others => '0');
					else
						cga_addr <= std_logic_vector(unsigned(cga_addr) + 1);
					end if;
				end if;
			end process;

			cga_clk  <= phy1_rxc;
			cga_ena  <= mac_vld and phy1_rx_dv;
			cga_data <= reverse(phy1_rx_d);

			process (video_vcntr, video_hcntr)
				variable aux : unsigned(video_addr'range);
			begin
				aux := resize(unsigned(video_vcntr) srl 4, video_addr'length);
				aux := resize(aux * (1920/16), aux'length) + (unsigned(video_hcntr) srl 4);
				video_addr <= std_logic_vector(aux);
			end process;

			rdaddr_e : entity hdl4fpga.align
			generic map (
				n => video_addr'length,
				d => (video_addr'range => 1))
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

		don_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (1 to 1 => 4))
		port map (
			clk => video_clk,
			di(0)  => video_hon,
			do(0)  => dot_on);

		codesel_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (1 to 1 => 2))
		port map (
			clk => video_clk,
			di  => video_hcntr(3 downto 3),
			do  => code_sel);

		font_addr <= word2byte(cga_code, code_sel) & font_row;

		cgarom_e : entity hdl4fpga.rom
		generic map (
			synchronous => 2,
			bitrom => psf1hex8x16)
		port map (
			clk  => video_clk,
			addr => font_addr,
			data => font_line);

		video_dot <= word2byte(font_line, font_col)(0) and dot_on;

	end block;


	process (fpga_gsrn, phy1_txc)
	begin
		if fpga_gsrn='0' then
			mii_treq <= '0';
		elsif rising_edge(phy1_txc) then
			mii_treq <= '1';
		end if;
	end process;

	ecp3_iob : block
		attribute oddrapps : string;
		attribute oddrapps of oddr_i : label is "SCLK_ALIGNED";
		signal en : std_logic;
		signal d  : std_logic_vector(phy1_tx_d'range);
	begin
		du : entity hdl4fpga.miitx_dhcp
		port map (
			mii_txc  => phy1_125clk,
			mii_treq => mii_treq,
			mii_txdv => en,
			mii_txd  => d);

		process (phy1_125clk)
		begin
			if rising_edge(phy1_125clk) then
				phy1_tx_en <= en;
				phy1_tx_d  <= d;
			end if;
		end process;

		oddr_i : oddrxd1
		port map (
			sclk => phy1_125clk,
			da   => '1',
			db   => '0',
			q    => phy1_gtxclk);
	end block;

	phy1_rst  <= '1';
	phy1_mdc  <= '0';
	phy1_mdio <= '0';

	expansionx4io_e : entity hdl4fpga.align
	generic map (
		n => expansionx4'length,
		i => (expansionx4'range => '-'),
		d => (expansionx4'range => 1))
	port map (
		clk   => video_clk,
		di(0) => video_dot,
		di(1) => video_dot,
		di(2) => video_dot,
		di(3) => video_hs,
		di(4) => video_vs,
		do    => expansionx4);

end;
