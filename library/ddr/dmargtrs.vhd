
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

entity dmargtr is
	port (
		clk    : in  std_logic;
		rrid   : in  std_logic_vector;
		raddr  : out std_logic_vector;
		rlen   : out std_logic_vector;

		wrid   : in  std_logic_vector;
		we     : in  std_logic;
		waddr  : in  std_logic_vector;
		wlen   : in  std_logic_vector);

end;

architecture def of dmargtr is
begin

	mem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => clk,
		wr_ena  => we,
		wr_addr => wrid 
		wr_data => input_data,

		rd_clk  => clk,
		rd_addr => std_logic_vector(addrb),
		rd_data => fifo_data);

	process (dmactlr_clk)
		variable q : std_logic;
	begin
		if rising_edge(dmactlr_clk) then
			ref_req <= setif(ctlr_refreq='1' and q='0');
			q := ctlr_refreq;
		end if;
	end process;

	process (dmactlr_clk, ceoc, ref_req, leoc)
		variable q : std_logic;
		variable s : std_logic;
	begin
		if rising_edge(dmactlr_clk) then
			if ctlr_idl='0' then
				if ceoc='1' then
					q := '1';
				elsif ref_req='1' then
					q := '1';
				end if;
			else
				q := '0';
			end if;
			s := setif(ceoc='1' or ref_req='1', not leoc, q);
			load   <= setif(s='1', '1', not dmactlr_req);
			ilen   <= word2byte(dmactlr_ilen  & tlen,  s);
			iaddr  <= word2byte(dmactlr_iaddr & taddr, s);
		end if;
		reload <= setif(ceoc='1' or ref_req='1', not leoc, q);
	end process;

	dma_e : entity hdl4fpga.ddrdma
	port map (
		clk     => dmactlr_clk,
		load    => load,
		ena     => ctlrdma_irdy,
		iaddr   => iaddr,
		ilen    => ilen,
		taddr   => taddr,
		tlen    => tlen,
		len_eoc => leoc,
		bnk     => bnk,
		row     => row,
		col     => col,
		col_eoc => ceoc);

	process (dmactlr_clk)
		variable q : unsigned(0 to lat+1);
	begin
		if rising_edge(dmactlr_clk) then
			if dmactlr_req='0' then
				q := (others => '1');
			elsif reload='1' then
				q := (others => '1');
			elsif ctlr_idl='0' then
				q := q sll 1;
			end if;
			preload <= not ctlr_idl and q(0);
		end if;
	end process;

	ctlrdma_irdy <= preload or ctlr_di_req;

	tlenlat_e : entity hdl4fpga.align
	generic map (
		n => dmactlr_tlen'length,
		d => (0 to dmactlr_tlen'length-1 => lat+1))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => tlen,
		do  => dmactlr_tlen);

	taddrlat_e : entity hdl4fpga.align
	generic map (
		n => dmactlr_taddr'length,
		d => (0 to dmactlr_taddr'length-1 => lat+1))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => taddr,
		do  => dmactlr_taddr);

	bnklat_e : entity hdl4fpga.align
	generic map (
		n => ctlr_b'length,
		d => (0 to ctlr_b'length-1 => 0))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => bnk,
		do  => ddrdma_bnk);

	ddrdma_row <= row;

	collat_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => lat))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => col,
		do  => ddrdma_col);

	eoclat_e : entity hdl4fpga.align
	generic map (
		n => 3,
		d => (0 to 3-1 => lat-1))
	port map (
		clk   => dmactlr_clk,
		di(0) => ceoc,
		di(1) => leoc,
		di(2) => ref_req,
		do(0) => col_eoc,
		do(1) => len_eoc,
		do(2) => refreq);

	process (dmactlr_clk)
		variable s : std_logic;
	begin
		if rising_edge(dmactlr_clk) then
			ctlr_a <= word2byte(ddrdma_row & std_logic_vector(resize(unsigned(ddrdma_col & '0'), ctlr_a'length)), s);
			ctlr_b <= ddrdma_bnk;
			if ctlr_idl='1' then
				s := '0';
			elsif s='0' then
				s := not ctlr_act;
			end if;
		end if;
	end process;

	process (dmactlr_req, refreq, col_eoc, len_eoc, ctlr_idl, dmactlr_clk)
		type states is (a, b, c, d);
		variable state : states;
	begin
		if rising_edge(dmactlr_clk) then
			case state is
			when a =>
				if len_eoc='1' then
					state := d;
				elsif refreq='1' then
					state := b;
				elsif col_eoc='1' then
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
				if len_eoc='0' then
					state := a;
				end if;
			end case;
		end if;

		case state is
		when a =>
			if len_eoc='1' then
				ctlr_irdy <= '0';
			elsif col_eoc='1' then
				ctlr_irdy <= '0';
			else
				ctlr_irdy <= dmactlr_req;
			end if;
			dmactlr_rdy <= '0';
		when b =>
			if ctlr_idl='0' then 
				ctlr_irdy <= '0';
			else
				ctlr_irdy <= dmactlr_req;
			end if;
			dmactlr_rdy <= '0';
		when c =>
			ctlr_irdy <= dmactlr_req;
			dmactlr_rdy <= '0';
		when d =>
			if len_eoc='0' then
				ctlr_irdy <= dmactlr_req;
			else
				ctlr_irdy <= '0';
			end if;
			dmactlr_rdy <= '1';
		end case;
	end process;



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
