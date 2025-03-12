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
use hdl4fpga.cgafonts.all;

entity cgaram is
	generic (
		cga_bitrom   : std_logic_vector := (1 to 0 => '-');
		font_bitrom  : std_logic_vector := psf1cp850x8x16;
		font_height  : natural := 16;
		font_width   : natural := 8);
	port (
		cga_clk      : in  std_logic;
		cga_we       : in  std_logic := '1';
		cga_addr     : in  std_logic_vector;
		cga_data     : in  std_logic_vector;

		video_clk    : in std_logic;
		video_addr   : in std_logic_vector;
		font_hcntr   : in std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);
		font_vcntr   : in std_logic_vector(unsigned_num_bits(font_height-1)-1 downto 0);
		video_on     : in std_logic := '1';

		video_dot    : out std_logic);
end;

architecture struct of cgaram is
	signal font_col : std_logic_vector(font_hcntr'range);
	signal font_row : std_logic_vector(font_vcntr'range);

	signal cga_codes : std_logic_vector(cga_data'range);
	signal cga_code  : std_logic_vector(unsigned_num_bits(font_bitrom'length/font_height/font_width-1)-1 downto 0);
	signal mux_code  : std_logic_vector(cga_code'range);

	signal char_addr : unsigned(cga_addr'length-1+(unsigned_num_bits(cga_codes'length/cga_code'length)-1) downto 0);
	signal char_on   : std_logic;
	signal char_dot  : std_logic;

	constant instant_mux  : boolean := char_addr'length > cga_addr'length; -- Xilinx work around
begin

	cgamem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true,
		bitrom => cga_bitrom)
	port map (
		wr_clk  => cga_clk,
		wr_addr => cga_addr,
		wr_ena  => cga_we,
		wr_data => cga_data,

		rd_clk  => video_clk,
		rd_addr => video_addr,
		rd_data => cga_codes);

	muxcode_g : if instant_mux generate
		constant n : natural := char_addr'length-cga_addr'length;
		signal sel : std_logic_vector(char_addr'length-cga_addr'length-1 downto 0);
	begin
		lat_e : entity hdl4fpga.latency
		generic map (
			n => n,
			d => (0 to n-1 => 2))
		port map (
			clk => video_clk,
			di  => std_logic_vector(char_addr(n-1 downto 0)),
			do  => sel);

		mux_code <= multiplex(cga_codes, sel, mux_code'length);
	end generate;
	cga_code <= mux_code when char_addr'length > cga_addr'length else cga_codes; 

	vsync_e : entity hdl4fpga.latency
	generic map (
		n   => font_row'length,
		d   => (font_row'range => 2))
	port map (
		clk => video_clk,
		di  => font_vcntr,
		do  => font_row);

	hsync_e : entity hdl4fpga.latency
	generic map (
		n   => font_col'length,
		d   => (font_col'range => 2))
	port map (
		clk => video_clk,
		di  => font_hcntr,
		do  => font_col);

	rom_e : entity hdl4fpga.cga_rom
	generic map (
		font_bitrom => font_bitrom,
		font_height => font_height,
		font_width  => font_width)
	port map (
		clk         => video_clk,
		char_col    => font_col,
		char_row    => font_row,
		char_code   => cga_code,
		char_dot    => char_dot);

	don_e : entity hdl4fpga.latency
	generic map (
		n     => 1,
		d     => (1 to 1 => 4))
	port map (
		clk   => video_clk,
		di(0) => video_on,
		do(0) => char_on);

	video_dot <= char_dot and char_on;

end;
