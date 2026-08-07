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

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity tb_ipoe is
	generic (
		ipaddress : std_logic_vector := aton("192.168.0.14");
		delay1 : time := 3 us;
		delay2 : time := 10 us;
		data : string := "{"           &
		"tha:0x"                 &
			"00_40_00_01_02_03," & -- target hardware address
		"udp:0x"                 &
			"0800"               & -- mac type
			"4500"               & -- IP Version, TOS
			"0054"               & -- IP Length
			"0000"               & -- IP Identification
			"0000"               & -- IP Fragmentation
			"0511"               & -- IP TTL, protocol
			"0000"               & -- IP Header Checksum
			"21436587"           & -- IP Source IP address
			"c0a8000e"           & -- IP Destiantion IP Address
			"482c"               & -- UDP source port 
			"6a1e"               & -- UDP destination port 
			"ffff"               & -- UDP length
			"0000"               & -- UDP checksum
			"010042"             &
    		"1702_000103_1603_0000_0000_ffff" &
		"}");
	port (
		mii_clk  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector;

		mii_txen : buffer std_logic;
		mii_txd  : out std_logic_vector);
end;

architecture def of tb_ipoe is
	signal rx_null  : std_logic_vector(mii_rxd'range);
	signal req      : std_logic := '0';
	signal mii_req  : std_logic := '0';
	signal mii_req1 : std_logic := '0';
	signal segment  : natural   := 0;
begin

	process
		constant max : natural := 1;
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
				if segment > max then
					wait;
				end if;
				req <= '1';
				wait on req;
			end if;
		end loop;
	end process;
	mii_req  <= req when segment=0 else '0';
	mii_req1 <= req when segment=1 else '0';

	tb_eth_e : entity work.tb_eth
	generic map (
		tha => hdo(data)**".tha",
		pyl => hdo(data)**".udp")
	port map (
		req  => mii_req,
		rdy  => mii_rdy,
		txc  => mii_rxc,
		txen => mii_rxdv,
		txd  => mii_rxd);

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		dll_data   => rx_null,
		mii_clk    => mii_clk,
		mii_frm    => mii_rxdv,
		mii_irdy   => mii_rxdv,
		mii_data   => mii_rxd);

end;
