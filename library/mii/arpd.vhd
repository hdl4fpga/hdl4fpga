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
		hwsa        : in std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk     : in  std_logic;
		arprx_frm   : in  std_logic;
		arprx_irdy  : in  std_logic;
		arprx_data  : in  std_logic_vector;

		arpdtx_req  : in  std_logic;
		arpdtx_rdy  : buffer  std_logic;

		sparx_irdy  : out std_logic;
		sparx_trdy  : in  std_logic;
		sparx_end   : in  std_logic;
		sparx_equ   : in  std_logic;

		spatx_frm   : out std_logic;
		spatx_irdy  : out std_logic;
		spatx_trdy  : in  std_logic;
		spatx_end   : in  std_logic;
		spatx_data  : in  std_logic_vector;

		arpdtx_frm  : buffer std_logic := '0';
		dlltx_irdy  : in  std_logic;
		dlltx_full  : in  std_logic;
		arpdtx_irdy : out std_logic;
		arpdtx_trdy : in  std_logic;
		arpdtx_end  : buffer std_logic;
		arpdtx_data : out std_logic_vector;

		tp          : out std_logic_vector(1 to 32));

end;

architecture def of arpd is

	signal tparx_frm  : std_logic;
	signal tparx_vld  : std_logic;
	signal arpd_rdy   : std_logic := '0';
	signal arpd_req   : std_logic := '0';
	signal arptx_irdy : std_logic;
	signal arptx_trdy : std_logic;
	signal arptx_data : std_logic_vector(arpdtx_data'range);

begin

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_clk  => mii_clk,
		arp_frm  => arprx_frm,
		arp_irdy => arprx_irdy,
		arp_data => arprx_data,
		tpa_frm  => tparx_frm);

	sparx_irdy <= tparx_frm and arprx_irdy;
	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if arprx_frm='0' then
				tparx_vld <= '0';
			elsif sparx_end='0' then
				tparx_vld <= sparx_equ;
			end if;
		end if;
	end process;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if to_bit(arpd_req xor arpd_rdy)='0' then
				if arprx_frm='1' then
					arpd_req <= arpd_rdy xor (tparx_vld and sparx_end);
				elsif to_bit(arpdtx_req xor arpd_rdy)='1' then
					arpd_req <= not arpd_rdy;
				end if;
			end if;
		end if;
	end process;
	arpdtx_rdy <= arpd_rdy;

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if arpdtx_frm='1' then
				if arpdtx_end='1' then
					if arpdtx_trdy='1' then
						arpdtx_frm <= '0';
						arpd_rdy  <= arpd_req;
					end if;
				end if;
			elsif (arpd_req xor arpd_rdy)='1' then
				arpdtx_frm <= '1';
			end if;
		end if;
	end process;

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		hwsa     => hwsa)
	port map (
		mii_clk  => mii_clk,
		pa_frm   => spatx_frm,
		pa_irdy  => spatx_irdy,
		pa_trdy  => spatx_trdy,
		pa_end   => spatx_end,
		pa_data  => spatx_data,

		arp_frm  => arpdtx_frm,
		arp_irdy => arptx_irdy,
		arp_trdy => arptx_trdy,
		arp_end  => arpdtx_end,
		arp_data => arptx_data);

	arpdtx_irdy <=  dlltx_irdy when dlltx_full='0' else arptx_trdy;
	arptx_irdy  <= '0' when dlltx_full='0' else arpdtx_trdy;
	arpdtx_data <= (arpdtx_data'range => '1') when dlltx_full='0' else arptx_data;
end;
