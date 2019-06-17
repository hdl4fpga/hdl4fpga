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
		variable div : unsigned(video_div'length-1 downto 0) := (others => '0');
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

--	mem_e : entity hdl4fpga.dpram
--	generic map (
--		bitrom => to_bitrom(edges, video_pos'length))
--	port map (
--		wr_clk  => '-',
--		wr_ena  => '0',
--		wr_addr => rd_addr,
--		wr_data => rd_data,
--
--		rd_addr => rd_addr,
--		rd_data => rd_data);

	mem_e : entity hdl4fpga.rom
	generic map (
		bitrom => to_bitrom(edges, video_pos'length))
	port map (
		addr => rd_addr,
		data => rd_data);

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
	signal hz_div  : std_logic_vector(2-1 downto 0) := (others => '0');
	signal vt_div  : std_logic_vector(2-1 downto 0) := (others => '0');
	signal hz_cntr : std_logic_vector(video_hzcntr'range) := (others => '0');
	signal vt_cntr : std_logic_vector(video_vtcntr'range) := (others => '0');

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
	video_hzcntr <= hz_cntr;

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if hz_ini='1' then
				hz_cntr <= (others => '0');
			else
				hz_cntr <= std_logic_vector(unsigned(hz_cntr) + 1);
			end if;
		end if;
	end process;

	vt_ini  <= hz_ini and vt_edge and setif(vt_div="11");
	vt_next <= hz_ini and vt_edge;
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

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if vt_ini='1' then
				vt_cntr <= (others => '0');
			elsif hz_ini='1' then
				vt_cntr <= std_logic_vector(unsigned(vt_cntr) + 1);
			end if;
		end if;
	end process;

	video_vtsync <= setif(vt_div="10");
	video_vton   <= setif(vt_div="00");
	video_vtcntr <= vt_cntr;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity videobox_layout is
	generic (
		x_edges   : natural_vector;
		y_edges   : natural_vector);
	port (
		video_clk : in  std_logic;
		video_xon : in  std_logic;
		video_yon : in  std_logic;
		video_x   : in  std_logic_vector;
		video_y   : in  std_logic_vector;

		box_xedge : out std_logic;
		box_yedge : out std_logic;
		box_xon   : out std_logic;
		box_yon   : out std_logic;
		box_eox   : out std_logic;
		box_nextx : out std_logic;
		box_nexty : out std_logic;
		box_xdiv  : out std_logic_vector;
		box_ydiv  : out std_logic_vector);
end;

architecture def of videobox_layout is

	signal x_ini  : std_logic;
	signal y_ini  : std_logic;
	signal x_edge : std_logic;
	signal y_edge : std_logic;
	signal next_x : std_logic;
	signal next_y : std_logic;
	signal x_div  : std_logic_vector(box_xdiv'range);
	signal y_div  : std_logic_vector(box_ydiv'range);

begin

	x_ini  <= not video_xon or not video_yon;
	next_x <= x_edge and setif(unsigned(x_div) < x_edges'length);
	xedges_e : entity hdl4fpga.box_edges
	generic map (
		edges      => x_edges)
	port map (
		video_clk  => video_clk,
		video_ini  => x_ini,
		next_edge  => next_x,
		video_pos  => video_x,
		video_div  => x_div,
		video_edge => x_edge);

	y_ini  <= not video_yon;
	next_y <= x_edge and y_edge and setif(unsigned(x_div) = x_edges'length-1);
	y_e : entity hdl4fpga.box_edges
	generic map (
		edges      => y_edges)
	port map (
		video_clk  => video_clk,
		video_ini  => y_ini,
		next_edge  => next_y,
		video_pos  => video_y,
		video_div  => y_div,
		video_edge => y_edge);

	box_xon <= setif(unsigned(x_div) < x_edges'length)   and video_xon;
	box_yon <= setif(unsigned(y_div) < y_edges'length)   and video_yon;
	box_eox <= setif(unsigned(x_div) = x_edges'length-1) and video_xon and x_edge;

	box_xedge <= x_edge;
	box_yedge <= y_edge;
	box_nextx <= next_x;
	box_nexty <= next_y;
	box_xdiv  <= x_div;
	box_ydiv  <= y_div;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity videobox is
	port (
		video_clk : in  std_logic;
		video_xon : in  std_logic;
		video_yon : in  std_logic;
		video_eox : in  std_logic;
		box_xedge : in  std_logic;
		box_yedge : in  std_logic;
		box_x     : out std_logic_vector;
		box_y     : out std_logic_vector);
end;

architecture def of videobox is
begin
	process (video_clk)
		variable x : unsigned(box_x'range);
		variable y : unsigned(box_y'range);
	begin
		if rising_edge(video_clk) then
			if video_xon='0' then
				x := (others => '0');
			elsif video_yon='0' then
				x := (others => '0');
			elsif box_xedge='1' then
				x := (others => '0');
			else
				x := x + 1;
			end if;

			if video_yon='0' then
				y := (others => '0');
			elsif video_eox='1' then
				if box_yedge='1' then
					y := (others => '0');
				else
					y := y + 1;
				end if;
			end if;

			box_x <= std_logic_vector(x);
			box_y <= std_logic_vector(y);
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

library hdl4fpga;
use hdl4fpga.std.all;

entity draw_vline is
	generic (
		n : natural := 0);
	port(
		clk  : in  std_logic;
		ena  : in  std_logic := '1';
		row1 : in  std_logic_vector(n-1 downto 0);
		row2 : in  std_logic_vector(n-1 downto 0);
		dot  : out std_logic);
end;

architecture def of draw_vline is
	signal enad : std_logic;
begin
	ena_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => 2))
	port map (
		clk => clk,
		di(0) => ena,
		do(0) => enad);

	process (clk)
		variable le1, le2 : std_logic;
		variable eq1, eq2 : std_logic;
	begin
		if rising_edge(clk) then
			dot <= ((le1 xor le2) or eq2 or eq1) and enad;
			le1 := le2;
			eq1 := eq2;
			le2 := setif(unsigned(row1) <= unsigned(row2));
			eq2 := setif(unsigned(row1)  = unsigned(row2));
		end if;
	end process;
end;

architecture serial_arith of draw_vline is
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
