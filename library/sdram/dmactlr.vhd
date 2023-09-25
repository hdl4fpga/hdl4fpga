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
use hdl4fpga.base.all;

entity dmactlr is
	generic (
		data_gear    : natural;
		burst_length : natural := 0;
		bank_size    : natural;
		addr_size    : natural;
		coln_size    : natural);
	port (

		tp           : out std_logic_vector(1 to 32);
		devcfg_clk   : in  std_logic;
		devcfg_req   : in  std_logic_vector;
		devcfg_rdy   : buffer std_logic_vector;
		dev_len      : in  std_logic_vector;
		dev_addr     : in  std_logic_vector;
		dev_we       : in  std_logic_vector;

		dev_req      : in  std_logic_vector;
		dev_gnt      : buffer std_logic_vector;
		dev_rdy      : buffer std_logic_vector;

		ctlr_clk     : in  std_logic;

		ctlr_inirdy  : in  std_logic;
		ctlr_refreq  : in  std_logic;

		ctlr_cl      : in  std_logic_vector;
		ctlr_alat    : in  std_logic_vector(2 downto 0);
		ctlr_blat    : in  std_logic_vector(2 downto 0);

		ctlr_frm     : buffer std_logic;
		ctlr_trdy    : in  std_logic;
		ctlr_fch     : in  std_logic;
		ctlr_cmd     : in  std_logic_vector(0 to 3-1);
		ctlr_rw      : out std_logic;
		ctlr_b       : out std_logic_vector;
		ctlr_a       : out std_logic_vector);

end;

architecture def of dmactlr is

	signal dmargtr_dv     : std_logic;
	signal dmargtr_id     : std_logic_vector(unsigned_num_bits(dev_req'length-1)-1 downto 0);
	signal dmargtr_addr   : std_logic_vector(dev_addr'length/dev_req'length-1 downto 0);
	signal dmargtr_len    : std_logic_vector(dev_len'length/dev_req'length-1 downto 0);
	signal dmargtr_we     : std_logic_vector(0 to 0);

	signal dmacfg_gnt     : std_logic_vector(devcfg_req'range);

	signal dmatrans_req   : std_logic;
	signal dmatrans_rdy   : std_logic;
	signal dmatrans_rid   : std_logic_vector(dmargtr_id'range);
	signal dmatrans_iaddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_ilen  : std_logic_vector(dmargtr_len'range);
	signal dmatrans_we    : std_logic_vector(0 to 0);
	signal dmatrans_taddr : std_logic_vector(dmargtr_addr'range);
	signal dmatrans_tlen  : std_logic_vector(dmargtr_len'range);

	signal ctlr_act       : std_logic;
	signal ctlr_ras       : std_logic;
	signal ctlr_cas       : std_logic;

begin

	dmacfg_b : block
		signal req  : std_logic_vector(dev_req'range);
	begin
		req <= to_stdlogicvector(to_bitvector(devcfg_req)) xor to_stdlogicvector(to_bitvector(devcfg_rdy));
		dmacfg_e : entity hdl4fpga.arbiter
		port map (
			clk  => devcfg_clk,
			req  => req,
			gnt  => dmacfg_gnt);

		process (devcfg_clk)
		begin
			if rising_edge(devcfg_clk) then
				if ctlr_inirdy='0' then
					devcfg_rdy <= to_stdlogicvector(to_bitvector(devcfg_req));
				else
					for i in dmacfg_gnt'range loop
						if dmacfg_gnt(i)='1' then
							devcfg_rdy(i) <= devcfg_req(i);
						end if;
					end loop;
				end if;
			end if;
		end process;

	end block;

	dmargtr_id   <= encoder(dmacfg_gnt);
	dmargtr_addr <= wirebus (dev_addr, dmacfg_gnt);
	dmargtr_len  <= wirebus (dev_len,  dmacfg_gnt);
	dmargtr_we   <= wirebus (dev_we,   dmacfg_gnt);
	dmargtr_dv   <= setif(dmacfg_gnt/=(dmacfg_gnt'range => '0'));

	dmatrans_b : block
		signal req  : std_logic_vector(dev_req'range);
	begin
		req <= dev_rdy xor to_stdlogicvector(to_bitvector(dev_req));
		dmacfg_e : entity hdl4fpga.arbiter
		port map (
			clk  => ctlr_clk,
			req  => req,
			gnt  => dev_gnt);

		process (ctlr_clk)
			type states is (s_idle, s_trans);
			variable state : states;
			variable gnt : std_logic_vector(dev_gnt'range);
		begin
			if rising_edge(ctlr_clk) then
				if ctlr_inirdy='0' then
					dev_rdy <= to_stdlogicvector(to_bitvector(dev_req));
				elsif (dmatrans_rdy xor to_stdulogic(to_bit(dmatrans_req)))='0' then
					for i in dev_gnt'range loop
						case state is
						when s_idle =>
							if dev_gnt(i)='1' then
								dmatrans_req <= not dmatrans_rdy;
								state := s_trans;
							end if;
						when s_trans =>
							if dev_gnt(i)='1' then
								dev_rdy(i) <= to_stdulogic(to_bit(dev_req(i)));
								state := s_idle;
							end if;
						end case;
					end loop;
				end if;
			end if;
		end process;

	end block;

	dmatrans_rid <= encoder(dev_gnt);
	dmaaddr_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => false)
	port map (
		wr_clk  => devcfg_clk,
		wr_ena  => dmargtr_dv,
		wr_addr => dmargtr_id,
		wr_data => dmargtr_addr,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => dmatrans_iaddr);

	dmalen_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => false)
	port map (
		wr_clk  => devcfg_clk,
		wr_addr => dmargtr_id,
		wr_ena  => dmargtr_dv,
		wr_data => dmargtr_len,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => dmatrans_ilen);

	dmawe_rgtr_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => false)
	port map (
		wr_clk  => devcfg_clk,
		wr_addr => dmargtr_id,
		wr_ena  => dmargtr_dv,
		wr_data => dmargtr_we,

		rd_clk  => ctlr_clk,
		rd_addr => dmatrans_rid,
		rd_data => dmatrans_we);

	dmatrans_e : entity hdl4fpga.dmatrans
	generic map (
		data_gear     => data_gear,
		burst_length  => burst_length,
		bank_size     => bank_size,
		addr_size     => addr_size,
		coln_size     => coln_size)
	port map (
		tp             => tp,
		dmatrans_clk   => ctlr_clk,
		dmatrans_req   => dmatrans_req,
		dmatrans_rdy   => dmatrans_rdy,
		dmatrans_we    => dmatrans_we(0),
		dmatrans_iaddr => dmatrans_iaddr,
		dmatrans_ilen  => dmatrans_ilen,
		dmatrans_taddr => dmatrans_taddr,
		dmatrans_tlen  => dmatrans_tlen,

		ctlr_inirdy    => ctlr_inirdy,
		ctlr_refreq    => ctlr_refreq,

		ctlr_frm       => ctlr_frm,
		ctlr_trdy      => ctlr_trdy,
		ctlr_fch       => ctlr_fch,
		ctlr_cmd       => ctlr_cmd,
		ctlr_rw        => ctlr_rw,
		ctlr_alat      => ctlr_alat,
		ctlr_blat      => ctlr_blat,
		ctlr_b         => ctlr_b,
		ctlr_a         => ctlr_a);

end;
