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
		latency    : natural := 1;
		dst_offset : natural := 0;
		src_offset : natural := 0;
		out_rgtr   : boolean := true;
		out_rgtren : boolean := false;
		check_sov  : boolean := false;
		check_dov  : boolean := false;
		gray_code  : boolean := true);
	port (
		src_clk    : in  std_logic;
		src_mode   : in  std_logic := '0';
		src_frm    : in  std_logic := '1';
		src_irdy   : in  std_logic := '1';
		src_trdy   : buffer std_logic;
		src_data   : in  std_logic_vector;

		dst_clk    : in  std_logic;
		dst_mode   : in  std_logic := '0';
		dst_frm    : in  std_logic := '1';
		dst_irdy   : buffer std_logic;
		dst_trdy   : in  std_logic := '1';
		dst_data   : buffer std_logic_vector;
		tp         : out std_logic_vector(32-1 downto 0));


end;

architecture def of fifo is

	constant addr_length : natural := unsigned_num_bits(max_depth)-1;

	signal wr_ena    : std_logic;
	signal wr_cntr   : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal rd_cntr   : unsigned(0 to addr_length) := to_unsigned(src_offset, addr_length+1);
	signal dst_irdy1 : std_logic;


	signal dst_ini  : std_logic;
	signal feed_ena : std_logic;

begin

	assert max_depth=2**addr_length
	report "fifo_depth should be a power of 2"
	severity FAILURE;

	wr_ena <= src_frm and src_irdy and (src_trdy or setif(not check_sov));
	max_depthgt1_g : if max_depth > 1 generate
		subtype addr_range is natural range 1 to addr_length;
		signal wdata : std_logic_vector(0 to src_data'length-1);
		signal rdata : std_logic_vector(0 to src_data'length-1);
		signal rd_ena : std_logic;
	begin

		assert not (latency > 1) or out_rgtren or out_rgtr
		report "Latency greater than 1 is not supported on out_regtren"
		severity FAILURE;

		assert not (latency > 3) or out_rgtren or not out_rgtr
		report "Latency greater than 3 is not supported"
		severity FAILURE;

		rd_ena <= feed_ena when out_rgtren else '1';

		wdata <= src_data when not debug else std_logic_vector(resize(unsigned(wr_cntr), wdata'length));
		mem_e : entity hdl4fpga.dpram(def)
		generic map (
			synchronous_rdaddr => false,
			synchronous_rddata => out_rgtr,
			bitrom => mem_data)
		port map (
			wr_clk  => src_clk,
			wr_ena  => wr_ena,
			wr_addr => std_logic_vector(wr_cntr(addr_range)),
			wr_data => wdata, 

			rd_clk  => dst_clk,
			rd_ena  => rd_ena,
			rd_addr => std_logic_vector(rd_cntr(addr_range)),
			rd_data => rdata);

		latency_p : process (rdata, dst_clk)
			variable rdata2 : std_logic_vector(rdata'range);
			variable rdata3 : std_logic_vector(rdata'range);
			variable data   : std_logic_vector(rdata'range);
			variable data2  : std_logic_vector(rdata'range);
			variable data3  : std_logic_vector(rdata'range);
			variable ena    : std_logic;
			variable ena2   : std_logic;
			variable ena3   : std_logic;
		begin
			if rising_edge(dst_clk) then
				case latency is
				when 1 => 
					if ena='1' then
						data := rdata;
					end if;
					ena := feed_ena;
				when 2 =>
					if ena2='1' then
						data2 := data;
						data  := rdata2;
					end if;
					rdata2 := rdata;
					ena2   := ena;
					ena    := feed_ena;
				when 3 =>
					if ena3='1' then
						data3 := data2;
						data2 := data;
						data  := rdata3;
					end if;
					rdata3 := rdata2;
					rdata2 := rdata;
					ena3   := ena2;
					ena2   := ena;
					ena    := feed_ena;
				when others =>
				end case;
			end if;

			if out_rgtr and not out_rgtren then
				case latency is
				when 1 => 
					dst_data <= word2byte(data & rdata, ena);
				when 2 =>
					dst_data <= word2byte(
				   --   00      01     10     11     
						data2 & data & data & rdata2, ena & ena2);
				when 3 =>
					dst_data <= word2byte(
				   --   000     001     010     011    100     101     110      111
						data3 & data2 & data2 & data & data2 & data  & data & rdata3, ena & ena2 & ena3);
				when others =>
				end case;
			else
				dst_data <= rdata;
			end if;
		end process;

--		dst_irdy_p : process (rdata, dst_clk)
--			variable q : std_logic_vector(0 to (0 to 0 => setif(out_rgtr,setif(out_rgtren, 1, latency),0)));
--		begin
--			if rising_edge(dst_clk) then
--				if dst_ini='1' then
--					q := (others => '0');
--				elsif feed_ena='1' then
--					q(0) := dst_irdy1;
--					for i in q'range loop
--						if q(i)='1' then
--							if i+1 < q'length then
--								if q(i+1)='1' then
--									exit;
--								else
--									q(i+1) := q(i);
--									q(i)   := '0';
--								end if;
--							end if;
--						end if;
--					end loop;
--				end if;
--				dst_irdy <= q(q'right);
--			end if;
--		end process;

		src_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));
	end generate;

	max_depth1_g : if max_depth = 1 generate
		signal rgtr : std_logic_vector(src_data'range);
	begin

		assert not (latency > 1)
		report "Latency greater than 1 is not supported"
		severity FAILURE;

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
						dst_data <= rgtr;
					end if;
				end if;
			else
				dst_data <= rgtr;
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
--	feed_ena  <= (dst_trdy or not (dst_irdy or setif(not check_dov)));
--	feed_ena  <= dst_trdy or (not dst_irdy and setif(check_dov) and dst_irdy1);
	feed_ena  <= dst_trdy or (not dst_irdy and not setif(check_dov)) or (not dst_irdy and dst_irdy1);
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
		d     => (0 to 0 => setif(out_rgtr,setif(out_rgtren, 1, latency),0)),
		i     => (0 to 0 => '0'))
	port map (
		clk   => dst_clk,
		ini   => dst_ini,
		ena   => feed_ena,
		di(0) => dst_irdy1,
		do(0) => dst_irdy);

--	tp(16-1 downto 0) <= std_logic_vector(resize(unsigned(dst_data) srl 4, 16));
--	tp(24-1 downto 0) <= std_logic_vector(resize(unsigned(wr_cntr), 12) & resize(unsigned(rd_cntr),  12));
--	tp(24) <= dst_irdy1;

end;
