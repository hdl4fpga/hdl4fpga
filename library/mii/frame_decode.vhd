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
        size  : natural := 4);
	port (
		clk  : in  std_logic := '0';
		frm  : in  std_logic := '0';
		irdy : in  std_logic := '0';
		trdy : out std_logic := '0';
		fin  : out std_logic := '0';
		last : out std_logic := '0';
		act  : out std_logic_vector(0 to length(frame)));
end;

architecture def of frame_decode is
begin

	process (frm, irdy, clk)
		constant total : natural := summation(frame)/size;
	
		function boundaries
			return natural_vector is
			variable boundary : natural;
			constant psize  : natural := 2**unsigned_num_bits(total-1);
			variable retval : natural_vector(act'range);
		begin
			boundary := 2*psize-total;
			for i in act'range loop
				assert true
					report "frame_decode.boundaries() : boundary => " & natural'image(boundary)
					severity note;
				if i=act'right then
					retval(i) := 0;
				else
					boundary  := hdo(frame)**('['&natural'image(i)&']')/size + boundary;
					retval(i) := (boundary-1);
				end if;
			end loop;
			return retval;
		end;

		constant boundary : natural_vector := boundaries;
		variable cntr  : unsigned(0 to unsigned_num_bits(total-1)) := ('1', others => '0');
		variable step  : natural range 0 to act'length-1;
		variable limit : natural range 0 to 2**cntr'length-1;

		variable active : std_logic;
	begin
		if rising_edge(clk) then
			if ((active or frm) and irdy)='1' then
				if cntr(0)='1' then
					if limit=cntr then
						step  := step + 1;
						limit := boundary(step);
					end if;
					cntr := cntr + 1;
				end if;
			end if;
			if cntr=(cntr'range => '1') then
				last <= '1';
			end if;
			if frm='0' then
				if irdy='0' then
					active := '0';
				elsif active='1' then
					active := '0';
				end if;
			elsif irdy='1' then
				active := '1';
			end if;
			-- if (frm or irdy)='0' then -- Initialization
			if active='0' then
				step  := 0;
				cntr  := to_unsigned(2**cntr'length-total, cntr'length);
				limit := boundary(step);
				last  <= '0';
			end if;
		end if;
		fin  <= not cntr(0);
		trdy <= (frm or active) and irdy;

		act <= (others => '0');
		act(step) <= frm;
	end process;

end;
