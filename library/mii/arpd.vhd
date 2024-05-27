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
use hdl4fpga.base.all;

entity arpd is
	generic (
		default_ipv4a : std_logic_vector;
		hwsa          : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk       : in  std_logic;
		arp_req       : in  std_logic;
		arp_rdy       : buffer  std_logic;

		arprx_frm     : in  std_logic;
		arprx_irdy    : in  std_logic;
		arprx_data    : in  std_logic_vector;

		sparx_irdy    : out std_logic;
		sparx_trdy    : in  std_logic;
		sparx_end     : in  std_logic;
		sparx_equ     : in  std_logic;

		ipv4sawr_frm  : in  std_logic;
		ipv4sawr_irdy : in  std_logic;
		ipv4sawr_trdy : out std_logic;
		ipv4sawr_end  : out std_logic;
		ipv4sawr_data : in  std_logic_vector;
	
		dlltx_irdy    : out  std_logic;
		dlltx_end     : in   std_logic;
		dlltx_data    : out std_logic_vector;

		arptx_frm     : buffer std_logic := '0';
		arptx_irdy    : out std_logic;
		arptx_trdy    : in  std_logic;
		arptx_end     : buffer std_logic;
		arptx_data    : out std_logic_vector;

		tp            : out std_logic_vector(1 to 32));

end;

architecture def of arpd is

	signal tparx_frm : std_logic;
	signal tparx_vld : std_logic;
	signal arptx_rdy : std_logic;
	signal arptx_req : std_logic;

	signal spatx_frm   : std_logic;
	signal spatx_irdy  : std_logic;
	signal spatx_trdy  : std_logic;
	signal spatx_end   : std_logic;
	signal spatx_data  : std_logic_vector(arptx_data'range);

begin

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (to_bit(arptx_req) xor to_bit(arptx_rdy))='0' then
				if arprx_frm='1' then
					arptx_req <= to_stdulogic(to_bit(arptx_rdy)) xor (tparx_vld and sparx_end);
				elsif (to_bit(arp_req) xor to_bit(arp_rdy))='1' then
					arptx_req <= not to_stdulogic(to_bit(arptx_rdy));
					arp_rdy   <= arp_req;
				end if;
			end if;
		end if;
	end process;

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

	ipv4sa_e : entity hdl4fpga.sio_ram
	generic map (
		mem_data => reverse(default_ipv4a,8),
		mem_length => 32)
	port map (
		si_clk  => mii_clk,
		si_frm  => ipv4sawr_frm,
		si_irdy => ipv4sawr_irdy,
		si_trdy => ipv4sawr_trdy,
		si_full => ipv4sawr_end,
		si_data => ipv4sawr_data,
	
		so_clk  => mii_clk,
		so_frm  => spatx_frm,
		so_irdy => spatx_irdy,
		so_trdy => spatx_trdy,
		so_end  => spatx_end,
		so_data => spatx_data);

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		hwsa       => hwsa)
	port map (
		mii_clk    => mii_clk,
		arp_req    => arptx_req,
		arp_rdy    => arptx_rdy,
		pa_frm     => spatx_frm,
		pa_irdy    => spatx_irdy,
		pa_trdy    => spatx_trdy,
		pa_end     => spatx_end,
		pa_data    => spatx_data,

		dlltx_irdy => dlltx_irdy,
		dlltx_end  => dlltx_end,
		dlltx_data => dlltx_data,

		arp_frm    => arptx_frm,
		arp_irdy   => arptx_irdy,
		arp_trdy   => arptx_trdy,
		arp_end    => arptx_end,
		arp_data   => arptx_data);

end;
