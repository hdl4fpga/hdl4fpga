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
use hdl4fpga.ipoepkg.all;

entity arpd is
	generic (
		mac_sa     : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk    : in  std_logic;
		tx_req     : buffer std_logic;
		tx_rdy     : buffer std_logic;

		arprx_frm  : in  std_logic;
		arprx_irdy : in  std_logic;
		arprx_data : in  std_logic_vector;

		ethda_frm  : in  std_logic;
		ethda_irdy : in  std_logic;
		ethda_trdy : out std_logic;
		ethda_data : buffer std_logic_vector;

		arptx_frm  : buffer std_logic := '0';
		arptx_irdy : out std_logic;
		arptx_trdy : in  std_logic;
		arptx_data : out std_logic_vector;

		tp         : out std_logic_vector(1 to 32));

end;

architecture def of arpd is

	signal tparx_frm  : std_logic;
	signal tparx_irdy : std_logic;
	signal tparx_trdy : std_logic := '1';
	signal tparx_data : std_logic_vector(arprx_data'range);

	signal arptx_rdy : std_logic := '0';
	signal arptx_req : std_logic := '0';

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
		tpa_frm  => tparx_frm,
		tpa_irdy => tparx_irdy,
		tpa_trdy => tparx_trdy);

	tpacmp_b : block
		signal tpa_equ : std_logic;
	begin
		ipsa_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(aton("192.168.0.14"),8))
		port map (
			si_data => arprx_data,
			so_clk  => mii_clk,
			so_frm  => tparx_frm,
			so_irdy => tparx_irdy,
			so_trdy => tparx_trdy,
			so_data => tparx_data);

		cmp_i : entity hdl4fpga.sio_cmp
		port map (
			clk     => mii_clk,
			mr_frm  => tparx_frm,
			mr_irdy => tparx_irdy,
			mr_trdy => tparx_trdy,
			mr_data => tparx_data,
			sl_data => arprx_data,
			equ     => tpa_equ);

		process (mii_clk)
			variable lat1 : std_logic;
		begin
			if rising_edge(mii_clk) then
				if (tparx_frm or tparx_irdy)='0' then
					if lat1='1' then
						tx_req <= not tx_rdy;
					end if;
				end if;
				lat1 := (tparx_frm or tparx_irdy);
			end if;
		end process;

	end block;

	ipsatx_e : entity hdl4fpga.sio_ram
	generic map (
		bitdata => reverse(aton("192.168.0.14"),8))
	port map (
		si_clk  => mii_clk,
		si_data => arprx_data,
	
		so_clk  => mii_clk,
		so_frm  => spatx_frm,
		so_irdy => spatx_irdy,
		so_trdy => spatx_trdy,
		so_data => spatx_data);

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		mac_sa     => mac_sa)
	port map (
		mii_clk    => mii_clk,
		tx_req     => tx_req,
		tx_rdy     => tx_rdy,
		pa_frm     => spatx_frm,
		pa_irdy    => spatx_irdy,
		pa_trdy    => spatx_trdy,
		pa_data    => spatx_data,

		ethda_frm  => ethda_frm,
		ethda_irdy => ethda_irdy,
		ethda_trdy => ethda_trdy,
		ethda_data => ethda_data,

		arp_frm    => arptx_frm,
		arp_irdy   => arptx_irdy,
		arp_trdy   => arptx_trdy,
		arp_data   => arptx_data);

end;