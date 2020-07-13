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
		mem_size   : natural;
		mem_data   : std_logic_vector := (0 to 0 => '-');
		dst_offset : natural := 0;
		src_offset : natural := 0;
		out_rgtr   : boolean := true;
		check_sov  : boolean := false;
		check_dov  : boolean := false;
		gray_code  : boolean := true);
	port (
		src_clk   : in  std_logic;
		src_frm   : in  std_logic := '1';
		src_mode  : in  std_logic := '0';
		src_irdy  : in  std_logic := '1';
		src_trdy  : buffer std_logic;
		src_data  : in  std_logic_vector;

		dst_clk   : in  std_logic;
		dst_frm   : in  std_logic := '1';
		dst_irdy  : buffer std_logic;
		dst_trdy  : in  std_logic := '1';
		dst_data  : out std_logic_vector);
end;

architecture def of fifo is

	subtype byte is std_logic_vector(0 to hdl4fpga.std.min(src_data'length,dst_data'length)-1);


	constant addr_length : natural := unsigned_num_bits(mem_size*byte'length/src_data'length-1);
	subtype addr_range is 1 to addr_length;

	signal wr_ena    : std_logic;
	signal wr_cntr   : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal rd_cntr   : unsigned(0 to addr_length) := to_unsigned(src_offset, addr_length+1);
	signal dst_irdy1 : std_logic;

	signal data : std_logic_vector(0 to src_data'length-1);

	signal dst_ini  : std_logic;
	signal feed_ena : std_logic;
begin

	wr_ena <= src_frm and src_irdy and (src_trdy or not check_sov);
	mem_e : entity hdl4fpga.dpram(def)
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => out_rgtr,
		bitrom => mem_data)
	port map (
		wr_clk  => src_clk,
		wr_ena  => wr_ena,
		wr_addr => std_logic_vector(wr_cntr(addr_range)),
		wr_data => src_data, 

		rd_clk  => dst_clk,
		rd_ena  => feed_ena,
		rd_addr => std_logic_vector(rd_cntr(addr_range)),
		rd_data => dst_data);

	process(src_clk)
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				if dst_mode='0' then
					wr_cntr <= rd_cntr;
				else	
					wr_cntr <= to_unsigned(src_offset, wr_cntr'length);
				end if;
			else
				if src_irdy='1' then
					if src_trdy='1' or not check_sov then
						if gray_code then
							wr_cntr <= unsigned(inc(gray(wr_cntr)));
						else
							wr_cntr <= wr_cntr+1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	src_trdy <= setif(wr_cntr(addr_range)/=rd_cntr(addr_range) or wr_cntr(0)=rd_cntr(0);

	dst_irdy1 <= setif(wr_cntr(addr_range'range)/=rd_cntr(addr_range'range);
	feed_ena  <= dst_trdy or not (dst_irdy or not check_dov);
	process(dst_clk)
	begin
		if rising_edge(dst_clk) then
			if dst_frm='0' then
				if dst_mode='0' then
					rd_cntr <= wr_cntr;
				else	
					rd_cntr <= to_unsigned(dst_offset, rd_cntr'length);
				end if;
			else
				if feed_ena='1' then
					if dst_irdy1='1' or not check_dov then
						if gray_code then
							rd_cntr <= std_logic_vector(inc(gray(rd_cntr)));
						else
							rd_cntr <= std_logic_vector(unsigned(rd_cntr)+1);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	dst_ini <= not dst_frm;
	dstirdy_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => setif(out_rgtr,1,0)),
		i => (0 to 0 => '0'))
	port map (
		clk   => dst_clk,
		ini   => dst_ini,
		ena   => feed_ena,
		di(0) => dst_irdy1,
		do(0) => dst_irdy);
end;
