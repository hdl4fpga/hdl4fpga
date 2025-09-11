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

entity mii_buffer is -- skid buffer
	generic (
		latency : natural := 1);
	port (
		clk : in std_logic;
		src_frm  : in  std_logic := '1';
		src_irdy : in  std_logic;
		src_trdy : out std_logic;
		src_data : in  std_logic_vector;
		dst_frm  : buffer std_logic;
		dst_irdy : buffer std_logic;
		dst_trdy : in  std_logic;
		dst_data : out std_logic_vector);
end;

architecture def of mii_buffer is
begin

	process (src_frm, dst_trdy, clk)
		variable frm_shr  : unsigned(0 to latency-1);
		variable irdy_shr : unsigned(0 to latency-1);
		variable data_shr : unsigned(0 to latency*src_data'length-1);
	begin
		if rising_edge(clk) then
			if (not irdy_shr(0) or dst_trdy)/='0' then
				frm_shr(0) := src_frm;
				frm_shr := rotate_left(frm_shr, 1);
				irdy_shr(0) := src_irdy;
				irdy_shr := rotate_left(irdy_shr, 1);
				data_shr(0 to src_data'length-1) := unsigned(src_data);
				data_shr := rotate_left(data_shr, src_data'length);
			end if;
			dst_frm  <= frm_shr(0);
			dst_irdy <= irdy_shr(0);
			dst_data <= std_logic_vector(data_shr(0 to dst_data'length-1));
		end if;
		if src_frm='1' then
			if irdy_shr(0)/='1' then
				src_trdy <= '1';
			else
				src_trdy <= dst_trdy;
			end if;
		elsif frm_shr(0)/='1' then
			src_trdy <= dst_trdy;
		else
			src_trdy <= '0';
		end if;
	end process;

end;
