
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

entity dmatrans is
	generic (
		no_latency    : boolean := false;
		size          : natural);
	port (
		dmatrans_clk   : in  std_logic;
		dmatrans_req   : in  std_logic;
		dmatrans_rdy   : buffer std_logic;
		dmatrans_we    : in  std_logic;
		dmatrans_iaddr : in  std_logic_vector;
		dmatrans_ilen  : in  std_logic_vector;
		dmatrans_taddr : out std_logic_vector;
		dmatrans_tlen  : out std_logic_vector;

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
		ctlr_dio_req   : in  std_logic);

end;

architecture def of dmatrans is
	constant lat : natural := setif(no_latency, 1, 2);

	signal ctlrdma_irdy : std_logic;

	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_col   : std_logic_vector(dmatrans_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal bnk          : std_logic_vector(ctlr_b'range);
	signal row          : std_logic_vector(ctlr_a'range);
	signal col          : std_logic_vector(dmatrans_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);

	signal leoc         : std_logic;
	signal ceoc         : std_logic;
	signal col_eoc      : std_logic;
	signal len_eoc      : std_logic;
	signal ilen         : std_logic_vector(dmatrans_ilen'range);
	signal iaddr        : std_logic_vector(dmatrans_iaddr'range);
	signal tlen         : std_logic_vector(dmatrans_tlen'range);
	signal taddr        : std_logic_vector(dmatrans_taddr'range);

	signal load         : std_logic;
	signal reload       : std_logic;
	signal preload      : std_logic;

	signal ref_req      : std_logic;
	signal refreq       : std_logic;
		signal s1 : std_logic;
begin

	ctlr_rw <= dmatrans_we;
	process (dmatrans_clk)
		variable q : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			ref_req <= setif(ctlr_refreq='1' and q='0');
			q := ctlr_refreq;
		end if;
	end process;

	load_p : process (dmatrans_clk, ceoc, ref_req, leoc)
		variable q : std_logic;
		variable s : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_idl='0' then
				if ceoc='1' then
					q := '1';
				elsif ref_req='1' then
					q := '1';
				end if;
			else
				q := '0';
			end if;
			s     := setif(ceoc='1' or ref_req='1', not leoc, q);
			load  <= setif(s='1', '1', not dmatrans_req);
			ilen  <= word2byte(dmatrans_ilen  & tlen,  s);
			iaddr <= word2byte(dmatrans_iaddr & taddr, s);
		end if;
		reload <= setif(ceoc='1' or ref_req='1', not leoc, q);
	end process;

	dma_e : entity hdl4fpga.ddrdma
	port map (
		clk     => dmatrans_clk,
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

	process (dmatrans_clk)
		variable q : unsigned(0 to lat+1);
	begin
		if rising_edge(dmatrans_clk) then
			if dmatrans_req='0' then
				q := (others => '1');
			elsif reload='1' then
				q := (others => '1');
			elsif ctlr_idl='0' then
				q := q sll 1;
			end if;
			preload <= not ctlr_idl and q(0);
		end if;
	end process;

	ctlrdma_irdy <= preload or ctlr_dio_req;

	tlenlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_tlen'length,
		d => (0 to dmatrans_tlen'length-1 => lat+1))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => tlen,
		do  => dmatrans_tlen);

	taddrlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_taddr'length,
		d => (0 to dmatrans_taddr'length-1 => lat+1))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => taddr,
		do  => dmatrans_taddr);

	bnklat_e : entity hdl4fpga.align
	generic map (
		n => ctlr_b'length,
		d => (0 to ctlr_b'length-1 => 0))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => bnk,
		do  => ddrdma_bnk);

	ddrdma_row <= row;

	collat_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => lat))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => col,
		do  => ddrdma_col);

	eoclat_e : entity hdl4fpga.align
	generic map (
		n => 3,
		d => (0 to 3-1 => lat-1))
	port map (
		clk   => dmatrans_clk,
		di(0) => ceoc,
		di(1) => leoc,
		di(2) => ref_req,
		do(0) => col_eoc,
		do(1) => len_eoc,
		do(2) => refreq);

	ctlrba_p : process (dmatrans_clk)
	begin
		if rising_edge(dmatrans_clk) then
			ctlr_a <= word2byte(ddrdma_row & std_logic_vector(resize(unsigned(ddrdma_col & '0'), ctlr_a'length)), s1);
			ctlr_b <= ddrdma_bnk;
			if ctlr_pre='1' then
				s1 <= '0';
			elsif ctlr_idl='1' then
				s1 <= '0';
			elsif s1='0' then
				s1 <= not ctlr_act;
			end if;
		end if;
	end process;

	process (dmatrans_req, refreq, col_eoc, len_eoc, ctlr_idl, dmatrans_clk)
		type states is (a, b, c, d);
		variable state : states;
	begin
		if rising_edge(dmatrans_clk) then
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
				ctlr_irdy <= dmatrans_req;
			end if;
			dmatrans_rdy <= '0';
		when b =>
			if ctlr_idl='0' then 
				ctlr_irdy <= '0';
			else
				ctlr_irdy <= dmatrans_req;
			end if;
			dmatrans_rdy <= '0';
		when c =>
			ctlr_irdy <= dmatrans_req;
			dmatrans_rdy <= '0';
		when d =>
			if len_eoc='0' then
				ctlr_irdy <= dmatrans_req;
			else
				ctlr_irdy <= '0';
			end if;
			dmatrans_rdy <= '1';
		end case;
	end process;

end;
