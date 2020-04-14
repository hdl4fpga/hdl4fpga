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
use hdl4fpga.videopkg.all;

entity graphics is
	generic (
		video_mode   : natural);
	port (
		ctlr_clk     : in  std_logic;
		ctlr_di_dv   : in  std_logic;
		ctlr_di      : in  std_logic_vector;
		video_clk    : in  std_logic;
		dma_req      : buffer std_logic := '0';
		dma_rdy      : in  std_logic;
		dma_len      : out std_logic_vector;
		dma_addr     : buffer std_logic_vector;
		video_hzsync : buffer std_logic;
		video_vtsync : buffer std_logic;
		video_hzon   : buffer std_logic;
		video_vton   : buffer std_logic;
		video_pixel  : out std_logic_vector);
end;

architecture def of graphics is

	constant fifo_size   : natural := 4*2**unsigned_num_bits(modeline_data(video_mode)(0)-1);
	constant byteperword : natural := ctlr_di'length/video_pixel'length;
	constant maxdma_len  : natural := fifo_size/byteperword;

	signal video_frm : std_logic;

	signal video_hzcntr : std_logic_vector(unsigned_num_bits(modeline_data(video_mode)(3)-1)-1 downto 0);
	signal video_vtcntr : std_logic_vector(unsigned_num_bits(modeline_data(video_mode)(7)-1)-1 downto 0);

	signal level     : unsigned(0 to unsigned_num_bits(maxdma_len-1));
	signal vton_edge : std_logic;
	signal hzon_edge : std_logic;

	signal src_irdy : std_logic;
	signal src_data : std_logic_vector(ctlr_di'range);

	signal video_on    : std_logic;
	signal dmafrm_req  : std_logic;
	signal dmaline_req : std_logic;
	signal hz_eol      : std_logic;
	signal mydma_rdy   : std_logic;
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
		variable rdy : std_logic;
	begin
		if rising_edge(video_clk) then
			rdy       := dma_rdy;
			mydma_rdy <= rdy;
		end if;
	end  process;

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			if dma_req='0' then
				if dmafrm_req='1' then
					dma_req  <= '1';
					dma_len  <= std_logic_vector(to_unsigned(maxdma_len-1, dma_len'length));
					dma_addr <= (dma_addr'range => '0');
				elsif dmaline_req='1' then
					dma_req  <= '1';
					dma_len  <= std_logic_vector(to_unsigned(maxdma_len/4-1, dma_len'length));
					dma_addr <= std_logic_vector(unsigned(dma_addr) + setif(video_vton='0', maxdma_len, maxdma_len/4));
				end if;
				if hz_eol='1' then
					level  <= level - modeline_data(video_mode)(0);
					hz_eol <= '0';
				end if;
			elsif mydma_rdy='1' then
				dma_req <= '0';
				if dmafrm_req='1' then
					dmafrm_req <= '0';
					level <= to_unsigned(maxdma_len, level'length);
				elsif dmaline_req='1' then
					dmaline_req <= '0';
					level <= level + (maxdma_len/4);
				end if;
			elsif hz_eol='1' then
				level  <= level - modeline_data(video_mode)(0);
				hz_eol <= '0';
			end if;

			if hzon_edge='1' then
				if video_hzon='0' then
					if video_vton='1' then
						hz_eol <= '1';
					end if;
				end if;
			end if;
			hzon_edge <= video_hzon;

			if dmafrm_req='1' and dma_req='0' then
				video_frm <= '0';
			else
				video_frm <= '1';
			end if;

			if dma_req='0' and mydma_rdy='0' then
				if video_vton='0' then
					if vton_edge='1' then
						dmafrm_req <= '1';
					end if;
				elsif level < (3*maxdma_len/4) then
					dmaline_req <= '1';
				end if;
				vton_edge <= video_vton;
			end if;

		end if;
	end process;

	process (ctlr_clk)
	begin
		if rising_edge(ctlr_clk) then
			src_irdy <= ctlr_di_dv;
			src_data <= ctlr_di;
		end if;
	end process;

	video_on <= video_hzon and video_vton;
	vram_e : entity hdl4fpga.fifo
	generic map (
		size           => fifo_size,
		overflow_check => false,
		gray_code      => false)
	port map (
		src_clk  => ctlr_clk,
		src_irdy => src_irdy,
		src_data => src_data,

		dst_clk  => video_clk,
		dst_frm  => video_frm,
		dst_trdy => video_on,
		dst_data => video_pixel);

end;
