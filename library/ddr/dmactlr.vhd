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

		dmactlr_rst   : in  std_logic;
		dmactlr_frm   : in  std_logic;
		dmactlr_clk   : in  std_logic;
		dmactlr_irdy  : in  std_logic;
		dmactlr_trdy  : out std_logic;
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
		ctlr_cas      : in  std_logic;
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
	signal ddrdma_bnk  : std_logic_vector(ctlr_b'range);
	signal ddrdma_row  : std_logic_vector(ctlr_a'range);
	signal ddrdma_col  : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal bnk         : std_logic_vector(ctlr_b'range);
	signal row         : std_logic_vector(ctlr_a'range);
	signal col         : std_logic_vector(dmactlr_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
	signal ddrdma_beoc : std_logic;
	signal ddrdma_reoc : std_logic;
	signal ddrdma_ceoc : std_logic;
	signal ddrdma_eoc  : std_logic;

	signal ena_lag     : std_logic;
	signal enai        : std_logic;
	signal enao        : std_logic;
begin

	dma_e : entity hdl4fpga.ddrdma
	port map (
		ddrdma_clk   => dmactlr_clk,
		ddrdma_frm   => dmactlr_frm,
		ddrdma_irdy  => dmactlr_irdy,
		ddrdma_trdy  => dmactlr_trdy,
		ddrdma_iaddr => dmactlr_iaddr,
		ddrdma_ilen  => dmactlr_ilen,
		ddrdma_taddr => dmactlr_taddr,
		ddrdma_tlen  => dmactlr_tlen,
		ddrdma_bnk   => bnk,
		ddrdma_row   => row,
		ddrdma_col   => col,
		ddrdma_beoc  => ddrdma_beoc,
		ddrdma_reoc  => ddrdma_reoc,
		ddrdma_ceoc  => ddrdma_ceoc,

		ctlr_irdy    => ctlr_irdy,
		ctlr_trdy    => ena_lag,
		ctlr_refreq  => ctlr_refreq);

	ena_lag <= enao or ctlr_di_req;
	enai   <= not ctlr_irdy;
	ena_e : entity hdl4fpga.align 
	generic map (
		n => 1,
		d => (0 to 0 => 3))
	port map (
		clk => dmactlr_clk,
		di(0) => enai,
		do(0) => enao);

	bnklag_e : entity hdl4fpga.align
	generic map (
		n => bnk'length,
		d => (0 to bnk'length-1 => 2))
	port map (
		clk => dmactlr_clk,
		ena => ena_lag,
		di  => bnk,
		do  => ddrdma_bnk);

	rowlag_e : entity hdl4fpga.align
	generic map (
		n => row'length,
		d => (0 to row'length-1 => 2))
	port map (
		clk => dmactlr_clk,
		ena => ena_lag,
		di  => row,
		do  => ddrdma_row);

	collag_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => 3))
	port map (
		clk => dmactlr_clk,
		ena => ena_lag,
		di  => col,
		do  => ddrdma_col);

	ctlr_a <= std_logic_vector(resize(unsigned(ddrdma_col), ctlr_a'length)) when ctlr_act='0' else ddrdma_row;
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
