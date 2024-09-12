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
		byte_lanes  : natural := 2;
		buffer_size : natural);
	port (
		stream_clk  : in  std_logic;
		stream_frm  : in  std_logic;
		stream_irdy : in  std_logic;
		stream_trdy : out std_logic := '1';
		stream_data : in  std_logic_vector;
		base_addr   : in   std_logic_vector;
		dmacfg_clk  : in   std_logic;
		dmacfg_req  : buffer std_logic := '0';
		dmacfg_rdy  : in  std_logic;
		dma_req     : buffer std_logic := '0';
		dma_rdy     : in  std_logic;
		dma_len     : buffer std_logic_vector;
		dma_addr    : buffer std_logic_vector;
		ctlr_inirdy : in  std_logic;
		ctlr_clk    : in  std_logic;
		ctlr_do_dv  : in  std_logic;
		ctlr_do     : out std_logic_vector);

	constant water_mark : natural := buffer_size/2;

end;

architecture def of sdram_stream is

	signal fifo_irdy : std_logic;
	signal fifo_trdy : std_logic;
	signal fifo_data : std_logic_vector(ctlr_do'range);

	signal wm_req : std_logic := '0';
	signal wm_rdy : std_logic := '0';

	constant xxx : natural := unsigned_num_bits(byte_lanes-1);
	signal level : unsigned(0 to unsigned_num_bits(buffer_size-1)) := (others => '0');
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
		max_depth  => buffer_size,
		async_mode => false,
		latency    => 1,
		check_sov  => false,
		check_dov  => true)
	port map (
		src_clk  => stream_clk,
		src_frm  => stream_frm,
		src_irdy => fifo_irdy,
		src_data => fifo_data,

		dst_frm  => ctlr_inirdy,
		dst_clk  => ctlr_clk,
		dst_trdy => ctlr_do_dv,
		dst_data => ctlr_do);

	dma_p : process(dmacfg_clk)
		type states is (s_init, s_ready, s_transfer);
		variable state : states;
	begin
		if rising_edge(dmacfg_clk) then
			if ctlr_inirdy='0' then
				wm_rdy <= wm_req;
				state := s_init;
			else
				case state is
				when s_init =>
					if stream_frm='1' then
						if (dmacfg_req xor dmacfg_rdy)='0' then
							dma_addr <= (dma_addr'range => '0');
							dmacfg_req <= not dmacfg_rdy;
							state := s_ready;
						end if;
					end if;
				when s_ready =>
					if (wm_rdy xor wm_req)='1' then
						if (dmacfg_req xor dmacfg_rdy)='0' then
							dma_addr <= std_logic_vector(unsigned(dma_addr) + unsigned(dma_len));
							dma_req <= not dma_rdy;
						end if;
					end if;
				when s_transfer =>
					if (dma_req xor dma_rdy)='0' then
						dmacfg_req <= not dmacfg_rdy;
						wm_rdy <= wm_req;
						if stream_frm='1' then
							state := s_ready;
						elsif level < 0 then
							state := s_init;
						end if;
					end if;
				end case;
			end if;
		end if;
	end process;
	
	process (stream_clk)
	begin
		if rising_edge(stream_clk) then
			if ctlr_inirdy='1' then
    			if stream_frm='1' then
    				if level >= water_mark then
    					dma_len <= std_logic_vector(resize(level-1, dma_len'length));
    					wm_req <= not wm_rdy;
    				end if;
    				if level >= water_mark then
						if stream_irdy='1' then
							level <= level + 1;
						end if;
					elsif stream_irdy='1' then
						level <= level + 1;
    				end if;
    			elsif level > 0 then
    				dma_len <= std_logic_vector(level);
    				wm_req  <= not wm_rdy;
    			end if;
    		end if;
		end if;
	end process;
end;
