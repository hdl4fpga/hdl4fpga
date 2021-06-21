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

library hdl4fpga;
use hdl4fpga.std.all;

entity arpd is
	generic (
		hwsa       : in std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk    : in  std_logic;
		arprx_frm  : in  std_logic;
		arprx_irdy : in  std_logic;
		arprx_data : in  std_logic_vector;

		arpdtx_req : in  std_logic;
		arpdtx_rdy : buffer  std_logic;


		spa_frm    : out std_logic;
		spa_irdy   : out std_logic;
		spa_trdy   : in  std_logic;
		spa_end    : in  std_logic;
		spa_equ    : in  std_logic;
		spa_data   : in  std_logic_vector;

		arptx_frm  : buffer std_logic := '0';
		arptx_irdy : out std_logic;
		arptx_trdy : in  std_logic;
		arptx_end  : out std_logic;
		arptx_data : out std_logic_vector;
		miitx_end  : in  std_logic;

		tp         : out std_logic_vector(1 to 32));

end;

architecture def of arpd is

	signal tparx_frm : std_logic;
	signal tparx_vld : std_logic;
	signal pa_frm    : std_logic;
	signal pa_irdy   : std_logic;
	signal arpd_rdy  : std_logic := '0';
	signal arpd_req  : std_logic := '0';

begin

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_clk  => mii_clk,
		arp_frm  => arprx_frm,
		arp_irdy => arprx_irdy,
		arp_data => arprx_data,
		tpa_frm  => tparx_frm);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if arprx_frm='0' then
				tparx_vld <= '0';
			elsif spa_end='0' then
				tparx_vld <= tparx_equ;
			end if;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if to_bit(arpd_req xor arpd_rdy)='0' then
				if arprx_frm='1' then
					arpd_req <= arpd_rdy xor (tparx_vld and spa_end);
				elsif to_bit(arpdtx_req xor arpd_rdy)='1' then
					arpd_req <= not arpd_rdy;
				end if;
			end if;
		end if;
	end process;
	arpdtx_rdy <= arpd_rdy;

	process (miitx_end, mii_clk)
	begin
		if rising_edge(mii_clk) then
			if arptx_frm='1' then
				if arptx_trdy='1' then
					if miitx_end='1' then
						arptx_frm <= '0';
						arpd_rdy  <= arpd_req;
					end if;
				end if;
			elsif (arpd_req xor arpd_rdy)='1' then
				arptx_frm <= '1';
			end if;
		end if;
	end process;

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		hwsa     => hwsa)
	port map (
		mii_clk  => mii_clk,
		pa_frm   => pa_frm,
		pa_irdy  => pa_irdy,
		pa_trdy  => spa_trdy,
		pa_end   => spa_end,
		pa_data  => spa_data,

		arp_frm  => arptx_frm,
		arp_irdy => arptx_trdy,
		arp_trdy => arptx_irdy,
		arp_end  => arptx_end,
		arp_data => arptx_data);

	spa_frm  <= tparx_frm or pa_frm;
	spa_irdy <= wirebus(arprx_irdy & pa_irdy, tparx_frm & pa_frm)(0);

end;
