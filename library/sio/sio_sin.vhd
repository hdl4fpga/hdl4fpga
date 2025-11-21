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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;

entity sio_sin is
	port (
		clk        : in  std_logic;
		frm        : in  std_logic;
		irdy       : in  std_logic;
		trdy       : buffer std_logic := '1';
		data       : in  std_logic_vector;

		rid_act    : buffer std_logic;
		length_act : buffer std_logic;
		data_act   : buffer std_logic;

		rgtr_frm   : buffer std_logic;
		rgtr_irdy  : buffer std_logic;
		rgtr_trdy  : in  std_logic := '1');

end;

architecture beh of sio_sin is
	constant frame : string := "{rid:8,length:8}";

	signal rgtr_last  : std_logic;

begin

	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => frame,
		size  => data'length)
	port map (
		clk    => clk,
		frm    => rgtr_frm,
		irdy   => rgtr_irdy,
		last   => rgtr_last,
		act(0) => rid_act,
		act(1) => length_act,
		act(2) => data_act);

	process (frm, clk)
		variable cntr : unsigned(0 to hdo(frame)**".length"+unsigned_num_bits(8/data'length)-1);
		alias xxx : unsigned(0 to hdo(frame)**".length"-1) is cntr(1 to hdo(frame)**".length");
	begin
		if rising_edge(clk) then
			if (frm or irdy)='1' then
				if (irdy and trdy)='1' then
					if length_act='1' then
						xxx := rotate_left(xxx, data'length);
						xxx(data'range) := reverse(unsigned(data));
					elsif cntr(0)='1' then
						cntr := (others => '0');
					elsif data_act='1' then
						cntr := cntr - 1;
					end if;
				end if;
			else
				cntr := (others => '0');
			end if;
		end if;
		rgtr_frm <= frm and not cntr(0);
	end process;
	rgtr_irdy <= irdy;
end;
