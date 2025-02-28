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

entity sio_udp is
	generic (
		debug         : boolean := false;
		default_ipv4a : std_logic_vector(0 to 32-1);
		my_mac        : std_logic_vector(0 to 48-1));
	port (
		hdplx         : in  std_logic;
		mii_clk       : in  std_logic;
		dhcpcd_req    : in  std_logic := '0';
		dhcpcd_rdy    : out std_logic := '0';


		miirx_frm     : in  std_logic;
		miirx_irdy    : in  std_logic;
		miirx_trdy    : out std_logic;
		miirx_data    : in  std_logic_vector;

		miitx_frm     : buffer std_logic;
		miitx_irdy    : buffer std_logic;
		miitx_trdy    : in  std_logic;
		miitx_end     : buffer std_logic;
		miitx_data    : out std_logic_vector;

		so_clk        : in  std_logic;
		so_frm        : out std_logic;
		so_irdy       : buffer std_logic;
		so_trdy       : in  std_logic := '1';
		so_data       : out std_logic_vector;

		si_frm        : in  std_logic;
		si_irdy       : in  std_logic;
		si_trdy       : out std_logic;
		si_end        : in  std_logic := '0';
		si_data       : in  std_logic_vector;

		tp            : out std_logic_vector(1 to 32));
end;

architecture struct of sio_udp is

		signal plrx_frm   : std_logic;
		signal plrx_irdy  : std_logic;
		signal plrx_trdy  : std_logic;
		signal plrx_end   : std_logic;
		signal plrx_data  : std_logic_vector(so_data'range);

		signal pltx_frm   : std_logic;
		signal pltx_irdy  : std_logic;
		signal pltx_trdy  : std_ulogic;
		signal pltx_end   : std_logic;
		signal pltx_data  : std_logic_vector(si_data'range);

begin

	mii_ipoe_e : entity hdl4fpga.mii_ipoe
	generic map (
		default_ipv4a => default_ipv4a,
		my_mac        => my_mac)
	port map (
		tp         => tp,
		hdplx      => hdplx,
		mii_clk    => mii_clk,
		dhcpcd_req => dhcpcd_req,
		dhcpcd_rdy => dhcpcd_rdy,
		miirx_frm  => miirx_frm,
		miirx_irdy => miirx_irdy,
		miirx_trdy => miirx_trdy,
		miirx_data => miirx_data,

		plrx_clk   => so_clk,
		plrx_frm   => plrx_frm,
		plrx_irdy  => plrx_irdy,
		plrx_trdy  => plrx_trdy,
		plrx_end   => plrx_end,
		plrx_data  => plrx_data,

		pltx_frm   => pltx_frm,
		pltx_irdy  => pltx_irdy,
		pltx_trdy  => pltx_trdy,
		pltx_end   => pltx_end,
		pltx_data  => pltx_data,

		miitx_frm  => miitx_frm,
		miitx_irdy => miitx_irdy,
		miitx_trdy => miitx_trdy,
		miitx_end  => miitx_end,
		miitx_data => miitx_data);

	sio_flow_b : block
		signal tx_frm  : std_logic;
		signal tx_irdy : std_logic;
		signal tx_trdy : std_logic;
		signal tx_end  : std_logic;
		signal tx_data : std_logic_vector(pltx_data'range);
	begin
		sio_flow_e : entity hdl4fpga.sio_flow
		generic map (
			debug   => debug)
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



