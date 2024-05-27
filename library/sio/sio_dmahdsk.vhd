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

entity sio_dmahdsk is
	port (
		dmacfg_clk  : in  std_logic;
		dmaio_irdy  : in  std_logic;
		dmaio_trdy  : buffer std_logic;

		dmacfg_req  : buffer std_logic;
		dmacfg_rdy  : in  std_logic;

		ctlr_clk    : in  std_logic;
		ctlr_inirdy : in  std_logic;

		dma_req     : out std_logic;
		dma_rdy     : in  std_logic);
end;

architecture def of sio_dmahdsk is
	signal rdy : std_logic;
	signal req : std_logic;
begin

	ctlr_p : process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			dma_req <= req;
		end if;
	end process;

	dmacfg_p : process(dmacfg_clk)
		variable cfg_busy   : std_logic;
		variable trans_busy : std_logic;
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				dmaio_trdy <= '0';
				dmacfg_req <= '0';
				cfg_busy   := '0';
				trans_busy := '0';
				req        <= rdy;
			elsif trans_busy='0' then
				if to_bit(dmacfg_req xor dmacfg_rdy)='0' then
					if cfg_busy='0' then
						if (dmaio_irdy and not dmaio_trdy)='1' then
							dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
							cfg_busy := '1';
						end if;
						trans_busy := '0';
					else
						req        <= not rdy;
						cfg_busy   := '0';
						trans_busy := '1';
					end if;
				end if;
				dmaio_trdy <= '0';
			elsif (req xor rdy)='0' then
				dmaio_trdy <= '1';
				cfg_busy   := '0';
				trans_busy := '0';
			end if;
			rdy <= dma_rdy;
		end if;
	end process;

end;
