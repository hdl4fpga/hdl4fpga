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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity eth_tx is
	generic (
		debug       : boolean := false);
	port (
		mii_clk     : in  std_logic;

		pl_frm      : in  std_logic;
		pl_irdy     : in  std_logic := '1';
		pl_trdy     : buffer std_logic;
		pl_end      : in  std_logic;
		pl_data     : in  std_logic_vector;

		hwda_irdy   : out std_logic;
		hwda_end    : in  std_logic := '1';
		hwda_data   : in  std_logic_vector;

		hwsa_irdy   : out std_logic;
		hwsa_end    : in  std_logic := '1';
		hwsa_data   : in  std_logic_vector;

		hwtyp_irdy  : out std_logic;
		hwtyp_end   : in  std_logic := '1';
		hwtyp_data  : in  std_logic_vector;

		mii_frm     : buffer std_logic;
		mii_irdy    : buffer std_logic;
		mii_trdy    : in  std_logic := '1';
		mii_end     : buffer std_logic;
		mii_data    : out std_logic_vector);

end;

architecture def of eth_tx is

	signal decode_frm  : std_logic;
	signal decode_irdy : std_logic;
	signal decode_trdy : std_logic := '1';
	signal decode_data : std_logic_vector(arp_data'range);

	signal prmb_trdy : std_logic;
	signal prmb_end  : std_logic;
	signal prmb_data : std_logic_vector(mii_data'range);

	signal fcs_irdy : std_logic;
	signal fcs_data : std_logic_vector(mii_data'range);
	signal fcs_crc  : std_logic_vector(0 to 32-1);

begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => "{"                 &
			"prmb:"& "64"                            & ','  &
			" tha:"& hdo(frames)**".format.mac.hwda" & ','  &
			" sha:"& hdo(frames)**".format.mac.hwsa" & ','  &
			"type:"& hdo(frames)**".format.mac.type" &  "}",
		size  => dll_data'length)
	port map (
		clk    => mii_clk,
		frm    => decode_frm,
		irdy   => decode_irdy,
		trdy   => decode_trdy,
		act(0) => prmb_frm,
		act(1) => hwda_frm,
		act(2) => hwsa_frm,
		act(3) => typ_frm,
		act(4) => pyl_frm);

	pre_e : entity hdl4fpga.sio_rom
	generic map (
		bitdata => reverse(x"5555_5555_5555_55d5", 8))
	port map (
        so_clk  => mii_clk,
		so_frm  => prmb_frm,
		so_irdy => prmb_irdy,
		so_trdy => prmb_trdy,
		so_data => prmb_data);

	sha_i : entity hdl4fpga.sio_rom
	generic map (
		bitdata => reverse(x"ff_ff_ff_ff_ff_ff", 8))
	port map (
        so_clk  => mii_clk,
		so_frm  => sha_frm,
		so_irdy => sha_irdy,
		so_trdy => sha_trdy,
		so_data => sha_data);

	fcs_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => mii_frm,
		irdy => fcs_irdy,
		mode => fcs_mode,
		data => fcs_data,
		crc  => fcs_crc);

end;
