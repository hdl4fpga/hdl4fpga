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
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_axis is
	generic (
		latency       : natural;
		layout        : string);
	port (
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		video_clk     : in  std_logic;
		hz_segment    : in  std_logic_vector;
		video_hcntr   : in  std_logic_vector;
		video_hzon    : in  std_logic;
		video_hzdot   : out std_logic;

		video_vcntr   : in  std_logic_vector;
		video_vton    : in  std_logic;
		video_vtdot   : out std_logic);

	constant num_of_segments : natural := hdo(layout)**".num_of_segments";
	constant max_delay       : natural := hdo(layout)**".max_delay=16384.";
	constant hz_unit         : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit         : real    := hdo(layout)**".axis.vertical.unit";
	constant vt_width        : natural := hdo(layout)**".axis.vertical.width";
	constant axis_fontsize   : natural := hdo(layout)**".axis.fontsize=8.";
	constant grid_width      : natural := hdo(layout)**".grid.width";
	constant grid_height     : natural := hdo(layout)**".grid.height";
	constant grid_unit       : natural := hdo(layout)**".grid.unit=32.";

	constant hzoffset_bits   : natural := unsigned_num_bits(max_delay-1);
	constant hzwidth_bits    : natural := unsigned_num_bits(num_of_segments*grid_width-1);
	constant vtheight_bits   : natural := unsigned_num_bits(grid_height-1);
	constant gridunit_bits   : natural := unsigned_num_bits(grid_unit-1);

end;

architecture def of scopeio_axis is

	constant division_size : natural := grid_unit;
	constant font_size     : natural := axis_fontsize;

	constant font_bits     : natural := unsigned_num_bits(font_size-1);

	constant hz_width      : natural := grid_width;
	constant hzmark_bits   : natural := unsigned_num_bits(8-1);

	constant vt_height     : natural := grid_height;
	constant vtmark_bits   : natural := unsigned_num_bits(8-1);
	signal vt_offset       : std_logic_vector((5+8)-1 downto 0);

	constant bcd_length    : natural := 4;

	signal mark_addr : std_logic_vector(max(hzwidth_bits-2*gridunit_bits,vtheight_bits-gridunit_bits)-1 downto 0);
	signal mark_vtwe : std_logic;
	signal mark_hzwe : std_logic;
	signal mark_we   : std_logic;
	signal mark_data : std_logic_vector(8*bcd_length-1 downto 0);

	signal hz_pos : unsigned(hzoffset_bits-1 downto 0);
	signal hz_mark : std_logic_vector(2**hzmark_bits*bcd_length-1 downto 0);
	signal vt_pos : unsigned(vtheight_bits-1 downto 0);
	signal vt_mark : std_logic_vector(2**vtmark_bits*bcd_length-1 downto 0);

	signal hz_bias : unsigned(hzwidth_bits-1 downto 0);
	signal hz_scaleid : std_logic_vector(4-1 downto 0);
	signal hz_offset  : std_logic_vector(hzoffset_bits-1 downto 0);
begin

	marks_e : entity hdl4fpga.scopeio_marks
	generic map (
		layout => layout)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,
		video_clk => video_clk,
		hz_pos    => std_logic_vector(hz_pos(hzwidth_bits-1  downto gridunit_bits+1)),
		hz_mark   => hz_mark,
		vt_pos    => std_logic_vector(vt_pos(vtheight_bits-1 downto gridunit_bits)),
		vt_mark   => vt_mark,
		export_vtoffset => vt_offset,
		export_hzoffset => hz_offset);

	video_b : block

		signal char_code  : std_logic_vector(bcd_length-1 downto 0);
		signal char_row   : std_logic_vector(font_bits-1 downto 0);
		signal char_col   : std_logic_vector(font_bits-1 downto 0);
		signal char_dot   : std_logic;

		signal code_frm   : std_logic;
		signal code       : std_logic_vector(0 to bcd_length-1);

		signal hz_bcd     : std_logic_vector(char_code'range);
		signal hzmark_row : std_logic_vector(font_bits-1 downto 0);
		signal hzmark_col : std_logic_vector(hzmark_bits+font_bits-1 downto 0);
		signal hz_don     : std_logic;
		signal hz_on      : std_logic;

		signal vt_bcd     : std_logic_vector(char_code'range);
		signal vtmark_row : std_logic_vector(font_bits-1 downto 0);
		signal vtmark_col : std_logic_vector(vtmark_bits+font_bits-1 downto 0);
		signal vt_on      : std_logic;
		signal vt_don     : std_logic;

	begin

		hz_b : block
			signal hz_bias : unsigned(hz_pos'range);
		begin 

			process (video_clk)
			begin
				if rising_edge(video_clk) then
					hz_bias <= resize(unsigned(hz_segment) + unsigned(hz_offset(hzmark_bits+font_bits-1 downto 0)), hz_bias'length);
				end if;
			end process;
			hz_pos <= resize(unsigned(video_hcntr) + hz_bias, hz_pos'length);

   			row_e : entity hdl4fpga.latency
   			generic map (
   				n => hzmark_row'length,
   				d => (hzmark_row'range => 2))
   			port map (
   				clk => video_clk,
   				di  => video_vcntr(hzmark_row'range),
   				do  => hzmark_row);

   			col_e : entity hdl4fpga.latency
   			generic map (
   				n => hzmark_col'length,
   				d => (hzmark_col'range => 2))
   			port map (
   				clk => video_clk,
   				di  => std_logic_vector(hz_pos(hzmark_col'range)),
   				do  => hzmark_col);

   			von_e : entity hdl4fpga.latency
   			generic map (
   				n => 1,
   				d => (0 to 0 => 2))
   			port map (
   				clk   => video_clk,
   				di(0) => video_hzon,
   				do(0) => hz_on);

			hz_bcd <= multiplex(hz_mark, hzmark_col(hzmark_bits+font_bits-1 downto font_bits), bcd_length);

		end block;

		vt_b : block
			signal von : std_logic;
		begin 

			vt_pos <= resize(unsigned(video_vcntr) + unsigned(vt_offset(gridunit_bits-1 downto 0)), vt_pos'length);
			charrow_e : entity hdl4fpga.latency
			generic map (
				n => vtmark_row'length,
				d => (0 to vtmark_row'length-1 => 2))
			port map (
				clk   => video_clk,
				di => std_logic_vector(vt_pos(vtmark_row'range)),
				do => vtmark_row);

			charcol_e : entity hdl4fpga.latency
			generic map (
				n => vtmark_col'length,
				d => (0 to vtmark_col'length-1 => 2))
			port map (
				clk   => video_clk,
				di => video_hcntr(vtmark_col'range),
				do => vtmark_col);

			von <= video_vton when vt_pos(gridunit_bits-1 downto font_bits)=(gridunit_bits-1 downto font_bits => '1') else '0';
			charon_e : entity hdl4fpga.latency
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => von,
				do(0) => vt_on);

			vt_bcd <= multiplex(vt_mark, vtmark_col(vtmark_bits+font_bits-1 downto font_bits), bcd_length);
		end block;

		char_code <= multiplex(vt_bcd     & hz_bcd,     not vt_on);
		char_row  <= multiplex(vtmark_row & hzmark_row, not vt_on); 
		char_col  <= multiplex(vtmark_col(font_bits-1 downto 0) & hzmark_col(font_bits-1 downto 0), not vt_on); 

		cgarom_e : entity hdl4fpga.cga_rom
		generic map (
			font_bitrom => setif(font_size=8, psf1bcd8x8, psf1bcd4x4),
			font_height => 2**font_bits,
			font_width  => 2**font_bits)
		port map (
			clk       => video_clk,
			char_col  => char_col,
			char_row  => char_row,
			char_code => char_code,
			char_dot  => char_dot);

		cgalat_e : entity hdl4fpga.latency
		generic map (
			n => 2,
			d => (0 to 1 => 2))
		port map (
			clk   => video_clk,
			di(0) => hz_on,
			di(1) => vt_on,
			do(0) => hz_don,
			do(1) => vt_don);

		latency_b : block
			signal dots : std_logic_vector(0 to 2-1);
		begin
			dots(0) <= char_dot and hz_don;
			dots(1) <= char_dot and vt_don;

			lat_e : entity hdl4fpga.latency
			generic map (
				n => dots'length,
				d => (dots'range => latency-4))
			port map (
				clk   => video_clk,
				di    => dots,
				do(0) => video_hzdot,
				do(1) => video_vtdot);
		end block;
	end block;

end;