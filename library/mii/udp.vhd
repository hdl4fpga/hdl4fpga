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

entity udp is
	generic (
		hwaddr     : std_logic_vector(0 to 48-1));
	port (
		tp : out std_logic_vector(1 to 32);

		dhcpcd_req : in  std_logic := '0';
		dhcpcd_rdy : buffer std_logic := '0';

		arp_req    : buffer std_logic := '0';
		arp_rdy    : in  std_logic := '0';

		upspa_frm  : out std_logic;
		upspa_irdy : out std_logic;
		upspa_trdy : in  std_logic := '1';
		upspa_data : out std_logic_vector;

		miirx_clk  : in  std_logic;

		sharx_frm  : in  std_logic;
		sharx_irdy : in  std_logic;
		sharx_trdy : buffer std_logic := '1';
		
		sparx_frm  : in  std_logic;
		sparx_irdy : in  std_logic;
		sparx_trdy : buffer std_logic := '1';

		udprx_frm  : in  std_logic := '0';
		udprx_irdy : in  std_logic := '0';
		udprx_trdy : out std_logic := '0';
		udprx_data : in  std_logic_vector;

		pylrx_frm  : buffer std_logic := '0';
		pylrx_irdy : buffer std_logic := '0';
		pylrx_trdy : in  std_logic := '1';
		pylrx_data : out std_logic_vector;

		miitx_clk  : in  std_logic;

		pyltx_frm  : in  std_logic := '0';
		pyltx_irdy : in  std_logic := '0';
		pyltx_trdy : out std_logic := '1';
		pyltx_data : in  std_logic_vector;

		udptx_frm  : buffer std_logic := '0';
		udptx_irdy : buffer std_logic := '0';
		udptx_trdy : in  std_logic := '0';
		udptx_data : buffer std_logic_vector);
end;

architecture def of udp is
	signal dhcpcdrx_frm  : std_logic;
	alias  dhcpcdrx_irdy is dhcpcdrx_frm;
	signal dhcpcdrx_trdy : std_logic;
	signal dhcpcdrx_data : std_logic_vector(udprx_data'range);

	signal udptx_frms  : std_logic_vector(0 to 2-1);
	signal udptx_irdys : std_logic_vector(0 to 2-1);
	signal udptx_trdys : std_logic_vector(0 to 2-1) := (others => '1');

	alias  dhcpcdtx_frm  is udptx_frms(1);
	alias  dhcpcdtx_irdy is udptx_irdys(1);
	alias  dhcpcdtx_trdy is udptx_trdys(1);
	signal dhcpcdtx_data : std_logic_vector(udptx_data'range);

begin

	rx_b : block
		constant udprx_frame : string := compact('{' &
			    "sp:" & string'(hdo(frames)**".format.udp.sp")     & ',' &
			    "dp:" & string'(hdo(frames)**".format.udp.dp")     & ',' &
			"length:" & string'(hdo(frames)**".format.udp.length") & ',' &
			"chksum:" & string'(hdo(frames)**".format.udp.chksum") & '}');

		signal udprx_acts  : std_logic_vector(0 to length(udprx_frame));
		signal udprx_frms  : std_logic_vector(udprx_acts'range);
		signal udprx_irdys : std_logic_vector(udprx_acts'range);
		signal udprx_trdys : std_logic_vector(udprx_acts'range);

		alias sp_act   is udprx_acts(0);
		alias dp_act   is udprx_acts(1);
		alias pyl_act  is udprx_acts(4);

		alias sp_frm   is udprx_frms(0);
		alias dp_frm   is udprx_frms(1);
		alias pyl_frm  is udprx_frms(4);

		alias sp_irdy  is udprx_irdys(0);
		alias dp_irdy  is udprx_irdys(1);
		alias pyl_irdy is udprx_irdys(4);

		signal mode    : std_logic_vector(0 to 2-1) := "00";
		signal rx_frm  : std_logic;
		signal rx_irdy : std_logic;
		signal rx_trdy : std_logic;
		signal rx_data : std_logic_vector(udprx_data'range);

	begin

		udprx_i : entity hdl4fpga.frame_decode
		generic map (
			frame => udprx_frame,
			size  => udprx_data'length)
		port map (
			clk   => miirx_clk,
			frm   => udprx_frm,
			irdy  => udprx_irdy,
			acts  => udprx_acts,
			frms  => udprx_frms,
			irdys => udprx_irdys,
			trdys => udprx_trdys);
		udprx_trdys <= (others => rx_trdy);

		process (miirx_clk)
			variable shr_data : unsigned(0 to rx_data'length-1);
			variable shr_frm  : unsigned(0 to shr_data'length/rx_data'length-1);
			variable shr_irdy : unsigned(0 to shr_data'length/rx_data'length-1);
		begin
			if rising_edge(miirx_clk) then
				rx_data     <= std_logic_vector(shr_data(rx_data'range));
				rx_frm      <= shr_frm(0);
				rx_irdy     <= shr_irdy(0);
				shr_frm(0)  := udprx_frm;
				shr_irdy(0) := sharx_irdy or sparx_irdy or sp_irdy or dp_irdy or pyl_irdy;
				shr_data    := unsigned(udprx_data);
				shr_frm     := rotate_left(shr_frm, 1);
				shr_irdy    := rotate_left(shr_irdy, 1);
				shr_data    := rotate_left(shr_data, rx_data'length);
			end if;
		end process;

		process (miirx_clk)
			type states is (s_flush, s_queue);
			variable state : states;
			variable sy_irdy : std_logic;
		begin
			if rising_edge(miirx_clk) then
				if udprx_frm='1' then
					mode <= "10"; -- fifo commit
				elsif sy_irdy='0' then
					case state is
					when s_flush =>
						if sharx_frm='1' then
							mode  <= "00"; -- fifo flush
							state := s_queue;
						end if;
					when s_queue =>
						mode <= "11"; -- fifo queue
						if sharx_frm='0' then
							state := s_flush;
						end if;
					end case;
				end if;
				sy_irdy := pyltx_irdy;
			end if;
		end process;

		buffer_i : entity hdl4fpga.fifo
		generic map(
			latency   => 1,
			check_sov => true,
			check_dov => true,
			max_depth => 1024)
		port map (
			mode      => mode,
			src_clk   => miirx_clk,
			src_irdy  => rx_irdy,
			src_trdy  => rx_trdy,
			src_data  => rx_data,
			dst_clk   => miitx_clk,
			dst_irdy  => pylrx_irdy,
			dst_trdy  => pylrx_trdy,
			dst_data  => pylrx_data);
		pylrx_frm <= pylrx_irdy;

		dhcpcd_b : block
			signal dhcpcd_equ : std_logic;
		begin
			sp_i : entity hdl4fpga.mii_cmp
			generic map (
				bitdata => reverse(hdo(frames)**".data.dhcp.offer.sp",8))
			port map (
				mii_clk => miirx_clk,
				frm     => sp_frm,
				irdy    => sp_irdy,
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

	tx_b : block
		constant udphdr_size   : natural := hdo(frames)**".format.udp.length"; -- latticesemi : Unable to evaluate expression type
		constant udphdr_length : natural := summation(hdo(frames)**".format.udp")/8; -- latticesemi : Unable to evaluate expression type
		constant udphdr_value : std_logic_vector := std_logic_vector(to_unsigned(udphdr_length, udphdr_size));
		alias  udppyltx_frm  is udptx_frms(0);
		alias  udppyltx_irdy is udptx_irdys(0);
		alias  udppyltx_trdy is udptx_trdys(0);
		signal udppyltx_data : std_logic_vector(udptx_data'range);

		signal gntd  : std_logic_vector(0 to 2-1);

		constant ports_length : natural :=  -- Lattice Semi error
			hdo(frames)**".format.udp.sp" + -- Lattice Semi error
			hdo(frames)**".format.udp.dp"; -- Lattice Semi error
		constant ports_value : string := natural'image(ports_length); -- Lattice Semi error
		constant udp_frame : string := compact('{' &
				"   tha:" & string'(hdo(frames)**".format.mac.hwda")    & ',' &
				"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"adjlen:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"    da:" & string'(hdo(frames)**".format.ipv4.da")     & ',' &
				" ports:" & ports_value                                 & ',' & -- Lattice Semi error
				"udplen:" & string'(hdo(frames)**".format.udp.length")  & ',' &
				"chksum:" & string'(hdo(frames)**".format.udp.chksum")  & '}');
		signal udp_act : std_logic_vector(0 to 7);

		alias tha_act    is udp_act(0);
		alias length_act is udp_act(1);
		alias adjlen_act is udp_act(2);
		alias da_act     is udp_act(3);
		alias ports_act  is udp_act(4);
		alias lentx_act  is udp_act(5);
		alias chksum_act is udp_act(6);
		alias pyl_act    is udp_act(7);

		signal adjlen_irdy : std_logic;
		signal adjlen_trdy : std_logic;
		signal si_data     : std_logic_vector(udptx_data'range);
		signal adjlen_data : std_logic_vector(udptx_data'range);
		signal decode_irdy : std_logic;

	begin

		udppyltx_frm  <= pyltx_frm;
		udppyltx_irdy <= pyltx_irdy when length_act='0' else '0';
		pyltx_trdy    <= 
			'1'   when length_act='1' else
			'0'   when adjlen_act='1' else
			'0'   when chksum_act='1' else
			'0'   when  lentx_act='1' else
			udppyltx_trdy;

		arbiter_i : entity hdl4fpga.mii_arbiter
		port map (
			clk   => miitx_clk,
			gntd  => gntd,
			frms  => udptx_frms,
			irdys => udptx_irdys,
			trdys => udptx_trdys,
			frm   => udptx_frm,
			irdy  => udptx_irdy,
			trdy  => udptx_trdy);

		udptx_data <= 
			udppyltx_data when gntd(0)='1' else
			dhcpcdtx_data when gntd(1)='1' else
			(udptx_data'range => '-');

		decode_irdy <= 
			pyltx_irdy when length_act='1' else 
			pyltx_irdy and udppyltx_trdy;

		udp_i : entity hdl4fpga.frame_decode
		generic map (
			frame => udp_frame,
			size  => udprx_data'length)
		port map (
			clk  => miitx_clk,
			frm  => udppyltx_frm,
			irdy => decode_irdy,
			acts => udp_act);

		adjlen_irdy <= length_act or adjlen_act or lentx_act;
		si_data <= 
			pyltx_data when length_act='1' else
			(udptx_data'range => '0');

		miiadjlen_i : entity hdl4fpga.mii_adjlen
		port map (
			clk     => miitx_clk,
			init    => udphdr_value,
			frm     => pyltx_frm,
			irdy    => adjlen_irdy,
			si_data => si_data,
			so_data => adjlen_data);

		udppyltx_data <= 
			adjlen_data               when adjlen_act='1' else
			adjlen_data               when  lentx_act='1' else
			(udptx_data'range => '0') when chksum_act='1' else
			pyltx_data;

	end block;

	dhcpcd_i : entity hdl4fpga.dhcpcd
	generic map (
		hwaddr        => hwaddr)
	port map (
--		tp => tp,
		dhcpcd_req    => dhcpcd_req,
		dhcpcd_rdy    => dhcpcd_rdy,

		arp_req       => arp_req,
		arp_rdy       => arp_rdy,

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

		dhcpcdtx_frm  => dhcpcdtx_frm,
		dhcpcdtx_irdy => dhcpcdtx_irdy,
		dhcpcdtx_trdy => dhcpcdtx_trdy,
		dhcpcdtx_data => dhcpcdtx_data);

end;
