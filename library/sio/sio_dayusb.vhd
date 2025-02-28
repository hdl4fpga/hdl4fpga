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

entity sio_dayusb is
	generic (
		usb_oversampling : natural := 0;
		usb_watermark    : natural := 0;
		mem_size    : natural := 4*(2048*8));
	port (
		usb_clk     : in  std_logic;
		usb_cken    : buffer std_logic;
		usb_dp      : inout std_logic;
		usb_dn      : inout std_logic;

		sio_clk     : in std_logic;
		sio_addr    : in  std_logic := '0';

		si_frm      : in  std_logic := '0';
		si_irdy     : in  std_logic := '1';
		si_trdy     : out std_logic;
		si_end      : in  std_logic;
		si_data     : in  std_logic_vector;

		so_frm      : out std_logic;
		so_irdy     : out std_logic;
		so_trdy     : in  std_logic := '1';
		so_data     : out std_logic_vector;
		tp          : buffer std_logic_vector(1 to 32));

end;

architecture beh of sio_dayusb is

	signal usb_txen    : std_logic;
	signal usb_txbs    : std_logic;
	signal usb_txd     : std_logic_vector(0 to 0);

	signal usb_rxdv    : std_logic;
	signal usb_rxbs    : std_logic;
	signal usb_rxd     : std_logic_vector(0 to 0);

	signal usbrx_irdy  : std_logic;
	signal usbrx_data  : std_logic_vector(so_data'range);

	signal usbtx_frm   : std_logic;
	signal usbtx_irdy  : std_logic;
	signal usbtx_trdy  : std_logic;
	signal usbtx_data  : std_logic_vector(so_data'range);

	signal sihdlc_frm  : std_logic;
	signal sihdlc_trdy : std_logic;
	signal sihdlc_irdy : std_logic;
	signal sihdlc_end  : std_logic;
	signal sihdlc_data : std_logic_vector(so_data'range);

	signal sohdlc_frm  : std_logic;
	signal sohdlc_trdy : std_logic;
	signal sohdlc_irdy : std_logic;
	signal sohdlc_data : std_logic_vector(so_data'range);

	signal tp_usb : std_logic_vector(1 to 32);
	signal src_irdy : std_logic;
	signal dst_trdy : std_logic;
begin

	usb_rxbs <= '0';
	usbdev_e : entity hdl4fpga.usbdev
	generic map (
		oversampling => usb_oversampling)
	port map (
		tp   => tp_usb,
		dp   => usb_dp,
		dn   => usb_dn,
		clk  => usb_clk,
		cken => usb_cken,
		txen => usb_txen, 
		txbs => usb_txbs,
		txd  => usb_txd(0),

		rxdv => usb_rxdv, 
		rxbs => usb_rxbs,
		rxd  => usb_rxd(0));
			
	rxserlzr_b : block
	begin
		src_irdy <= usb_rxdv and usb_cken and not usb_rxbs;
		serlzr_e : entity hdl4fpga.serlzr
		port map (
			src_clk  => usb_clk,
			src_frm  => usb_rxdv,
			src_data => usb_rxd,
			src_irdy => src_irdy,
			dst_clk  => usb_clk,
			dst_irdy => usbrx_irdy,
			dst_data => usbrx_data);
	end block;

	sihdlc_frm  <= si_frm  when sio_addr='0' else '0';
	sihdlc_irdy <= si_irdy when sio_addr='0' else '0';
	si_trdy     <= sihdlc_trdy when sio_addr='0' else so_trdy;
	sihdlc_end  <= si_end  when sio_addr='0' else '0';
	sihdlc_data <= si_data;

	siohdlc_e : entity hdl4fpga.sio_hdlc
	generic map (
		mem_size    => mem_size)
	port map (
		uart_clk    => usb_clk,

		uartrx_irdy => usbrx_irdy,
		uartrx_data => usbrx_data,

		uarttx_frm  => usbtx_frm,
		uarttx_irdy => usbtx_irdy,
		uarttx_trdy => usbtx_trdy,
		uarttx_data => usbtx_data,

		sio_clk   => sio_clk,
		si_frm    => sihdlc_frm,
		si_irdy   => sihdlc_irdy,
		si_trdy   => sihdlc_trdy,
		si_end    => sihdlc_end,
		si_data   => sihdlc_data,

		so_frm    => sohdlc_frm,
		so_irdy   => sohdlc_irdy,
		so_trdy   => sohdlc_trdy,
		so_data   => sohdlc_data,
		tp => open);

	txserlzr_b : block
		signal dst_frm : std_logic;
		signal src_irdy : std_logic;
		signal src_data : std_logic_vector(usbtx_data'range);
	begin
		dst_trdy <= usb_cken and not usb_txbs;
		process (usbtx_frm, usb_clk)
			variable q : std_logic := '0';
		begin
			if rising_edge(usb_clk) then
				if usbtx_frm='1' then
					q := '1';
				elsif usbtx_trdy='1' then
					q := '0';
				end if;
			end if;
			dst_frm <= usbtx_frm or q;
		end process;

		process (usbtx_irdy, usb_clk)
			variable q : std_logic;
		begin
			if rising_edge(usb_clk) then
				if usbtx_irdy='1' then
					q := '1';
				elsif usbtx_trdy='1' then
					q := '0';
				end if;
			end if;
			src_irdy <= usbtx_irdy or q;
		end process;

		src_data <= reverse(usbtx_data);
		serlzr_e : entity hdl4fpga.serlzr
		port map (
			src_clk  => usb_clk,
			src_frm  => usbtx_frm,
			src_irdy => src_irdy,
			src_trdy => usbtx_trdy,
			src_data => src_data,
			dst_clk  => usb_clk,
			dst_frm  => dst_frm,
			dst_irdy => usb_txen,
			dst_trdy => dst_trdy,
			dst_data => usb_txd);
	end block;

	tp(1 to 3) <= tp_usb(1 to 3);
	-- tp(1 to 3) <= (usbtx_frm, usb_txen and usb_cken,  usb_txd(0));
	tp(4)      <= usbtx_irdy and usbtx_trdy; --usbrx_irdy;
	tp(5 to 12) <= usbtx_data; -- usbrx_data;

	process (usb_clk)
		variable q : std_logic;
		variable e : std_logic;
	begin
		if rising_edge(usb_clk) then
			if e='0' and usb_rxdv='1' then
				q := not q;
			end if;
			-- tp(4) <= q;
			e := usbrx_irdy;
		end if;
	end process;

	so_frm  <= si_frm  when sio_addr/='0' else sohdlc_frm;
	so_irdy <= si_irdy when sio_addr/='0' else sohdlc_irdy;
	sohdlc_trdy <= si_irdy when sio_addr/='0' else so_trdy;
	so_data <= si_data when sio_addr/='0' else sohdlc_data;

end;



