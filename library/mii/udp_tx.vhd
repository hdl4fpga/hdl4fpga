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

entity udp_tx is
	port (
		mii_clk  : in  std_logic;

		pl_frm   : in  std_logic;
		pl_irdy  : in  std_logic;
		pl_trdy  : out std_logic;
		pl_len   : in  std_logic_vector(16-1 downto 0);
		pl_data  : in  std_logic_vector;

		hdr_irdy : in  std_logic;
		hdr_trdy : out std_logic;
		hdr_end  : in  std_logic;
		hdr_data : in  std_logic_vector;

		udp_frm  : buffer std_logic;
		udp_irdy : out std_logic;
		udp_trdy : in  std_logic;
		udp_data : out std_logic_vector;
		udp_end  : out std_logic;
		tp       : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is
begin

	hdr_trdy <= udp_trdy;
	udp_irdy <= primux(udphdr_trdy & pl_irdy, not hdr_end & '1')(0);
	udp_data <= primux(udphdr_data & pl_data, not hdr_end & '1');

	pl_trdy  <= hdr_end and udp_trdy;
end;

