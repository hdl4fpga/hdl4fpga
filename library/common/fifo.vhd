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

entity fifo is
	generic (
		size     : natural);
	port (
		src_clk  : in  std_logic;
		src_frm  : in  std_logic := '1';
		src_irdy : in  std_logic;
		src_trdy : buffer std_logic;
		src_data : in  std_logic_vector;

		dst_clk  : in  std_logic;
		dst_frm  : buffer std_logic := '1';
		dst_irdy : buffer std_logic;
		dst_trdy : in  std_logic;
		dst_data : out std_logic_vector);
end;

architecture def of fifo is

	signal wr_ena    : std_logic;
	signal wr_addr   : gray(0 to unsigned_num_bits(size-1)-1);
	signal rd_addr   : gray(0 to unsigned_num_bits(size-1)-1);
	signal dst_irdy1 : std_logic;
	signal dly_irdy  : std_logic;

begin

	wr_ena <= src_frm and src_irdy and src_trdy;
	mem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => src_clk,
		wr_ena  => wr_ena,
		wr_addr => wr_addr,
		wr_data => src_data, 

		rd_clk  => dst_clk,
		rd_addr => rd_addr,
		rd_data => dst_data);

	process(src_clk)
	begin
		if rising_edge(src_clk) then
			if src_frm='1' then
				if src_trdy='1' then
					wr_addr <= inc(wr_addr);
				end if;
			end if;
		end if;
	end process;
	src_trdy <= setif(wr_addr/=rd_addr);

	dst_irdy1 <= setif(wr_addr=inc(rd_addr));
	process(dst_clk)
	begin
		if rising_edge(dst_clk) then
			if dst_frm='1' then
				if dst_irdy1='1' then
					if dst_trdy='1' then
						rd_addr <= inc(rd_addr);
					end if;
				end if;
			end if;
		end if;
	end process;

	dstirdy_e : entity hdl4fpga.align
	generic map (
		n => 2,
		d => (0 to 0 => 2))
	port map (
		clk   => dst_clk,
		ena   => dst_trdy,
		di(0) => dst_irdy1,
		do(0) => dly_irdy);
	dst_irdy <= dly_irdy and dst_trdy;
end;
