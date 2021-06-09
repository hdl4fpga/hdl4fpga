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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity ipv4_rx is
	port (
		mii_clk        : in  std_logic;

		ipv4_frm       : in  std_logic;
		ipv4_irdy      : in  std_logic;
		ipv4_data      : in  std_logic_vector;

		ipv4len_irdy   : out std_logic;
		ipv4da_frm     : buffer std_logic;
		ipv4da_irdy    : out std_logic;
		ipv4sa_irdy    : out std_logic;
		ipv4proto_irdy : out std_logic;

		pl_frm         : buffer std_logic;
		pl_irdy        : out std_logic);

end;

architecture def of ipv4_rx is

	signal frm_ptr       : std_logic_vector;
	signal ipv4len_frm   : std_logic;
	signal ipv4sa_frm    : std_logic;
	signal ipv4proto_frm : std_logic;

begin

	ipv4len_frm   <= ipv4_frm and frame_decode(frm_ptr, ipv4hdr_frame, ipv4_data'length, ipv4_len);
	ipv4sa_frm    <= ipv4_frm and frame_decode(frm_ptr, ipv4hdr_frame, ipv4_data'length, ipv4_sa);
	ipv4da_frm    <= ipv4_frm and frame_decode(frm_ptr, ipv4hdr_frame, ipv4_data'length, ipv4_da);
	ipv4proto_frm <= ipv4_frm and frame_decode(frm_ptr, ipv4hdr_frame, ipv4_data'length, ipv4_proto);
	pl_frm        <= ipv4_frm and frame_decode(frm_ptr, ipv4hdr_frame, ipv4_data'length, ipv4_da, gt);

	ipv4len_irdy   <= ipv4_irdy and ipv4len_frm;
	ipv4sa_irdy    <= ipv4_irdy and ipv4sa_frm;
	ipv4da_irdy    <= ipv4_irdy and ipv4da_frm;
	ipv4proto_irdy <= ipv4_irdy and ipv4proto_frm;
	pl_irdy        <= ipv4_irdy and pl_frm;

end;

