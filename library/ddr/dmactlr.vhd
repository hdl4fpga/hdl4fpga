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
		no_latency : boolean);
	port (

		dma_clk      : in  std_logic;
		dmacfg_req   : in  std_logic_vector;
		dmacfg_rdy   : out std_logic_vector;
		dev_len      : in  std_logic_vector;
		dev_addr     : in  std_logic_vector;
		dev_we       : in  std_logic_vector;

		dev_req      : in  std_logic_vector;
		dev_rdy      : out std_logic_vector;

		ctlr_clk     : in  std_logic;

		ctlr_inirdy  : in  std_logic;
		ctlr_refreq  : in  std_logic;

		ctlr_irdy    : out  std_logic;
		ctlr_trdy    : in  std_logic;
		ctlr_rw      : out std_logic;
		ctlr_b       : out std_logic_vector;
		ctlr_a       : out std_logic_vector;
		ctlr_r       : out std_logic_vector;
		ctlr_dio_req : in  std_logic;
		ctlr_act     : in  std_logic;
		ctlr_pre     : in  std_logic;
		ctlr_idl     : in  std_logic);

end;

architecture def of dmactlr is

	signal dmargtr_dv     : std_logic;
	signal dmargtr_rdy    : std_logic;
	signal dmargtr_id     : std_logic_vector(0 to unsigned_num_bits(dev_req'length-1)-1);
	signal dmargtr_addr   : std_logic_vector(0 to dev_addr'length/dev_req'length-1);
	signal dmargtr_len    : std_logic_vector(0 to dev_len'length/dev_req'length-1);
	signal dmargtr_we     : std_logic_vector(0 to 0);

	signal dmacfg_gnt     : std_logic_vector(dev_req'range);

	signal dmatrans_rid   : std_logic_vector(dmargtr_id'range);
	signal dmatrans_iaddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_ilen  : std_logic_vector(dmargtr_len'range);
	signal dmatrans_we    : std_logic;
	signal trans_we       : std_logic_vector(0 to 0);
	signal dmatrans_taddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_tlen  : std_logic_vector(dmargtr_len'range);

	signal devtrans_gnt   : std_logic_vector(dev_req'range);
	signal devtrans_req   : std_logic_vector(dev_req'range);
	signal devtrans_rdy   : std_logic_vector(dev_req'range);
	signal dmatrans_req   : std_logic;
	signal dmatrans_rdy   : std_logic;
begin

	dmargtrgnt_e : entity hdl4fpga.grant
	port map (
		rsrc_clk => dma_clk,
		rsrc_rdy => dmargtr_rdy,

		dev_req => dmacfg_req,
		dev_gnt => dmacfg_gnt,
		dev_rdy => dmacfg_rdy);

	process (dma_clk)
		variable dv : std_logic;
	begin
		if rising_edge(dma_clk) then
			if dv='1' then
				dmargtr_rdy <= setif(dmacfg_gnt/=(dmacfg_gnt'range => '0'));
			elsif dmargtr_rdy='1' then
				dmargtr_rdy <= setif(dmacfg_gnt/=(dmacfg_gnt'range => '0'));
			end if;

			dmargtr_dv   <= setif(dmacfg_gnt/=(dmacfg_gnt'range => '0')) and not dv;
			dmargtr_id   <= encoder(dmacfg_gnt);
			dmargtr_addr <= wirebus (dev_addr, dmacfg_gnt);
			dmargtr_len  <= wirebus (dev_len,  dmacfg_gnt);
			dmargtr_we   <= wirebus (dev_we,   dmacfg_gnt);
			dv := setif(dmacfg_gnt/=(dmacfg_gnt'range => '0'));
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

	dmawe_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true)
	port map (
		wr_clk  => dma_clk,
		wr_addr => dmargtr_id,
		wr_ena  => dmargtr_dv,
		wr_data => dmargtr_we,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => trans_we);

	
--	process (ctlr_clk, dev_req, dmatrans_rdy, devtrans_rdy)
--		variable cancel : std_logic;
--		variable gnt    : std_logic_vector(devtrans_gnt'range);
--	begin
--		if rising_edge(ctlr_clk) then
--			if cancel='0' then
--				if dmatrans_rdy='0' then
--					cancel := setif((gnt and not dev_req)/=(dev_req'range => '0'));
--				end if;
--			else
--				if ctlr_trdy='1' then
--					cancel := '0';
--				end if;
--			end if;
--			if cancel='0' then
--				gnt := devtrans_gnt;
--			end if;
--		end if;
--		dev_rdy      <= setif(cancel='0', devtrans_rdy, gnt and (dev_rdy'range => dmatrans_rdy));
--		devtrans_req <= dev_req and (dev_req'range => cancel);
--	end process;

	dmatransgnt_e : entity hdl4fpga.grant
	port map (
		dev_req => dev_req,
		dev_gnt => devtrans_gnt,
		dev_rdy => dev_rdy,

		rsrc_clk => ctlr_clk,
		rsrc_rdy => dmatrans_rdy);

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			if ctlr_inirdy='0' then
				dmatrans_req <= '0';
			else
				dmatrans_req <= setif(devtrans_gnt /= (devtrans_gnt'range => '0'));
			end if;
			dmatrans_rid <= encoder(devtrans_gnt);
		end if;
	end process;

	dmatrans_we <= setif(trans_we(0)/='0');
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
		ctlr_r         => ctlr_r,
		ctlr_dio_req   => ctlr_dio_req);

end;
