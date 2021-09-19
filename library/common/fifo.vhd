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
		async_mode : boolean := false;
		max_depth  : natural;
		mem_data   : std_logic_vector := (0 to 0 => '-');
		latency    : natural := 1;
		dst_offset : natural := 0;
		src_offset : natural := 0;
		check_sov  : boolean := false;
		check_dov  : boolean := false;
		gray_code  : boolean := false);
	port (
		src_clk    : in  std_logic;
		src_mode   : in  std_logic := '0';
		src_frm    : in  std_logic := '1';
		src_writ   : in  std_logic := '0';
		src_auto   : in  std_logic := '1';
		src_irdy   : in  std_logic := '1';
		src_trdy   : buffer std_logic;
		src_data   : in  std_logic_vector;

		rollback : in  std_logic := '0';
		commit   : in  std_logic := '1';
		overflow : out std_logic := '0';

		dst_clk    : in  std_logic;
		dst_mode   : in  std_logic := '0';
		dst_frm    : in  std_logic := '1';
		dst_irdy   : buffer std_logic;
		dst_trdy   : in  std_logic := '1';
		dst_data   : buffer std_logic_vector);
end;

architecture def of fifo is

	constant addr_length : natural := unsigned_num_bits(max_depth)-1;

	signal wr_ena    : std_logic;
	signal wr_ptr    : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal wr_cntr   : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal wr_cmp    : unsigned(0 to addr_length) := to_unsigned(dst_offset, addr_length+1);
	signal rd_cntr   : unsigned(0 to addr_length) := to_unsigned(src_offset, addr_length+1);
	signal rd_cmp    : unsigned(0 to addr_length) := to_unsigned(src_offset, addr_length+1);
	signal dst_irdy1 : std_logic;

	signal feed_ena  : std_logic;

begin

	assert max_depth=2**addr_length
	report "fifo_depth should be a power of 2"
	severity FAILURE;

	wr_ena <= src_frm and ((src_irdy and src_auto) or src_writ) and (src_trdy or setif(not check_sov));
	max_depthgt1_g : if max_depth > 1 generate

		subtype addr_range is natural range 1 to addr_length;

		signal wdata   : std_logic_vector(0 to src_data'length-1);
		signal rdata   : std_logic_vector(0 to src_data'length-1);
		signal dst_ini : std_logic;

	begin

		wdata <= src_data;
		mem_e : entity hdl4fpga.dpram(def)
		generic map (
			synchronous_rdaddr => false,
			synchronous_rddata => setif(latency > 0, true, false),
			bitrom => mem_data)
		port map (
			wr_clk  => src_clk,
			wr_ena  => wr_ena,
			wr_addr => std_logic_vector(wr_cntr(addr_range)),
			wr_data => wdata, 

			rd_clk  => dst_clk,
			rd_addr => std_logic_vector(rd_cntr(addr_range)),
			rd_data => rdata);

		src_trdy <= 
			setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0)) when not async_mode else
			setif(wr_cntr(addr_range) /= rd_cmp(addr_range)  or wr_cntr(0) = rd_cmp(0));

		dst_ini <= not to_stdulogic(to_bit(dst_frm)) or not to_stdulogic(to_bit(src_frm));


		latencygt1_g : if latency > 1 generate
			signal fill  : std_logic;
			signal q_reg : unsigned(0 to latency-1) := (others => '0'); -- XILINX synthesys BUG
			signal v_req : unsigned(0 to latency-1) := (others => '0'); -- XILINX synthesys BUG
		begin

			dstirdy_p : process (dst_clk)
				variable q    : unsigned(0 to latency-1) := (others => '0');
				variable b    : unsigned(0 to latency-1) := (others => '0');
				variable v    : unsigned(0 to latency-1) := (others => '0');
				variable slr  : unsigned(0 to dst_data'length*v'length-1);
				variable data : unsigned(0 to dst_data'length*q'length-1);
			begin
				if rising_edge(dst_clk) then
					slr(dst_data'length*((v'length-1)-1) to dst_data'length*((v'length-1))-1) := unsigned(rdata);

					if dst_ini='1' then
						q := (others => '0');
						b := (others => '0');
						v := (others => '0');
					else
						if to_bit(b(b'right))='0' then
							if dst_irdy1='0' then
								if dst_trdy='1' then
									b := b ror 1;
									b(b'right) := '0';
								end if;
							elsif dst_trdy='0' then
								if fill='1' then
									b(b'right) := '1';
								end if;
							end if;
						elsif dst_irdy1='0' then
							if dst_trdy='1' then
								b(b'right) := '0';
								b := b rol 1;
							end if;
						elsif dst_trdy='0' then
							if fill='1' then
								b := b rol 1;
								b(b'right) := '1';
							end if;
						end if;

						v := v_req;  -- avoids XILINX ISE's synthesys BUG of using latch instead of register
						v(v'length-1) := (dst_trdy and (dst_irdy1 or not setif(check_dov))) or (fill and dst_irdy1);

						q := q_reg;  -- avoids XILINX ISE's synthesys BUG of using latch instead of register
						if dst_irdy='1' and dst_trdy='1' then
							data := data sll dst_data'length;
							q    := q sll 1;
						end if;

						if to_bit(v(0))='1' then
							for i in q'range loop
								if to_bit(q(i))='0' then
									data(i*dst_data'length to (i+1)*dst_data'length-1) := slr(0 to dst_data'length-1);
									q(i) := '1';
									exit;
								end if;
							end loop;
						end if;
					end if;

					fill     <= not b(0);
					dst_irdy <= q(0);
					dst_data <= std_logic_vector(data(0 to dst_data'length-1));

					slr      := slr sll dst_data'length;
					v        := v sll 1;

					q_reg <= q;   -- avoids XILINX ISE's synthesys BUG of using latch instead of register
					v_req <= v;   -- avoids XILINX ISE's synthesys BUG of using latch instead of register
				end if;
			end process;
			feed_ena <= to_stdulogic(to_bit(dst_trdy)) or (fill and dst_irdy1);
		end generate;

		latency1_g : if latency=1 generate
			signal fill : std_logic;
			signal data : std_logic_vector(dst_data'range);
			signal q    : std_logic := '0';
			signal v    : std_logic := '0';
		begin

			dstirdy_p : process (dst_clk)
			begin
				if rising_edge(dst_clk) then
					if dst_ini='1' then
						q <= '0';
						v <= '0';
					else
						if v='1' then
							q <= '1';
						elsif (dst_trdy and dst_irdy)='1' then
							q <= '0';
						end if;

						if v='1' then
							data <= rdata;
						end if;
						v <= (dst_trdy and (dst_irdy1 or not setif(check_dov))) or (fill and dst_irdy1);
					end if;
				end if;
			end process;

			dst_irdy <= v or q;
			fill     <= not v and not q;
			dst_data <= primux(rdata & data, v & q, data);
			feed_ena <= to_stdulogic(to_bit(dst_trdy)) or (fill and dst_irdy1);
		end generate;

		nolatency_g : if latency = 0 generate
			feed_ena <= to_stdulogic(to_bit(dst_trdy));
			dst_irdy <= dst_irdy1;
			dst_data <= rdata;
		end generate;

	end generate;

	max_depth1_g : if max_depth = 1 generate
	begin

		process (src_clk)
		begin
			if rising_edge(src_clk) then
				if wr_ena='1' then
					dst_data <= src_data;
				end if;
			end if;
		end process;

		src_trdy <= setif(wr_cntr(0) = rd_cntr(0));
		dst_irdy <= dst_irdy1;

	end generate;

	process(src_clk)
		variable succ : unsigned(wr_cntr'range);
	begin
		if rising_edge(src_clk) then
			if src_frm='0' then
				if src_mode='0' then
					if async_mode then
						wr_cntr <= rd_cmp;
					else
						wr_cntr <= rd_cntr;
					end if;
				else	
					wr_cntr <= to_unsigned(src_offset, wr_cntr'length);
				end if;
			elsif rollback='1' then
				wr_cntr  <= wr_ptr;
				overflow <= '0';
			else
				succ := wr_cntr;
				if src_irdy='1' then
					if src_trdy='1' or not check_sov then
						if gray_code and addr_length > 1 then
							if wr_cntr(1 to addr_length)=to_unsigned(2**(addr_length-1), addr_length) then
--								wr_cntr(0) <= not wr_cntr(0);
								succ(0) := not succ(0);
							end if;
--							wr_cntr(1 to addr_length) <= unsigned(inc(gray(wr_cntr(1 to addr_length))));
							succ(1 to addr_length) := unsigned(inc(gray(succ(1 to addr_length))));
						else
--							wr_cntr <= wr_cntr + 1;
							succ := succ + 1;
						end if;
					end if;
					if src_trdy='0' and not check_sov then
						overflow <= '1';
					else
						overflow <= '0';
					end if;
				end if;
				wr_cntr <= succ;
				if commit='1' then
					wr_ptr   <= succ;
					overflow <= '0';
				end if;
			end if;
		end if;
	end process;

	dst_irdy1 <= 
		setif(wr_ptr /= rd_cntr) when not async_mode else 
		setif(wr_cmp /= rd_cntr);
	process(dst_clk)
	begin
		if rising_edge(dst_clk) then
			if dst_frm='0' then
				if dst_mode='0' then
					if async_mode then
						rd_cntr <= wr_cmp;
					else
						rd_cntr <= wr_ptr;
					end if;
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

	async_b : block
		signal rd_req, rd_rdy : bit;
		signal wr_req, wr_rdy : bit;
		signal rd_cpy : unsigned(rd_cmp'range);
		signal wr_cpy : unsigned(wr_cmp'range);
	begin
		process(src_clk)
			variable cpied : bit;
			variable req   : bit;
			variable rdy   : bit;
		begin
			if rising_edge(src_clk) then
				if (req xor wr_rdy)='1' then
					if cpied='0' then
						wr_cpy <= wr_ptr;
						cpied  := '1';
					else
						wr_rdy <= wr_req;
						cpied  := '0';
					end if;
				end if;
				if (rdy xor rd_req)='0' then
					rd_cmp <= rd_cpy;
					rd_req <= not rdy;
				end if;
				req := wr_req;
				rdy := rd_rdy;
			end if;
		end process;

		process(dst_clk)
			variable cpied : bit;
			variable req   : bit;
			variable rdy   : bit;
		begin
			if rising_edge(dst_clk) then
				if (req xor rd_rdy)='1' then
					if cpied='0' then
						rd_cpy <= rd_cntr;
						cpied  := '1';
					else
						rd_rdy <= rd_req;
						cpied  := '0';
					end if;
				end if;
				if (rdy xor wr_req)='0' then
					wr_cmp <= wr_cpy;
					wr_req <= not rdy;
				end if;
				req := rd_req;
				rdy := wr_rdy;
			end if;
		end process;
	end block;

end;
