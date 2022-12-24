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
use hdl4fpga.base.all;

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
	signal rd_req  : std_logic_vector(0 to 2-1);
	signal rd_rdy  : std_logic_vector(rd_req'range);
	signal wr_addr : std_logic_vector(rd_req'range);
	signal rd_addr : std_logic_vector(rd_rdy'range);
begin

	process (src_clk)
		variable rdy : std_logic_vector(rd_rdy'range);
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				rd_req  <= inc(gray(to_stdlogicvector(to_bitvector(rdy))));
			elsif rd_req=rdy then
				if src_trdy='0' then
					if src_irdy='1' then
						rd_req  <= inc(gray(to_stdlogicvector(to_bitvector(rdy))));
						wr_addr <= inc(gray(rdy));
						src_trdy <= '1';
					end if;
				else
					src_trdy <= '0';
				end if;
			else
				src_trdy <= '0';
			end if;
			rdy := rd_rdy;
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram
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
		variable req : std_logic_vector(rd_req'range);
	begin
		if rising_edge(dst_clk) then
			if dst_frm='0' then
				rd_rdy <= (others => '0');
			elsif req/=rd_rdy then
				if dst_trdy='1' then
					rd_addr <= rd_rdy;
					rd_rdy  <= req;
				end if;
				dst_irdy <= dst_trdy;
			else
				dst_irdy <= '0';
			end if;
			req := rd_req;
		end if;
	end process;

end;
