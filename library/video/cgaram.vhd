-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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





