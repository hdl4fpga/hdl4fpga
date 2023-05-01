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
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity ipoe_tb is
	generic (
		snd_data : std_logic_vector;
		req_data : std_logic_vector);
	port (
		mii_clk  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;

		mii_txen : buffer std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of ipoe_tb is
	signal datarx_null :  std_logic_vector(mii_rxd'range);
	signal req    : std_logic := '0';
	signal mii_req : std_logic := '0';
	signal mii_req1 : std_logic := '0';
	signal x        : natural := 0;
begin

	process
	begin
		req <= '0';
		wait for 36 us;
		loop
			if req='1' then
				wait on mii_rxdv;
				if falling_edge(mii_rxdv) then
					req <= '0';
					x <= x + 1;
					wait for 12 us;
				end if;
			else
				if x > 1 then
					wait;
				end if;
				req <= '1';
				wait on req;
			end if;
		end loop;
	end process;
	mii_req  <= req when x=0 else '0';
	mii_req1 <= req when x=1 else '0';

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug => false)
	port map (
		mii_data4 => snd_data,
		mii_data5 => req_data,
		mii_frm1  => mii_req, -- arp
		mii_frm2  => '0', --mii_req, -- ping
		mii_frm3  => '0',
		mii_frm4  => '0', --mii_req, -- write
		mii_frm5  => '0', --mii_req1, -- read

		mii_txc   => mii_clk,
		mii_txen  => mii_txen,
		mii_txd   => mii_txd);

	-- mii_txen <= miirx_frm and not miirx_end;
	-- mii_txd  <= miirx_data;

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data   => datarx_null,
		mii_clk    => mii_clk,
		mii_frm    => mii_rxdv,
		mii_irdy   => mii_rxdv,
		mii_data   => mii_rxd);

end;
