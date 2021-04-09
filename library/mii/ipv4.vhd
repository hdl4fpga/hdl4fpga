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

library hdl4fpga;
use hdl4fpga.std.all;

entity ipv4 is
	port (
		my_ipv4a   : in std_logic_vector(0 to 32-1) := x"00_00_00_00";
		my_mac     : in std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03";

		mii_clk    : in  std_logic;
		frmrx_ptr  : in  std_logic_vector;

		ipv4rx_frm  : in  std_logic;
		ipv4rx_irdy : in  std_logic;
		ipv4rx_trdy : out std_logic;

		ipv4darx_frm  : out std_logic;
		ipv4darx_vld  : in  std_logic;

		ipv4tx_frm  : buffer std_logic := '0';
		ipv4tx_irdy : out std_logic;
		ipv4tx_trdy : in  std_logic;
		ipv4tx_end  : out std_logic;
		ipv4tx_data : out std_logic_vector;
		miitx_end  : in  std_logic;

		tp         : out std_logic_vector(1 to 32));

end;

architecture def of ipv4 is

	signal arpd_rdy  : std_logic := '0';
	signal arpd_req  : std_logic := '0';

begin

	ipv4rx_e : entity hdl4fpga.ipv4_rx
	port map (
		mii_clk       => mii_clk,
		mii_ptr       => frmrx_ptr,
		ipv4_frm      => ipv4rx_frm,

		ip4len_irdy   => 
		ip4da_frm     => 
		ip4da_irdy    => 
		ip4sa_irdy    => 
		ip4proto_irdy => 

		pl_irdy       => 
		pl_trdy       => );


end;
