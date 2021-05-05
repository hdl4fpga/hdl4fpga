--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ipoepkg.all;

entity ipv4 is
	port (
		my_ipv4a       : in std_logic_vector(0 to 32-1) := x"00_00_00_00";

		mii_clk        : in  std_logic;
		miirx_data     : in  std_logic_vector;
		frmrx_ptr      : in  std_logic_vector;

		ipv4rx_frm     : in  std_logic;
		ipv4rx_irdy    : in  std_logic;
		ipv4arx_vld    : in  std_logic;

		ipv4lenrx_irdy : buffer std_logic;
		ipv4protorx_irdy : buffer std_logic;
		ipv4sarx_irdy  : buffer std_logic;
		ipv4darx_frm   : out std_logic;
		ipv4darx_irdy  : buffer std_logic;

		plrx_frm       : out std_logic;
		plrx_irdy      : out std_logic;
		plrx_trdy      : in  std_logic;
		plrx_data      : out std_logic_vector;

		pltx_frm       : in  std_logic;
		pltx_irdy      : in  std_logic;
		pltx_trdy      : out std_logic;
		pltx_data      : in  std_logic_vector;

		ipv4tx_frm     : buffer std_logic := '0';
		ipv4tx_irdy    : out std_logic;
		ipv4tx_trdy    : in  std_logic := '1';
		ipv4tx_end     : out std_logic := '0';
		ipv4tx_data    : out std_logic_vector;

		tp             : out std_logic_vector(1 to 32));

end;

architecture def of ipv4 is
	signal ipv4len_tx   : std_logic_vector(16-1 downto 0);
	signal ipv4sa_tx    : std_logic_vector(32-1 downto 0);
	signal ipv4da_tx    : std_logic_vector(32-1 downto 0);
	signal ipv4proto_tx : std_logic_vector(8-1 downto 0) := x"e7";

	signal ipv4da_vld   : std_logic;
	signal ipv4plrx_frm : std_logic;
	signal ipv4plrx_irdy: std_logic;

	signal ipv4pltx_frm  : std_logic;
	signal ipv4pltx_irdy : std_logic;
	signal ipv4pltx_trdy : std_logic;
	signal ipv4pltx_end  : std_logic;
	signal ipv4pltx_data : std_logic_vector(ipv4tx_data'range);

	signal icmprx_frm  : std_logic;
	signal icmprx_equ  : std_logic;
	signal icmprx_vld  : std_logic;
	signal icmptx_frm  : std_logic;
	signal icmptx_irdy : std_logic;
	signal icmptx_trdy : std_logic;
	signal icmptx_end  : std_logic;
	signal icmptx_data : std_logic_vector(ipv4tx_data'range);

	signal udptx_frm  : std_logic;
	signal udptx_irdy : std_logic;
	signal udptx_trdy : std_logic;
	signal udptx_end  : std_logic;
	signal udptx_data : std_logic_vector(ipv4tx_data'range);

	signal protorx_last : std_logic;

begin

	ipv4rx_e : entity hdl4fpga.ipv4_rx
	port map (
		mii_clk        => mii_clk,
		mii_data       => miirx_data,
		mii_ptr        => frmrx_ptr,
		ipv4_frm       => ipv4rx_frm,
		ipv4_irdy      => ipv4rx_irdy,

		ipv4len_irdy   => ipv4lenrx_irdy,
		ipv4proto_irdy => ipv4protorx_irdy,
		ipv4sa_irdy    => ipv4sarx_irdy,
		ipv4da_frm     => ipv4darx_frm,
		ipv4da_irdy    => ipv4darx_irdy,

		pl_frm         => ipv4plrx_frm,
		pl_irdy        => ipv4plrx_irdy);

	ipv4sa_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => ipv4rx_frm,
		ser_irdy   => ipv4sarx_irdy,
		ser_trdy   => open,
		ser_data   => miirx_data,
		des_irdy   => open,
		des_data   => ipv4da_tx);

	ipv4len_e : entity hdl4fpga.serdes
	generic map (
		rgtr => true)
	port map (
		serdes_clk => mii_clk,
		serdes_frm => ipv4rx_frm,
		ser_irdy   => ipv4lenrx_irdy,
		ser_trdy   => open,
		ser_data   => miirx_data,
		des_irdy   => open,
		des_data   => ipv4len_tx);

	arbiter_b : block
		signal dev_req : std_logic_vector(0 to 2-1);
		signal dev_gnt : std_logic_vector(0 to 2-1);
	begin

		dev_req <= icmptx_frm & udptx_frm;
		arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => mii_clk,
			req => dev_req,
			gnt => dev_gnt);

		ipv4pltx_frm  <= wirebus(icmptx_frm  & udptx_frm,  dev_gnt)(0);
		ipv4pltx_irdy <= wirebus(icmptx_irdy & udptx_irdy, dev_gnt)(0);
		ipv4pltx_end  <= wirebus(icmptx_end  & udptx_end,  dev_gnt)(0);
		ipv4pltx_data <= wirebus(icmptx_data & udptx_data, dev_gnt);
		(0 => icmptx_trdy, 1 => udptx_trdy) <= dev_gnt and (dev_gnt'range => ipv4pltx_trdy); 
		ipv4len_tx <= wirebus(x"00_00_00_00_00_00" & x"00_00_00_00_00_00", dev_gnt);
		ipv4sa_tx  <= my_ipv4a;
		ipv4da_tx  <= wirebus(x"00_00_00_00" & x"00_00_00_00", dev_gnt);

	end block;

	ipv4tx_e : entity hdl4fpga.ipv4_tx
	port map (
		mii_clk    => mii_clk,

		pl_frm     => ipv4pltx_frm,
		pl_irdy    => ipv4pltx_irdy,
		pl_trdy    => ipv4pltx_trdy,
		pl_end     => ipv4pltx_end,
		pl_data    => ipv4pltx_data,

		ipv4_len   => ipv4len_tx,
		ipv4_sa    => ipv4sa_tx,
		ipv4_da    => ipv4da_tx,
		ipv4_proto => ipv4proto_tx,

		ipv4_frm   => ipv4tx_frm,
		ipv4_irdy  => ipv4tx_irdy,
		ipv4_trdy  => ipv4tx_trdy,
		ipv4_end   => ipv4tx_end,
		ipv4_data  => ipv4tx_data);

	ipv4a_p : process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if ipv4rx_frm='0' then
				ipv4da_vld <= '0';
			elsif ipv4da_vld='0' then
				ipv4da_vld <= ipv4arx_vld;
			end if;
		end if;
	end process;

	proto_e : entity hdl4fpga.sio_cmp
	generic map (
		n => 1)
	port map (
		mux_data  => reverse(ipv4proto_icmp,8),
        sio_clk   => mii_clk,
        sio_frm   => ipv4rx_frm,
		sio_irdy  => ipv4protorx_irdy,
        si_data   => miirx_data,
		so_last   => protorx_last,
		so_equ(0) => icmprx_equ);

	icmp_p : process (mii_clk)
	begin
		if rising_edge(mii_clk) then
			if ipv4rx_frm='0' then
				icmprx_vld <= '0';
			elsif protorx_last='1' and ipv4protorx_irdy='1' then
				icmprx_vld <= icmprx_equ;
			end if;
		end if;
	end process;
	icmprx_frm <= ipv4plrx_frm and icmprx_vld and ipv4da_vld;

	icmp_e : entity hdl4fpga.icmp
	port map (
		mii_clk     => mii_clk,
		icmprx_frm  => icmprx_frm,
		miirx_irdy  => ipv4rx_irdy,
		frmrx_ptr   => frmrx_ptr,
		miirx_data  => miirx_data,
		icmptx_frm  => icmptx_frm,
		icmptx_irdy => icmptx_irdy,
		icmptx_trdy => icmptx_trdy,
		icmptx_end  => icmptx_end ,
		miitx_data  => icmptx_data);

	udp_e : entity hdl4fpga.udp
	port map (
		mii_clk     => mii_clk,
		miirx_irdy  => ipv4rx_irdy,
		frmrx_ptr   => frmrx_ptr,
		miirx_data  => miirx_data,

		plrx_frm    => plrx_frm,
		plrx_irdy   => plrx_irdy,
		plrx_trdy   => plrx_trdy,
		plrx_data   => plrx_data,

		pltx_frm    => pltx_frm,
		pltx_irdy   => pltx_irdy,
		pltx_trdy   => pltx_trdy,
		pltx_data   => pltx_data,

		udptx_frm   => udptx_frm,
		udptx_irdy  => udptx_irdy,
		udptx_trdy  => udptx_trdy,
		udptx_data  => udptx_data);

end;
