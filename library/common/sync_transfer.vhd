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

entity sync_transfer is
	port (
		src_clk    : in  std_logic;
		src_frm    : in  std_logic := '1';
		src_irdy   : in  std_logic := '1';
		src_trdy   : buffer std_logic;
		src_data   : in  std_logic_vector;

		dst_clk    : in  std_logic;
		dst_frm    : in  std_logic := '1';
		dst_irdy   : buffer std_logic;
		dst_trdy   : in  std_logic := '1';
		dst_data   : out std_logic_vector);
end;

architecture def of sync_transfer is
	signal rd_req  : bit;
	signal rd_rdy  : bit;
	signal wr_addr : std_logic_vector(0 to 0);
	signal rd_addr : std_logic_vector(wr_addr'range);
begin

	process (src_clk)
		variable we   : std_logic;
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				rd_req <= not rd_rdy;
			elsif (rd_req xor rd_rdy)='0' then
				if src_trdy='0' then
					if src_irdy='1' then
						src_trdy <= '1';
						rd_req <= not rd_rdy;
					end if;
				else
					src_trdy <= '0';
				end if;
			else
				src_trdy <= '0';
			end if;
		end if;
	end process;

	wr_addr(0) <= to_stdulogic(rd_req);
	rd_addr(0) <= to_stdulogic(not rd_rdy);
	mem_e : entity hdl4fpga.dpram(def)
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => true)
	port map (
		wr_clk  => src_clk,
		wr_addr => wr_addr,
		wr_data => src_data,

		rd_clk  => dst_clk,
		rd_addr => rd_addr,
		rd_data => dst_data);

	process (dst_clk)
	begin
		if rising_edge(dst_clk) then
			if dst_frm='0' then
				rd_rdy <= '0';
			elsif (rd_req xor rd_rdy)='1' then
				if dst_trdy='1'  then
					rd_rdy <= rd_req;
				end if;
				dst_irdy <= dst_trdy;
			else
				dst_irdy <= '0';
			end if;
		end if;
	end process;

end;
