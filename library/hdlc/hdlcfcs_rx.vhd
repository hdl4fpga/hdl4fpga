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
use hdl4fpga.base.all;

entity hdlcfcs_rx is
	port (
		fcs_g       : in  std_logic_vector := std_logic_vector'(x"1021");
		fcs_rem     : in  std_logic_vector := std_logic_vector'(x"1d0f");

		uart_clk    : in  std_logic;

		hdlcrx_frm  : in  std_logic;
		hdlcrx_irdy : in  std_logic;
		hdlcrx_trdy : out std_logic := '1';
		hdlcrx_end  : in  std_logic;
		hdlcrx_data : in  std_logic_vector;

		fcs_sb      : out std_logic;
		fcs_vld     : out std_logic);
end;

architecture def of hdlcfcs_rx is

	signal crc_frm : std_logic;
	signal crc      : std_logic_vector(fcs_rem'range);

begin

	crc_frm <= to_stdulogic(to_bit(hdlcrx_frm));
	crc_e : entity hdl4fpga.crc
	port map (
		g    => fcs_g,
		clk  => uart_clk,
		frm  => crc_frm,
		irdy => hdlcrx_irdy,
		data => hdlcrx_data,
		crc  => crc);

	fcs_sb  <= hdlcrx_frm and hdlcrx_end and hdlcrx_irdy;
	fcs_vld <= setif(crc=not fcs_rem);

end;
