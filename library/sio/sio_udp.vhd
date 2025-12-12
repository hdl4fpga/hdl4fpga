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
	signal udppylrx_data : std_logic_vector(miirx_data'range);

	signal pylrx_frm     : std_logic;
	signal pylrx_irdy    : std_logic;
	signal pylrx_trdy    : std_logic;
	signal pylrx_data    : std_logic_vector(miirx_data'range);

	signal udppyltx_frm  : std_logic;
	signal udppyltx_irdy : std_logic;
	signal udppyltx_trdy : std_ulogic;
	signal udppyltx_data : std_logic_vector(miitx_data'range);

	signal fcs_sb        : std_logic;
	signal fcs_vld       : std_logic;
	signal pylfcs_sb     : std_logic;
	signal pylfcs_vld    : std_logic;

begin

	miiipoe_i : entity hdl4fpga.mii_ipoe
	generic map (
		hwaddr        => hwaddr,
		ipv4addr      => ipv4addr)
	port map (
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
		miitx_data    => miitx_data);

	process (udppylrx_frm, udppylrx_irdy, miirx_clk)
		constant prefix   : unsigned := x"00" & to_unsigned(summation(hdo(frames)**".format.pyl")/8-1,8);
		variable shr_frm  : unsigned(0 to prefix'length/miirx_data'length-1);
		variable shr_irdy : unsigned(shr_frm'range);
		variable shr_data : unsigned(prefix'range);
	begin
		if rising_edge(miirx_clk) then
			if (udppylrx_frm or udppylrx_irdy)='1' then
				shr_data(0 to udppylrx_data'length-1) := unsigned(udppylrx_data);
				shr_data := rotate_left(shr_data, udppylrx_data'length);
			elsif (pylrx_frm or pylrx_irdy)='1' then
				shr_data(0 to udppylrx_data'length-1) := unsigned(udppylrx_data);
				shr_data := rotate_left(shr_data, udppylrx_data'length);
			else
				shr_data := reverse(prefix, 8);
			end if;
			shr_frm(0)  := udppylrx_frm;
			shr_irdy(0) := udppylrx_irdy;
			shr_frm     := rotate_left(shr_frm,  1);
			shr_irdy    := rotate_left(shr_irdy, 1);
		end if;
		pylrx_frm  <= udppylrx_frm  or shr_frm(0);
		pylrx_irdy <= udppylrx_irdy or shr_irdy(0);
		pylrx_data <= std_logic_vector(shr_data(0 to udppylrx_data'length-1));
	end process;

	process (miirx_clk)
		variable vld : std_logic;
		variable sb  : std_logic;
	begin
		if rising_edge(miirx_clk) then
			if pylrx_frm='1' then
				if fcs_sb='1' then
					vld := fcs_vld;
					-- vld := '1';
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
		tx_frm  => udppyltx_frm,
		tx_irdy => udppyltx_irdy,
		tx_trdy => udppyltx_trdy,
		tx_data => udppyltx_data);
end;
