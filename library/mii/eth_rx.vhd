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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity eth_rx is
	port (
		mii_clk  : in  std_logic;
		mii_frm  : in  std_logic;
		mii_irdy : in  std_logic;
		mii_trdy : buffer std_logic;
		mii_data : in  std_logic_vector;

		dll_frm  : buffer std_logic;
		dll_irdy : buffer std_logic := '0';
		dll_trdy : in  std_logic := '1';
		dll_data : buffer std_logic_vector;

		da_frm   : out std_logic := '0';
		da_irdy  : out std_logic := '0';
		sa_frm   : out std_logic := '0';
		sa_irdy  : out std_logic := '0';
		typ_frm  : out std_logic := '0';
		typ_irdy : out std_logic := '0';
		pyl_frm  : out std_logic := '0';
		pyl_irdy : out std_logic := '0';

		fcs_sb   : out std_logic;
		fcs_vld  : out std_logic;
		fcs_rem  : out std_logic_vector(0 to 32-1));

end;

architecture def of eth_rx is
begin

	mii_pre_e : entity hdl4fpga.mii_rxpre
	port map (
		mii_clk  => mii_clk,
		mii_frm  => mii_frm,
		mii_irdy => mii_irdy,
		mii_data => mii_data,
		mii_pre  => dll_frm);

	serlzr_i : entity hdl4fpga.serlzr
	port map (
		src_clk   => mii_clk,
		src_frm   => dll_frm,
		src_irdy  => mii_irdy,
		src_trdy  => mii_trdy,
		src_data  => mii_data,
		dst_clk   => mii_clk,
		dst_irdy  => dll_irdy,
		dst_trdy  => dll_trdy,
		dst_data  => dll_data);

	dllrx_i : entity hdl4fpga.dll_rx
	port map (
		mii_clk  => mii_clk,
		dll_frm  => dll_frm,
		dll_irdy => dll_frm,
		dll_data => dll_data,

		da_frm   => da_frm,
		da_irdy  => da_irdy,
		sa_frm   => sa_frm,
		sa_irdy  => sa_irdy,
		typ_frm  => typ_frm,
		typ_irdy => typ_irdy,
		pyl_frm  => pyl_frm,
		pyl_irdy => pyl_irdy,
		crc_sb   => fcs_sb,
		crc_equ  => fcs_vld,
		crc_rem  => fcs_rem);

end;
