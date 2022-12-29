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
--	signal wr_addr : std_logic_vector(rd_addr'range);
--	signal wr_data : std_logic_vector(rd_data'range);

begin

	process (video_clk)
		variable div : std_logic_vector(video_div'length-1 downto 0) := (others => '0');
	begin
		if rising_edge(video_clk) then
			if video_ini='1' then
				div := (others => '0');
			elsif next_edge='1' then
				div := std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(div))) + 1);
			end if;
			rd_addr   <= div(rd_addr'range);
			video_div <= div;
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
		clk  => video_clk,
		addr => rd_addr,
		data => rd_data);

	video_edge <= setif(video_pos=rd_data);
	
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.videopkg.all;

entity video_sync is
	generic (
		timing_id : videotiming_ids;
		modeline  : natural_vector(0 to 9-1) := (others => 0);
		width     : natural := 0;
		height    : natural := 0;
		fps       : real    := 0.0;
		pclk      : real    := 0.0);
	port (
		video_clk     : in std_logic;
		extern_video  : in  std_logic := '0';
		extern_hzsync : in std_logic := '-';
		extern_vtsync : in std_logic := '-';
		extern_blankn : in std_logic := '-';
		video_hzsync  : out std_logic;
		video_vtsync  : out std_logic;
		video_hzcntr  : out std_logic_vector;
		video_vtcntr  : out std_logic_vector;
		video_hzon    : out std_logic;
		video_vton    : out std_logic);
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

	signal extern_vton : std_logic;

	function user_fallback (
		timing_id : videotiming_ids;
		modeline  : natural_vector)
		return natural_vector is
	begin
		if timing_id=user_timingid then
			return modeline;
		end if;
		return modeline_tab(timing_id);
	end;

	constant modeline_data : natural_vector := user_fallback(timing_id, modeline);
begin

	hz_ini  <= hz_edge and setif(hz_div="11");
	hz_next <= hz_edge;
	hzedges_e : entity hdl4fpga.box_edges
	generic map (
		edges =>  to_edges(modeline_data(0 to 4-1)))
	port map (
		video_clk  => video_clk,
		video_ini  => hz_ini,
		next_edge  => hz_next,
		video_pos  => hz_cntr,
		video_edge => hz_edge,
		video_div  => hz_div);
	video_hzsync <= setif(hz_div="10") when extern_video='0' else extern_hzsync;
	video_hzon   <= setif(hz_div="00") when extern_video='0' else extern_blankn;
	video_hzcntr <= hz_cntr;

	process(video_clk)
	begin
		if rising_edge(video_clk) then
			if extern_video='0' and hz_ini='1' then
				hz_cntr <= (others => '0');
			elsif extern_video='1' and extern_blankn='0' then
				hz_cntr <= (others => '0');
			else
				hz_cntr <= std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(hz_cntr))) + 1);
			end if;
		end if;
	end process;

	vt_ini  <= hz_ini and vt_edge and setif(vt_div="11") when extern_video='0' else '1';

	vt_next <= hz_ini and vt_edge when extern_video='0' else '0';

	vtedges_e : entity hdl4fpga.box_edges
	generic map (
		edges =>  to_edges(modeline_data(4 to 8-1)))
	port map (
		video_clk  => video_clk,
		video_ini  => vt_ini,
		next_edge  => vt_next,
		video_pos  => vt_cntr,
		video_edge => vt_edge,
		video_div  => vt_div);

	process(video_clk)
		variable blankn_edge  : std_logic;
	begin
		if rising_edge(video_clk) then
			if extern_video='0' then
				if vt_ini='1' then
					vt_cntr <= (others => '0');
				elsif hz_ini='1' then
					vt_cntr <= std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(vt_cntr))) + 1);
				end if;
			else
				if extern_vtsync='1' then
					vt_cntr <= (others => '0');
				elsif extern_blankn='0' and blankn_edge='1' then
					vt_cntr <= std_logic_vector(unsigned(to_stdlogicvector(to_bitvector(vt_cntr))) + 1);
				end if;
			end if;
			blankn_edge := extern_blankn;
		end if;
	end process;

	process(extern_blankn, video_clk)
		variable sel_blankn : std_logic;
	begin
		if rising_edge(video_clk) then
			if vt_edge='1' then
				if extern_blankn='1' then
					sel_blankn := '1';
				end if;
			elsif extern_vtsync='1' then
				sel_blankn := '1';
			elsif extern_blankn='1' then
				sel_blankn := '0';
			end if;
		end if;
		extern_vton <= setif(sel_blankn='0', '1', extern_blankn);
	end process;

	video_vtsync <= setif(vt_div="10") when extern_video='0' else extern_vtsync;
	video_vton   <= setif(vt_div="00") when extern_video='0' else extern_vton;
	video_vtcntr <= vt_cntr;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

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
use hdl4fpga.base.all;

architecture def of draw_line is
	constant min_len : natural := hdl4fpga.base.min(x'length, mask'length);
begin
	dot <= ena when (resize(unsigned(x), min_len) and resize(unsigned(mask),min_len))=(0 to min_len-1 => '0') else '0';
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

entity draw_vline is
	generic (
		sync : boolean := false);
	port(
		clk  : in  std_logic := '-';
		ena  : in  std_logic := '1';
		y1   : in  std_logic_vector;
		y2   : in  std_logic_vector;
		row  : in  std_logic_vector;
		dot  : out std_logic);
end;

architecture def of draw_vline is
	signal lt1 : std_logic;
	signal eq1 : std_logic;
	signal lt2 : std_logic;
	signal eq2 : std_logic;
	signal don : std_logic;
begin

	process (ena, row, y1, y2, clk)
	begin
		if sync then
			if rising_edge(clk) then
				don <= ena;
				lt1 <= setif(signed(y1) < signed(row));
				eq1 <= setif(signed(y1) = signed(row));
				lt2 <= setif(signed(y2) < signed(row));
				eq2 <= setif(signed(y2) = signed(row));
			end if;
		else
			don <= ena;
			lt1 <= setif(signed(y1) < signed(row));
			eq1 <= setif(signed(y1) = signed(row));
			lt2 <= setif(signed(y2) < signed(row));
			eq2 <= setif(signed(y2) = signed(row));
		end if;
	end process;

	dot <= ((lt1 xor lt2) or eq2 or eq1) and don;
end;
