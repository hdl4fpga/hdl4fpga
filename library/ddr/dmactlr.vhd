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
		ctlr_cyl      : in  std_logic;
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
	constant lat : natural := 2;

	signal ddrdma_bnk  : std_logic_vector(ctlr_b'range);
	signal ddrdma_row  : std_logic_vector(ctlr_a'range);
	signal ddrdma_col  : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal bnk         : std_logic_vector(ctlr_b'range);
	signal row         : std_logic_vector(ctlr_a'range);
	signal col         : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal col_eoc  : std_logic;

	signal load : std_logic;
	signal len_eoc : std_logic;
	signal ctlrdma_irdy : std_logic;
	signal preload_rst : std_logic;
	signal preload_di  : std_logic;
	signal preload_do  : std_logic;
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
		tlen    => dmactlr_tlen,
		len_eoc => len_eoc,
		bnk     => bnk,
		row     => row,
		col     => col,
		col_eoc => col_eoc);

	preload_di  <= not dmactlr_req;
	preload_rst <= not dmactlr_req;
	preload_e : entity hdl4fpga.align 
	generic map (
		n => 1,
		d => (0 to 0 => lat+1),
		i => (0 to 0 => '1'))
	port map (
		clk   => dmactlr_clk,
		rst   => preload_rst,
		di(0) => preload_di,
		do(0) => preload_do);

	b : block
		signal ceoc  : std_logic;
		signal leoc  : std_logic;
	begin
		process (dmactlr_clk)
			type states is (s_run, s_ceoc, s_leoc);
			variable state : states;
		begin
			if rising_edge(dmactlr_clk) then
				case state is
				when s_run =>
					if len_eoc='0' then
						if col_eoc='1' then
							ceoc <= '1';
							leoc <= '0';
						else
							ceoc <= '0';
							leoc <= '1';
						end if;
					else
						ceoc <= '0';
						leoc <= '1';
					end if;

					if len_eoc='0' then
						if col_eoc='1' then
							state := s_ceoc;
						end if;
					end if;

				when s_ceoc =>
					if ctlr_pre='1' then
						ceoc <= '0';
					else
						ceoc <= '1';
					end if;
					leoc <= '0';

					if ctlr_pre='1' then
						state := s_leoc;
					end if;
				when s_leoc =>
					ceoc <= '0';

					if ctlr_act='1' then
						leoc <= '1';
					else
						leoc <= '0';
					end if;

					if ctlr_act='1' then
						state := s_run;
					end if;

				end case;
			end if;
		end process;

		dmactlr_rdy <= len_eoc and leoc;
		ctlr_irdy   <= (not col_eoc and not ceoc) and (not len_eoc or not leoc);
	end block;

	ctlrdma_irdy <= preload_do or ctlr_di_req;

	bnklat_e : entity hdl4fpga.align
	generic map (
		n => ctlr_b'length,
		d => (0 to ctlr_b'length-1 => lat))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => bnk,
		do  => ddrdma_bnk);

	rowlat_e : entity hdl4fpga.align
	generic map (
		n => ctlr_a'length,
		d => (0 to ctlr_a'length-1 => lat))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => row,
		do  => ddrdma_row);

	collat_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => lat))
	port map (
		clk => dmactlr_clk,
		ena => ctlrdma_irdy,
		di  => col,
		do  => ddrdma_col);

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
