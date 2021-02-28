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

entity hdlcdll_rx is
	port (
		uart_clk    : in  std_logic;
		uart_rxdv   : in  std_logic;
		uart_rxd    : in  std_logic_vector;

		hdlcrx_frm  : buffer std_logic;
		hdlcrx_irdy : buffer  std_logic;
		hdlcrx_data : buffer std_logic_vector;
		fcs_sb      : out std_logic;
		fcs_vld     : out std_logic);
end;

architecture def of hdlcdll_rx is
	signal hdlcsyncrx_irdy : std_logic;
	signal hdlcsyncrx_data : std_logic_vector(hdlcrx_data'range);
begin

	syncrx_e : entity hdl4fpga.hdlcsync_rx
	port map (
		uart_clk  => uart_clk,

		uart_rxdv => uart_rxdv,
		uart_rxd  => uart_rxd,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcsyncrx_irdy,
		hdlcrx_data => hdlcsyncrx_data);

	fcsrx_e : entity hdl4fpga.hdlcfcs_rx
	port map (
		uart_clk  => uart_clk,

		hdlcrx_frm  => hdlcrx_frm,
		hdlcrx_irdy => hdlcsyncrx_irdy,
		hdlcrx_data => hdlcsyncrx_data,
		fcs_sb      => fcs_sb,
		fcs_vld     => fcs_vld);

	process (hdlcsyncrx_irdy, uart_clk)
		variable q : unsigned(0 to 2-1);
	begin
		if rising_edge(uart_clk) then
			if hdlcrx_frm='0' then
				q := (others => '0');
			elsif hdlcsyncrx_irdy='1' then
				q(0) := '1';
				q := q rol 1;
			end if;
		end if;
		hdlcrx_irdy <= hdlcsyncrx_irdy and to_stdulogic(to_bit(q(0)));
	end process;

	data_e : entity hdl4fpga.align 
	generic map (
		n => hdlcrx_data'length,
		d => (hdlcrx_data'range => 2))
	port map (
		clk => uart_clk,
		ena => hdlcsyncrx_irdy,
		di  => hdlcsyncrx_data,
		do  => hdlcrx_data);

end;
