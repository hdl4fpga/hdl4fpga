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
		hwaddr        : std_logic_vector(0 to 48-1);
		ipv4addr      : std_logic_vector(0 to 32-1));
	port (
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : buffer std_logic := '0';

		miirx_clk     : in  std_logic;
		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic;
		miirx_trdy    : out std_logic;
		miirx_data    : in  std_logic_vector;

		miitx_clk     : in  std_logic;
		miitx_frm     : buffer std_logic;
		miitx_irdy    : buffer std_logic;
		miitx_trdy    : in  std_logic;
		miitx_data    : out std_logic_vector;

		so_clk        : in  std_logic;
		so_frm        : out std_logic;
		so_irdy       : buffer std_logic;
		so_trdy       : in  std_logic := '1';
		so_data       : out std_logic_vector;

		si_frm        : in  std_logic;
		si_irdy       : in  std_logic;
		si_trdy       : out std_logic;
		si_data       : in  std_logic_vector;

		tp            : out std_logic_vector(1 to 32));
end;

architecture struct of sio_udp is

	signal udppylrx_frm  : std_logic;
	signal udppylrx_irdy : std_logic;
	signal udppylrx_trdy : std_logic;
	signal udppylrx_data : std_logic_vector(miirx_data'range);

	signal udppyltx_frm  : std_logic;
	signal udppyltx_irdy : std_logic;
	signal udppyltx_trdy : std_ulogic;
	signal udppyltx_data : std_logic_vector(miitx_data'range);

begin

	miiipoe_i : entity hdl4fpga.mii_ipoe
	generic map (
		hwaddr     => hwaddr,
		ipv4addr   => ipv4addr)
	port map (
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		miirx_clk     => miirx_clk,
		miirx_frm     => miirx_frm,
		miirx_irdy    => miirx_irdy,
		miirx_data    => miirx_data,

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

	-- decode_i : entity hdl4fpga.frame_decode
	-- generic map (
	-- 	frame => compact('{'                                                &
	-- 		"pylhdr:" & natural'image(summation(hdo(frames)**".format.pyl")) & '}'),
	-- 	size  => miirx_data'length)
	-- port map (
	-- 	clk    => miirx_clk,
	-- 	frm    => udppylrx_frm,
	-- 	irdy   => udppylrx_irdy,
	-- 	act(0) => header_act,
	-- 	act(1) => pyl_act);

	process (miirx_clk)
		constant pfx : unsigned := x"00" & to_unsigned(summation(hdo(frames)**".format.pyl"),8);
		variable shr : unsigned(pfx'range);
	begin
		if rising_edge(miirx_clk) then
			if (udppylrx_frm or udppylrx_irdy)='1' then
				shr(0 to udppylrx_data'length-1) := unsigned(udppylrx_data);
				shr := rotate_left(shr, udppylrx_data'length);
			else
				shr := reverse(pfx, 8);
			end if;
		end if;
		udppylrx_data <= std_logic_vector(shr(0 to udppylrx_data'length-1));
	end process;

	sio_flow_b : block
		signal tx_frm  : std_logic;
		signal tx_irdy : std_logic;
		signal tx_trdy : std_logic;
		signal tx_end  : std_logic;
		signal tx_data : std_logic_vector(pltx_data'range);
	begin
		sio_flow_e : entity hdl4fpga.sio_flow
		port map (
			-- tp => tp,
			rx_clk  => so_clk,
			rx_frm  => plrx_frm,
			rx_irdy => plrx_irdy,
			rx_trdy => plrx_trdy,
			rx_end  => plrx_end,
			rx_data => plrx_data,
	
			so_clk  => so_clk,
			so_frm  => so_frm,
			so_irdy => so_irdy,
			so_trdy => so_trdy,
			so_data => so_data,
	
			si_frm  => si_frm,
			si_irdy => si_irdy,
			si_trdy => si_trdy,
			si_end  => si_end,
			si_data => si_data,
	
			tx_clk  => mii_clk,
			tx_frm  => tx_frm,
			tx_irdy => tx_irdy,
			tx_trdy => tx_trdy,
			tx_end  => tx_end,
			tx_data => tx_data);

		miibuffer_e : entity hdl4fpga.mii_buffer
		port map(
			io_clk => mii_clk,
			i_frm  => tx_frm,
			i_irdy => tx_irdy,
			i_trdy => tx_trdy,
			i_data => tx_data,
			i_end  => tx_end,
			o_frm  => pltx_frm,
			o_irdy => pltx_irdy,
			o_trdy => pltx_trdy,
			o_data => pltx_data,
			o_end  => pltx_end);

	end block;

end;
