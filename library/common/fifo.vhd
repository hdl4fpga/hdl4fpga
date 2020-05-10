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
		size : natural;
		synchronous_rddata : boolean := true;
		overflow_check : boolean := true;
		gray_code      : boolean := true);
	port (
		src_clk  : in  std_logic;
		src_frm  : in  std_logic := '1';
		src_irdy : in  std_logic := '1';
		src_trdy : buffer std_logic;
		src_data : in  std_logic_vector;

		dst_clk  : in  std_logic;
		dst_frm  : in  std_logic := '1';
		dst_irdy : buffer std_logic;
		dst_trdy : in  std_logic := '1';
		dst_data : out std_logic_vector);
end;

architecture def of fifo is

	subtype word is std_logic_vector(0 to hdl4fpga.std.max(src_data'length,dst_data'length)-1);
	subtype byte is std_logic_vector(0 to hdl4fpga.std.min(src_data'length,dst_data'length)-1);


	signal dst_ena   : std_logic;
	signal wr_ena    : std_logic;
	signal wr_addr   : std_logic_vector(0 to unsigned_num_bits(size*byte'length/src_data'length-1)-1) := (others => '0');
	signal rd_addr   : std_logic_vector(0 to unsigned_num_bits(size*byte'length/dst_data'length-1)-1) := (others => '0');
	signal dst_irdy1 : std_logic;

	subtype word_addr is std_logic_vector(0 to hdl4fpga.std.min(rd_addr'length,wr_addr'length)-1);
	signal data : std_logic_vector(0 to src_data'length-1);

begin

	wr_ena <= src_frm and src_irdy and src_trdy;
--	data <= (1 to 8 => wr_addr(wr_addr'right-4)) & (1 to 8 => wr_addr(wr_addr'right-5)) & (1 to 8 => wr_addr(wr_addr'right-3)) & (1 to 8 => wr_addr(wr_addr'right));
	data <= std_logic_vector(resize(unsigned(wr_addr(1 to wr_addr'length-1)), data'length));
--	dst_data <= std_logic_vector(resize(unsigned(rd_addr), data'length));
--	data <= src_data;
	mem_e : entity hdl4fpga.dpram(def)
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => synchronous_rddata)
	port map (
		wr_clk  => src_clk,
		wr_ena  => wr_ena,
		wr_addr => wr_addr,
--		wr_data => src_data, 
		wr_data => data, 

		rd_clk  => dst_clk,
		rd_addr => rd_addr,
		rd_data => dst_data);

	process(src_clk)
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				wr_addr <= (others => '0');
				wr_addr(word_addr'range) <= rd_addr(word_addr'range);
			else
				if src_irdy='1' then
					if src_trdy='1' then
						if gray_code then
							wr_addr <= std_logic_vector(inc(gray(wr_addr)));
						else
							wr_addr <= std_logic_vector(unsigned(wr_addr)+1);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	src_trdy <= 
		'1' when not overflow_check else
		setif(inc(wr_addr(word_addr'range))/=rd_addr(word_addr'range)) when gray_code else
		setif(unsigned(wr_addr(word_addr'range))+1/=unsigned(rd_addr(word_addr'range)));

	dst_irdy1 <= (setif(wr_addr(word_addr'range)/=rd_addr(word_addr'range)) or setif(not overflow_check));
	process(dst_clk)
	begin
		if rising_edge(dst_clk) then
			if dst_frm='0' then
				rd_addr <= (others => '0');
--				rd_addr(word_addr'range) <= wr_addr(word_addr'range);
			else
				if dst_trdy='1' then
					if dst_irdy1='1' then
						if gray_code then
							rd_addr <= std_logic_vector(inc(gray(rd_addr)));
						else
							rd_addr <= std_logic_vector(unsigned(rd_addr)+1);
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	dst_ena <= dst_trdy;
	dstirdy_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => setif(synchronous_rddata,1,0)),
		i => (0 to 0 => '0'))
	port map (
		clk   => dst_clk,
		ena   => dst_trdy,
		di(0) => dst_irdy1,
		do(0) => dst_irdy);
end;
