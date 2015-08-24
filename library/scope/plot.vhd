--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

entity plot is
	generic (
		max_hght : natural);
	port (
		video_clk : in  std_logic;
		video_row : in  std_logic_vector;
		video_seg : in  std_logic_vector;
		video_off : in  std_logic_vector;
		chann_dat : in  std_logic_vector;
		video_dot : out std_logic_vector);

	constant num_chann : natural := video_dot'length;
	subtype dword is unsigned(chann_dat'length/num_chann-1 downto 0);
	type dword_vector is array (natural range <>) of dword;

	subtype oword is unsigned(video_off'length/num_chann-1 downto 0);
	type oword_vector is array (natural range <>) of oword;

	subtype rword is signed(video_row'length-1 downto 0);
end;

library ieee;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of plot is

	constant m : natural := unsigned_num_bits(max_hght);

	signal values  : dword_vector(0 to num_chann-1);
	signal offsets : oword_vector(0 to num_chann-1);
	signal vrow    : rword;

	signal vline_dot  : std_logic_vector(0 to video_dot'length-1);
	signal muxdot_do  : std_logic_vector(0 to video_dot'length-1);
	signal muxdot_sel : std_logic;

begin

	process (chann_dat, video_off)
		variable vdata : std_logic_vector(chann_dat'length-1 downto 0);
		variable odata : std_logic_vector(video_off'length-1 downto 0);
	begin
		vdata := chann_dat;
		odata := video_off;
		for i in 0 to num_chann-1 loop
			values(i) <= shift_right(unsigned(vdata(dword'range)), dword'length-m-1);
			--values(i) <= unsigned(vdata(dword'range));
			vdata := vdata srl dword'length;
			offsets(i) <= unsigned(odata(oword'range));
			odata := odata srl oword'length;
		end loop;
	end process;
	vrow <= rword(video_row);

	muxdot_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => m+2))
	port map (
		clk   => video_clk,
		di(0) => video_seg(video_seg'right),
		do(0) => muxdot_sel);

	vline_g : for l in 0 to num_chann-1 generate
		signal row1 : unsigned(m-1 downto 0);
		signal row2 : unsigned(m-1 downto 0);

		signal muxdot_di  : std_logic_vector(0 to video_dot'length-1);

	begin

		process (video_clk)
		begin
			if rising_edge(video_clk) then
				row1 <= unsigned(resize(vrow,m)) + resize(offsets(l),m);
				row2 <= unsigned(resize(values(l),m)) + max_hght;
			end if;
		end process;

		draw_e : entity hdl4fpga.draw_vline 
		generic map (
			n => m)
		port map (
			video_clk  => video_clk,
			video_row1 => row1,
			video_row2 => row2,
			video_dot  => vline_dot(l));

		muxdot_di <= vline_dot rol l;
		mux_dot_e : entity hdl4fpga.muxw 
		generic map (
			addr_size => 1,
			data_size => 1)
		port map (
			sel(0) => muxdot_sel,
			di     => muxdot_di,
			do(0)  => muxdot_do(l));

	end generate;
	video_dot <= muxdot_do;
end;
