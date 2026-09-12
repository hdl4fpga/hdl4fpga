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
		trdy       : out std_logic;
		data       : in  std_logic_vector;

		rid_act    : buffer std_logic;
		len_act    : buffer std_logic;
		pyl_act    : buffer std_logic;

		rgtr_frm   : buffer std_logic;
		rgtr_irdy  : buffer std_logic;
		rgtr_trdy  : in  std_logic := '1');

end;

architecture beh of sio_sin is

	signal rgtr_last : std_logic;

	constant frame : string := "{rid:8,length:8}";
	signal acts    : std_logic_vector(0 to length(frame));
	signal frms    : std_logic_vector(acts'range);
	signal irdys   : std_logic_vector(acts'range);
	signal trdys   : std_logic_vector(acts'range);

	alias rid_frm  is frms(0);
	alias len_frm  is frms(1);
	alias pyl_frm  is frms(2);
	alias rid_irdy is irdys(0);
	alias len_irdy is irdys(1);
	alias pyl_irdy is irdys(2);

begin

	trdys <= (others => rgtr_trdy);
	decode_i : entity hdl4fpga.frame_decode
	generic map (
		frame => frame,
		size  => data'length)
	port map (
		clk   => clk,
		frm   => rgtr_frm,
		irdy  => rgtr_irdy,
		trdy  => trdy,
		last  => rgtr_last,
		frms  => frms,
		acts  => acts,
		irdys => irdys,
		trdys => trdys);
	(rid_act, len_act, pyl_act) <= acts;

	process (frm, irdy, len_act, clk)
		-- variable cntr : unsigned(0 to hdo(frame)**".length"+unsigned_num_bits(8/data'length)-1); -- Xilinx ISE 14.7 bug
		-- alias    algn : unsigned(0 to hdo(frame)**".length"-1) is cntr(1 to hdo(frame)**".length"); -- Xilinx ISE 14.7 bug
		constant length : natural := hdo(frame)**".length"; -- Xilinx ISE 14.7 bug
		variable cntr   : unsigned(0 to length+unsigned_num_bits(8/data'length)-1);
		alias    algn   : unsigned(0 to length-1) is cntr(1 to length);
	begin
		if rising_edge(clk) then
			if (frm or irdy)='1' then
				if (irdy and rgtr_trdy)='1' then
					if len_act='1' then
						algn := rotate_left(algn, data'length);
						algn(data'range) := reverse(unsigned(data));
						cntr(0) := '0';
					elsif pyl_act='1' then
						cntr := cntr - 1;
					end if;
				end if;
			else
				cntr(0) := '1';
			end if;
		end if;
		if cntr/=0 then
			rgtr_frm <= frm;
		elsif irdy='0' then
			rgtr_frm <= frm;
		else
			rgtr_frm <= '0';
		end if;
	end process;
	rgtr_irdy <= irdy;
end;
