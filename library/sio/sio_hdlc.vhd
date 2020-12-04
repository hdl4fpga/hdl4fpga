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

entity sio_ahdlc is
	port (
		hdlc_rxdv : in  std_logic;
		hdlc_rxd  : in  std_logic_vector;

		sio_clk   : in  std_logic;
		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_data   : out std_logic_vector);

end;

architecture def of sio_udp is

	signal ahdlc_frm  : std_logic;
	signal ahdlc_irdy : std_logic;
	signal ahdlc_data : std_logic_vector(so_data'range);

begin

	ahdlc_e : entity hdl4fpga.ahdlc
	port map (
		clk        => sio_clk,

		uart_rxdv  => hdlc_rxdv,
		uarr_rxd   => hdlc_rxd,

		ahdlc_frm  => ahdlc_frm,
		ahdlc_irdy => ahdlc_irdy,
		ahdlc_data => ahdlc_data);


end;
