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
	port (
		src_clk     : in  std_logic;
		src_frm     : in  std_logic;
		src_irdy    : in  std_logic;
		src_trdy    : out std_logic;
		src_end     : in  std_logic := '0';
		src_data    : in  std_logic_vector;
		rollback    : in  std_logic;
		commit      : in  std_logic;

		dst_frm     : in  std_logic;
		dst_irdy    : in std_logic;
		dst_trdy    : buffer std_logic;
		dst_end     : out std_logic;
		dst_data    : out std_logic_vector);
end;

architecture def of txn_buffer is

	signal rx_irdy   : std_logic;
	signal rx_writ   : std_logic;
	signal rx_data   : std_logic_vector(0 to 6);

	signal tx_trdy   : std_logic;
	signal tx_data   : std_logic_vector(rx_data'range);

begin

	data_e : entity hdl4fpga.fifo
	generic map (
		max_depth => 128,
		latency   => 1,
		check_dov => true)
	port map(
		src_clk   => src_clk,
		src_irdy  => src_irdy,
		src_trdy  => src_trdy,
		src_data  => src_data,

		rollback  => rollback,
		commit    => commit,
		overflow  => open,

		dst_clk   => src_clk,
		dst_irdy  => dst_trdy,
		dst_trdy  => dst_irdy,
		dst_data  => dst_data);

	process (src_frm, src_end, src_clk)
		variable cntr : unsigned(rx_data'range);
		variable q    : std_logic;
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				cntr := (others => '0');
			elsif src_irdy='1' then
				if commit='1' then
					cntr := cntr + 1;
				end if;
			end if;
			rx_data <= std_logic_vector(cntr);
			q       := (src_frm and not src_end);
		end if;
		rx_irdy <= not (src_frm and not src_end) and q;
	end process;

	rx_writ <= commit and src_irdy;
	fifo_e : entity hdl4fpga.fifo
	generic map (
		latency    => 0,
		max_depth  => 4)
	port map (
		src_clk    => src_clk,
		src_frm    => dst_irdy,
		src_irdy   => rx_irdy,
		src_auto   => '0',
		src_writ   => rx_writ,
		src_trdy   => open,
		src_data   => rx_data,

		dst_clk    => src_clk,
		dst_irdy   => open,
		dst_trdy   => tx_trdy,
		dst_data   => tx_data);

	process (tx_data, src_clk)
		variable q    : std_logic;
		variable cntr : unsigned(tx_data'range);
	begin
		if rising_edge(src_clk) then
			if dst_frm='1' then
				if dst_irdy='1' then
					if dst_trdy='1' then
						if cntr < unsigned(tx_data) then
							cntr := cntr + 1;
						end if;
					end if;
				end if;
			else
				cntr := (others => '0');
			end if;
		end if;
		tx_trdy <= not dst_frm and q;
		dst_end <= not setif(cntr < unsigned(tx_data));
		q := dst_frm;
	end process;

end;
