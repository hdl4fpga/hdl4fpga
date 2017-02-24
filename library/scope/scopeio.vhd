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

entity scopeio_miirx is
	port (
		mii_rxc   : in  std_logic;
		mii_rxdv  : in  std_logic;
		mii_rxd   : in  std_logic_vector;
		scope_cmd : out std_logic_vector;
		dma_addr  : out std_logic_vector;
		dma_size  : out std_logic_vector;
		mem_addr  : in  std_logic_vector;
		mem_ena   : out std_logic;
		mem_data  : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of scopeio_miirx is
	signal mac_rdy  : std_logic;
	signal udp_rdy  : std_logic;
	signal dma_rdy  : std_logic;

	signal dma_data : unsigned;
begin

	miirx_mac_e : entity hdl4fpga.miirx_mac
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		mii_txen => mac_rdy);

	miirx_udp_p : process(mii_rxc)
		variable cntr : unsigned;
	begin
		if rising_edge(mii_rxc) then
			if mac_rdy='0' then
				cntr := to_unsigned(0, cntr'length);
			elsif cntr(0)='0' then
				cnt := cntr - 1;
			end if;
			udp_rdy <= cntr(0);
		end if;
	end process;

	process(mii_rxc)
		variable cntr : unsigned;
	begin
		if rising_edge(mii_rxc) then
			if udp_rdy='0' then
				cntr := to_unsigned(0, cntr'length);
			elsif cntr(0)='0' then
				dma_data := dma_data sll mii_rxd'length;
				dma_data(mii_rxd'reverse_range) := reverse(mii_rxd);
				cntr := cntr - 1;
			end if;
			dma_rdy <= cntr(0);
		end if;
	end process;

	process(dma_data)
		variable data : unsigned(dma_data'range);
	begin
		data      := dma_data;
		dma_addr  <= data(dma_addr'range);
		data      := data sll dma_addr'length;
		dma_size  <= data(dma_size'range);
		data      := data sll dma_addr'length;
		scope_cmd <= data(scope_cmd'range);
	end process;

	process(mii_rxc)
		variable cntr : unsigned;
		variable data : unsigned(mem_data'range);
	begin
		if rising_edge(mii_rxc) then
			if dma_rdy='0' then
				cntr := to_unsigned(mem_data'length/mii_rxd'length-1, cntr'length);
			elsif cntr(0)='1' then
				cntr := to_unsigned(mem_data'length/mii_rxd'length-1, cntr'length);
			else
				cntr := cntr - 1;
			end if;
			mem_ena  <= cntr(0);
			mem_data <= data;
			data := data sll mii_rxd'length;
			data(mii_rxd'reverse_range) := reverse(mii_rxd);
		end if;
	end process;
end;
