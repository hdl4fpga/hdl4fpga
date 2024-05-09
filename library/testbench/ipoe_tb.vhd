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
		ipaddress : std_logic_vector := aton("192.168.0.14");
		delay1 : time := 36 us;
		delay2 : time := 10 us;
		snd_data : std_logic_vector :=
			x"01007e" &
			x"18ff"   &
			x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" &
			x"202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" &
			x"404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f" &
			x"606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f" &
			x"808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9f" &
			x"a0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf" &
			x"c0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedf" &
			x"e0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff" &
			x"1702_0003ff_1603_0000_0000";
		req_data : std_logic_vector := 
			x"010008_1702_0003ff_1603_8000_0000");
	port (
		mii_clk  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;

		mii_txen : buffer std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of ipoe_tb is
	signal rx_null  : std_logic_vector(mii_rxd'range);
	signal req      : std_logic := '0';
	signal mii_req  : std_logic := '0';
	signal mii_req1 : std_logic := '0';
	signal segment  : natural   := 0;
begin

	process
	begin
		req  <= '0';
		wait for delay1;
		loop
			if req='1' then
				wait on mii_rxdv;
				if falling_edge(mii_rxdv) then
					req <= '0';
					segment <= segment + 1;
					wait for delay2;
				end if;
			else
				if segment > 1 then
					wait;
				end if;
				req <= '1';
				wait on req;
			end if;
		end loop;
	end process;
	mii_req  <= req when segment=0 else '0';
	mii_req1 <= req when segment=1 else '0';

	htb_e : entity hdl4fpga.eth_tb
	generic map (
		debug => false,
		ipaddress => ipaddress)
	port map (
		mii_data4 => snd_data,
		mii_data5 => req_data,
		mii_frm1  => '0', -- arp
		mii_frm2  => '0', --mii_req, -- ping
		mii_frm3  => '0',
		mii_frm4  => mii_req, --mii_req, -- write
		mii_frm5  => mii_req1, -- read

		mii_txc   => mii_clk,
		mii_txen  => mii_txen,
		mii_txd   => mii_txd);

	-- mii_txen <= miirx_frm and not miirx_end;
	-- mii_txd  <= miirx_data;

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data   => rx_null,
		mii_clk    => mii_clk,
		mii_frm    => mii_rxdv,
		mii_irdy   => mii_rxdv,
		mii_data   => mii_rxd);

end;
