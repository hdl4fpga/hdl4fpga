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

entity tb_ipoe is
	generic (
	port (
		mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;

		mii_txc  : in  std_logic;
		mii_txen : buffer std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of tb_ipoe is
begin

	mii_req  <= req when segment=0 else '0';
	mii_req1 <= req when segment=1 else '0';

	tb_ethtx_e : entity work.tb_eth
	generic map (
		tha => hdo(data)**".tha",
		pyl => hdo(data)**".udp")
	port map (
		req  => mii_req,
		rdy  => mii_rdy,
		txc  => mii_txc,
		txen => mii_txen,
		txd  => mii_rxd);

	tb_ehrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data   => rx_null,
		mii_clk    => mii_clk,
		mii_frm    => mii_rxdv,
		mii_irdy   => mii_rxdv,
		mii_data   => mii_rxd);

end;
