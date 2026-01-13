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
use hdl4fpga.ipoepkg.all;

entity dll_rx is
	port (
		mii_clk  : in  std_logic;
		dll_frm  : in  std_logic;
		dll_irdy : in  std_logic := '0';
		dll_trdy : buffer std_logic := '0';
		dll_data : in  std_logic_vector;

		da_frm   : buffer std_logic := '0';
		da_irdy  : out std_logic := '0';
		da_trdy  : in  std_logic := '1';
		sa_frm   : buffer std_logic := '0';
		sa_irdy  : out std_logic := '0';
		sa_trdy  : in  std_logic := '1';
		typ_frm  : buffer std_logic := '0';
		typ_irdy : out std_logic := '0';
		typ_trdy : in  std_logic := '1';
		pyl_frm  : buffer std_logic := '0';
		pyl_irdy : out std_logic := '0';
		pyl_trdy : in  std_logic := '1';

		crc_sb   : out std_logic;
		crc_equ  : out std_logic;
		crc_rem  : buffer std_logic_vector(0 to 32-1));

end;

architecture def of dll_rx is
	signal irdy : std_logic;
begin

	irdy <= dll_irdy and dll_trdy;
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => hdo(frames)**".format.mac",
		size  => dll_data'length)
	port map (
		clk    => mii_clk,
		frm    => dll_frm,
		irdy   => irdy,
		frms(0) => da_frm,
		frms(1) => sa_frm,
		frms(2) => typ_frm,
		frms(3) => pyl_frm);

	crc_i : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		frm  => dll_frm,
		irdy => dll_irdy,
		data => dll_data,
		crc  => crc_rem);

	process (dll_frm, mii_clk)
		variable q : std_ulogic;
	begin
		if rising_edge(mii_clk) then
			q := dll_frm;
		end if;
		crc_sb <= q and not dll_frm;
	end process;

	crc_equ <= '1' when crc_rem=x"38fb2284" else '0';

	dll_trdy <=
		da_trdy  when  da_frm='1' else
		sa_trdy  when  sa_frm='1' else
		typ_trdy when typ_frm='1' else
		pyl_trdy when pyl_frm='1' else
		'0';

	da_irdy  <=  da_frm;
	sa_irdy  <=  sa_frm;
	typ_irdy <= typ_frm;
	pyl_irdy <= pyl_frm;

end;
