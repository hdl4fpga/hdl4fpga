-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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





