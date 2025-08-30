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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity eth_tx is
	generic (
		sha         : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk     : in  std_logic;

		mac_frm     : in  std_logic;
		mac_irdy    : in  std_logic := '1';
		mac_trdy    : buffer std_logic;
		mac_data    : in  std_logic_vector;

		ethda_frm   : out std_logic;
		ethda_irdy  : out std_logic;
		ethda_trdy  : in  std_logic := '1';
		ethda_data  : in  std_logic_vector;

		ethtyp_frm  : out std_logic;
		ethtyp_irdy : out std_logic;
		ethtyp_trdy : in  std_logic := '1';
		ethtyp_data : in  std_logic_vector;

		mii_frm     : buffer std_logic;
		mii_irdy    : buffer std_logic;
		mii_trdy    : in  std_logic := '1';
		mii_data    : out std_logic_vector);
end;

architecture def of eth_tx is

	signal decode_frm  : std_logic;
	signal decode_irdy : std_logic;
	signal decode_trdy : std_logic := '1';
	signal decode_data : std_logic_vector(arp_data'range);

	signal prmb_frm  : std_logic;
	signal prmb_irdy : std_logic;
	signal prmb_trdy : std_logic;
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
