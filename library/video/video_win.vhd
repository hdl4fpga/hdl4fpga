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

entity win_side is
	generic (
		synchronous : natural := 1;
		tab         : natural_vector);
	port (
		video_clk   : in  std_logic;
		video_on    : in  std_logic;
		video_x     : in  std_logic_vector;
		win_on      : out std_logic_vector);
end;

architecture def of win_side is

	impure function init_data (
		constant tab  : natural_vector;
		constant size : natural)
		return std_logic_vector is
		variable retval : std_logic_vector(0 to 2**size*win_on'length-1) := (others => '0');
		constant t : natural_vector(0 to tab'length-1) := tab;
	begin
		for i in 0 to t'length/2-1 loop
			for j in t(2*i) to t(2*i)+t(2*i+1)-1 loop
				retval(win_on'length*j+i) := '1';
			end loop;
		end loop;
		return retval;
	end;

	constant tab_bit : std_logic_vector := init_data(tab, video_x'length);
	signal   won     : std_logic_vector(win_on'range);

begin

	g1 : for i in won'range generate
		g2 : if i < tab'length/2 generate
			constant low  : natural := tab(2*i);
			constant high : natural := tab(2*i)+tab(2*i+1);
		begin
			process(video_clk)
			begin
				if rising_edge(video_clk) then
					won(i) <= setif(low <= to_integer(unsigned(video_x)) and to_integer(unsigned(video_x)) < high);
				end if;
			end process;
		end generate;
	end generate;

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			win_on <= won and (win_on'range => video_on);
		end if;
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity win_mngr is
	generic (
		synchronous : natural := 1;
		tab         : natural_vector);
	port (
		video_clk   : in  std_logic;
		video_x     : in  std_logic_vector;
		video_y     : in  std_logic_vector;
		video_frm   : in  std_logic;
		video_don   : in  std_logic;
		win_don     : out std_logic_vector;
		win_frm     : out std_logic_vector);

	constant x : natural := 0;
	constant y : natural := 1;
end;

architecture def of win_mngr is

	impure function init_data (
		constant tab  : natural_vector;
		constant side : natural)
		return natural_vector is
		variable retval : natural_vector(0 to tab'length/2-1) := (others => 0);
		constant t : natural_vector(0 to tab'length-1) := tab;
	begin
		for i in 0 to t'length/2-1 loop
			retval(i) := t(2*i+side);
		end loop;
		return retval;
	end;

	constant tabx : natural_vector := init_data(tab, x);
	constant taby : natural_vector := init_data(tab, y);

	signal mask_y : std_logic_vector(win_don'range);
	signal mask_x : std_logic_vector(win_don'range);
	signal edge_x : std_logic_vector(win_don'range);
	signal frm    : std_logic;
	signal don    : std_logic;

begin

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			frm <= video_frm;
			don <= video_don;
		end if;
	end process;

	x_e : entity hdl4fpga.win_side
	generic map (
		synchronous => synchronous,
		tab         => tabx)
	port map (
		video_clk   => video_clk,
		video_on    => don,
		video_x     => video_x,
		win_on      => mask_x);

	y_e : entity hdl4fpga.win_side
	generic map (
		synchronous => synchronous,
		tab         => taby)
	port map (
		video_clk   => video_clk,
		video_on    => frm,
		video_x     => video_y,
		win_on      => mask_y);

	win_don <= mask_y and mask_x;
	win_frm <= mask_y;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity win is
	port (
		video_clk : in  std_logic;
		video_hzl : in  std_logic;
		win_frm   : in  std_logic;
		win_ena   : in  std_logic;
		win_x     : out std_logic_vector;
		win_y     : out std_logic_vector);
end;

architecture def of win is
begin
	process (video_clk)
		variable x : unsigned(win_x'range);
		variable y : unsigned(win_y'range);
	begin
		if rising_edge(video_clk) then
			if win_ena='0' then
				x := (others => '0');
			else
				x := x + 1;
			end if;
			if win_frm='0' then
				y := (others => '0');
			elsif video_hzl='1' then
				y := y + 1;
			end if;
			win_x <= std_logic_vector(x);
			win_y <= std_logic_vector(y);
		end if;
	end process;
end architecture;

