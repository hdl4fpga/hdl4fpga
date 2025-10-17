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

entity sio_flow is
	generic (
		debug   : boolean := false);
	port (
		rx_clk  : in std_logic;
		rx_frm  : in std_logic;
		rx_irdy : in std_logic;
		rx_trdy : out std_logic;
		rx_data : in std_logic_vector;
		fcs_sb  : in  std_logic;
		fcs_vld : in  std_logic;

		so_clk  : in std_logic;
		so_frm  : out std_logic;
		so_irdy : buffer std_logic;
		so_trdy : in  std_logic := '1';
		so_data : out std_logic_vector;

		si_clk  : in  std_logic := '-';
		si_frm  : in  std_logic;
		si_irdy : in  std_logic;
		si_trdy : out std_logic;
		si_data : in  std_logic_vector;

		tx_clk  : in std_logic;
		tx_frm  : out std_logic;
		tx_irdy : out std_logic;
		tx_trdy : in  std_logic := '1';
		tx_data : buffer std_logic_vector;
		tp      : out std_logic_vector(1 to 32));

end;

architecture struct of sio_flow is

	signal rgtr_frm     : std_logic;
	signal rgtr_irdy    : std_logic;
	signal rgtr_trdy    : std_logic;
	signal rid_act      : std_logic;

	signal buffer_cmmt  : std_logic;
	signal buffer_rllbk : std_logic;
	signal buffer_ovfl  : std_logic;

	signal rply_req     : std_logic := '0';
	signal rply_rdy     : std_logic := '0';

	signal tx_frms      : std_logic_vector(0 to 2-1);
	signal tx_irdys     : std_logic_vector(0 to 2-1);
	signal tx_trdys     : std_logic_vector(0 to 2-1) := (others => '1');

	alias  acktx_frm  is tx_frms(0);
	alias  acktx_irdy is tx_irdys(0);
	alias  acktx_trdy is tx_trdys(0);

	signal acktx_data : std_logic_vector(tx_data'range);
begin

	siosin_e : entity hdl4fpga.sio_sin
	port map (
		clk       => rx_clk,
		frm       => rx_frm,
		irdy      => rx_irdy,
		data      => rx_data,
		rid_act   => rid_act,
		rgtr_frm  => rgtr_frm,
		rgtr_irdy => rgtr_irdy,
		rgtr_trdy => rgtr_trdy);

	ack_b : block
		signal cmp_frm  : std_logic;
		signal cmp_irdy : std_logic;
		signal cmp_data : std_logic_vector(rx_data'range);

		signal rom_frm  : std_logic;
		signal rom_irdy : std_logic;
		signal rom_data : std_logic_vector(rx_data'range);

		signal ram_frm  : std_logic;
		signal ram_irdy : std_logic;
		signal ram_data : std_logic_vector(rx_data'range);
		signal ack_equ  : std_logic;
	begin

		cmp_frm  <= rgtr_frm and rid_act;
		cmp_irdy <= cmp_frm  and rx_irdy;
		cmp_i : entity hdl4fpga.sio_cmp
		port map (
			clk     => rx_clk,
			mr_frm  => cmp_frm,
			mr_irdy => cmp_irdy,
			mr_data => cmp_data,
			sl_frm  => rom_frm,
			sl_irdy => rom_irdy,
			sl_data => rom_data,
			equ     => ack_equ);

		rom_i : entity hdl4fpga.sio_rom
		generic map (
			bitdata => reverse(x"01"))
		port map (
			so_clk  => rx_clk,
			so_frm  => rom_frm,
			so_irdy => rom_irdy,
			so_data => rom_data);

		process (rgtr_irdy, ack_equ, rx_clk)
			variable equ : std_logic;
		begin
			if rising_edge(rx_clk) then
				if equ='0' then
					if (rgtr_frm or rgtr_irdy)='1' then
						equ := ack_equ;
					end if;
				elsif (rgtr_frm or rgtr_irdy)='0' then
					equ := '0';
				elsif (rgtr_frm or not rgtr_trdy)='0' then
					equ := '0';
				end if;
			end if;
			ram_irdy <= (ack_equ or equ) and rgtr_irdy;
		end process;

		ram_data <=
			rx_data  when ram_irdy='1' else
			rom_data;

		mem_i : entity hdl4fpga.sio_ram
		generic map (
			bitdata => (0 to 24-1 => '-'))
		port map (
			si_clk  => rx_clk,
			si_frm  => rgtr_frm,
			si_irdy => ram_irdy,
			si_data => ram_data,
			so_clk  => tx_clk,
			so_frm  => acktx_frm,
			so_irdy => acktx_irdy,
			so_trdy => acktx_trdy,
			so_data => acktx_data);

	end block;


	artibiter_b : block
		signal gntd  : std_logic_vector(0 to 2-1);
	begin

		tx_frms(1)  <= si_frm;
		tx_irdys(1) <= si_irdy;
		si_trdy     <= tx_trdys(1);

		arbiter_i : entity hdl4fpga.mii_arbiter
		port map (
			clk   => tx_clk,
			gntd  => gntd,
			frms  => tx_frms,
			irdys => tx_irdys,
			trdys => tx_trdys,
			frm   => tx_frm,
			irdy  => tx_irdy,
			trdy  => tx_trdy);

		tx_data <= 
			acktx_data when gntd(0)='1' else
			si_data    when gntd(1)='1' else
			(tx_data'range => '-');

	end block;

end;
