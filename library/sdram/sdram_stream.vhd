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
use hdl4fpga.videopkg.all;

entity sdram_stream is
	generic (
		stream_width : natural);
	port (
		stream_clk  : in  std_logic;
		stream_frm  : in  std_logic;
		stream_irdy : in  std_logic;
		stream_data : out std_logic_vector;
		base_addr   : in   std_logic_vector;
		dmacfg_clk  : in   std_logic;
		dmacfg_req  : buffer std_logic;
		dmacfg_rdy  : in  std_logic;
		dma_req     : buffer std_logic;
		dma_rdy     : in  std_logic;
		dma_len     : out std_logic_vector;
		dma_addr    : buffer std_logic_vector;
		ctlr_inirdy : in  std_logic;
		ctlr_clk    : in  std_logic;
		ctlr_do_dv  : in  std_logic;
		ctlr_do     : out std_logic_vector);
end;

architecture def of sdram_stream is

	constant pslice_size : natural := 2**(unsigned_num_bits(video_width-1));
	constant ppage_size  : natural := 2*pslice_size;
	constant pwater_mark : natural := ppage_size-pslice_size;

	signal stream_frm     : std_logic;
	signal stream_trdy    : std_logic;
	signal stream_on      : std_logic;
	signal stream_rdy     : std_logic;
	signal stream_req     : std_logic;

	signal src_irdy      : std_logic;
	signal src_data      : std_logic_vector(ctlr_do'range);

	signal dma_step      : unsigned(dma_addr'range);

	signal stream_word : std_logic_vector(ctlr_do'range);

	signal fifo_irdy : std_logic;
	signal fifo_trdy : std_logic;
	signal fifo_data : std_logic_vector(ctlr_do'range);

	signal wm_req : std_logic := '0';
	signal wm_rdy : std_logic := '0';

begin

	serdes_e : entity hdl4fpga.serlzr
	generic map (
		fifo_mode => false,
		lsdfirst  => false)
	port map (
		src_clk   => stream_clk,
		src_frm   => stream_frm,
		src_irdy  => stream_irdy,
		src_data  => stream_data,
		dst_clk   => stream_clk,
		dst_irdy  => fifo_irdy,
		dst_data  => fifo_data);

	fifo_e : entity hdl4fpga.fifo
	generic map (
		max_depth  => ppage_size,
		async_mode => false,
		latency    => 1,
		check_sov  => false,
		check_dov  => true)
	port map (
		src_clk  => stream_clk,
		src_frm  => stream_frm,
		src_irdy => fifo_irdy,
		src_data => fifo_data,

		dst_clk  => ctlr_clk,
		dst_trdy => ctlr_do_dv,
		dst_data => ctlr_do);

	dma_p : process(dmacfg_clk)
		type states is (s_idle, s_transfer, s_config);
		variable state : states;
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				wm_rdy <= wm_req;
				state := s_idle;
			elsif (wm_rdy xor wm_req)='1' then
				case state is
				when s_idle =>
					if (dmacfg_req xor dmacfg_rdy)='0' then
						if (dma_req xor dma_rdy)='0' then
							dma_req <= not dma_rdy;
							state := s_transfer;
						end if;
					end if;
				when s_transfer =>
					if (dma_req xor dma_rdy)='0' then
						if (dmacfg_req xor dmacfg_rdy)='0' then
							dmacfg_req <= not dmacfg_rdy;
							state := s_config;
						end if;
					end if;
				when s_config =>
					if (dmacfg_req xor dmacfg_rdy)='0' then
						wm_rdy <= wm_req;
						state := s_idle;
					end if;
				end case;
			else
				if stream_frm='0' then
				end if;
				state := s_idle;
			end if;
		end if;
	end process;
	
	stream_b : block
		signal level : unsigned(0 to unsigned_num_bits(ppage_size-1));
	begin
		process (stream_clk)
			constant dpage_size   : natural := ( ppage_size*stream_data'length+ctlr_do'length-1)/ctlr_do'length;
			constant dslice_size  : natural := (pslice_size*stream_data'length+ctlr_do'length-1)/ctlr_do'length;
	
			type states is (s_idle, s_line);
			variable state : states;

			variable new_level : unsigned(level'range);
		begin
			if rising_edge(stream_clk) then
				if stream_frm='1' then
    				case state is
    				when s_stream =>
    					if level >= water_mark then
							dmacfg_req <= not dmscfg_rdy;
    					end if;
    				when s_cfgdma =>
						if (dmacfg_req xor dmscfg_rdy)='0' then
    					if (to_bit(stream_rdy) xor to_bit(stream_req))='0' then
    						dma_addr  <= std_logic_vector(unsigned(dma_addr) + dma_step);
    						dma_step  <= to_unsigned(dslice_size, dma_step'length);
    						stream_req <= not to_stdulogic(to_bit(stream_rdy));
    						state     := s_hzpoll;
    					end if;
					end case;
				else
					state := s_cfg;
				end if;
			end if;
		end process;
	end block;

	stream_on <= stream_irdy and stream_frm;
end;
