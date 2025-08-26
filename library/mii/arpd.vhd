-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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

		myipad_frm    : out std_logic;
		myipad_irdy   : out std_logic;
		myipad_trdy   : in  std_logic := '1';
		myipad_data   : in  std_logic;

		ipv4sa_frm    : in  std_logic;
		ipv4sa_irdy   : in  std_logic;
		ipv4sa_trdy   : out std_logic;
		ipv4sa_end    : out std_logic;
		ipv4sa_data   : in  std_logic_vector;
	
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

	signal arptx_rdy : std_logic := '0';
	signal arptx_req : std_logic := '0';

	signal tparx_frm : std_logic;
	signal tparx_vld : std_logic;

	signal spatx_frm   : std_logic;
	signal spatx_irdy  : std_logic;
	signal spatx_trdy  : std_logic;
	signal spatx_end   : std_logic;
	signal spatx_data  : std_logic_vector(arptx_data'range);

begin

	arprx_i : entity hdl4fpga.arp_decode
	port map (
		mii_clk  => mii_clk,
		arp_frm  => arprx_frm,
		arp_irdy => arprx_irdy,
		arp_data => arprx_data,
		tpa_frm  => myipad_frm,
		tpa_irdy => myipad_irdy);

	cmp_i : entity hdl4fpga.sio_cmp
	port map (
		clk     => mii_clk,
		mr_frm  => myipad_frm,
		mr_irdy => myipad_irdy,
		mr_data => myipad_data,
		sl_data => arprx_data,
		equ     => myipad_equ);

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (arprx_frm and myipad_equ)='1' then
				arptx_req <= not arptx_rdy;
			end if;
		end if;
	end process;

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
		bitdata => reverse(default_ipv4a,8))
	port map (
		si_clk  => mii_clk,
		si_frm  => ipv4sa_frm,
		si_irdy => ipv4sa_irdy,
		si_data => ipv4sa_data,
	
		so_clk  => mii_clk,
		so_frm  => spa_frm,
		so_irdy => spa_irdy,
		so_trdy => spa_trdy,
		so_data => spa_data);

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		hwsa       => hwsa)
	port map (
		mii_clk    => mii_clk,
		tx_req     => tx_req,
		tx_rdy     => tx_rdy,
		pa_frm     => spa_frm,
		pa_irdy    => spa_irdy,
		pa_trdy    => spa_trdy,
		pa_data    => spa_data,

		dlltx_irdy => dlltx_irdy,
		dlltx_end  => dlltx_end,
		dlltx_data => dlltx_data,

		arp_frm    => arptx_frm,
		arp_irdy   => arptx_irdy,
		arp_trdy   => arptx_trdy,
		arp_data   => arptx_data);

end;
