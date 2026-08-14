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
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity mii_ipoe is
	generic (
		ipv4addr      : std_logic_vector(0 to 32-1) := aton("192.168.0.14");
		hwaddr        : std_logic_vector := x"00_40_00_01_02_03");
	port (
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		miirx_clk     : in  std_logic;
		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic := '0';
		miirx_trdy    : out std_logic := '1';
		miirx_data    : in  std_logic_vector;

		udppylrx_frm  : out std_logic;
		udppylrx_irdy : out std_logic;
		udppylrx_trdy : in  std_logic := '1';
		udppylrx_data : out std_logic_vector;

		fcs_sb        : out std_logic;
		fcs_vld       : out std_logic;

		miitx_clk     : in  std_logic;

		udppyltx_frm  : in  std_logic := '0';
		udppyltx_irdy : in  std_logic := '0';
		udppyltx_trdy : out std_logic := '1';
		udppyltx_data : in  std_logic_vector;

		miitx_frm     : out std_logic;
		miitx_irdy    : out std_logic := '0';
		miitx_trdy    : in  std_logic := '1';
		miitx_data    : out std_logic_vector;

		tp            : buffer std_logic_vector(1 to 32) := (others => '0'));
end;

architecture def of mii_ipoe is
	signal dll_frm       : std_logic;
	signal ethda_frm     : std_logic;
	signal ethda_irdy    : std_logic;
	signal ethsa_frm     : std_logic;
	signal ethsa_irdy    : std_logic;
	signal ethda_equ     : std_logic;
	signal bcstda_equ    : std_logic;
	signal ethtyp_frm    : std_logic;
	signal ethtyp_irdy   : std_logic;
	signal ipv4typ_equ   : std_logic;
	signal arptyp_equ    : std_logic;
	signal ethpyl_frm    : std_logic;
	signal ethpyl_irdy   : std_logic;

	signal arprx_frm     : std_logic;
	alias  arprx_irdy is miirx_irdy;
	signal arprx_data    : std_logic_vector(miirx_data'range);

	signal arptha_frm    : std_logic;
	signal arptpa_frm    : std_logic;

	signal ipv4sharx_frm  : std_logic;
	signal ipv4sharx_irdy : std_logic;

	signal ipv4rx_frm    : std_logic;
	signal ipv4rx_irdy : std_logic;
	signal ipv4rx_data   : std_logic_vector(miirx_data'range);

	signal eth_frms  : std_logic_vector(0 to 2-1);
	signal eth_irdys : std_logic_vector(0 to 2-1);
	signal eth_trdys : std_logic_vector(0 to 2-1) := (others => '1');

	alias  arptx_frm   is eth_frms(0);
	alias  arptx_irdy  is eth_irdys(0);
	alias  arptx_trdy  is eth_trdys(0);
	signal arptx_data  : std_logic_vector(miitx_data'range);

	alias  ipv4tx_frm  is eth_frms(1);
	alias  ipv4tx_irdy is eth_irdys(1);
	alias  ipv4tx_trdy is eth_trdys(1);
	signal ipv4tx_data : std_logic_vector(miitx_data'range);

	signal upspa_frm  : std_logic;
	signal upspa_irdy : std_logic;
	signal upspa_trdy : std_logic;
	signal upspa_data : std_logic_vector(miirx_data'range);

	signal arp_req : std_logic;
	signal arp_rdy : std_logic;

	constant bcst_data : std_logic_vector := (miirx_data'range => '1');

begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk  => miirx_clk,
		mii_frm  => miirx_frm,
		mii_irdy => miirx_irdy,
		mii_data => miirx_data,
		dll_frm  => dll_frm,

		da_frm   => ethda_frm,
		da_irdy  => ethda_irdy,
		sa_frm   => ethsa_frm,
		sa_irdy  => ethsa_irdy,
		typ_frm  => ethtyp_frm,
		typ_irdy => ethtyp_irdy,
		pyl_frm  => ethpyl_frm,
		pyl_irdy => ethpyl_irdy,
		fcs_sb   => fcs_sb,
		fcs_vld  => fcs_vld);

	bcstcmp_i : entity hdl4fpga.sio_cmp
	port map (
		clk     => miirx_clk,
		mr_frm  => ethda_frm,
		mr_irdy => ethda_irdy,
		mr_trdy => open,
		mr_data => bcst_data,
		sl_data => miirx_data,
		equ     => bcstda_equ);

	ethda_cmp_i : entity hdl4fpga.mii_cmp
	generic map (
		bitdata => reverse(hwaddr,8))
	port map (
		mii_clk => miirx_clk,
		frm     => ethda_frm,
		irdy    => ethda_irdy,
		data    => miirx_data,
		equ     => ethda_equ);

	arptyp_cmp_i : entity hdl4fpga.mii_cmp
	generic map (
		bitdata => reverse(hdo(frames)**".data.mac.type.arp",8))
	port map (
		mii_clk => miirx_clk,
		frm     => ethtyp_frm,
		irdy    => ethtyp_irdy,
		data    => miirx_data,
		equ     => arptyp_equ);

	process (miirx_clk)
		variable da_vld  : std_logic := '0';
		variable typ_vld : std_logic := '0';
	begin
		if rising_edge(miirx_clk) then
			if (miirx_frm or miirx_irdy)='0' then
				da_vld  := '0';
				typ_vld := '0';
			else
				if (not da_vld and ethda_equ)='1' then
					da_vld := '1';
				end if;
				if (not da_vld and bcstda_equ)='1' then
					da_vld := '1';
				end if;
				if (not typ_vld and arptyp_equ)='1' then
					typ_vld := '1';
				end if;
			end if;
			arprx_frm  <= ethpyl_frm and da_vld and typ_vld;
			arprx_data <= miirx_data;
		end if;
	end process;
	tp(1) <= arprx_frm; --miirx_frm;
	tp(2 to arprx_data'length+1) <= arprx_data;

	arpd_i : entity hdl4fpga.arpd
	generic map (
		ipv4addr      => ipv4addr,
		hwaddr        => hwaddr)
	port map (
		arp_req       => arp_req,
		arp_rdy       => arp_rdy,

		miirx_clk     => miirx_clk,

		upspa_frm     => upspa_frm,
		upspa_irdy    => upspa_irdy,
		upspa_trdy    => upspa_trdy,
		upspa_data    => upspa_data,

		arprx_frm     => arprx_frm,
		arprx_irdy    => arprx_irdy,
		arprx_data    => arprx_data,

		miitx_clk     => miitx_clk,
		arptx_frm     => arptx_frm,
		arptx_irdy    => arptx_irdy,
		arptx_trdy    => arptx_trdy,
		arptx_data    => arptx_data);

	tx_b : block
		signal gntd  : std_logic_vector(0 to 2-1);

		signal pyl_frm   : std_logic;
		signal pyl_irdy  : std_logic;
		signal pyl_trdy  : std_logic;
		signal pyl_data  : std_logic_vector(miitx_data'range);
	begin

		arbiter_i : entity hdl4fpga.mii_arbiter
		port map (
			clk   => miitx_clk,
			gntd  => gntd,
			frms  => eth_frms,
			irdys => eth_irdys,
			trdys => eth_trdys,
			frm   => pyl_frm,
			irdy  => pyl_irdy,
			trdy  => pyl_trdy);

		pyl_data <= 
			arptx_data  when gntd(0)='1' else
			ipv4tx_data when gntd(1)='1' else
			(pyl_data'range => '-');

		ethtx_i : entity hdl4fpga.eth_tx
		port map (
			mii_clk     => miitx_clk,
			mii_frm     => miitx_frm,
			mii_irdy    => miitx_irdy,
			mii_trdy    => miitx_trdy,
			mii_data    => miitx_data,

			pyl_frm     => pyl_frm,
			pyl_irdy    => pyl_irdy,
			pyl_trdy    => pyl_trdy,
			pyl_data    => pyl_data);

	end block;

	ipv4typ_cmp_i : entity hdl4fpga.mii_cmp
	generic map (
		bitdata => reverse(hdo(frames)**".data.mac.type.ipv4",8))
	port map (
		mii_clk => miirx_clk,
		frm     => ethtyp_frm,
		irdy    => ethtyp_irdy,
		data    => miirx_data,
		equ     => ipv4typ_equ);

	process (miirx_clk)
		variable da_vld  : std_logic := '0';
		variable typ_vld : std_logic := '0';
	begin
		if rising_edge(miirx_clk) then
			if (miirx_frm or miirx_irdy)='0' then
				da_vld  := '0';
				typ_vld := '0';
			else
				if (not da_vld and ethda_equ)='1' then
					da_vld := '1';
				end if;
				-- if (not da_vld and bcstda_equ)='1' then
				-- 	da_vld := '1';
				-- end if;
				if (not typ_vld and ipv4typ_equ)='1' then
					typ_vld := '1';
				end if;
			end if;
			ipv4sharx_frm  <= ethsa_frm;
			ipv4sharx_irdy <= ethsa_irdy;
			ipv4rx_frm     <= ethpyl_frm and da_vld and typ_vld;
			ipv4rx_irdy    <= miirx_irdy;
			ipv4rx_data    <= miirx_data;
		end if;
	end process;

	-- tp(1) <= ipv4rx_frm; --miirx_frm;
	-- tp(2 to 2+miirx_data'length-1) <= ipv4rx_data;
	-- ipv4rx_irdy <= ipv4rx_frm and miirx_irdy;
	ipv4_i : entity hdl4fpga.ipv4
	generic map (
		hwaddr   => hwaddr,
		ipv4addr => ipv4addr)
	port map (
		--tp => tp,

		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		arp_req       => arp_req,
		arp_rdy       => arp_rdy,

		upspa_frm     => upspa_frm,
		upspa_irdy    => upspa_irdy,
		upspa_trdy    => upspa_trdy,
		upspa_data    => upspa_data,

		miirx_clk     => miirx_clk,

		udppylrx_frm  => udppylrx_frm,
		udppylrx_irdy => udppylrx_irdy,
		udppylrx_trdy => udppylrx_trdy,
		udppylrx_data => udppylrx_data,

		sharx_frm     => ipv4sharx_frm,
		sharx_irdy    => ipv4sharx_irdy,

		ipv4rx_frm    => ipv4rx_frm,
		ipv4rx_irdy   => ipv4rx_irdy,
		ipv4rx_data   => ipv4rx_data,

		miitx_clk     => miitx_clk,

		udppyltx_frm  => udppyltx_frm,
		udppyltx_irdy => udppyltx_irdy,
		udppyltx_trdy => udppyltx_trdy,
		udppyltx_data => udppyltx_data,

		ipv4tx_frm    => ipv4tx_frm,
		ipv4tx_irdy   => ipv4tx_irdy,
		ipv4tx_trdy   => ipv4tx_trdy,
		ipv4tx_data   => ipv4tx_data);

end;
