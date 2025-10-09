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

		pylrx_frm  : buffer std_logic;
		pylrx_irdy : buffer std_logic;
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
		signal sp_act  : std_logic;
		signal dp_act  : std_logic;
		signal act2    : std_logic;
		signal act3    : std_logic;
		signal pyl_act : std_logic;
	begin

		udp_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{' &
				"    sp:" & string'(hdo(frames)**".format.udp.sp")     & ',' &
				"    dp:" & string'(hdo(frames)**".format.udp.dp")     & ',' &
				"length:" & string'(hdo(frames)**".format.udp.length") & ',' &
				"chksum:" & string'(hdo(frames)**".format.udp.chksum") & '}'),
			size  => udprx_data'length)
		port map (
			clk    => miirx_clk,
			frm    => udprx_frm,
			irdy   => udprx_irdy,
			act(0) => sp_act,
			act(1) => dp_act,
			act(2) => act2,
			act(3) => act3,
			act(4) => pyl_act);

		fifo_b : block
			signal ne_addr : boolean;
			signal wr_ena  : std_logic;
			signal wr_addr : std_logic_vector(0 to 5-1);
			signal rd_addr : std_logic_vector(wr_addr'range);
			signal wr_data : std_logic_vector(udprx_data'range);
		begin

			data_i : entity hdl4fpga.dpram
			port map (
				wr_clk  => miirx_clk,
				wr_addr => wr_addr,
				wr_ena  => wr_ena,
				wr_data => wr_data,
				rd_addr => rd_addr,
				rd_data => pylrx_data);

			process (miirx_clk)
			begin
				if rising_edge(miirx_clk) then
					if ne_addr then
						if pyl_act='1' then
							pylrx_frm  <= pyl_act;
							pylrx_irdy <= pyl_act;
						end if;
					else
						pylrx_frm  <= '0';
						pylrx_irdy <= '0';
					end if;
				end if;
			end process;

			process (miirx_clk)
				variable init    : boolean;
				variable wr_cntr : unsigned (wr_addr'range);
				variable rd_cntr : unsigned (rd_addr'range);
			begin
				if rising_edge(miirx_clk) then
					ne_addr <= wr_cntr /= rd_cntr;
				end if;

				if rising_edge(miirx_clk) then
					if init then
						if sharx_frm='1' then
							wr_cntr := (others => '0');
						end if;
					end if;

					wr_addr <= std_logic_vector(wr_cntr);
					wr_data <= udprx_data;
					if (sharx_frm and sharx_irdy)='1' or
					   (sparx_frm and sparx_irdy)='1' or
					   (sp_act or dp_act or pyl_act)='1' then
						wr_ena  <= '1';
						wr_cntr := wr_cntr + 1;
					else
						wr_ena  <= '0';
					end if;
				end if;

				if rising_edge(miirx_clk) then
					if init then
						if sharx_frm='1' then
							rd_cntr := (others => '0');
						end if;
					end if;

					if pylrx_trdy='1' then
						if pyl_act='1' then
							rd_addr <= std_logic_vector(rd_cntr);
							rd_cntr := rd_cntr + 1;
						elsif (pylrx_frm and pylrx_irdy)='1' then
							rd_addr <= std_logic_vector(rd_cntr);
							rd_cntr := rd_cntr + 1;
						end if;
					end if;
				end if;

				if rising_edge(miirx_clk) then
					if init then
						if sharx_frm='1' then
							init := false;
						end if;
					elsif sharx_frm='0' then
						init := true;
					end if;
				end if;

			end process;
		end block;

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

			sp_p : process (pyl_act, miirx_clk)
				variable sp_vld : std_logic := '0';
			begin
				if rising_edge(miirx_clk) then
					if (udprx_frm or udprx_irdy)='0' then
						sp_vld := '0';
					elsif (not sp_vld and dhcpcd_equ)='1' then
						sp_vld := '1';
					end if;
				end if;
				dhcpcdrx_frm <= pyl_act and sp_vld;
			end process;

			dhcpcdrx_data <= udprx_data;

		end block;

	end block;

	tx_b : block
		alias  udppyltx_frm  is udptx_frms(1);
		alias  udppyltx_irdy is udptx_irdys(1);
		alias  udppyltx_trdy is udptx_trdys(0);
		signal udppyltx_data : std_logic_vector(udptx_data'range);

		signal tha_act    : std_logic;
		signal length_act : std_logic;
		signal adjlen_act : std_logic;
		signal da_act     : std_logic;
		signal ports_act  : std_logic;
		signal chksum_act : std_logic;
		signal pyl_act    : std_logic;
		signal adjlen_irdy : std_logic;
		signal xxx_data : std_logic_vector(udptx_data'range);
		signal adjlen_data : std_logic_vector(udptx_data'range);
		signal decode_irdy : std_logic;

	begin

		decode_irdy <= udptx_irdy and udppyltx_trdy;
		udp_i : entity hdl4fpga.frame_decode
		generic map (
			frame => compact('{' &
				"   tha:" & string'(hdo(frames)**".format.mac.hwda")    & ',' &
				"length:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"adjlen:" & string'(hdo(frames)**".format.ipv4.length") & ',' &
				"    da:" & string'(hdo(frames)**".format.ipv4.da")     & ',' &
				" ports:" & natural'image(
					hdo(frames)**".format.udp.sp" +
					hdo(frames)**".format.udp.dp")                      & ',' &
				"chksum:" & string'(hdo(frames)**".format.udp.chksum")  & '}'),
			size  => udprx_data'length)
		port map (
			clk    => miitx_clk,
			frm    => udprx_frm,
			irdy   => udprx_irdy,
			act(0) => tha_act,
			act(1) => length_act,
			act(2) => adjlen_act,
			act(3) => da_act,
			act(4) => ports_act,
			act(5) => chksum_act,
			act(6) => pyl_act);

		udppyltx_irdy <= '1' when length_act='0' else '1';
		udppyltx_data <= 
			adjlen_data when length_act='1' else
			udptx_data;

		adjlen_irdy <= length_act and adjlen_act;
		xxx_data <= 
			udptx_data when adjlen_act='1' else
			(udptx_data'range => '0');

		miiadjlen_i : entity hdl4fpga.mii_adjlen
		generic map (
			diff => std_logic_vector(to_unsigned(summation(hdo(frames)**".format.udp"),hdo(frames)**".format.ipv4.length")))
		port map (
			clk     => miirx_clk,
			frm     => udprx_frm,
			irdy    => adjlen_irdy,
			si_data => xxx_data,
			so_data => adjlen_data);

		arbiter_b : block
			signal gntd  : std_logic_vector(0 to 2-1);
		begin

			udptx_frms(0)  <= pyltx_frm;
			udptx_irdys(0) <= pyltx_irdy;
			pyltx_trdy     <= udptx_trdys(0);

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
				pyltx_data    when gntd(0)='1' else
				dhcpcdtx_data when gntd(1)='1' else
				(udptx_data'range => '-');

		end block;

	end block;

	dhcpcd_i : entity hdl4fpga.dhcpcd
	generic map (
		hwaddr        => hwaddr)
	port map (
		-- tp => tp,
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
