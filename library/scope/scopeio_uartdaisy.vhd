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

entity scopeio_uartdaisy is
	port (
		uart_rxc       : in  std_logic;
		uart_rxdv      : in  std_logic;
		uart_rxd       : in  std_logic_vector(8-1 downto 0);

		chaini_sel     : in  std_logic;

		chaini_clk     : in  std_logic;
		chaini_frm     : in  std_logic;
		chaini_irdy    : in  std_logic;
		chaini_data    : in  std_logic_vector(8-1 downto 0);

		chaino_clk     : out std_logic;
		chaino_frm     : out std_logic;
		chaino_irdy    : out std_logic;
		chaino_data    : out std_logic_vector(8-1 downto 0));


end;

architecture beh of scopeio_uartdaisy is
begin

	chaino_clk  <= chaini_clk  when chaini_sel='1' else uart_rxc;
	chaino_frm  <= chaini_frm  when chaini_sel='1' else uart_rxdv; 
	chaino_irdy <= chaini_irdy when chaini_sel='1' else uart_rxdv;
	chaino_data <= chaini_data when chaini_sel='1' else uart_rxd;

end;
