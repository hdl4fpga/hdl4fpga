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

entity dmactlr is
	generic (
		no_latency    : boolean := false;
		size          : natural);
	port (
		dmactlr_clk   : in  std_logic;
		dmactlr_req   : in  std_logic;
		dmactlr_rdy   : buffer std_logic;
		dmactlr_we    : in  std_logic;
		dmactlr_iaddr : in  std_logic_vector;
		dmactlr_ilen  : in  std_logic_vector;
		dmactlr_taddr : out std_logic_vector;
		dmactlr_tlen  : out std_logic_vector;

		ctlr_inirdy   : in std_logic;
		ctlr_refreq   : in std_logic;

		ctlr_irdy     : buffer std_logic;
		ctlr_trdy     : in  std_logic;
		ctlr_rw       : out std_logic := '0';
		ctlr_act      : in  std_logic;
		ctlr_pre      : in  std_logic;
		ctlr_idl      : in  std_logic;
		ctlr_b        : out std_logic_vector;
		ctlr_a        : out std_logic_vector;
		ctlr_di_req   : in  std_logic;
		ctlr_di       : in  std_logic_vector;
		ctlr_do_trdy  : in  std_logic_vector;
		ctlr_do       : in  std_logic_vector;
		ctlr_dm       : out std_logic_vector;

		dst_clk       : in  std_logic;
		dst_irdy      : out std_logic;
		dst_trdy      : in  std_logic;
		dst_do        : out std_logic_vector);

end;

architecture def of dmactlr is

	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_col   : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal bnk          : std_logic_vector(ctlr_b'range);
	signal row          : std_logic_vector(ctlr_a'range);
	signal col          : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal col_eoc      : std_logic;

	signal load         : std_logic;
	signal tlen         : std_logic_vector(dmactlr_tlen'range);
	signal ddrdma_ceoc  : std_logic;
	signal ddrdma_leoc  : std_logic;
	signal len_eoc      : std_logic;
	signal ctlrdma_irdy : std_logic;
begin

	process (dmactlr_clk)
	begin
		if rising_edge(dmactlr_clk) then
			load <= not dmactlr_req;
		end if;
	end process;

	dma_e : entity hdl4fpga.ddrdma
	port map (
		clk     => dmactlr_clk,
		load    => load,
		ena     => ctlrdma_irdy,
		iaddr   => dmactlr_iaddr,
		ilen    => dmactlr_ilen,
		taddr   => dmactlr_taddr,
		tlen    => tlen,
		len_eoc => len_eoc,
		bnk     => bnk,
		row     => row,
		col     => col,
		col_eoc => col_eoc);
	dmactlr_tlen <= tlen;

	latency_b: block
		signal src_irdy : std_logic;
		signal src_trdy : std_logic;
		signal src_data : std_logic_vector(dmactlr_tlen'length+bnk'length+row'length+col'length+2-1 downto 0);
		signal dst_irdy : std_logic;
		signal dst_trdy : std_logic;
		signal dst_data : std_logic_vector(src_data'range);
	begin
		src_irdy <= not load;
		src_data <= len_eoc & tlen & col_eoc & bnk & row & col;

		dst_trdy <= not ctlr_idl;
		lat_e : entity hdl4fpga.fifo
		generic map (
			size => 4,
			synchronous_rddata => false)
		port map (
			src_frm  => dmactlr_req,
			src_clk  => dmactlr_clk,
			src_irdy => src_irdy, 
			src_trdy => ctlrdma_irdy, 
			src_data => src_data,

			dst_clk  => dmactlr_clk,
			dst_irdy => dst_irdy, 
			dst_trdy => dst_trdy, 
			dst_data => dst_data);


		process(dst_data)
			variable tmp : unsigned(dst_data'range);
		begin
			tmp := unsigned(dst_data);
			ddrdma_col  <= std_logic_vector(tmp(ddrdma_col'range));
			tmp := tmp ror ddrdma_col'length;
			ddrdma_row  <= std_logic_vector(tmp(ddrdma_row'range));
			tmp := tmp ror ddrdma_row'length;
			ddrdma_bnk  <= std_logic_vector(tmp(ddrdma_bnk'range));
			tmp := tmp ror ddrdma_bnk'length;
			ddrdma_ceoc <= tmp(0);
			tmp := tmp ror 1;
			ddrdma_leoc <= tmp(0);
		end process;

	end block;

	process (dmactlr_req, ddrdma_ceoc, ddrdma_leoc, ctlr_idl, dmactlr_clk)
		type states is (a, b, c, d);
		variable state : states;
		variable irdy : std_logic;
	begin
		if rising_edge(dmactlr_clk) then
			case state is
			when a =>
				if ddrdma_leoc='1' then
					state := d;
				elsif ddrdma_ceoc='1' then
					state := b;
				else
					state := a;
				end if;
			when b =>
				if ctlr_idl='1' then
					state := c;
				end if;
			when c =>
				if ctlr_idl='0' then
					state := a;
				end if;
			when d => 
				if ddrdma_leoc='0' then
					state := a;
				end if;
			end case;
		end if;

		case state is
		when a =>
			if ddrdma_leoc='1' then
				ctlr_irdy <= '0' and dmactlr_req;
			elsif ddrdma_ceoc='1' then
				ctlr_irdy <= '0' and dmactlr_req;
			else
				ctlr_irdy <= '1' and dmactlr_req;
			end if;
			dmactlr_rdy <= '0';
		when b =>
			if ctlr_idl='0' then 
				ctlr_irdy <= '0' and dmactlr_req;
			else
				ctlr_irdy <= '1' and dmactlr_req;
			end if;
			dmactlr_rdy <= '0';
		when c =>
			ctlr_irdy <= '1' and dmactlr_req;
			dmactlr_rdy <= '0';
		when d =>
			if ddrdma_leoc='0' then
				ctlr_irdy <= '1' and dmactlr_req;
			else
				ctlr_irdy <= '0' and dmactlr_req;
			end if;
			dmactlr_rdy <= '1';

		end case;
	end process;

	ctlr_a <= std_logic_vector(resize(unsigned(ddrdma_col & '0'), ctlr_a'length)) when ctlr_act='0' else ddrdma_row;
	ctlr_b <= ddrdma_bnk;

	mem_e : entity hdl4fpga.fifo
	generic map (
		size => size)
	port map (
		src_clk  => dmactlr_clk,
		src_irdy => ctlr_di_req, 
		src_data => ctlr_do,

		dst_clk  => dst_clk,
		dst_irdy => dst_irdy, 
		dst_trdy => dst_trdy, 
		dst_data => dst_do);
end;
