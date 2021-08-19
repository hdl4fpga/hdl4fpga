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
		pl_end   : in  std_logic;
		pl_data  : in  std_logic_vector;

		hdr_irdy : in  std_logic;
		hdr_trdy : out std_logic;
		hdr_end  : in  std_logic;
		hdr_data : in  std_logic_vector;

		udp_frm  : buffer std_logic;
		meta_full : in std_logic := '0';
		meta_irdy : in std_logic := '1';
		udp_irdy : out std_logic;
		udp_trdy : in  std_logic;
		udp_data : out std_logic_vector;
		udp_end  : out std_logic;
		tp       : out std_logic_vector(1 to 32));
end;

architecture def of udp_tx is
begin

	hdr_trdy <= 
		'0' when meta_full='0' else
		udp_trdy;
	udp_irdy <= 
		meta_irdy when meta_full='0' else 
		hdr_irdy  when hdr_end='0'   else
		pl_irdy;
	udp_data <= 
		pl_data  when meta_full='0' else 
		hdr_data when hdr_end='0'   else 
		pl_data;

	pl_trdy <= meta_irdy when meta_full='0' else udp_trdy;
	udp_end  <= 
		'0' when hdr_end='0' else 
		pl_end;
end;

