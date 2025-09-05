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
		ipaddr : std_logic_vector(0 to 32-1) := aton("192.168.0.14");
		hwaddr : std_logic_vector := x"00_40_00_01_02_03");
	port (
		miirx_clk    : in  std_logic;
		miirx_frm  : in  std_logic;
		miirx_irdy : in  std_logic := '0';
		miirx_trdy : out std_logic := '1';
		miirx_data : in  std_logic_vector;
		fcs_sb     : out std_logic;
		fcs_vld    : out std_logic;

		miitx_clk  : in  std_logic;
		miitx_frm  : out std_logic;
		miitx_irdy : out std_logic := '0';
		miitx_trdy : in  std_logic := '1';
		miitx_data : out std_logic_vector;

		tp         : buffer std_logic_vector(1 to 32) := (others => '0'));

end;

architecture def of mii_ipoe is
	signal dll_frm       : std_logic;
	signal dll_irdy      : std_logic;
	signal dll_trdy      : std_logic;
	signal dll_data      : std_logic_vector(miirx_data'range);

	signal ethda_frm     : std_logic;
	signal ethda_irdy    : std_logic;
	signal ethda_equ     : std_logic;
	signal bcstda_equ    : std_logic;
	signal ethtyp_frm    : std_logic;
	signal ethtyp_irdy   : std_logic;
	signal ipv4typ_equ   : std_logic;
	signal arptyp_equ    : std_logic;
	signal ethpyl_frm    : std_logic;
	signal ethpyl_irdy   : std_logic;

	signal thatx_frm     : std_logic := '0';
	signal thatx_irdy    : std_logic := '0';
	signal thatx_trdy    : std_logic := '0';
	signal thatx_data    : std_logic_vector(miirx_data'range);

	signal arprx_frm     : std_logic;
	alias  arprx_irdy is arprx_frm;
	signal arprx_data    : std_logic_vector(miirx_data'range);

	signal arptx_frm     : std_logic;
	signal arptx_irdy    : std_logic;
	signal arptx_trdy    : std_logic := '1';
	signal arptx_data    : std_logic_vector(miirx_data'range);

	signal arptha_frm    : std_logic;
	signal arptpa_frm    : std_logic;

	signal ipv4rx_frm    : std_logic;
	alias  ipv4rx_irdy is ipv4rx_frm;
	signal ipv4rx_data   : std_logic_vector(miirx_data'range);

	signal ipv4da_frm    : std_logic;

	signal ethtyptx_frm  : std_logic := '0';
	signal ethtyptx_irdy : std_logic := '0';
	signal ethtyptx_trdy : std_logic := '0';
	signal ethtyptx_data : std_logic_vector(miitx_data'range);

begin

	ethrx_e : entity hdl4fpga.eth_rx
	port map (
		mii_clk  => miirx_clk,
		mii_frm  => miirx_frm,
		mii_irdy => miirx_irdy,
		mii_data => miirx_data,

		dll_frm  => dll_frm,
		dll_irdy => dll_irdy,
		dll_trdy => dll_trdy,
		dll_data => dll_data,

		da_frm   => ethda_frm,
		da_irdy  => ethda_irdy,
		typ_frm  => ethtyp_frm,
		typ_irdy => ethtyp_irdy,
		pyl_frm  => ethpyl_frm,
		pyl_irdy => ethpyl_irdy,
		fcs_sb   => fcs_sb,
		fcs_vld  => fcs_vld);

	bcstda_cmp_i : entity hdl4fpga.mii_cmp
	generic map (
		bitdata => reverse(x"ff_ff_ff_ff_ff_ff",8))
	port map (
		mii_clk => miirx_clk,
		frm     => ethda_frm,
		irdy    => ethda_irdy,
		data    => miirx_data,
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

	arpd_i : entity hdl4fpga.arpd
	generic map (
		hwaddr => hwaddr)
	port map (
		miirx_clk     => miirx_clk,

		arprx_frm     => arprx_frm,
		arprx_irdy    => arprx_irdy,
		arprx_data    => arprx_data,

		thatx_frm     => thatx_frm,
		thatx_irdy    => thatx_irdy,
		thatx_trdy    => thatx_trdy,
		thatx_data    => thatx_data,

		ethtyptx_frm  => ethtyptx_frm,
		ethtyptx_irdy => ethtyptx_irdy,
		ethtyptx_trdy => ethtyptx_trdy,
		ethtyptx_data => ethtyptx_data,

		miitx_clk     => miitx_clk,
		arptx_frm     => arptx_frm,
		arptx_irdy    => arptx_irdy,
		arptx_trdy    => arptx_trdy,
		arptx_data    => arptx_data);

	ethtx_i : entity hdl4fpga.eth_tx
	port map (
		mii_clk     => miitx_clk,
		mii_frm     => miitx_frm,
		mii_irdy    => miitx_irdy,
		mii_trdy    => miitx_trdy,
		mii_data    => miitx_data,

		pyl_frm     => arptx_frm,
		pyl_irdy    => arptx_irdy,
		pyl_trdy    => arptx_trdy,
		pyl_data    => arptx_data,

		ethda_frm   => thatx_frm,
		ethda_irdy  => thatx_irdy,
		ethda_trdy  => thatx_trdy,
		ethda_data  => thatx_data,

		ethtyp_frm  => ethtyptx_frm,
		ethtyp_irdy => ethtyptx_irdy,
		ethtyp_trdy => ethtyptx_trdy,
		ethtyp_data => ethtyptx_data);

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
				if (not da_vld and bcstda_equ)='1' then
					da_vld := '1';
				end if;
				if (not typ_vld and ipv4typ_equ)='1' then
					typ_vld := '1';
				end if;
			end if;
			ipv4rx_frm  <= ethpyl_frm and da_vld and typ_vld;
			ipv4rx_data <= miirx_data;
		end if;
	end process;

	ipv4rx_i : entity hdl4fpga.ipv4_decode
	port map (
		mii_clk   => miirx_clk,
		ipv4_frm  => ipv4rx_frm,
		ipv4_irdy => ipv4rx_irdy,
		ipv4_data => ipv4rx_data,
		da_frm    => ipv4da_frm);
	tp(1) <= arptpa_frm or arptha_frm;
	tp(2 to 2+miirx_data'length-1) <= ipv4rx_data;
end;
