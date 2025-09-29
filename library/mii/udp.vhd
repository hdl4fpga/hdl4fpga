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

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.ipoepkg.all;

entity udp is
	generic (
		hwaddr        : std_logic_vector(0 to 48-1));
	port (
		tp : out std_logic_vector(1 to 32);

		dhcpcd_req  : in  std_logic := '0';
		dhcpcd_rdy  : buffer std_logic := '0';

		upspa_frm     : out std_logic;
		upspa_irdy    : out std_logic;
		upspa_trdy    : in  std_logic := '1';
		upspa_data    : out std_logic_vector;

		miirx_clk   : in  std_logic;

		-- tharx_frm   : in  std_logic;
		-- tharx_irdy  : in  std_logic;
		-- tharx_trdy  : buffer std_logic := '1';
		--
		-- tparx_frm   : in  std_logic;
		-- tparx_irdy  : in  std_logic;
		-- tparx_trdy  : buffer std_logic := '1';

		udprx_frm  : in  std_logic := '0';
		udprx_irdy : in  std_logic := '0';
		udprx_trdy : out std_logic := '0';
		udprx_data : in  std_logic_vector;

		-- pylrx_frm   : buffer std_logic;
		-- pylrx_irdy  : out std_logic;
		-- pylrx_trdy  : in  std_logic := '1';
		-- pylrx_data  : out std_logic_vector;

		miitx_clk     : in  std_logic;

		thatx_frm     : in  std_logic;
		thatx_irdy    : in  std_logic;
		thatx_trdy    : out std_logic := '1';
		thatx_data    : out std_logic_vector;

		tpatx_frm     : in  std_logic;
		tpatx_irdy    : in  std_logic;
		tpatx_trdy    : out std_logic := '1';

		lentx_frm  : in std_logic;
		lentx_irdy : in std_logic;
		lentx_trdy : out std_logic := '1';

		udptx_frm     : buffer std_logic := '0';
		udptx_irdy    : buffer std_logic := '0';
		udptx_trdy    : in  std_logic := '0';
		udptx_data    : buffer std_logic_vector);
end;

architecture def of udp is
	signal dhcpcdrx_frm  : std_logic;
	signal dhcpcdrx_irdy : std_logic;
	signal dhcpcdrx_trdy : std_logic;
	signal dhcpcdrx_data : std_logic_vector(udprx_data'range);

	signal dhcpcdlentx_frm  : std_logic;
	signal dhcpcdlentx_irdy : std_logic;
	signal dhcpcdlentx_trdy : std_logic;

	signal dhcpcdtpatx_frm  : std_logic;
	signal dhcpcdtpatx_irdy : std_logic;
	signal dhcpcdtpatx_trdy : std_logic;

	signal dhcpcdtx_frm  : std_logic;
	signal dhcpcdtx_irdy : std_logic;
	signal dhcpcdtx_trdy : std_logic;
	signal dhcpcdtx_data : std_logic_vector(udptx_data'range);
begin

	rx_b : block
		signal sp_act : std_logic;
		signal dp_frm : std_logic;
		signal length_frm : std_logic;
		signal chksum_frm : std_logic;
		signal pyl_frm : std_logic;
	begin
		udp_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{' &
				"    sp:" & string'(hdo(frames)**".format.udp.sp")      & ',' &
				"    dp:" & string'(hdo(frames)**".format.udp.dp")      & ',' &
				"length:" & string'(hdo(frames)**".format.udp.length")  & ',' &
				"chksum:" & string'(hdo(frames)**".format.ipv4.chksum") & '}'),
			size  => udprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => udprx_frm,
			irdy   => udprx_irdy,
			act(0) => sp_act,
			act(1) => dp_frm,
			act(2) => length_frm,
			act(3) => chksum_frm,
			act(4) => pyl_frm);
		-- pylrx_frm  <= tharx_frm or tparx_frm or meta_frm or chksum_frm;
		-- pylrx_irdy <= pylrx_frm;
		dhcpcd_b : block
			signal dhcpcd_equ : std_logic;
		begin
			sp_i : entity hdl4fpga.mii_cmp
			generic map (
				bitdata => reverse(hdo(frames)**".data.dhcp.offer.sp",8))
			port map (
				mii_clk => miirx_clk,
				frm     => sp_act,
				irdy    => sp_act,
				trdy    => open,
				data    => udprx_data,
				equ     => dhcpcd_equ);

			sp_p : process (pyl_frm, miirx_clk)
				variable sp_vld : std_logic := '0';
			begin
				if rising_edge(miirx_clk) then
					if (udprx_frm or udprx_irdy)='0' then
						sp_vld := '0';
					elsif (not sp_vld and dhcpcd_equ)='1' then
						sp_vld := '1';
					end if;
				end if;
				dhcpcdrx_frm <= pyl_frm and sp_vld;
			end process;

			dhcpcdrx_data <= udprx_data;

		end block;

	end block;

	dhcpcd_i : entity hdl4fpga.dhcpcd
	generic map (
		hwaddr        => hwaddr)
	port map (
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		upspa_frm     => upspa_frm,
		upspa_irdy    => upspa_irdy,
		upspa_trdy    => upspa_trdy,
		upspa_data    => upspa_data,

		miirx_clk     => miirx_clk,
		dhcpcdrx_frm  => dhcpcdrx_frm,
		dhcpcdrx_irdy => dhcpcdrx_irdy,
		dhcpcdrx_trdy => dhcpcdrx_trdy,
		dhcpcdrx_data => dhcpcdrx_data,

		miitx_clk     => miitx_clk,
		thatx_frm     => thatx_frm,
		thatx_irdy    => thatx_irdy,
		thatx_trdy    => thatx_trdy,
		thatx_data    => thatx_data,

		lentx_frm     => dhcpcdlentx_frm,
		lentx_irdy    => dhcpcdlentx_irdy,
		lentx_trdy    => dhcpcdlentx_trdy,

		tpatx_frm     => dhcpcdtpatx_frm,
		tpatx_irdy    => dhcpcdtpatx_irdy,
		tpatx_trdy    => dhcpcdtpatx_trdy,

		dhcpcdtx_frm  => dhcpcdtx_frm,
		dhcpcdtx_irdy => dhcpcdtx_irdy,
		dhcpcdtx_trdy => dhcpcdtx_trdy,
		dhcpcdtx_data => dhcpcdtx_data);

		dhcpcdlentx_frm  <= lentx_frm;
		dhcpcdlentx_irdy <= lentx_irdy;
		lentx_trdy       <= dhcpcdlentx_trdy;

		dhcpcdtpatx_frm  <= tpatx_frm;
		dhcpcdtpatx_irdy <= tpatx_irdy;
		tpatx_trdy    <= dhcpcdtpatx_trdy;

		udptx_frm        <= dhcpcdtx_frm;
		udptx_irdy       <= dhcpcdtx_irdy;
		dhcpcdtx_trdy    <= udptx_trdy ;
		udptx_data       <= dhcpcdtx_data;
end;
