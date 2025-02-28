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

entity sio_mux is
    port (
		mux_data : in  std_logic_vector;
        sio_clk  : in  std_logic;
        sio_frm  : in  std_logic;
		sio_irdy : in  std_logic := '1';
		sio_trdy : out std_logic;
		so_last  : buffer std_logic;
		so_end   : buffer std_logic;
        so_data  : out std_logic_vector);
end;

architecture def of sio_mux is
	constant mux_length : natural := unsigned_num_bits(mux_data'length/so_data'length-1);
	subtype mux_range is natural range 1 to mux_length;

	signal mux_sel : std_logic_vector(mux_range);
	signal rdata   : std_logic_vector(0 to 2**mux_length*so_data'length-1);

begin

	process (so_end, sio_clk)
		variable cntr : signed(0 to mux_length);
	begin
		if rising_edge(sio_clk) then
			if sio_frm='0' then
				cntr   := to_signed(mux_data'length/so_data'length-2, cntr'length);
				so_end <= '0';
			elsif sio_irdy='1' then
				so_end <= cntr(0);
				if cntr(0)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			mux_sel <= std_logic_vector(cntr(mux_range));
		end if;
		so_last <= not so_end and cntr(0);
	end process;
	sio_trdy <= sio_frm;

	rdata <= std_logic_vector(unsigned(reverse(reverse(std_logic_vector(resize(unsigned(mux_data), rdata'length)), so_data'length))) rol so_data'length);

	so_data <=
		rdata when so_data'length=rdata'length else
		multiplex(rdata, mux_sel, so_data'length);

end;
