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

entity dmactrl is
	generic (
		size     : natural);
	port (

		dmactlr_rst   : in  std_logic;
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

		ctlr_irdy     : out std_logic;
		ctlr_trdy     : in  std_logic;
		ctlr_rw       : out std_logic;
		ctlr_act      : in  std_logic;
		ctlr_cas      : in  std_logic;
		ctlr_b        : out std_logic_vector;
		ctlr_a        : out std_logic_vector;
		ctlr_di_irdy  : out std_logic;
		ctlr_di_trdy  : in  std_logic;
		ctlr_di       : in  std_logic_vector;
		ctlr_do_rdy   : out std_logic_vector;
		ctlr_do       : in  std_logic_vector;
		ctlr_dm       : out std_logic_vector;

		dst_clk       : in  std_logic;
		dst_irdy      : out std_logic;
		dst_trdy      : in  std_logic;
		dst_do        : out std_logic_vector);

end;


architecture def of dmactrl is
	signal dmactlr_frm : std_logic;
	signal ddrdma_bnk  : std_logic_vector(ctlr_b'range);
	signal ddrdma_row  : std_logic_vector(ctlr_a'range);
	signal ddrdma_col  : std_logic_vector(ctlr_a'range);
begin

	dma_e : entity hdl4fpga.ddrdma
	port map (
		ddrdma_frm   => dmactlr_frm,
		ddrdma_clk   => dmactlr_clk,
		ddrdma_irdy  => dmactlr_irdy,
		ddrdma_trdy  => dmactlr_trdy,
		ddrdma_iaddr => dmactlr_iaddr,
		ddrdma_ilen  => dmactlr_ilen,
		ddrdma_taddr => dmactlr_taddr,
		ddrdma_tlen  => dmactlr_tlen,
		ddrdma_bnk   => ddrdma_bnk,
		ddrdma_row   => ddrdma_row,
		ddrdma_col   => ddrdma_col,

		ctlr_irdy    => ctlr_irdy,
		ctlr_trdy    => ctlr_trdy,
		ctlr_refreq  => ctlr_refreq);

	ctlr_a <= ddrdma_col when ctlr_cas='1' else ddrdma_row;
	ctlr_b <= ddrdma_bnk;

	mem_e : entity hdl4fpga.fifo
	generic map (
		size => size)
	port map (
		src_clk  => dmactlr_clk,
		src_irdy => ctlr_di_trdy, 
		src_trdy => ctlr_di_irdy, 
		src_data => ctlr_do,

		dst_clk  => dst_clk,
		dst_irdy => dst_irdy, 
		dst_trdy => dst_trdy, 
		dst_data => dst_do);
end;
