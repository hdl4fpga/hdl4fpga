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
		debug      : boolean := false;
		max_depth  : natural;
		mem_data   : std_logic_vector := (0 to 0 => '-');
		dst_offset : natural := 0;
		src_offset : natural := 0;
		out_rgtr   : boolean := true;
		latency    : natural := 1;
		check_sov  : boolean := false;
		check_dov  : boolean := false;
		gray_code  : boolean := true);
	port (
		src_clk   : in  std_logic;
		src_mode  : in  std_logic := '0';
		src_frm   : in  std_logic := '1';
		src_irdy  : in  std_logic := '1';
		src_trdy  : buffer std_logic;
		src_data  : in  std_logic_vector;

		dst_clk   : in  std_logic;
		dst_mode  : in  std_logic := '0';
		dst_frm   : in  std_logic := '1';
		dst_irdy  : buffer std_logic;
		dst_trdy  : in  std_logic := '1';
		dst_data  : buffer std_logic_vector;
		tp        : out std_logic_vector(32-1 downto 0));
end;

architecture def of fifo is

	constant addr_length : natural := unsigned_num_bits(max_depth)-1;

	signal wr_ena    : std_logic;
	signal wr_cntr   : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal rd_cntr   : unsigned(0 to addr_length) := to_unsigned(src_offset, addr_length+1);
	signal dst_irdy1 : std_logic;

	signal data : std_logic_vector(0 to src_data'length-1);

	signal dst_ini  : std_logic;
	signal feed_ena : std_logic;

	signal rdata : std_logic_vector(dst_data'range);
begin

	assert max_depth=2**addr_length
	report "fifo_depth should be a power of 2"
	severity FAILURE;

	wr_ena <= src_frm and src_irdy and (src_trdy or setif(not check_sov));
	max_depthgt1_g : if max_depth > 1 generate
		subtype addr_range is natural range 1 to addr_length;
	begin
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
			rd_data => rdata);
		src_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));
	end generate;

	max_depth1_g : if max_depth = 1 generate
		signal rgtr : std_logic_vector(src_data'range);
	begin
		process (src_clk)
		begin
			if rising_edge(src_clk) then
				if wr_ena='1' then
					rgtr <= src_data;
				end if;
			end if;
		end process;

		process (rgtr, dst_clk)
		begin
			if out_rgtr then
				if rising_edge(dst_clk) then
					if feed_ena='1' then
						rdata <= rgtr;
					end if;
				end if;
			else
				rdata <= rgtr;
			end if;
		end process;

		src_trdy <= setif(wr_cntr(0) = rd_cntr(0));
	end generate;

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
						if gray_code and addr_length > 1 then
							if wr_cntr(1 to addr_length)=to_unsigned(2**(addr_length-1), addr_length) then
								wr_cntr(0) <= not wr_cntr(0);
							end if;
							wr_cntr(1 to addr_length) <= unsigned(inc(gray(wr_cntr(1 to addr_length))));
						else
							wr_cntr <= wr_cntr + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	dst_irdy1 <= setif(wr_cntr /= rd_cntr);
	feed_ena  <= dst_trdy or not (dst_irdy or setif(not check_dov));
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
						if gray_code and addr_length > 1 then
							if rd_cntr(1 to addr_length)=to_unsigned(2**(addr_length-1), addr_length) then
								rd_cntr(0) <= not rd_cntr(0);
							end if;
							rd_cntr(1 to addr_length) <= unsigned(inc(gray(rd_cntr(1 to addr_length))));
						else
							rd_cntr <= rd_cntr + 1;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	dst_ini <= not dst_frm;
	dstirdy_e : entity hdl4fpga.align
	generic map (
		n     => 1,
		d     => (0 to 0 => setif(out_rgtr,latency,0)),
		i     => (0 to 0 => '0'))
	port map (
		clk   => dst_clk,
		ini   => dst_ini,
		ena   => feed_ena,
		di(0) => dst_irdy1,
		do(0) => dst_irdy);

	datalat_e : entity hdl4fpga.align
	generic map (
		n  => rdata'length,
		d  => (0 to rdata'length-1 => setif(out_rgtr,latency-1,0)))
	port map (
		clk => dst_clk,
		ena => feed_ena,
		di  => rdata,
		do  => dst_data);

--	tp(16-1 downto 0) <= std_logic_vector(resize(unsigned(dst_data) srl 4, 16));
--	tp(24-1 downto 0) <= std_logic_vector(resize(unsigned(wr_cntr), 12) & resize(unsigned(rd_cntr),  12));
--	tp(24) <= dst_irdy1;

end;
