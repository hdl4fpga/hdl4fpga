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
	port (
		dev_clks     : in  std_logic_vector;
		dev_reqs     : in  std_logic_vector;
		dev_addr     : in  std_logic_vector;
		dev_len      : in  std_logic_vector;

		dma_clk      : in  std_logic;
		dmacfg_req   : in  std_logic_vector;
		dmacfg_rdy   : in  std_logic_vector;
		devtrans_req : in  std_logic_vector;
		devtrans_rdy : in  std_logic_vector;

		ctlr_clk     : in  std_logic;

		ctlr_inirdy  : in  std_logic;
		ctlr_refreq  : in  std_logic;

		ctlr_irdy    : out  std_logic;
		ctlr_trdy    : in  std_logic;
		ctlr_rw      : out std_logic;
		ctlr_b       : out std_logic_vector;
		ctlr_a       : out std_logic_vector;
		ctlr_di_dv   : out std_logic;
		ctlr_di_req  : in  std_logic;
		ctlr_do_dv   : in  std_logic_vector;
		ctlr_act     : in  std_logic;
		ctlr_pre     : in  std_logic;
		ctlr_idl     : in  std_logic;
		ctlr_dm      : out std_logic_vector := (others => '0');
		ctlr_di      : out std_logic_vector;
		ctlr_do      : in  std_logic_vector);

end;

architecture def of dmactlr is

	signal dmargtr_dv     : std_logic;
	signal dmargtr_rid    : std_logic_vector(0 to unsigned_num_bits(dev_clks'length-1)-1);
	signal dmargtr_addr   : std_logic_vector(0 to dev_addr'length/dev_clks'length-1);
	signal dmargtr_len    : std_logic_vector(0 to  dev_len'length/dev_clks'length-1);

	signal dmacfg_req     : std_logic_vector(dev_clks'range);
	signal dmacfg_rdy     : std_logic_vector(dev_clks'range);

	signal dmatrans_rid   : std_logic_vector(dmargtr_rid'range);
	signal dmatrans_iaddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_ilen  : std_logic_vector(dmargtr_len'range);
	signal dmatrans_taddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_tlen  : std_logic_vector(dmargtr_len'range);

	signal dmatrans_req   : std_logic;
	signal dmatrans_rdy   : std_logic;
begin

	dmargtrgnt_e : entity hdl4fpga.grant
	port map (
		gnt_clk => dma_clk,
		gnt_rdy => dmargtr_dv,

		dev_clk => dev_clks,
		dev_req => dmacfg_req,
		dev_gnt => dmacfg_gnt,
		dev_rdy => dmacfg_rdy);

	process (dma_clk)
		variable dv : std_logic;
	begin
		if rising_edge(dma_clk) then
			dmartgr_dv   <= setif(dmacfg_gnt/=(dmacfg_gnt'range => '0') and not dv;
			dmargtr_id   <= encoder(dmacfg_gnt);
			dmargtr_addr <= word2byte (dma_addr, dmacfg_gnt);
			dmargtr_len  <= word2byte (dma_len,  dmacfg_gnt);
			dv := setif(dmacfg_gnt/=(dmacfg_gnt'range => '0');
		end if;
	end process;

	dmaaddr_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => dma_clk,
		wr_ena  => dmargtr_dv,
		wr_addr => dmargtr_id,
		wr_data => dmargtr_addr,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => dmatrans_iaddr);

	dmalen_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => dma_clk,
		wr_addr => dmargtr_id,
		wr_ena  => dmargtr_dv,
		wr_data => dmargtr_len,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => dmatrans_ilen);

	dmatransgnt_e : entity hdl4fpga.grant
	port map (
		dev_clk => dev_clks,
		dev_req => devtrans_req,
		dev_gnt => dmatrans_gnt,
		dev_rdy => devtrans_rdy,

		gnt_clk => ctlr_clk,
		gnt_rdy => dmatrans_rdy);

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_inirdy='0' then
				dmatrans_req <= '0';
			else
				dmatrans_req <= setif(dmatrans_gnt /= (dmatrans_gnt'range => '0'));
			end if;
		end if;
	end process;

	dmatrans_e : entity hdl4fpga.dmatrans
	generic map (
		no_latency   => no_latency,
		size => 256)
	port map (
		dmatrans_clk   => ctlr_clk,
		dmatrans_req   => dmatrans_req,
		dmatrans_rdy   => dmatrans_rdy,
		dmatrans_we    => dmatrans_we,
		dmatrans_iaddr => dmatrans_iaddr,
		dmatrans_ilen  => dmatrans_ilen,
		dmatrans_taddr => dmatrans_taddr,
		dmatrans_tlen  => dmatrans_tlen,

		ctlr_inirdy    => ctlr_inirdy,
		ctlr_refreq    => ctlr_refreq,

		ctlr_irdy      => ctlr_irdy,
		ctlr_trdy      => ctlr_trdy,
		ctlr_rw        => ctlr_rw,
		ctlr_act       => ctlr_act,
		ctlr_pre       => ctlr_pre,
		ctlr_idl       => ctlr_idl,
		ctlr_b         => ctlr_b,
		ctlr_a         => ctlr_a,
		ctlr_di_req    => ctlr_di_req,
		ctlr_di        => ctlr_di,
		ctlr_dm        => ctlr_dm,
		ctlr_do_trdy   => ctlr_do_dv,
		ctlr_do        => ctlr_do);

end;
