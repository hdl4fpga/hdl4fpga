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

entity dvi_subpxl is
	port (
		clk   : in  std_logic;
		hsync : in  std_logic;
		vsync : in  std_logic;
		blank : in  std_logic;
		rgb   : in  std_logic_vector(3*8-1 downto 0);
		chn0  : buffer std_logic_vector(10-1 downto 0);
		chn1  : out std_logic_vector(10-1 downto 0);
		chn2  : out std_logic_vector(10-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of dvi_subpxl is
	constant c00  : std_logic_vector := "1101010100";
	constant c01  : std_logic_vector := "0010101011";
	constant c10  : std_logic_vector := "0101010100";
	constant c11  : std_logic_vector := "1010101011";

	signal c_chn0 : std_logic_vector(chn0'range);
	signal c      : std_logic_vector(3*chn0'length-1 downto 0);
	signal chnpxl : std_logic_vector(3*chn0'length-1 downto 0);
begin
	c <= c00 & c00 & std_logic_vector'(multiplex(c00 & c01 & c10 & c11, vsync & hsync));
	chn0to2_g : for i in 0 to 3-1 generate
		tmds_encoder_e : entity hdl4fpga.tmds_encoder
		port map (
			clk     => clk,
			c       => c(c00'length*(i+1)-1 downto c00'length*i),
			de      => blank,
			data    => rgb(rgb'length/3*(i+1)-1 downto rgb'length/3*i),
			encoded => chnpxl(chn0'length*(i+1)-1 downto chn0'length*i));
	end generate;

	chn0 <= chnpxl(chn0'length*1-1 downto chn0'length*0);
	chn1 <= chnpxl(chn0'length*2-1 downto chn0'length*1);
	chn2 <= chnpxl(chn0'length*3-1 downto chn0'length*2);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dvi is
	generic (
		fifo_mode : boolean := false;
		gear : natural := 10);
	port (
		clk   : in  std_logic;
		rgb   : in  std_logic_vector(3*8-1 downto 0);
		hsync : in  std_logic;
		vsync : in  std_logic;
		blank : in  std_logic;
		cclk  : in  std_logic;
		chn0  : out std_logic_vector(gear-1 downto 0);
		chn1  : out std_logic_vector(gear-1 downto 0);
		chn2  : out std_logic_vector(gear-1 downto 0);
		chnc  : out std_logic_vector(gear-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.base.all;

architecture def of dvi is
	signal cpixel : std_logic_vector(3*10-1 downto 0);
	alias cred   is cpixel(3*10-1 downto 2*10);
	alias cgreen is cpixel(2*10-1 downto 1*10);
	alias cblue  is cpixel(1*10-1 downto 0*10);

	signal spixel : std_logic_vector(3*gear-1  downto 0);
	alias sred   is spixel(3*gear-1 downto 2*gear);
	alias sgreen is spixel(2*gear-1 downto 1*gear);
	alias sblue  is spixel(1*gear-1 downto 0*gear);

	constant dvi_clk : unsigned(10-1 downto 0) := b"0000011111";
begin

	dvisubpxl_e : entity hdl4fpga.dvi_subpxl
	port map (
		clk   => clk,
		hsync => hsync,
		vsync => vsync,
		blank => blank,
		rgb   => rgb,
		chn0  => cblue,
		chn1  => cgreen,
		chn2  => cred);

	chnc_e : entity hdl4fpga.serlzr
	generic map (
		fifo_mode => fifo_mode)
	port map (
		src_clk  => clk,
		src_frm  => '1',
		src_data => std_logic_vector(dvi_clk),
		dst_clk  => cclk,
		dst_data => chnc);

	chn0to2_g : for i in 0 to 3-1 generate
		serlzr_e : entity hdl4fpga.serlzr
		generic map (
			lsdfirst  => true,
			fifo_mode => fifo_mode)
		port map (
			src_clk  => clk,
			src_frm  => '1',
			src_data => cpixel(10*(i+1)-1 downto 10*i),
			dst_clk  => cclk,
			dst_data => spixel(gear*(i+1)-1 downto gear*i));
	end generate;

	chn0 <= sblue;
	chn1 <= sgreen;
	chn2 <= sred;

end;