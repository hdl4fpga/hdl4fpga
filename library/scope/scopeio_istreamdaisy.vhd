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

entity scopeio_istreamdaisy is
	generic (
		istream_esc : std_logic_vector := std_logic_vector(to_unsigned(character'pos('\'), 8));
		istream_eos : std_logic_vector := std_logic_vector(to_unsigned(character'pos(NUL), 8)));
	port (
		chaini_sel     : in  std_logic;

		chaini_clk     : in  std_logic;
		chaini_frm     : in  std_logic;
		chaini_irdy    : in  std_logic;
		chaini_data    : in  std_logic_vector;

		chaino_clk     : out std_logic;
		chaino_frm     : out std_logic;
		chaino_irdy    : out std_logic;
		chaino_data    : out std_logic_vector);

end;

architecture beh of scopeio_istreamdaisy is

	signal strm_frm  : std_logic;
	signal strm_irdy : std_logic;
	signal strm_data : std_logic_vector(chaini_data'range);

begin

	assert chaino_data'length=chaini_data'length 
		report "chaino_data'lengthi not equal chaini_data'length"
		severity failure;

	scopeio_istream_e : entity hdl4fpga.scopeio_istream
	generic map (
		esc => istream_esc,
		eos => istream_eos)
	port map (
		clk     => chaini_clk,
		rxdv    => chaini_frm,
		rxd     => chaini_data,

		so_frm  => strm_frm,
		so_irdy => strm_irdy,
		so_data => strm_data);

	chaino_clk  <= chaini_clk;
	chaino_frm  <= chaini_frm  when chaini_sel='1' else strm_frm; 
	chaino_irdy <= chaini_irdy when chaini_sel='1' else strm_irdy;
	chaino_data <= chaini_data when chaini_sel='1' else strm_data;

end;
