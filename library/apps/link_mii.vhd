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
use hdl4fpga.videopkg.all;

entity link_mii is
	generic (
		default_mac   : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03";
		default_ipv4a : std_logic_vector(0 to 32-1) := aton("192.168.1.1");
		n             : natural);
	port (
		tp       : out std_logic_vector(1 to 32);
		si_frm   : in  std_logic;
		si_irdy  : in  std_logic := '1';
		si_trdy  : out std_logic := '1';
		si_end   : in  std_logic;
		si_data  : in  std_logic_vector(0 to 8-1);

		so_frm   : out std_logic;
		so_irdy  : out std_logic := '1';
		so_trdy  : in  std_logic := '1';
		so_data  : out std_logic_vector(0 to 8-1);

		dhcp_btn : in  std_logic;
		hdplx    : in  std_logic := '0';
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

	signal miirx_frm  : std_logic;
	signal miirx_irdy : std_logic;
	signal miirx_data : std_logic_vector(mii_rxd'range);

	signal miitx_frm  : std_logic;
	signal miitx_irdy : std_logic;
	signal miitx_trdy : std_logic;
	signal miitx_end  : std_logic;
	signal miitx_data : std_logic_vector(si_data'range);

begin

	sync_g : if true generate
		signal rxc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal txc_rxbus : std_logic_vector(0 to mii_rxd'length);
		signal dst_irdy  : std_logic;
		signal dst_trdy  : std_logic;
	begin

		process (mii_rxc)
		begin
			if rising_edge(mii_rxc) then
				rxc_rxbus <= mii_rxdv & mii_rxd;
			end if;
		end process;

		rxc2txc_e : entity hdl4fpga.fifo
		generic map (
			max_depth  => 4,
			latency    => 0,
			dst_offset => 0,
			src_offset => 2,
			check_sov  => false,
			check_dov  => true)
		port map (
			src_clk  => mii_rxc,
			src_irdy => mii_rxdv,
			src_data => rxc_rxbus,
			dst_clk  => mii_txc,
			dst_irdy => dst_irdy,
			dst_trdy => dst_trdy,
			dst_data => txc_rxbus);

		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				dst_trdy   <= dst_irdy;
				miirx_frm  <= txc_rxbus(0);
				miirx_irdy <= txc_rxbus(0);
				miirx_data <= txc_rxbus(1 to mii_rxd'length);
			end if;
		end process;
	end generate;

	nosync_g : if false generate 
		miirx_frm  <= mii_rxdv;
		miirx_irdy <= mii_rxdv;
		miirx_data <= mii_rxd;
	end generate;

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
		my_mac        => default_mac,
		default_ipv4a => default_ipv4a)
	port map (
		tp         => tp,
		hdplx      => hdplx,
		mii_clk    => mii_txc,
		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,
		miirx_frm  => miirx_frm,
		miirx_irdy => miirx_irdy,
		miirx_data => miirx_data,
	
		miitx_frm  => miitx_frm,
		miitx_irdy => miitx_irdy,
		miitx_trdy => miitx_trdy,
		miitx_end  => miitx_end,
		miitx_data => miitx_data,
	
		si_frm     => si_frm,
		si_irdy    => si_irdy,
		si_trdy    => si_trdy,
		si_end     => si_end,
		si_data    => si_data,
	
		so_clk     => mii_txc,
		so_frm     => so_frm,
		so_irdy    => so_irdy,
		so_trdy    => so_trdy,
		so_data    => so_data);
	
	desser_e: entity hdl4fpga.desser
	port map (
		desser_clk => mii_txc,
	
		des_frm  => miitx_frm,
		des_irdy => miitx_irdy,
		des_trdy => miitx_trdy,
		des_data => miitx_data,
	
		ser_irdy => open,
		ser_data => mii_txd);
	
	mii_txen <= miitx_frm and not miitx_end;
end;
