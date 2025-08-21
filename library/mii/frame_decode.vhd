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
use hdl4fpga.ipoepkg.all;

entity frame_decode is
    generic (
        frame : string := hdo(frames)**".format.mac";
        size  : natural := 8);
	port (
		clk  : in  std_logic := '0';
		frm  : in  std_logic := '0';
		irdy : in  std_logic := '0';
		trdy : out std_logic := '1';
		act  : out std_logic_vector(0 to length(frame)));
end;

architecture def of frame_decode is
begin

	process (frm, clk)
		constant total : natural := summation(frame)/size;
	
		function boundaries
			return natural_vector is
			variable boundary : natural;
			constant psize  : natural := 2**unsigned_num_bits(total-1);
			variable retval : natural_vector(act'range);
		begin
			boundary := 2*psize-total;
			for i in act'range loop
				if i=act'right then
					retval(i) := boundary;
				else
				report natural'image(boundary);
					boundary  := hdo(frame)**('['&natural'image(i)&']')/size + boundary;
				report natural'image(boundary);
					retval(i) := (boundary-1);
				end if;
			end loop;
			return retval;
		end;

		constant boundary : natural_vector := boundaries;
		variable cntr  : unsigned(0 to unsigned_num_bits(total-1)) := (others => '0');
		variable step  : natural range 0 to act'length-1;
		variable limit : natural;

	begin
		if rising_edge(clk) then
			if frm='0' then
				if irdy='0' then
					step  := 0;
					cntr  := (others => '0');
					cntr  := cntr-total;
					limit := boundary(step);
				end if;
			elsif (irdy and cntr(0))='1' then
				if limit=cntr then
					step  := step + 1;
					limit := boundary(step);
				end if;
				cntr := cntr + 1;
			end if;
		end if;
		act <= (others => '0');
		act(step) <= frm;
	end process;

end;
