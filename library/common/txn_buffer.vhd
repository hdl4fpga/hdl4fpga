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
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity txn_buffer is
	generic (
		m : natural := 7;
		n : natural := 1);
	port (
		src_clk     : in  std_logic;
		src_frm     : in  std_logic;
		src_irdy    : in  std_logic;
		src_trdy    : buffer std_logic;
		src_end     : in  std_logic := '0';
		src_tag     : in  std_logic_vector(0 to n-1) := (0 to n-1 => '-');
		src_data    : in  std_logic_vector;
		rollback    : in  std_logic;
		commit      : in  std_logic;
		tx_irdy     : out  std_logic;


		dst_frm     : in  std_logic;
		dst_irdy    : in std_logic;
		dst_trdy    : buffer std_logic;
		dst_end     : buffer std_logic;
		dst_tag     : out std_logic_vector(0 to n-1);
		dst_data    : out std_logic_vector);
end;

architecture def of txn_buffer is

	signal rx_irdy : std_logic;
	signal rx_writ : std_logic;
	signal rx_data : std_logic_vector(0 to m+src_tag'length);

	signal tx_trdy : std_logic;
	signal tx_data : std_logic_vector(rx_data'range);

	signal di_irdy : std_logic;
	signal di_trdy : std_logic;
	signal do_irdy : std_logic;
	signal do_trdy : std_logic;

begin

	process (src_frm, src_tag, src_end, src_clk)
		variable cntr : unsigned(0 to rx_data'length-src_tag'length-1);
		variable q    : std_logic;
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				cntr := (others => '0');
			elsif (di_irdy and di_trdy and not src_end)='1' then
				cntr := cntr + 1;
			end if;
			q := (src_frm and not src_end and commit);
		end if;
		rx_data <= std_logic_vector(cntr) & src_tag;
		rx_irdy <= not (src_frm and not src_end and commit) and q;
	end process;

	di_irdy <= not rx_data(0) and src_irdy;
	do_trdy <= dst_frm        and dst_irdy;
	data_e : entity hdl4fpga.fifo
	generic map (
		check_dov => true,
		check_sov => true,
		max_depth => 2**m,
		latency   => 0)
	port map(
		src_clk   => src_clk,
		src_irdy  => di_irdy,
		src_trdy  => di_trdy,
		src_data  => src_data,

		rollback  => rollback,
		commit    => commit,
		overflow  => open,

		dst_clk   => src_clk,
		dst_irdy  => do_irdy,
		dst_trdy  => do_trdy,
		dst_data  => dst_data);

	rx_writ <= (not rx_data(0) and commit) or (not src_frm and not rx_irdy);
	fifo_e : entity hdl4fpga.fifo
	generic map (
		latency    => 0,
		max_depth  => 2)
	port map (
		src_clk    => src_clk,
		src_irdy   => rx_irdy,
		src_auto   => '0',
		src_writ   => rx_writ,
		src_trdy   => open,
		src_data   => rx_data,

		dst_clk    => src_clk,
		dst_irdy   => tx_irdy,
		dst_trdy   => tx_trdy,
		dst_data   => tx_data);

	process (dst_frm, dst_trdy, tx_data, src_clk)
		variable q    : std_logic;
		variable cntr : unsigned(0 to tx_data'length-dst_tag'length-1);
	begin
		if rising_edge(src_clk) then
			if dst_frm='1' then
				if (do_irdy and do_trdy)='1' then
					if cntr <= unsigned(tx_data(cntr'range)) then
						cntr := cntr + 1;
					end if;
				end if;
			else
				cntr := (others => '0');
			end if;
			q := dst_frm;
		end if;
		tx_trdy <= not dst_frm and q;
		dst_end <= (not setif(cntr <= unsigned(tx_data(cntr'range))));
	end process;

	src_trdy <=  not rx_data(0) and di_trdy and src_frm;
	dst_trdy <= (not tx_data(0) and do_irdy) or (dst_end and dst_frm);
	dst_tag  <= tx_data(tx_data'length-dst_tag'length to tx_data'length-1);
end;
