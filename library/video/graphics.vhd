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

entity graphics is
	generic (
		video_mode   : natural);
	port (
		ctlr_clk      : in  std_logic;
		ctlr_di_dv   : in  std_logic;
		ctlr_di      : in  std_logic_vector;
		dma_req      : buffer std_logic;
		dma_rdy      : in  std_logic;
		dma_len      : out std_logic_vector;
		dma_addr     : buffer std_logic_vector;
		video_clk    : in  std_logic;
		video_hzsync : buffer std_logic;
		video_vtsync : buffer std_logic;
		video_hzon   : buffer std_logic;
		video_vton   : buffer std_logic;
		video_pixel  : out std_logic_vector);
end;

architecture def of graphics is

	signal video_frm : std_logic;

	signal video_hzcntr : std_logic_vector(12-1 downto 0);
	signal video_vtcntr : std_logic_vector(12-1 downto 0);

begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		mode => video_mode)
	port map (
		video_clk    => video_clk,
		video_hzsync => video_hzsync,
		video_vtsync => video_vtsync,
		video_hzcntr => video_hzcntr,
		video_vtcntr => video_vtcntr,
		video_hzon   => video_hzon,
		video_vton   => video_vton);

	process (video_clk)
		variable level     : unsigned(0 to unsigned_num_bits(4096)-1);
		variable vton_edge : std_logic;
		variable hzon_edge : std_logic;
	begin
		if rising_edge(video_clk) then
			if dma_rdy='1' then
				if dma_req='1' then
					dma_req <= '0';
					if video_vton='0' then
						level := to_unsigned(4096, level'length);
					else
						level := level + (4096/4);
					end if;
				elsif hzon_edge='1' then
					if video_hzsync='0' then
						level := level - 1920;
						hzon_edge := '0';
					end if;
				else
					hzon_edge := video_hzsync;
				end if;
			else
				if video_frm='1' then
					dma_req <= '1';
				elsif level < (3*4096/4) then
					dma_req <= '1';
				end if;

				if hzon_edge='1' then
					if video_hzsync='0' then
						level := level - 1920;
						hzon_edge := '0';
					end if;
				else
					hzon_edge := video_hzsync;
				end if;
			end if;

			if video_vton='0' then
				if vton_edge='1' then
					video_frm <= '0';
				else
					video_frm <= '1';
				end if;
			end if;

			if video_vton='0' then
				dma_len  <= std_logic_vector(to_unsigned(4096, dma_len'length));
				dma_addr <= (dma_addr'range => '0');
			elsif dma_rdy='1' then
				if dma_req='1' then
					dma_len  <= std_logic_vector(to_unsigned(4096/4, dma_len'length));
					dma_addr <= std_logic_vector(unsigned(dma_addr) + (4096/4));
				end if;
			end if;

			hzon_edge := video_hzon;
			vton_edge := video_vton;
		end if;
	end process;

	vram_e : entity hdl4fpga.fifo
	generic map (
		size           => 4096,
		overflow_check => false,
		gray_code      => false,
		synchronous_rddata => true)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => ctlr_di_dv,
		src_data => ctlr_di,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_hzon,
		dst_data => video_pixel);

end;
