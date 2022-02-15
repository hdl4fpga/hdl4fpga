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

entity sio_dmahdsk is
	port (
		dmacfg_clk  : in  std_logic;
		dmaio_irdy  : in  std_logic;
		dmaio_trdy  : buffer std_logic;

		dmacfg_req  : buffer std_logic;
		dmacfg_rdy  : in  std_logic;

		ctlr_clk    : in  std_logic;
		ctlr_inirdy : in  std_logic;

		dma_req     : buffer std_logic;
		dma_rdy     : in  std_logic);
end;

architecture def of sio_dmahdsk is

	signal cfg_req : bit;
	signal cfg_rdy : bit;

	signal ctlr_req : bit;
	signal ctlr_rdy : bit;

begin

	dmacfg_p : process(dmacfg_clk)
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				dmaio_trdy   <= '0';
				dmacfg_req   <= '0';
				cfg_req <= '0';
				ctlr_rdy <= '0';
			elsif (ctlr_req xor ctlr_rdy)='0' then
				if (cfg_req xor cfg_rdy)='0' then
					if to_bit(dma_rdy xor dma_req)='0' then
						if to_bit(dmacfg_req xor dmacfg_rdy)='0' then
							if (dmaio_irdy and not dmaio_trdy)='1' then
								dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
							end if;
						else
							cfg_req <= not cfg_rdy;
						end if;
					end if;
				end if;
				dmaio_trdy <= '0';
			elsif (dma_req xor dma_rdy)='0' then
				dmaio_trdy <= '1';
				ctlr_rdy <= ctlr_req;
			end if;
		end if;
	end process;

	dmaddr_p : process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_inirdy='0' then
				dma_req      <= '0';
				ctlr_req <= '0';
				cfg_rdy <= '0';
			elsif (cfg_req xor cfg_rdy)='1' then
				if (ctlr_req xor ctlr_rdy)='0' then
					if (dmacfg_req xor dmacfg_rdy)='0' then
						if (dma_req xor dma_rdy)='0' then
							dma_req <= not to_stdulogic(to_bit(dma_rdy));
						else
							ctlr_req <= not ctlr_rdy;
						end if;
					end if;
				else
					cfg_rdy <= cfg_req;
				end if;
			end if;
		end if;
	end process;

end;
