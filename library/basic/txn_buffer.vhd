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
use hdl4fpga.base.all;

entity txn_buffer is
	generic (
		debug : boolean := false;
		m : natural := 7;
		n : natural := 1;
		lat : natural:= 1);
	port (
		tp       : out std_logic_vector(1 to 32);

		src_clk  : in  std_logic;
		src_frm  : in  std_logic;
		src_irdy : in  std_logic;
		src_trdy : buffer std_logic;
		src_end  : in  std_logic := '0';
		src_tag  : in  std_logic_vector(0 to n-1) := (0 to n-1 => '-');
		src_data : in  std_logic_vector;
		rollback : in  std_logic := '0';
		commit   : in  std_logic := '1';
		avail    : buffer std_logic;


		dst_clk  : in  std_logic;
		dst_frm  : in  std_logic;
		dst_irdy : in  std_logic;
		dst_trdy : out std_logic;
		dst_end  : buffer std_logic;
		dst_tag  : out std_logic_vector(0 to n-1);
		dst_data : out std_logic_vector);
end;

architecture def of txn_buffer is

	signal rx_irdy : std_logic;
	signal rx_trdy : std_logic;
	signal rx_writ : std_logic;
	signal rx_data : std_logic_vector(0 to m+src_tag'length);

	signal tx_irdy : std_logic;
	signal tx_trdy : std_logic;
	signal tx_data : std_logic_vector(rx_data'range);

	signal di_irdy : std_logic;
	signal di_trdy : std_logic;
	signal do_irdy : std_logic;
	signal do_trdy : std_logic;

	signal fifo_rollback : std_logic;
	signal fifo_commit   : std_logic;

begin

	rx_b : block
	begin
		process (src_frm, src_end, commit, src_clk)
			variable d, q : std_logic;
		begin
			d := src_frm and not src_end and commit;
			if rising_edge(src_clk) then
				q := d;
			end if;
			rx_irdy <= not d and q;
		end process;

		process (src_clk)
			variable cntr : unsigned(0 to m);
		begin
			if rising_edge(src_clk) then
				if src_frm='0' then
					cntr := (others => '0');
				elsif src_end='0' then
					if (src_irdy and di_trdy)='1' then
						cntr := cntr + 1;
					end if;
				end if;
				rx_writ <= commit or not src_frm;
				rx_data(cntr'range) <= std_logic_vector(cntr);
			end if;
		end process;
		rx_data(m+1 to rx_data'length-1) <= src_tag;
	end block;

	fifo_rollback <= rollback or not src_frm;
	fifo_commit   <= commit;

	di_irdy <= (src_frm and not src_end) and src_irdy;
	do_trdy <= (dst_frm and not dst_end) and dst_irdy;
	data_e : entity hdl4fpga.fifo
	generic map (
		check_dov => true,
		check_sov => true,
		max_depth => 2**m,
		latency   => 1)
	port map(
		src_clk   => src_clk,
		src_irdy  => di_irdy,
		src_trdy  => di_trdy,
		src_data  => src_data,

		rollback  => fifo_rollback,
		commit    => fifo_commit,
		overflow  => open,

		dst_clk   => dst_clk,
		dst_irdy  => do_irdy,
		dst_trdy  => do_trdy,
		dst_data  => dst_data);

	fifo_e : entity hdl4fpga.fifo
	generic map (
		latency    => 1,
		check_sov => true,
		check_dov => true,
		max_depth  => 4)
	port map (
		src_clk    => src_clk,
		src_irdy   => rx_irdy,
		src_auto   => '0',
		src_writ   => rx_writ,
		src_trdy   => rx_trdy,
		src_data   => rx_data,

		dst_clk    => dst_clk,
		dst_irdy   => tx_irdy,
		dst_trdy   => tx_trdy,
		dst_data   => tx_data);

	tx_b : block
		signal cntr : unsigned(0 to tx_data'length-dst_tag'length-1);
	begin

		process (dst_frm, dst_clk)
			variable d, q : std_logic;
		begin
			d := dst_frm;
			if rising_edge(dst_clk) then
				if dst_frm='0' then
					cntr <= (others => '0');
				elsif tx_irdy='0' then
					cntr <= (others => '0');
				elsif dst_end='0' then
					if (do_irdy and do_trdy)='1' then
						cntr <= cntr + 1;
					end if;
				end if;
				q := d;
			end if;
			tx_trdy <= not d and q;
		end process;

		dst_end <= not setif(cntr < unsigned(tx_data(cntr'range)));
	end block;

	src_trdy <= (di_trdy and rx_trdy) or src_end;
	dst_trdy <= (do_irdy and tx_irdy) or dst_end;
	tp(4) <= do_irdy;
	tp(3) <= tx_irdy;
	dst_tag  <= tx_data(tx_data'length-dst_tag'length to tx_data'length-1);

	avail    <= tx_irdy and not tx_trdy;
end;