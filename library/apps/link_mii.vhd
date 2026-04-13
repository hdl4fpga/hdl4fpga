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
use hdl4fpga.ipoepkg.all;

entity link_mii is
	generic (
		hwaddr   : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03";
		ipv4addr : std_logic_vector(0 to 32-1) := aton("192.168.1.1");
		n        : natural);
	port (
		tp       : out std_logic_vector(1 to 32);
		si_frm   : in  std_logic;
		si_irdy  : in  std_logic := '1';
		si_trdy  : out std_logic := '1';
		si_data  : in  std_logic_vector(0 to 8-1);

		so_frm   : out std_logic;
		so_irdy  : out std_logic := '1';
		so_trdy  : in  std_logic := '1';
		so_data  : out std_logic_vector(0 to 8-1);

		dhcp_btn : in  std_logic;
		mii_rxc  : in  std_logic;
		mii_rxdv : in  std_logic;
		mii_rxd  : in  std_logic_vector(0 to n-1);

		mii_txc  : in  std_logic;
		mii_txen : out std_logic;
		mii_txd  : out std_logic_vector(0 to n-1));
end;

architecture graphics of link_mii is
	signal dhcpcd_req : std_logic;
	signal dhcpcd_rdy : std_logic;

begin

	dhcp_p : process(mii_txc)
		type states is (s_request, s_wait);
		variable state : states;
	begin
		if rising_edge(mii_txc) then
			case state is
			when s_request =>
				if dhcp_btn='1' then
					dhcpcd_req <= not dhcpcd_rdy;
					state := s_wait;
				end if;
			when s_wait =>
				if to_bit(dhcpcd_req xor dhcpcd_rdy)='0' then
					if dhcp_btn='0' then
						state := s_request;
					end if;
				end if;
			end case;
		end if;
	end process;

	udpdaisy_e : entity hdl4fpga.sio_dayudp
	generic map (
		hwaddr     => hwaddr,
		ipv4addr   => ipv4addr)
	port map (
		tp         => tp,
		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,
		miirx_clk  => mii_txc,
		miirx_frm  => mii_rxdv,
		miirx_irdy => mii_rxdv,
		miirx_data => mii_rxd,
	
		miitx_clk  => mii_txc,
		miitx_frm  => mii_txen,
		miitx_irdy => open,
		miitx_data => mii_txd,
	
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_data    => si_data,
	
		so_clk     => mii_txc,
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data);
	
end;