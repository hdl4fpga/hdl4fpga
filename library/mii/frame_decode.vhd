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
		clk  : in  std_logic;
		irdy : in  std_logic;
		trdy : out std_logic := '1';
		eof  : in  std_logic;
		vld  : buffer std_logic_vector(0 to length(frame)-1));
end;

architecture def of frame_decode is

	constant total : natural := summation(frame)/size;

	function boundaries
		return natural_vector is
		variable boundary : natural;
		constant xxx : natural := 2**unsigned_num_bits(total-1);
		variable retval : natural_vector(vld'range);
	begin
		boundary := xxx-total;
		for i in vld'range loop
			boundary := hdo(frame)**('['&natural'image(i)&']')/size + boundary;
			retval(i) := boundary-1;
		end loop;
		return retval;
	end;

	constant limits : natural_vector(vld'range) := boundaries;
begin

	process (clk)
		variable cntr  : unsigned(0 to unsigned_num_bits(total-1));
		variable step  : natural range 0 to vld'length-1;
		variable limit : natural;
	begin
		if rising_edge(clk) then
			if irdy='1' then
			if limit=cntr then
				limit := limits(step);
				vld(step) <= '1';
				step := step + 1;
			end if;
			if cntr(0)='0' then
				if irdy='1' then
					cntr := cntr + 1;
				end if;
			end if;
			if (eof and irdy)='1' then
				step  := 0;
				cntr  := (others => '0');
				cntr  := cntr-total;
				limit := limits(step);
			end if;
			vld <= (others => '0');
			if step < vld'length then
				vld(step) <= '1';
			end if;
		end if;
	end process;

end;
