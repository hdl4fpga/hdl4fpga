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
use hdl4fpga.videopkg.all;

entity box_edges is
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

architecture def of box_edges is

	signal rd_addr : std_logic_vector(unsigned_num_bits(edges'length-1)-1 downto 0); 
	signal rd_data : std_logic_vector(video_pos'range);
	signal wr_addr : std_logic_vector(rd_addr'range);
	signal wr_data : std_logic_vector(rd_data'range);

begin

	process (video_clk)
		variable div : unsigned(video_div'length-1 downto 0);
	begin
		if rising_edge(video_clk) then
			if video_ini='1' then
				div := (others => '0');
			elsif next_edge='1' then
				div := div + 1;
			end if;
			rd_addr   <= std_logic_vector(div(rd_addr'range));
			video_div <= std_logic_vector(div);
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => to_bitrom(edges, video_pos'length))
	port map (
		wr_clk  => '-',
		wr_ena  => '0',
		wr_addr => rd_addr,
		wr_data => rd_data,

		rd_addr => rd_addr,
		rd_data => rd_data);

	video_edge <= setif(video_pos=rd_data);
	
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.videopkg.all;

entity video_sync is
	generic (
		mode : natural := 1);
	port (
		video_clk    : in std_logic;
		video_hzsync : out std_logic;
		video_vtsync : out std_logic;
		video_hzcntr : out std_logic_vector;
		video_vtcntr : out std_logic_vector;
		video_hzon   : out std_logic;
		video_vton   : out std_logic);
end;

architecture mix of video_sync is

	signal hz_ini  : std_logic;
	signal vt_ini  : std_logic;
	signal hz_edge : std_logic;
	signal vt_edge : std_logic;
	signal hz_next : std_logic;
	signal vt_next : std_logic;
	signal hz_div  : std_logic_vector(2-1 downto 0);
	signal vt_div  : std_logic_vector(2-1 downto 0);
	signal hz_cntr : std_logic_vector(video_hzcntr'range);
	signal vt_cntr : std_logic_vector(video_vtcntr'range);

begin

	hz_ini  <= hz_edge and setif(hz_div="11");
	hz_next <= hz_edge;
	hzedges_e : entity hdl4fpga.box_edges
	generic map (
		edges =>  to_edges(modeline_data(mode)(0 to 4-1)))
	port map (
		video_clk  => video_clk,
		video_ini  => hz_ini,
		next_edge  => hz_next,
		video_pos  => hz_cntr,
		video_edge => hz_edge,
		video_div  => hz_div);
	video_hzsync <= setif(hz_div="10");
	video_hzon   <= setif(hz_div="00");

	vt_ini  <= vt_edge and hz_ini and setif(vt_div="11");
	vt_next <= vt_edge and hz_ini;
	vtedges_e : entity hdl4fpga.box_edges
	generic map (
		edges =>  to_edges(modeline_data(mode)(4 to 8-1)))
	port map (
		video_clk  => video_clk,
		video_ini  => vt_ini,
		next_edge  => vt_next,
		video_pos  => vt_cntr,
		video_edge => vt_edge,
		video_div  => vt_div);

	video_vtsync <= setif(vt_div="10");
	video_vton   <= setif(vt_div="00");

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity videobox_layout is
	generic (
		x_sides     : natural_vector;
		y_sides     : natural_vector);
	port (
		video_clk   : in  std_logic;
		video_yon   : in  std_logic;
		video_xon   : in  std_logic;
		video_posx  : in  std_logic_vector;
		video_posy  : in  std_logic_vector;
		box_sidex   : out std_logic;
		box_sidey   : out std_logic;
		box_xon     : out std_logic;
		box_eol     : out std_logic;
		box_yon     : out std_logic;
		box_divx    : out std_logic_vector;
		box_divy    : out std_logic_vector);
end;

architecture def of videobox_layout is

	signal video_inix  : std_logic;
	signal video_iniy  : std_logic;
	signal video_sidex : std_logic;
	signal video_sidey : std_logic;
	signal next_sidex  : std_logic;
	signal next_sidey  : std_logic;
	signal video_divx  : std_logic_vector(box_divx'range);
	signal video_divy  : std_logic_vector(box_divy'range);

begin

	next_sidex <= video_sidex and setif(unsigned(video_divx) < to_unsigned(x_sides'length, video_divx'length));
	video_inix <= not video_xon or not video_yon;
	x_e : entity hdl4fpga.box_edges
	generic map (
		edges      => x_sides)
	port map (
		video_clk  => video_clk,
		video_ini  => video_inix,
		next_edge  => next_sidex,
		video_pos  => video_posx,
		video_div  => video_divx,
		video_edge => video_sidex);

	next_sidey <= setif(unsigned(video_divx) = to_unsigned(x_sides'length-1, video_divx'length)) and video_sidex and video_sidey;
	video_iniy <= not video_yon;
	y_e : entity hdl4fpga.box_edges
	generic map (
		edges      => y_sides)
	port map (
		video_clk  => video_clk,
		video_ini  => video_iniy,
		next_edge  => next_sidey,
		video_pos  => video_posy,
		video_div  => video_divy,
		video_edge => video_sidey);

	box_xon <= setif(unsigned(video_divx) < to_unsigned(x_sides'length, video_divx'length))   and video_xon;
	box_eol <= setif(unsigned(video_divx) = to_unsigned(x_sides'length-1, video_divx'length)) and video_sidex and video_xon;
	box_yon <= setif(unsigned(video_divy) < to_unsigned(y_sides'length, video_divy'length))   and video_yon;

	box_sidex <= video_sidex;
	box_sidey <= next_sidey;
	box_divx  <= video_divx;
	box_divy  <= video_divy;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_box is
	port (
		video_clk    : in  std_logic;
		video_xon    : in std_logic;
		video_yon    : in std_logic;
		video_eol    : in std_logic;
		box_sidex    : in  std_logic;
		box_sidey    : in  std_logic;
		box_posx     : out std_logic_vector;
		box_posy     : out std_logic_vector);
end;

architecture def of video_box is
begin
	process (video_clk)
		variable posx : unsigned(box_posx'range);
		variable posy : unsigned(box_posy'range);
	begin
		if rising_edge(video_clk) then
			if video_xon='0' then
				posx := (others => '0');
			elsif video_yon='0' then
				posx := (others => '0');
			elsif box_sidex='1' then
				posx := (others => '0');
			else
				posx := posx + 1;
			end if;

			if video_yon='0' then
				posy := (others => '0');
			elsif box_sidey='1' then
				posy := (others => '0');
			elsif video_eol='1' then
				posy := posy + 1;
			end if;

			box_posx <= std_logic_vector(posx);
			box_posy <= std_logic_vector(posy);
		end if;
	end process;
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity draw_line is
	port (
		ena   : in  std_logic := '1';
		mask  : in  std_logic_vector; 
		x     : in  std_logic_vector;
		dot   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of draw_line is
	constant min_len : natural := hdl4fpga.std.min(x'length, mask'length);
begin
	dot <= ena when (resize(unsigned(x), min_len) and resize(unsigned(mask),min_len))=(0 to min_len-1 => '0') else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity draw_vline is
	generic (
		n : natural := 12);
	port(
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		row1 : in  std_logic_vector(n-1 downto 0);
		row2 : in  std_logic_vector(n-1 downto 0);
		dot  : out std_logic);
end;

library hdl4fpga;

architecture arc of draw_vline is
	signal le1, le2 : std_logic;
	signal eq1, eq2 : std_logic;
	signal enad : std_logic;
begin
	ena_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => n+1))
	port map (
		clk => clk,
		di(0) => ena,
		do(0) => enad);

	leq_e : entity hdl4fpga.pipe_le
	generic map (
		n => n)
	port map (
		clk => clk,
		a   => row1,
		b   => row2,
		le  => le2,
		eq  => eq2);

	process (clk)
	begin
		if rising_edge(clk) then
			dot <= ((le1 xor le2) or eq2 or eq1) and enad;
			le1 <= le2;
			eq1 <= eq2;
		end if;
	end process;
end;
