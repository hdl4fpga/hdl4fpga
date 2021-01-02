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

entity sio_dmactlr is
	port (
		dmacfg_clk  : in  std_logic;
		dmasin_irdy : in  std_logic;
		dmasin_trdy : buffer std_logic;

		dmacfg_req  : buffer std_logic;
		dmacfg_rdy  : in  std_logic;

		ctlr_clk    : in  std_logic;
		ctlr_inirdy : in  std_logic;

		dma_req     : buffer std_logic;
		dma_rdy     : in  std_logic);
end;

architecture def of sio_dmactlr is

	signal cfg2ctlr_req : std_logic;
	signal cfg2ctlr_rdy : std_logic;

	signal ctlr2cfg_req : std_logic;
	signal ctlr2cfg_rdy : std_logic;

begin

	dmacfg_p : process(dmacfg_clk)
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				dmasin_trdy   <= '0';
				dmacfg_req   <= '0';
				cfg2ctlr_req <= '0';
				ctlr2cfg_rdy <= '0';
			elsif (to_stdulogic(to_bit(ctlr2cfg_req)) xor to_stdulogic(to_bit(ctlr2cfg_rdy)))='0' then
				if (to_stdulogic(to_bit(cfg2ctlr_req)) xor to_stdulogic(to_bit(cfg2ctlr_rdy)))='0' then
					if (to_stdulogic(to_bit(dma_rdy)) xor to_stdulogic(to_bit(dma_req)))='0' then
						if (to_stdulogic(to_bit(dmacfg_req)) xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
							if dmasin_irdy='1' then
								if dmasin_trdy='0' then
									dmacfg_req <= not to_stdulogic(to_bit(dmacfg_rdy));
								end if;
							end if;
						else
							cfg2ctlr_req <= not to_stdulogic(to_bit(cfg2ctlr_rdy));
						end if;
					end if;
				end if;
				dmasin_trdy <= '0';
			else
				ctlr2cfg_rdy <= to_stdulogic(to_bit(ctlr2cfg_req));
				dmasin_trdy <= '1';
			end if;
		end if;
	end process;

	dmaddr_p : process(ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_inirdy='0' then
				dma_req      <= '0';
				ctlr2cfg_req <= '0';
				cfg2ctlr_rdy <= '0';
			elsif (to_stdulogic(to_bit(cfg2ctlr_req)) xor to_stdulogic(to_bit(cfg2ctlr_rdy)))='1' then
				if (to_stdulogic(to_bit(ctlr2cfg_req)) xor to_stdulogic(to_bit(ctlr2cfg_rdy)))='0' then
					if (to_stdulogic(to_bit(dmacfg_req)) xor to_stdulogic(to_bit(dmacfg_rdy)))='0' then
						if (to_stdulogic(to_bit(dma_req)) xor to_stdulogic(to_bit(dma_rdy)))='0' then
							dma_req <= not to_stdulogic(to_bit(dma_rdy));
						else
							ctlr2cfg_req <= not to_stdulogic(to_bit(ctlr2cfg_rdy));
						end if;
					end if;
				else
					cfg2ctlr_rdy <= to_stdulogic(to_bit(cfg2ctlr_req));
				end if;
			end if;
		end if;
	end process;

end;
