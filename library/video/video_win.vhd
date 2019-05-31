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
		video_edge : out std_logic_vector);
end;

architecture def of winlayout_edge is

	signal rd_addr : std_logic_vector(video_div'range);
	signal rd_data : std_logic_vector(video_pos'range);

	function to_bitrom (
		constant data : natural_vector;
		constant size : natural)
		return std_logic_vector is
		variable retval : unsigned(0 to data'length*size)
	begin
		for i in divisions'range loop
			retval(0 tosize-1) := to_unsigned(data(i), size);
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
				rd_addr <= std_logic_vector(unsigned(rd_addr) + 1));
			end if;
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => to_bitrom(edges))
	port map (
		wr_clk  => '-',
		wr_ena  => '0',
		wr_addr => (rd_addr'range => '-'),
		wr_data => (rd_data'range => '-'),

		rd_addr => rd_addr,
		rd_data => rd_data);

	video_div  <= rd_addr;
	video_edge <=  setif(video_pos=rd_data);
	
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity win_layout is
	generic (
		x_edges     : natural_vector;
		y_edges     : natural_vector;
	port (
		video_clk   : in  std_logic;
		video_posx  : in  std_logic_vector;
		video_posy  : in  std_logic_vector;
		video_vton  : in  std_logic;
		video_hzon  : in  std_logic;
		video_xdiv  : out std_logic_vector;
		video_ydiv  : out std_logic_vector;
		win_hzsync  : out std_logic;
		win_vtsync  : out std_logic;
		win_xdiv    : out std_logic;
		win_ydiv    : out std_logic);

end;

architecture def of win_layout is

	signal video_xini : std_logic;
	signal video_yini : std_logic;
	signal video_xdiv : std_logic_vector(win_xdiv);
	signal video_ydiv : std_logic_vector(win_ydiv);

	signal last_xedge : std_logic;
	signal last_yedge : std_logic;
	signal next_xedge : std_logic;
	signal next_yedge : std_logic;

begin

	last_xedge <= setif(unsigned(video_xdiv) = to_unsigned(x_edges'length-1));
	next_xedge <= video_xedge and not last_xedge;
	video_xini <= not video_hzon;
	xedge_e : entity hdl4fpga.winlayout_edge
	generic map (
		edges      => x_edges)
	port map (
		video_clk  => video_clk,
		video_ini  => video_xini,
		next_edge  => next_xedge,
		video_pos  => video_xpos,
		video_div  => video_xdiv,
		video_edge => video_xedge);

	last_yedge <= setif(unsigned(video_ydiv) = to_unsigned(y_edges'length-1));
	next_yedge <= video_xedge and last_xdge;
	video_yini <= not video_vton;
	yedge_e : entity hdl4fpga.winlayout_dge
	generic map (
		edges      => y_edges)
	port map (
		video_clk  => video_clk,
		video_ena  => video_yena,
		video_ini  => video_yini,
		video_pos  => video_ypos,
		video_div  => video_ydiv,
		video_edge => video_yedge);

	win_hzsync <= video_xedge;
	win_vtsync <= video_yedge and video_xedge;
	win_xdiv   <= video_xdiv;
	win_ydiv   <= video_ydiv;

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
		win_xedge    : in  std_logic;
		win_posx     : out std_logic_vector;
		win_poxy     : out std_logic_vector);
end;

architecture def of win is
begin
	process (video_clk)
		variable x : unsigned(win_x'range);
		variable y : unsigned(win_y'range);
	begin
		if rising_edge(video_clk) then
			if win_hzsync='1' then
				x := (others => '0');
			else
				x := x + 1;
			end if;
			if win_vtsync='1' then
				y := (others => '0');
			elsif video_hzsync='1' then
				y := y + 1;
			end if;
			win_posx <= std_logic_vector(x);
			win_posy <= std_logic_vector(y);
		end if;
	end process;
end architecture;

