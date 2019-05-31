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

entity winlayout_edge is
	generic (
		edges      : natural_vector);
	port (
		video_clk  : in  std_logic;
		video_ini  : in  std_logic;
		next_edge  : in  std_logic;
		video_pos  : in  std_logic_vector;
		video_div  : out std_logic_vector;
		video_edge : out std_logic);
end;

architecture def of winlayout_edge is

	signal rd_addr : std_logic_vector(video_div'range);
	signal rd_data : std_logic_vector(video_pos'range);

	function to_bitrom (
		constant data : natural_vector;
		constant size : natural)
		return std_logic_vector is
		variable retval : unsigned(0 to data'length*size);
	begin
		for i in edges'range loop
			retval(0 to size-1) := to_unsigned(data(i), size);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	signal on_edge : std_logic;

begin

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			if video_ini='1' then
				rd_addr <= (others => '0');
			elsif next_edge='1' then
				rd_addr <= std_logic_vector(unsigned(rd_addr) + 1);
			end if;
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => to_bitrom(edges, video_pos'length))
	port map (
		wr_clk  => '-',
		wr_ena  => '0',
		wr_addr => (rd_addr'range => '-'),
		wr_data => (rd_data'range => '-'),

		rd_addr => rd_addr,
		rd_data => rd_data);

	video_div  <= rd_addr;
	video_edge <= setif(video_pos=rd_data);
	
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity win_layout is
	generic (
		x_edges     : natural_vector;
		y_edges     : natural_vector);
	port (
		video_clk   : in  std_logic;
		video_posx  : in  std_logic_vector;
		video_posy  : in  std_logic_vector;
		video_vton  : in  std_logic;
		video_hzon  : in  std_logic;
		win_hzsync  : out std_logic;
		win_vtsync  : out std_logic;
		win_divx    : out std_logic_vector;
		win_divy    : out std_logic_vector);

end;

architecture def of win_layout is

	signal video_inix : std_logic;
	signal video_iniy : std_logic;
	signal video_divx : std_logic_vector(win_divx'range);
	signal video_divy : std_logic_vector(win_divy'range);

	signal last_edgex  : std_logic;
	signal last_edgey  : std_logic;
	signal video_edgex : std_logic;
	signal video_edgey : std_logic;
	signal next_edgex  : std_logic;
	signal next_edgey  : std_logic;

begin

	last_edgex <= setif(unsigned(video_divx) = to_unsigned(x_edges'length-1, video_divx'length));
	next_edgex <= video_edgex and not last_edgex;
	video_inix <= not video_hzon;
	xedge_e : entity hdl4fpga.winlayout_edge
	generic map (
		edges      => x_edges)
	port map (
		video_clk  => video_clk,
		video_ini  => video_inix,
		next_edge  => next_edgex,
		video_pos  => video_posx,
		video_div  => video_divx,
		video_edge => video_edgex);

	last_edgey <= setif(unsigned(video_divy) = to_unsigned(y_edges'length-1, video_divy'length));
	next_edgey <= video_edgex and last_edgex;
	video_iniy <= not video_vton;
	edgey_e : entity hdl4fpga.winlayout_edge
	generic map (
		edges      => y_edges)
	port map (
		video_clk  => video_clk,
		video_ini  => video_iniy,
		next_edge  => next_edgey,
		video_pos  => video_posy,
		video_div  => video_divy,
		video_edge => video_edgey);

	win_hzsync <= video_edgex;
	win_vtsync <= video_edgey and video_edgex;
	win_divx   <= video_divx;
	win_divy   <= video_divy;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity win is
	port (
		video_clk    : in  std_logic;
		video_hzon   : in std_logic;
		video_vton   : in std_logic;
		video_hzsync : in std_logic;
		win_edgex    : in  std_logic;
		win_posx     : out std_logic_vector;
		win_posy     : out std_logic_vector);
end;

architecture def of win is
begin
	process (video_clk)
		variable posx : unsigned(win_posx'range);
		variable posy : unsigned(win_posy'range);
	begin
		if rising_edge(video_clk) then
			if win_edgex='1' then
				posx := (others => '0');
			else
				posx := posx + 1;
			end if;
			if video_vton='0' then
				posy := (others => '0');
			elsif video_hzsync='1' then
				posy := posy + 1;
			end if;
			win_posx <= std_logic_vector(posx);
			win_posy <= std_logic_vector(posy);
		end if;
	end process;
end architecture;

