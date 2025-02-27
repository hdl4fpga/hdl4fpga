-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity mii_buffer is
	port (
		io_clk : in  std_logic;
		i_frm  : in  std_logic;
		i_irdy : in  std_logic;
		i_trdy : out std_logic;
		i_data : in  std_logic_vector;
		i_end  : in  std_logic;
		o_frm  : buffer std_logic;
		o_irdy : buffer std_logic;
		o_trdy : in  std_logic;
		o_data : out std_logic_vector;
		o_end  : buffer std_logic);
end;

architecture def of mii_buffer is

	signal src_trdy : std_logic;
	signal src_irdy : std_logic;
	signal src_data : std_logic_vector(0 to i_data'length+1-1);
	signal dst_data : std_logic_vector(src_data'range);

	signal src_end : std_logic;
begin

	process (io_clk)
	begin
		if rising_edge(io_clk) then
			if i_frm='1' then
				if (i_irdy and src_trdy)='1' then
					src_end <= i_end;
				end if;
			else
				src_end <= '0';
			end if;
		end if;
	end process;

	i_trdy <= 
		src_trdy when i_end='0' else
		src_trdy when o_end='1' and o_trdy='1' else
		'0';

		
	src_irdy <= 
		   '0' when   i_frm='0' else
		i_irdy when src_end='0' else
		'0';

	src_data <= i_end & i_data;
	buffer_e : entity hdl4fpga.fifo
	generic map (
		latency   => 1,
		max_depth => 2,
		check_sov => true,
		check_dov => true)
	port map(
		src_clk  => io_clk,
		src_irdy => src_irdy,
		-- src_trdy => i_trdy,
		src_trdy => src_trdy,
		src_data => src_data,
		dst_clk  => io_clk,
		dst_irdy => o_irdy,
		dst_trdy => o_trdy,
		dst_data => dst_data);

	o_frm <= o_irdy and i_frm;
	process (dst_data)
		variable data : unsigned(dst_data'range);
	begin
		data   := unsigned(dst_data);
		o_end  <= data(0);
		data   := data sll 1;
		o_data <= std_logic_vector(data(0 to o_data'length-1));
		data   := data sll o_data'length;
	end process;

end;
