-- Copyright (c) <2015> <Miguel Angel Sagreras>                                    --
--                                                                                 --
-- Permission is hereby granted, free of charge, to any person obtaining a copy of --
-- this software and associated documentation files (the "Software"), to deal in   --
-- the Software without restriction, including without limitation the rights to    --
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   --
-- of the Software, and to permit persons to whom the Software is furnished to do  --
-- so, subject to the following conditions:                                        --
--                                                                                 --
-- The above copyright notice and this permission notice shall be included in all  --
-- copies or substantial portions of the Software.                                 --
--                                                                                 --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   --
-- SOFTWARE.                                                                       --
--                                                                                 --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity arpd is
	generic (
		default_ipv4a : std_logic_vector;
		hwsa          : std_logic_vector(0 to 48-1) := x"00_40_00_01_02_03");
	port (
		mii_clk       : in  std_logic;
		arp_req       : in  std_logic;
		arp_rdy       : buffer  std_logic;

		arprx_frm     : in  std_logic;
		arprx_irdy    : in  std_logic;
		arprx_data    : in  std_logic_vector;

		sparx_irdy    : out std_logic;
		sparx_trdy    : in  std_logic;
		sparx_end     : in  std_logic;
		sparx_equ     : in  std_logic;

		ipv4sawr_frm  : in  std_logic;
		ipv4sawr_irdy : in  std_logic;
		ipv4sawr_trdy : out std_logic;
		ipv4sawr_end  : out std_logic;
		ipv4sawr_data : in  std_logic_vector;
	
		dlltx_irdy    : out  std_logic;
		dlltx_end     : in   std_logic;
		dlltx_data    : out std_logic_vector;

		arptx_frm     : buffer std_logic := '0';
		arptx_irdy    : out std_logic;
		arptx_trdy    : in  std_logic;
		arptx_end     : buffer std_logic;
		arptx_data    : out std_logic_vector;

		tp            : out std_logic_vector(1 to 32));

end;

architecture def of arpd is

	signal tparx_frm : std_logic;
	signal tparx_vld : std_logic;
	signal arptx_rdy : std_logic;
	signal arptx_req : std_logic;

	signal spatx_frm   : std_logic;
	signal spatx_irdy  : std_logic;
	signal spatx_trdy  : std_logic;
	signal spatx_end   : std_logic;
	signal spatx_data  : std_logic_vector(arptx_data'range);

begin

	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if (to_bit(arptx_req) xor to_bit(arptx_rdy))='0' then
				if arprx_frm='1' then
					arptx_req <= to_stdulogic(to_bit(arptx_rdy)) xor (tparx_vld and sparx_end);
				elsif (to_bit(arp_req) xor to_bit(arp_rdy))='1' then
					arptx_req <= not to_stdulogic(to_bit(arptx_rdy));
					arp_rdy   <= arp_req;
				end if;
			end if;
		end if;
	end process;

	arprx_e : entity hdl4fpga.arp_rx
	port map (
		mii_clk  => mii_clk,
		arp_frm  => arprx_frm,
		arp_irdy => arprx_irdy,
		arp_data => arprx_data,
		tpa_frm  => tparx_frm);

	sparx_irdy <= tparx_frm and arprx_irdy;
	process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if arprx_frm='0' then
				tparx_vld <= '0';
			elsif sparx_end='0' then
				tparx_vld <= sparx_equ;
			end if;
		end if;
	end process;

	ipv4sa_e : entity hdl4fpga.sio_ram
	generic map (
		mem_data => reverse(default_ipv4a,8),
		mem_length => 32)
	port map (
		si_clk  => mii_clk,
		si_frm  => ipv4sawr_frm,
		si_irdy => ipv4sawr_irdy,
		si_trdy => ipv4sawr_trdy,
		si_full => ipv4sawr_end,
		si_data => ipv4sawr_data,
	
		so_clk  => mii_clk,
		so_frm  => spatx_frm,
		so_irdy => spatx_irdy,
		so_trdy => spatx_trdy,
		so_end  => spatx_end,
		so_data => spatx_data);

	arptx_e : entity hdl4fpga.arp_tx
	generic map (
		hwsa       => hwsa)
	port map (
		mii_clk    => mii_clk,
		arp_req    => arptx_req,
		arp_rdy    => arptx_rdy,
		pa_frm     => spatx_frm,
		pa_irdy    => spatx_irdy,
		pa_trdy    => spatx_trdy,
		pa_end     => spatx_end,
		pa_data    => spatx_data,

		dlltx_irdy => dlltx_irdy,
		dlltx_end  => dlltx_end,
		dlltx_data => dlltx_data,

		arp_frm    => arptx_frm,
		arp_irdy   => arptx_irdy,
		arp_trdy   => arptx_trdy,
		arp_end    => arptx_end,
		arp_data   => arptx_data);

end;
