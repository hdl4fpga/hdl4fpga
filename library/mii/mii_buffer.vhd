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
use hdl4fpga.std.all;

entity mii_buffer is
	port (
		io_clk : in  std_logic;
		i_frm  : in  std_logic;
		i_irdy : in  std_logic;
		i_trdy : out std_logic;
		i_data : in  std_logic_vector;
		i_end  : in  std_logic;
		o_frm  : out std_logic;
		o_irdy : out std_logic;
		o_trdy : in  std_logic;
		o_data : out std_logic_vector;
		o_end  : out std_logic);
end;

architecture def of mii_buffer is

	signal src_frm  : std_logic;
	signal src_irdy : std_logic;
	signal src_trdy : std_logic;
	signal src_data : std_logic_vector(0 to i_data'length+2-1);
	signal dst_data : std_logic_vector(src_data'range);

begin

	src_irdy <= i_frm and i_irdy;
	src_data <= i_frm & i_data & i_end;
	buffer_e : entity hdl4fpga.fifo
	generic map (
		max_depth => 2,
		check_sov => false,
		check_dov => true)
	port map(
		src_clk  => io_clk,
		src_irdy => src_irdy,
		src_trdy => i_trdy,
		src_data => src_data,
		dst_clk  => io_clk,
		dst_irdy => o_irdy,
		dst_trdy => o_trdy,
		dst_data => dst_data);

	process (dst_data)
		variable data : unsigned(dst_data'range);
	begin
		data := unsigned(dst_data);
		o_frm <= data(0);
		data := data sll 1;
		o_data <= std_logic_vector(data(0 to o_data'length-1));
		data := data sll o_data'length;
		o_end <= data(0);
		data := data sll 1;
	end process;

end;
