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

entity sio_dayudp is
	generic (
		debug      : boolean := false;
		ipv4addr   : std_logic_vector(0 to 32-1) := aton("192.168.0.14");
		hwaddr     : std_logic_vector := x"00_40_00_01_02_03");
	port (
		sio_addr   : in  std_logic := '0';

		dhcpcd_req : in  std_logic := '0';
		dhcpcd_rdy : out std_logic := '0';

		miirx_clk  : in  std_logic;
		miirx_frm  : in  std_logic;
		miirx_irdy : in  std_logic := '1';
		miirx_trdy : out std_logic;
		miirx_data : in  std_logic_vector;

		miitx_clk  : in  std_logic;
		miitx_frm  : buffer std_logic;
		miitx_irdy : buffer std_logic;
		miitx_trdy : in  std_logic := '1';
		miitx_data : out std_logic_vector;

		si_frm     : in  std_logic := '0';
		si_irdy    : in  std_logic := '0';
		si_trdy    : out std_logic := '0';
		si_data    : in  std_logic_vector;

		so_clk     : in  std_logic;
		so_frm     : out std_logic;
		so_irdy    : out std_logic;
		so_trdy    : in  std_logic := '1';
		so_data    : out std_logic_vector;

		tp         : out std_logic_vector(1 to 32));

end;

architecture beh of sio_dayudp is

	signal siudp_clk  : std_logic;
	signal siudp_frm  : std_logic;
	signal siudp_irdy : std_logic;
	signal siudp_trdy : std_logic;

	signal soudp_clk  : std_logic;
	signal soudp_frm  : std_logic;
	signal soudp_irdy : std_logic;
	signal soudp_trdy : std_logic;
	signal soudp_data : std_logic_vector(so_data'range);

	signal srzrx_frm  : std_logic;
	signal srzrx_irdy : std_logic;
	signal srzrx_trdy : std_logic;
	signal srzrx_data : std_logic_vector(so_data'range);

	signal srztx_frm  : std_logic;
	signal srztx_irdy : std_logic;
	signal srztx_trdy : std_logic;
	signal srztx_data : std_logic_vector(si_data'range);

begin

	siudp_frm  <= '0' when sio_addr/='0' else si_frm;
	siudp_irdy <= '0' when sio_addr/='0' else si_irdy;
	soudp_trdy <= '0' when sio_addr/='0' else so_trdy;

	rxserlzr_e : entity hdl4fpga.serlzr
	generic map (
		lsdfirst => false)
	port map (
		src_clk  => miirx_clk,
		src_frm  => miirx_frm,
		src_irdy => miirx_irdy,
		src_data => miirx_data,
		dst_clk  => miirx_clk,
		dst_irdy => srzrx_irdy,
		dst_data => srzrx_data);

	process(miirx_clk)
	begin
		if rising_edge(miirx_clk) then
			srzrx_frm <= miirx_frm;
		end if;
	end process;

	sio_udp_e : entity hdl4fpga.sio_udp
	generic map (
		ipv4addr   => ipv4addr,
		hwaddr     => hwaddr)
	port map (

		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,

		miirx_clk  => miirx_clk,
		miirx_frm  => srzrx_frm,
		miirx_irdy => srzrx_irdy,
		miirx_trdy => srzrx_trdy,
		miirx_data => srzrx_data,

		miitx_clk  => miirx_clk,
		miitx_frm  => srztx_frm,
		miitx_irdy => srztx_irdy,
		miitx_trdy => srztx_trdy,
		miitx_data => srztx_data,

		si_clk     => so_clk,
		si_frm     => siudp_frm,
		si_irdy    => siudp_irdy,
		si_trdy    => siudp_trdy,
		si_data    => si_data,

		so_clk     => so_clk,
		so_frm     => soudp_frm,
		so_irdy    => soudp_irdy,
		so_trdy    => soudp_trdy,
		so_data    => soudp_data,
		tp         => tp);

	txserlzr_e : entity hdl4fpga.serlzr
	port map (
		src_clk  => miirx_clk,
		src_frm  => srztx_frm,
		src_irdy => srztx_irdy,
		src_trdy => srztx_trdy,
		src_data => srztx_data,
		dst_clk  => miitx_clk,
		dst_irdy => miitx_irdy,
		dst_data => miitx_data);

	si_trdy <= so_trdy when sio_addr/='0' else siudp_trdy;
	so_frm  <= si_frm  when sio_addr/='0' else soudp_frm;
	so_irdy <= si_irdy when sio_addr/='0' else soudp_irdy;
	so_data <= si_data when sio_addr/='0' else soudp_data;

end;