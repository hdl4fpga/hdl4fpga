--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

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
