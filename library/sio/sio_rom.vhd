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

entity sio_rom is
	generic (
		bitdata : std_logic_vector);
    port (
		so_clk  : in  std_logic := '0';
		so_frm  : in  std_logic := '0';
		so_irdy : in  std_logic := '0';
		so_trdy : out std_logic := '0';
		so_data : out std_logic_vector);
end;

architecture def of sio_rom is
	signal rd_addr : std_logic_vector(1 to unsigned_num_bits(bitdata'length/so_data'length-1));

begin

	process (so_frm, so_clk)
		variable cntr : unsigned(0 to rd_addr'length);
		variable active : std_logic;
	begin
		if rising_edge(so_clk) then
			if ((active or so_frm) and so_irdy)='1' then
				cntr := cntr + 1;
			end if;
			if (so_frm or so_irdy)='0' then
				cntr := (others => '0');
				cntr := cntr-bitdata'length/so_data'length;
			end if;
			if so_frm='0' then
				if so_irdy='0' then
					active := '0';
				elsif active='1' then
					active := '0';
				end if;
			elsif so_irdy='1' then
				active := '1';
			end if;
			rd_addr <= std_logic_vector(cntr(rd_addr'range));
		end if;
		so_trdy <= so_frm or active;
	end process;

	mem_i : entity hdl4fpga.rom
	generic map (
		bitdata  => std_logic_vector(resize(unsigned(bitdata), so_data'length*2**rd_addr'length)))
	port map (
		addr => rd_addr,
		data => so_data);

end;