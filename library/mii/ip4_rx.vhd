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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ip4_rx is
	port (
		mii_rxc    : in  std_logic;
		mii_rxdv   : in  std_logic;
		mii_rxd    : in  std_logic_vector;

		eth_ptr    : in  std_logic_vector;

		ip4da_rxdv : out std_logic;
		ip4sa_rxdv : out std_logic;

		pl_rxdv    : in  std_logic);

end;

architecture def of ip4_rx is
begin

	ip4sa_rxdv <= frame_decode(unsigned(eth_ptr), eth_frame & ip4hdr_frame, mii_rxd'length, ip4_sa);
	ip4da_rxdv <= frame_decode(unsigned(eth_ptr), eth_frame & ip4hdr_frame, mii_rxd'length, ip4_da);
	pl_rxdv    <= frame_decode(unsigned(eth_ptr), eth_frame & ip4hdr_frame, mii_rxd'length, ip4_da, gt);

end;

