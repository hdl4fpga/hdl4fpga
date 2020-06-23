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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity ethtype is
	generic (
		protos    : std_logic_vector);
	port (
		mii_rxc  : in  std_logic;
		mii_rxd  : in  std_logic_vector;
		mii_rxdv : in  std_logic;

		frame    : in  std_logic;
		field    : in  std_logic;
		proto    : out std_logic_vector);
end;

architecture def of ethtype is

begin

	decode_g : for i in proto'range generate

		proto_e : entity hdl4fpga.mii_romcmp
		generic map (
			mem_data => reverse(word2byte(protos, i, protos'length/proto'length),8))
		port map (
			mii_rxc  => mii_rxc,
			mii_rxd  => mii_rxd,
			mii_treq => frame,
			mii_ena  => field,
			mii_pktv => proto(i));

	end generate;

end;

