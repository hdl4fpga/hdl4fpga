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

entity sio_udp is
	generic (
		latency    : natural := 0;
		ipv4addr   : std_logic_vector(0 to 32-1) := aton("192.168.0.14");
		hwaddr     : std_logic_vector := x"00_40_00_01_02_03");
	port (
		dhcpcd_req : in  std_logic := '0';
		dhcpcd_rdy : buffer std_logic := '0';

		miirx_clk  : in  std_logic;
		miirx_frm  : in  std_logic;
		miirx_irdy : in  std_logic;
		miirx_trdy : out std_logic := '1';
		miirx_data : in  std_logic_vector;
		fcs_sb     : buffer std_logic;
		fcs_vld    : buffer std_logic;

		miitx_clk  : in  std_logic;
		miitx_frm  : buffer std_logic;
		miitx_irdy : buffer std_logic;
		miitx_trdy : in  std_logic := '1';
		miitx_data : out std_logic_vector;

		so_clk     : in  std_logic;
		so_frm     : out std_logic;
		so_irdy    : buffer std_logic;
		so_trdy    : in  std_logic := '1';
		so_data    : out std_logic_vector;

		si_clk     : in  std_logic;
		si_frm     : in  std_logic;
		si_irdy    : in  std_logic;
		si_trdy    : out std_logic;
		si_data    : in  std_logic_vector;

		tp         : out std_logic_vector(1 to 32));
end;

architecture struct of sio_udp is

	signal udppylrx_frm  : std_logic;
	signal udppylrx_irdy : std_logic;
	signal udppylrx_trdy : std_logic := '1';
	signal udppylrx_data : std_logic_vector(miitx_data'range);

	signal srzrx_frm     : std_logic;
	signal srzrx_irdy    : std_logic;
	signal srzrx_trdy    : std_logic;
	signal srzrx_data    : std_logic_vector(so_data'range);

	signal pylrx_frm     : std_logic;
	signal pylrx_irdy    : std_logic;
	signal pylrx_trdy    : std_logic;
	signal pylrx_data    : std_logic_vector(so_data'range);

	signal srztx_frm     : std_logic;
	signal srztx_irdy    : std_logic;
	signal srztx_trdy    : std_logic;
	signal srztx_data    : std_logic_vector(si_data'range);

	signal udppyltx_frm  : std_logic;
	signal udppyltx_irdy : std_logic;
	signal udppyltx_trdy : std_ulogic;
	signal udppyltx_data : std_logic_vector(miitx_data'range);

	signal pylfcs_sb     : std_logic;
	signal pylfcs_vld    : std_logic;

begin

	miiipoe_i : entity hdl4fpga.mii_ipoe
	generic map (
		hwaddr        => hwaddr,
		ipv4addr      => ipv4addr)
	port map (
		tp => tp,
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		miirx_clk     => miirx_clk,
		miirx_frm     => miirx_frm,
		miirx_irdy    => miirx_irdy,
		miirx_data    => miirx_data,
		fcs_sb        => fcs_sb,
		fcs_vld       => fcs_vld,

		udppylrx_frm  => udppylrx_frm,
		udppylrx_irdy => udppylrx_irdy,
		udppylrx_trdy => udppylrx_trdy,
		udppylrx_data => udppylrx_data,

		udppyltx_frm  => udppyltx_frm,
		udppyltx_irdy => udppyltx_irdy,
		udppyltx_trdy => udppyltx_trdy,
		udppyltx_data => udppyltx_data,

		miitx_clk     => miitx_clk,
		miitx_frm     => miitx_frm,
		miitx_irdy    => miitx_irdy,
		miitx_trdy    => miitx_trdy,
		miitx_data    => miitx_data);

	rxserlzr_e : entity hdl4fpga.serlzr
	generic map (
		lsdfirst => false)
	port map (
		src_clk  => miirx_clk,
		src_frm  => udppylrx_frm,
		src_irdy => udppylrx_irdy,
		src_trdy => udppylrx_trdy,
		src_data => udppylrx_data,
		dst_clk  => so_clk,
		dst_frm  => srzrx_frm,
		dst_irdy => srzrx_irdy,
		dst_trdy => srzrx_trdy,
		dst_data => srzrx_data);

	rxpack_e : entity hdl4fpga.sio_pack
	port map (
		sio_clk => so_clk,
		si_frm  => srztx_frm,
		si_rid  => x"00",
		si_len  => std_logic_vector(to_unsigned(summation(hdo(frames)**".format.pyl")/8-1,8)),
		si_irdy => srzrx_irdy,
		si_trdy => srzrx_trdy,
		si_data => srzrx_data,

		so_frm  => pylrx_frm,
		so_irdy => pylrx_irdy,
		so_trdy => pylrx_irdy,
		so_data => pylrx_data);

	process (miirx_clk)
		variable vld : std_logic;
		variable sb  : std_logic;
	begin
		if rising_edge(miirx_clk) then
			if pylrx_frm='1' then
				if fcs_sb='1' then
					vld := fcs_vld;
					sb  := '1';
				end if;
			else
				pylfcs_vld <= vld;
				pylfcs_sb  <= sb;
				vld := '0';
				sb  := '0';
			end if;
		end if;
	end process;

	sio_flow_e : entity hdl4fpga.sio_flow
	port map (
		rx_clk  => miirx_clk,
		rx_frm  => pylrx_frm,
		rx_irdy => pylrx_irdy,
		rx_trdy => pylrx_trdy,
		rx_data => pylrx_data,
		fcs_sb	=> pylfcs_sb,
		fcs_vld => pylfcs_vld,

		so_clk  => so_clk,
		so_frm  => so_frm,
		so_irdy => so_irdy,
		so_trdy => so_trdy,
		so_data => so_data,

		si_clk  => si_clk,
		si_frm  => si_frm,
		si_irdy => si_irdy,
		si_trdy => si_trdy,
		si_data => si_data,

		tx_clk  => miitx_clk,
		tx_frm  => srztx_frm,
		tx_irdy => srztx_irdy,
		tx_trdy => srztx_trdy,
		tx_data => srztx_data);

	txserlzr_e : entity hdl4fpga.serlzr
	generic map (
		lsdfirst => false)
	port map (
		src_clk  => si_clk,
		src_frm  => srztx_frm,
		src_irdy => srztx_irdy,
		src_trdy => srztx_trdy,
		src_data => srztx_data,
		dst_clk  => miitx_clk,
		dst_frm  => udppyltx_frm,
		dst_irdy => udppyltx_irdy,
		dst_trdy => udppyltx_trdy,
		dst_data => udppyltx_data);

end;
