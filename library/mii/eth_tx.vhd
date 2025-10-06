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
		mii_frm     : buffer std_logic;
		mii_irdy    : buffer std_logic;
		mii_trdy    : in  std_logic := '1';
		mii_data    : out std_logic_vector;

		pyl_frm     : in  std_logic;
		pyl_irdy    : in  std_logic;
		pyl_trdy    : buffer std_logic := '0';
		pyl_data    : in  std_logic_vector);

end;

architecture def of eth_tx is

	signal decode_frm  : std_logic;
	signal decode_data : std_logic_vector(mii_data'range);
	signal decode_fin  : std_logic;
	signal decode_last : std_logic;

	signal rom_frm    : std_logic;
	signal rom_irdy   : std_logic;
	signal rom_data   : std_logic_vector(mii_data'range);

	signal prmb_act    : std_logic;
	signal sha_act     : std_logic;
	signal pad_act     : std_logic;

	signal fcs_frm     : std_logic;
	signal fcs_irdy    : std_logic;
	signal fcs_trdy    : std_logic;
	signal fcs_data    : std_logic_vector(mii_data'range);
	signal fcs_g       : std_logic_vector(0 to 32-1);
	signal fcs_crc     : std_logic_vector(fcs_g'range);

	signal crc_frm     : std_logic;
	signal crc_irdy    : std_logic;
	alias  crc_trdy    is crc_irdy;
	alias  crc_data    is fcs_crc(mii_data'range);

    signal tha_act     : std_logic;
    signal typ_act     : std_logic;
    signal act5        : std_logic;

begin

	decode_frm <= pyl_frm;
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => "{"                                                 &
			"prmb:" & "64"                                     & ',' &
			" tha:" & string'(hdo(frames)**".format.mac.hwda") & ',' &
			" sha:" & string'(hdo(frames)**".format.mac.hwsa") & ',' &
			"type:" & string'(hdo(frames)**".format.mac.type") & ',' &
			" pad:" & natural'image(46*8)                      & '}',
		size  => mii_data'length)
	port map (
		clk    => mii_clk,
		frm    => pyl_frm,
		irdy   => pyl_irdy,
		fin    => decode_fin,
		last   => decode_last,
		act(0) => prmb_act,
		act(1) => tha_act,
		act(2) => sha_act,
		act(3) => typ_act,
		act(4) => pad_act,
		act(5) => act5);

	rom_frm  <= pyl_frm;
	rom_irdy <= prmb_act or sha_act;
	rom_i : entity hdl4fpga.sio_rom
	generic map (
		bitdata => reverse(
			x"5555_5555_5555_55d5" &
			sha, 8))
	port map (
        so_clk  => mii_clk,
		so_frm  => rom_frm,
		so_irdy => rom_irdy,
		so_data => rom_data);

	fcs_frm_p : process (tha_act, mii_clk)
		variable frm : std_logic;
	begin
		if rising_edge(mii_clk) then
			if tha_act='1' then
				frm := '1';
			elsif (pyl_frm or (pyl_irdy and not pyl_trdy))='0' then
				frm := '0';
			end if;
		end if;
		fcs_frm <= tha_act or frm;
	end process;

	fcs_irdy <=
		'0'      when  prmb_act='1' else
		pyl_irdy when   tha_act='1' else
		'1'      when   sha_act='1' else
		pyl_irdy when   typ_act='1' else
		crc_irdy;

	fcs_data <= 
		pyl_data when  tha_act='1' else
		rom_data when  sha_act='1' else
		pyl_data when  typ_act='1' else
		pyl_data when  pyl_frm='1' else
		pyl_data when pyl_irdy='1' else
		(pyl_data'range => '-');

	process (pad_act, decode_fin, pyl_frm, pyl_irdy, mii_clk)
		variable shr : unsigned(0 to fcs_crc'length/mii_data'length);
	begin
		if rising_edge(mii_clk) then
			if (pad_act or pyl_frm or pyl_irdy or crc_trdy)='1' then
				shr(0) := pyl_frm or (pad_act and not decode_last);
				shr := rotate_left(shr, 1);
			end if;
			crc_irdy <= shr(0);
			crc_frm <= not pyl_frm and pyl_irdy and (not pad_act or decode_last);
		end if;

		if decode_fin='0' then
			if prmb_act='1' then
				pyl_trdy <= '0';
			elsif (not pyl_frm and pyl_irdy)='1' then
				pyl_trdy <= '0';
			else
				pyl_trdy <= pyl_frm;
			end if;
		elsif pyl_frm='1' then
			pyl_trdy <= '1';
		elsif (pyl_irdy and not shr(1))='1' then
			pyl_trdy <= '1';
		else
			pyl_trdy <= '0';
		end if;
	end process;

	fcs_g <= x"04c11db7" when crc_frm='0' else x"00000000";
	fcs_e : entity hdl4fpga.crc
	port map (
		g    => fcs_g,
		clk  => mii_clk,
		frm  => fcs_frm,
		irdy => fcs_irdy,
		trdy => fcs_trdy,
		data => fcs_data,
		crc  => fcs_crc);

	mii_frm_p : process (prmb_act, mii_clk)
		variable frm : std_logic;
	begin
		if rising_edge(mii_clk) then
			if prmb_act='1' then
				frm := '1';
			elsif ((pyl_frm or pyl_irdy) and (pyl_frm or not pyl_trdy))='0' then
				frm := '0';
			end if;
		end if;
		mii_frm <= prmb_act or frm;
	end process;

	mii_irdy <=
		'1'      when prmb_act='1' else
		fcs_irdy when  fcs_frm='1' else
		crc_trdy when  crc_frm='1' else
		'0';
		
	mii_data <= 
		rom_data when prmb_act='1' else
		pyl_data when  tha_act='1' else
		rom_data when  sha_act='1' else
		pyl_data when  typ_act='1' else
		crc_data when  crc_frm='1' else
		pyl_data;
end;
