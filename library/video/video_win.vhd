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

entity video_win is
	port (
		video_clk  : in  std_logic;
		video_x    : in  std_logic_vector;
		video_y    : in  std_logic_vector;
		video_frm  : in  std_logic;
		video_don  : in  std_logic;
		win_don    : out std_logic_vector;
		win_nhl    : out std_logic_vector;
		win_frm    : out std_logic_vector);
end;

architecture def of video_win is

	constant xtab : std_logic_vector := (
		b"001_0111_1111" & b"110_0000_0001" &
		b"001_0111_1111" & b"110_0000_0001" &
		b"001_0111_1111" & b"110_0000_0001" &
		b"001_0111_1111" & b"110_0000_0001");

	constant ytab : std_logic_vector := (
		b"000_0000_0000" & b"001_0000_0001" &
		b"001_0001_0010" & b"001_0000_0001" &
		b"010_0010_0100" & b"001_0000_0001" &
		b"011_0011_0111" & b"001_0000_0001");

	impure function init_data (
		constant tab    : std_logic_vector;
		constant size   : natural)
		return            std_logic_vector is
		variable x      : natural;
		variable width  : natural;
		variable aux    : unsigned(0 to tab'length-1);
		variable retval : std_logic_vector(0 to 2**size*win_don'length-1) := (others => '0');
	begin
		aux := unsigned(tab);
		for i in win_don'range loop
			x     := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			width := to_integer(aux(0 to size-1));
			aux   := aux sll size;
			for j in x to x+width-1 loop
				retval(win_don'length*j+i) := '1';
			end loop;
		end loop;
		return retval;
	end;

	constant xtab_bit : std_logic_vector := init_data(xtab, video_x'length);
	constant ytab_bit : std_logic_vector := init_data(ytab, video_y'length);

	signal mask_y     : std_logic_vector(win_don'range);
	signal mask_x     : std_logic_vector(win_don'range);
	signal edge_x     : std_logic_vector(win_don'range);
	signal frm        : std_logic;
	signal don        : std_logic;

begin

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			frm <= video_frm;
			don <= video_don;
		end if;
	end process;

	x_e : entity hdl4fpga.rom
	generic map (
		bitrom => xtab_bit)
	port map (
		clk    => video_clk,
		addr   => video_x,
		data   => mask_x);

	y_e : entity hdl4fpga.rom
	generic map (
		bitrom => ytab_bit)
	port map (
		clk    => video_clk,
		addr   => video_y,
		data   => mask_y);

	win_don <= mask_y and mask_x and (win_don'range => frm and don);
	process (video_clk)
	begin
		if rising_edge(video_clk) then
			win_nhl <= edge_x and not (mask_x and mask_y);
			edge_x  <= mask_x and mask_y;
		end if;
	end process;
	win_frm <= mask_y and (win_frm'range => frm);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity win is
	port (
		video_clk : in  std_logic;
		video_nhl : in  std_logic;
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
			elsif video_nhl='1' then
				y := y + 1;
			end if;
			win_x <= std_logic_vector(x);
			win_y <= std_logic_vector(y);
		end if;
	end process;
end architecture;

