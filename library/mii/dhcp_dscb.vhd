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
use hdl4fpga.ethpkg.all;
use hdl4fpga.ipoepkg.all;

entity dhcpc_dscb is
	generic (
		dhcp_sp       : std_logic_vector(0 to 16-1)  := x"0044";
		dhcp_dp       : std_logic_vector(0 to 16-1)  := x"0043";
		dhcp_mac      : std_logic_vector(0 to 6*8-1) := x"00_40_00_01_02_03");
	port (
		mii_clk       : in  std_logic;
		dhcpdscb_frm  : in  std_logic;

		dlltx_irdy    : out std_logic;
		dlltx_end     : in  std_logic := '1';
		dlltx_data    : out std_logic_vector;
		netdatx_irdy  : out std_logic := '1';
		netdatx_end   : in  std_logic;
		netlentx_irdy : out std_logic := '1';
		netlentx_end  : in  std_logic;
		netlentx_data : out std_logic_vector;
		nettx_end     : in  std_logic;

		dhcpdscb_irdy : out std_logic;
		dhcpdscb_trdy : in  std_logic;
		dhcpdscb_end  : out std_logic;
		dhcpdscb_data : out std_logic_vector);

end;

architecture def of dhcpc_dscb is

	constant payload_size : natural := 250;
	constant udp_size     : std_logic_vector := std_logic_vector(to_unsigned(payload_size+8,16));

	constant vendor_data : std_logic_vector :=
		x"350101"       &     -- DHCPDISCOVER
		x"320400000000" &     -- IP REQUEST
		x"FF";                -- END

	constant dhcp_pkt : std_logic_vector :=
		udp_checksummed (
			x"00000000",
			x"ffffffff",
			dhcp_sp      &    -- UDP Source port
			dhcp_dp      &    -- UDP Destination port
			udp_size     &    -- UDP Length,
			x"0000"      &	  -- UDP CHECKSUM
			x"01010600"  &    -- OP, HTYPE, HLEN,  HOPS
			x"3903f326"  &    -- XID
			dhcp_mac     &    -- CHADDR
			x"63825363"  &    -- MAGIC COOKIE
			vendor_data);

	signal dhcppkt_irdy  : std_logic;
	signal dhcppkt_trdy  : std_logic;
	signal dhcppkt_ena   : std_logic;
	signal dhcppkt_end   : std_logic;
	signal dhcppkt_data  : std_logic_vector(dhcpdscb_data'range);

	constant dhcp_vendor : natural := dhcp4hdr_frame'right+1;
	constant dscb_frame  : natural_vector(udp4hdr_frame'left to dhcp_vendor) :=
		 udp4hdr_frame  &
		 dhcp4hdr_frame &
		(dhcp_vendor => vendor_data'length);

	signal dhcpdscb_ptr  : std_logic_vector(0 to unsigned_num_bits((payload_size+8)*8/dhcpdscb_data'length-1));

	alias net_end is netdatx_end;

begin

	process (mii_clk)
		variable cntr : unsigned(dhcpdscb_ptr'range);
	begin
		if rising_edge(mii_clk) then
			if dhcpdscb_frm='0' then
				cntr := (others => '0');
			elsif dhcpdscb_trdy='1' and net_end='1' then
				if dhcppkt_end='0' then
					cntr := cntr + 1;
				end if;
			end if;
			dhcpdscb_ptr <= std_logic_vector(cntr);
		end if;
	end process;

	dhcppkt_ena <= frame_decode (
		dhcpdscb_ptr, dscb_frame,  dhcpdscb_data'length,
		(udp4_sp,     udp4_dp,     udp4_len,      udp4_cksm,
		dhcp4_op,     dhcp4_htype, dhcp4_hlen,
		dhcp4_hops,   dhcp4_xid,   dhcp4_chaddr6, dhcp4_cookie, dhcp_vendor));

	dhcppkt_irdy <=
		'0'           when    dlltx_end='0' else
		'1'           when netlentx_end='0' else
		'0'           when  netdatx_end='0' else
		dhcpdscb_trdy when  dhcppkt_ena='1' else
		'0';

	dhcppkt_e : entity hdl4fpga.sio_mux
	port map (
		mux_data => reverse(reverse(udp_size) & dhcp_pkt, 8),
        sio_clk  => mii_clk,
		sio_frm  => dhcpdscb_frm,
		sio_irdy => dhcppkt_irdy,
        sio_trdy => dhcppkt_trdy,
        so_end   => dhcppkt_end,
        so_data  => dhcppkt_data);

	dlltx_irdy    <= dhcpdscb_trdy;
	netlentx_irdy <= dhcpdscb_trdy when    dlltx_end='1' else '0';
	netlentx_data <= dhcppkt_data;
	netdatx_irdy  <= dhcpdscb_trdy when netlentx_end='1' else '0';

	dhcpdscb_irdy <= 
		'1'          when    dlltx_end='0' else
		dhcppkt_trdy when netlentx_end='1' else
		'0';

	dhcpdscb_end <=
		'0' when netdatx_end='0' else
		dhcppkt_end;

	dhcpdscb_data <=
		(dhcpdscb_data'range => '1') when    dlltx_end='0' else
		dhcppkt_data                 when netlentx_end='0' else
		(dhcpdscb_data'range => '1') when  netdatx_end='0' else
		dhcppkt_data                 when  dhcppkt_ena='1' else
		(dhcpdscb_data'range => '0');
end;
