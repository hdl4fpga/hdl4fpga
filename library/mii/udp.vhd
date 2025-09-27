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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity udp is
	generic (
		hwaddr        : std_logic_vector(0 to 48-1));
	port (
		tp : out std_logic_vector(1 to 32);

		dhcpcd_req  : in  std_logic := '0';
		dhcpcd_rdy  : buffer std_logic := '0';

		-- miirx_clk   : in  std_logic;
		--
		-- tharx_frm   : in  std_logic;
		-- tharx_irdy  : in  std_logic;
		-- tharx_trdy  : buffer std_logic := '1';
		--
		-- tparx_frm   : in  std_logic;
		-- tparx_irdy  : in  std_logic;
		-- tparx_trdy  : buffer std_logic := '1';
		--
		-- udprx_frm  : in  std_logic := '0';
		-- udprx_irdy : in  std_logic := '0';
		-- udprx_trdy : out std_logic := '0';
		-- udprx_data : in  std_logic_vector;
		--
		-- pylrx_frm   : buffer std_logic;
		-- pylrx_irdy  : out std_logic;
		-- pylrx_trdy  : in  std_logic := '1';
		-- pylrx_data  : out std_logic_vector;

		miitx_clk     : in  std_logic;

		thatx_frm     : in  std_logic;
		thatx_irdy    : in  std_logic;
		thatx_trdy    : out std_logic := '1';
		thatx_data    : out std_logic_vector;

		tpatx_frm     : in  std_logic;
		tpatx_irdy    : in  std_logic;
		tpatx_trdy    : out std_logic := '1';

		lentx_frm  : in std_logic;
		lentx_irdy : in std_logic;
		lentx_trdy : out std_logic := '1';

		udptx_frm     : buffer std_logic := '0';
		udptx_irdy    : buffer std_logic := '0';
		udptx_trdy    : in  std_logic := '0';
		udptx_data    : buffer std_logic_vector);
end;

architecture def of udp is
	signal dhcpcdlentx_frm  : std_logic;
	signal dhcpcdlentx_irdy : std_logic;
	signal dhcpcdlentx_trdy : std_logic;

	signal dhcpcdtpatx_frm  : std_logic;
	signal dhcpcdtpatx_irdy : std_logic;
	signal dhcpcdtpatx_trdy : std_logic;

	signal dhcpcdtx_frm  : std_logic;
	signal dhcpcdtx_irdy : std_logic;
	signal dhcpcdtx_trdy : std_logic;
	signal dhcpcdtx_data : std_logic_vector(udptx_data'range);
begin

	-- rx_b : block
	-- 	signal meta_frm   : std_logic;
	-- 	signal chksum_frm : std_logic;
	-- 	signal pyl_frm : std_logic;
	-- begin
	-- 	udp_i : entity hdl4fpga.frame_decode
	-- 	generic map (
	-- 		frame => compact('{' &
	-- 			"  meta:" & natural'image(
	-- 				hdo(frames)**".format.udp.sp"  +
	-- 				hdo(frames)**".format.udp.dp"  +         
	-- 				hdo(frames)**".format.udp.length")             & ',' &
	-- 			"chksum:" & string'(hdo(frames)**".format.ipv4.chksum")  & '}'),
	-- 		size  => udprx_data'length)
	-- 	port map (
	-- 		clk    => miirx_clk,
	-- 		frm    => udprx_frm,
	-- 		irdy   => udprx_irdy,
	-- 		act(0) => meta_frm,
	-- 		act(1) => chksum_frm,
	-- 		act(2) => pyl_frm);
	-- 	pylrx_frm  <= tharx_frm or tparx_frm or meta_frm or chksum_frm;
	-- 	pylrx_irdy <= pylrx_frm;
	-- end block;

	dhcpcd_i : entity hdl4fpga.dhcpcd
	generic map (
		hwaddr        => hwaddr)
	port map (
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		miitx_clk     => miitx_clk,
		thatx_frm     => thatx_frm,
		thatx_irdy    => thatx_irdy,
		thatx_trdy    => thatx_trdy,
		thatx_data    => thatx_data,

		lentx_frm     => dhcpcdlentx_frm,
		lentx_irdy    => dhcpcdlentx_irdy,
		lentx_trdy    => dhcpcdlentx_trdy,

		tpatx_frm     => dhcpcdtpatx_frm,
		tpatx_irdy    => dhcpcdtpatx_irdy,
		tpatx_trdy    => dhcpcdtpatx_trdy,

		dhcpcdtx_frm  => dhcpcdtx_frm,
		dhcpcdtx_irdy => dhcpcdtx_irdy,
		dhcpcdtx_trdy => dhcpcdtx_trdy,
		dhcpcdtx_data => dhcpcdtx_data);

		dhcpcdlentx_frm  <= lentx_frm;
		dhcpcdlentx_irdy <= lentx_irdy;
		lentx_trdy       <= dhcpcdlentx_trdy;

		dhcpcdtpatx_frm  <= tpatx_frm;
		dhcpcdtpatx_irdy <= tpatx_irdy;
		tpatx_trdy    <= dhcpcdtpatx_trdy;

		udptx_frm        <= dhcpcdtx_frm;
		udptx_irdy       <= dhcpcdtx_irdy;
		dhcpcdtx_trdy    <= udptx_trdy ;
		udptx_data       <= dhcpcdtx_data;
end;
