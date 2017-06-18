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
		tab         : natural_vector);
	port (
		video_clk : in  std_logic;
		pwin_on   : in  std_logic;
		pwin_x    : in  std_logic_vector;
		win_rst   : out std_logic_vector;
		win_on    : out std_logic_vector;
		win_eof   : out std_logic_vector);
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

	constant tab_bit     : std_logic_vector := init_data(tab, pwin_x'length);
	signal   won, don    : std_logic_vector(win_on'range);
	signal   q0,q1,q2,q3 : std_logic_vector(win_on'range);
begin

	rom_e : entity hdl4fpga.rom
	generic map (
		synchronous => false,
		bitrom      => tab_bit)
	port map (
		addr        => pwin_x,
		data        => won);
	don <= won and (win_on'range => pwin_on);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			q3  <= not q0 or  don;
			q2  <=     q0 and don;
			q1  <= q0;
			q0  <= don;
		end if;
	end process;
	win_on  <= q1;
	win_rst <= q2;
	win_eof <= q3;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity win_mngr is
	generic (
		synchronous : boolean := TRUE;
		tab         : natural_vector);
	port (
		video_clk : in  std_logic;
		pwin_x    : in  std_logic_vector;
		pwin_y    : in  std_logic_vector;
		pwin_fon  : in  std_logic;
		pwin_lon  : in  std_logic;
		win_leof  : out std_logic_vector;
		win_lrst  : out std_logic_vector;
		win_frst  : out std_logic_vector;
		win_lon   : out std_logic_vector;
		win_fon   : out std_logic_vector);

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

	signal mask_y : std_logic_vector(win_lon'range);
	signal mask_x : std_logic_vector(win_fon'range);
	signal feof   : std_logic_vector(win_fon'range);


begin

	x_e : entity hdl4fpga.win_side
	generic map (
		tab       => tabx)
	port map (
		video_clk => video_clk,
		pwin_on   => pwin_lon,
		pwin_x    => pwin_x,
		win_eof   => win_leof,
		win_rst   => win_lrst,
		win_on    => mask_x);

	y_e : entity hdl4fpga.win_side
	generic map (
		tab       => taby)
	port map (
		video_clk => video_clk,
		pwin_on   => pwin_fon,
		pwin_x    => pwin_y,
		win_eof   => feof,
		win_rst   => win_frst,
		win_on    => mask_y);

	win_lon <= mask_y and mask_x;
	win_fon <= mask_y;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity win is
	port (
		video_clk : in  std_logic;
		win_frst  : in  std_logic;
		win_lrst  : in  std_logic;
		win_leof  : in  std_logic;
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
			if win_lrst='0' then
				x := (others => '0');
			else
				x := x + 1;
			end if;

			if win_frst='0' then
				y := (others => '0');
			elsif win_leof='0' then
				y := y + 1;
			end if;
			win_x <= std_logic_vector(x);
			win_y <= std_logic_vector(y);
		end if;
	end process;
end architecture;

