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

entity ipv4 is
	generic (
		ipv4addr    : std_logic_vector);
	port (
		miirx_clk   : in  std_logic;
		ipv4rx_frm  : in  std_logic;
		ipv4rx_irdy : in  std_logic;
		ipv4rx_trdy : out std_logic := '1';
		ipv4rx_data : in  std_logic_vector;
		tp        : out std_logic_vector(1 to 32));

end;

architecture def of ipv4 is
	signal ipv4da_frm  : std_logic;
	signal ipv4da_irdy : std_logic;
	signal proto_frm   : std_logic;
	signal proto_irdy  : std_logic;
	signal proto_trdy  : std_logic;
	signal icmp_equ    : std_logic;
	signal icmprx_frm  : std_logic;
	signal icmprx_irdy : std_logic;
	signal icmprx_trdy : std_logic;
	signal icmprx_data : std_logic_vector(ipv4rx_data'range);

begin

	ipv4rx_i : entity hdl4fpga.ipv4_decode
	port map (
		mii_clk    => miirx_clk,
		ipv4_frm   => ipv4rx_frm,
		ipv4_irdy  => ipv4rx_irdy,
		ipv4_data  => ipv4rx_data,
		da_frm     => ipv4da_frm,
		da_irdy    => ipv4da_irdy,
		proto_frm  => proto_frm,
		proto_irdy => proto_irdy);  

	pa_b : block
		signal so_data : std_logic_vector(ipv4rx_data'range);
		signal pa_equ  : std_logic;
	begin
		mem_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => reverse(ipv4addr,8))
		port map (
			si_data => ipv4rx_data,
			so_clk  => miirx_clk,
			so_frm  => ipv4da_frm,
			so_irdy => ipv4da_irdy,
			so_trdy => open,
			so_data => so_data);

		cmp_i : entity hdl4fpga.sio_cmp
		port map (
			clk     => miirx_clk,
			mr_frm  => ipv4da_frm,
			mr_irdy => ipv4da_irdy,
			mr_trdy => open,
			mr_data => so_data,
			sl_data => ipv4rx_data,
			equ     => pa_equ);

		icmpproto_cmp_i : entity hdl4fpga.mii_cmp
		generic map (
			bitdata => reverse(hdo(frames)**".data.ipv4.proto.icmp",8))
		port map (
			mii_clk => miirx_clk,
			frm     => proto_frm,
			irdy    => proto_irdy,
			trdy    => proto_trdy,
			data    => ipv4rx_data,
			equ     => icmp_equ);

		process (miirx_clk)
			variable icmp_vld : std_logic := '0';
			variable pa_vld   : std_logic := '0';
		begin
			if rising_edge(miirx_clk) then
				if (ipv4rx_frm or ipv4rx_irdy)='0' then
					 icmp_vld := '0';
					 pa_vld   := '0';
				else
					if (not icmp_vld and icmp_equ)='1' then
						icmp_vld := '1';
					end if;
					if (not pa_vld and pa_equ)='1' then
						pa_vld := '1';
					end if;
				end if;
				icmprx_frm  <= ipv4rx_frm and pa_vld and icmp_vld;
				icmprx_data <= ipv4rx_data;

			end if;
		end process;

	end block;

	-- tp(1) <= ipv4rx_frm;
	-- tp(2 to 2+ipv4rx_data'length-1) <= ipv4rx_data;
	tp(1) <= icmprx_frm;
	tp(2 to 2+ipv4rx_data'length-1) <= icmprx_data;
end;
