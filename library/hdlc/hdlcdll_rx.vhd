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

entity hdlcrx_dll is
	port (
		uart_clk  : in  std_logic;
		uart_rxdv : in  std_logic;
		uart_rxd  : in  std_logic_vector;

		hdlc_frm  : buffer std_logic;
		hdlc_irdy : in  std_logic;
		hdlc_data : buffer std_logic_vector(8-1 downto 0));
		fcs_sb    : out std_logic;
		fcs_vld   : out std_logic);
end;

architecture def of hdlc_dll is
	signal hdlcrx_frm  : std_logic;
	signal hdlcrx_irdy : std_logic;
	signal hdlcrx_data : std_logic_vector(so_data'range);
begin

	syncrx_e : entity hdl4fpga.hdlcsync_rx
	port map (
		uart_clk  => uart_clk,

		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd,

		hdlc_frm  => hdlcrx_frm,
		hdlc_irdy => hdlcrx_irdy,
		hdlc_data => hdlcrx_data);

	fcsrx_e : entity hdl4fpga.hdlcfcs_rx
	port map (
		uart_clk  => uart_clk,

		hdlc_frm  => hdlcrx_frm,
		hdlc_irdy => hdlcrx_irdy,
		hdlc_data => hdlcrx_data,
		fcs_sb    => fsc_sb,
		fcs_vld   => fcs_vld);

end;
