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

entity videobox_sides is
	generic (
		sides      : natural_vector);
	port (
		video_clk  : in  std_logic;
		video_ini  : in  std_logic;
		next_side  : in  std_logic;
		video_pos  : in  std_logic_vector;
		video_div  : out std_logic_vector;
		video_side : out std_logic);
end;

architecture def of box_sides is

	signal rd_addr : std_logic_vector(unsigned_num_bits(sides'length-1)-1 downto 0); 
	signal rd_data : std_logic_vector(video_pos'range);

	function to_bitrom (
		constant data : natural_vector;
		constant size : natural)
		return std_logic_vector is
		variable retval : unsigned(0 to data'length*size-1);
	begin
		for i in data'range loop
			retval(0 to size-1) := to_unsigned(data(i), size);
			retval := retval rol size;
		end loop;
		return std_logic_vector(retval);
	end;

	signal on_side : std_logic;

begin

	process (video_clk)
		variable div : unsigned(video_div'length-1 downto 0);
	begin
		if rising_edge(video_clk) then
			if video_ini='1' then
				div := (others => '0');
			elsif next_side='1' then
				div := div + 1;
			end if;
			rd_addr   <= std_logic_vector(div(rd_addr'range));
			video_div <= std_logic_vector(div);
		end if;
	end process;

	mem_e : entity hdl4fpga.dpram
	generic map (
		bitrom => to_bitrom(sides, video_pos'length))
	port map (
		wr_clk  => '-',
		wr_ena  => '0',
		wr_addr => (rd_addr'range => '-'),
		wr_data => (rd_data'range => '-'),

		rd_addr => rd_addr,
		rd_data => rd_data);

	video_side <= setif(video_pos=rd_data);
	
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
	x_e : entity hdl4fpga.box_sides
	generic map (
		sides      => x_sides)
	port map (
		video_clk  => video_clk,
		video_ini  => video_inix,
		next_side  => next_sidex,
		video_pos  => video_posx,
		video_div  => video_divx,
		video_side => video_sidex);

	next_sidey <= setif(unsigned(video_divx) = to_unsigned(x_sides'length-1, video_divx'length)) and video_sidex and video_sidey;
	video_iniy <= not video_yon;
	y_e : entity hdl4fpga.box_sides
	generic map (
		sides      => y_sides)
	port map (
		video_clk  => video_clk,
		video_ini  => video_iniy,
		next_side  => next_sidey,
		video_pos  => video_posy,
		video_div  => video_divy,
		video_side => video_sidey);

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

