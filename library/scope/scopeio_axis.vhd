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

		vt_dv         : in  std_logic;
		vt_scale      : in  std_logic_vector;
		vt_offset     : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		video_vton    : in  std_logic;
		video_vtdot   : out std_logic);

	constant num_of_segments : natural := hdo(layout)**".num_of_segments";
	constant hz_unit         : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit         : real    := hdo(layout)**".axis.vertical.unit";
	constant vt_width        : natural := hdo(layout)**".axis.vertical.width";
	constant axis_fontsize   : natural := hdo(layout)**".axis.fontsize";
	constant grid_width      : natural := hdo(layout)**".grid.width";
	constant grid_height     : natural := hdo(layout)**".grid.height";
	constant grid_unit       : natural := hdo(layout)**".grid.unit";

	constant hzwidth_bits    : natural := unsigned_num_bits(num_of_segments*grid_width-1);
	constant vtheight_bits   : natural := unsigned_num_bits(grid_height-1);
	constant division_bits   : natural := unsigned_num_bits(grid_unit-1);

end;

architecture def of scopeio_axis is

	constant division_size : natural := grid_unit;
	constant font_size     : natural := axis_fontsize;

	constant font_bits     : natural := unsigned_num_bits(font_size-1);

	constant hz_width      : natural := grid_width;
	constant hzmark_bits   : natural := unsigned_num_bits(8-1);

	constant vt_height     : natural := grid_height;
	constant vtmark_bits   : natural := unsigned_num_bits(8-1);

	constant bcd_length    : natural := 4;

	signal mark_addr : std_logic_vector(max(hzwidth_bits-2*division_bits,vtheight_bits-division_bits)-1 downto 0);
	signal mark_vtwe : std_logic;
	signal mark_hzwe : std_logic;
	signal mark_we   : std_logic;
	signal mark_data : std_logic_vector(8*4-1 downto 0);

	signal hz_pos : unsigned(hzwidth_bits-1 downto 0);
	signal hz_mark : std_logic_vector(2**hzmark_bits*bcd_length-1 downto 0);
	signal vt_pos : unsigned(vtheight_bits-1 downto 0);
	signal vt_mark : std_logic_vector(2**vtmark_bits*bcd_length-1 downto 0);

	signal hz_bias : unsigned(hzwidth_bits-1 downto 0);
begin

	marks_e : entity hdl4fpga.scopeio_marks
	generic map (
		layout => layout)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,
		hz_pos    => std_logic_vector(hz_pos),
		hz_mark   => hz_mark,
		vt_pos    => std_logic_vector(vt_pos),
		vt_mark   => vt_mark);

	video_b : block

		signal char_code  : std_logic_vector(4-1 downto 0);
		signal char_row   : std_logic_vector(font_bits-1 downto 0);
		signal char_col   : std_logic_vector(font_bits-1 downto 0);
		signal char_dot   : std_logic;

		signal code_frm   : std_logic;
		signal code       : std_logic_vector(0 to bcd_length-1);

		signal hz_bcd     : std_logic_vector(char_code'range);
		signal hz_charrow : std_logic_vector(font_bits-1 downto 0);
		signal hz_charcol : std_logic_vector(font_bits-1 downto 0);
		signal hz_don     : std_logic;
		signal hz_on      : std_logic;

		signal vt_bcd     : std_logic_vector(char_code'range);
		signal vt_charrow : std_logic_vector(font_bits-1 downto 0);
		signal vt_charcol : std_logic_vector(font_bits-1 downto 0);
		signal vt_on      : std_logic;
		signal vt_don     : std_logic;

	begin

		hz_b : block

			signal tick   : std_logic_vector(bcd_length-1 downto 0);

			signal hz_bias : unsigned(hz_pos'range);
			signal vaddr  : std_logic_vector(hz_pos'range);
			signal vdata  : std_logic_vector(mark_data'range);

		begin 

			hz_pos <= unsigned(video_hcntr) + unsigned(hz_segment);

   			charrow_e : entity hdl4fpga.latency
   			generic map (
   				n => hz_charrow'length,
   				d => (hz_charrow'range => 2))
   			port map (
   				clk => video_clk,
   				di  => video_vcntr(hz_charrow'range),
   				do  => hz_charrow);

   			charcol_e : entity hdl4fpga.latency
   			generic map (
   				n => hz_charcol'length,
   				d => (hz_charcol'range => 2))
   			port map (
   				clk => video_clk,
   				di  => std_logic_vector(hz_pos(hz_charcol'range)),
   				do  => hz_charcol);

   			charon_e : entity hdl4fpga.latency
   			generic map (
   				n => 1,
   				d => (0 to 0 => 2))
   			port map (
   				clk   => video_clk,
   				di(0) => video_hzon,
   				do(0) => hz_on);

   			-- col_e : entity hdl4fpga.latency
   			-- generic map (
   				-- n => vcol'length,
   				-- d => (vcol'range => 2))
   			-- port map (
   				-- clk => video_clk,
   				-- di  => std_logic_vector(hz_pos(vcol'range)),
   				-- do  => );

			hz_bcd <= multiplex(x"12345678", resize(shift_right(unsigned(video_hcntr), font_bits), hzmark_bits), hz_bcd'length);

		end block;

		vt_b : block


			signal vton   : std_logic;

		begin 

			vt_pos <= resize(unsigned(video_vcntr) + unsigned(vt_offset(division_bits-1 downto 0)), vt_pos'length);
			vton <= video_vton and setif(vt_pos(division_bits-1 downto font_bits)=(division_bits-1 downto font_bits => '1'));

			charcol_e : entity hdl4fpga.latency
			generic map (
				n => font_bits,
				d => (0 to font_bits-1 => 2))
			port map (
				clk   => video_clk,
				di => video_hcntr(font_bits-1 downto 0),
				do => vt_charcol);

			charrow_e : entity hdl4fpga.latency
			generic map (
				n => font_bits,
				d => (0 to font_bits-1 => 2))
			port map (
				clk   => video_clk,
				di => std_logic_vector(vt_pos(font_bits-1 downto 0)),
				do => vt_charrow);

			charon_e : entity hdl4fpga.latency
			generic map (
				n => 1,
				d => (0 to 0 => 2))
			port map (
				clk   => video_clk,
				di(0) => vton,
				do(0) => vt_on);

		end block;

		char_code <= multiplex(vt_bcd     & hz_bcd,     not vt_on);
		char_row  <= multiplex(vt_charrow & hz_charrow, not vt_on); 
		char_col  <= multiplex(vt_charcol & hz_charcol, not vt_on); 

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
