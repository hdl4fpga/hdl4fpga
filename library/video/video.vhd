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

entity video_timing_rom is
	generic (
		m : natural := 1;
		n : natural := 11;
		mode : in  natural);
	port (

		hparm : in  std_logic_vector(0 to 1);
		hdata : out std_logic_vector(n-1 downto 0);

		vparm : in  std_logic_vector(0 to 1);
		vdata : out std_logic_vector(n-1 downto 0));
end;

architecture mix of video_timing_rom is
	type natural_matrix is array (natural range <>, natural range <>) of natural range 0 to 2**n-1;

	constant h_tab : natural_matrix (0 to 8, 3 downto 0) := (
--		0 => ( 32,  3,  5,  6),
		0 => ( 640,  24,  56,  80),	 --   640x480C@60Hz pclk  23.75MHz
		1 => ( 800,  32,  80, 112),	 --   800x600C@60Hz pclk  38.25MHz
		2 => (1024,  48, 104, 152),	 --  1024x768C@60Hz pclk  63.50MHz
		3 => (1280,  48,  32,  80),	 -- 1280x1024R@60Hz pclk  90.75MHz
		4 => (1280,  48, 112, 248),	 -- 1280x1024C@60Hz pclk 108.00MHz
		5 => (1680,  48,  32,  80),	 -- 1680x1050R@60Hz pclk 119.00MHz
		6 => (1920,  48,  32,  80),	 -- 1920x1080R@60Hz pclk 138.50MHz
--		7 => (1920,  92,  56, 132),  -- 1920x1080R@60Hz pclk 148.50MHz
		7 => (1920,  76,  128, 76),  -- 1920x1080R@60Hz pclk 148.50MHz
		8 => (1920, 128, 200, 328)); -- 1920x1080R@60Hz pclk 173.00MHz

	constant v_tab : natural_matrix (0 to 8, 3 downto 0) := (
--		0 => ( 24, 3, 4, 5),
		0 => ( 480, 3, 4, 13),	--   640x480C@60Hz pclk  23.75MHz
		1 => ( 600, 3, 4, 17),	--   800x600C@60Hz pclk  38.25MHz
		2 => ( 768, 3, 4, 23),	--  1024x768C@60Hz pclk  63.50MHz
		3 => (1024, 3, 7, 20),	-- 1280x1024R@60Hz pclk  90.75MHz
		4 => (1024, 1, 3, 38),	-- 1280x1024C@60Hz pclk 108.00MHz
		5 => (1050, 3, 6, 21),	-- 1680x1050R@60Hz pclk 119.00MHz
		6 => (1080, 3, 5, 23),	-- 1920x1080R@60Hz pclk 138.50MHz
--		7 => (1080, 2, 6, 37),	-- 1920x1080C@60Hz pclk 148.50MHz
		7 => (1080, 6, 1, 37),	-- 1920x1080C@60Hz pclk 148.50MHz
		8 => (1080, 3, 5, 32));	-- 1920x1080C@60Hz pclk 173.00MHz

	subtype word is std_logic_vector(n-1 downto 0);
	type word_vector is array (natural range <>) of word;

	function tab2rom (
		mode : natural;
		tab  : natural_matrix)
		return word_vector is
		variable val : word_vector(0 to 3);
	begin
		for i in tab'range(2) loop
			val(i) := std_logic_vector(to_signed(tab(mode, i)-2,n));
		end loop;
		return val;
	end;

	constant h_rom : word_vector(0 to 3) := tab2rom(mode,h_tab);
	constant v_rom : word_vector(0 to 3) := tab2rom(mode,v_tab);

begin
	hdata <= h_rom(to_integer(unsigned(hparm)));
	vdata <= v_rom(to_integer(unsigned(vparm)));
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_timing_gen is
	generic (
		n : natural := 12);
	port (
		clk   : in  std_logic;

		hdata : in  std_logic_vector(n downto 0);
		htmg  : out std_logic_vector(0 to 1);
		hpos  : out std_logic_vector(n-1 downto 0);
		heot  : buffer std_logic;
		heof  : out std_logic;

		vdata : in  std_logic_vector(n downto 0);
		vtmg  : out std_logic_vector(0 to 1);
		vpos  : out std_logic_vector(n-1 downto 0);
		veot  : out std_logic;
		veof  : out std_logic);
	end;

architecture beh of video_timing_gen is

	function dec (
		succ : std_logic;
		cntr : unsigned;
		data : std_logic_vector)
		return unsigned is
	begin
		if succ='1' then
			return resize(unsigned(data),cntr'length);
		else
			return cntr-1;
		end if;
	end;

	constant dp : std_logic_vector(0 to 1) := "11";
	constant bp : std_logic_vector(0 to 1) := "10";
	constant pw : std_logic_vector(0 to 1) := "01";
	constant fp : std_logic_vector(0 to 1) := "00";
begin
	process (clk)
		variable vparm     : unsigned(0 to 2)   := (others => '0');
		variable hparm     : unsigned(0 to 2)   := (others => '0');
		variable hcntr     : unsigned(0 to n)   := (others => '0');
		variable vcntr     : unsigned(0 to n)   := (others => '0');
		variable hcntrp    : unsigned(0 to n-1) := (others => '0');
		variable vcntrp    : unsigned(0 to n-1) := (others => '0');
		variable heoc      : std_logic;
		variable ena_vcntr : std_logic;
		variable ena_hparm : std_logic;
		variable ena_vparm : std_logic;
	begin
		if rising_edge(clk) then
			ena_hparm := heot;
			ena_vcntr := ena_hparm and hparm(0);
			ena_vparm := ena_vcntr and vcntr(0);

			if ena_vparm='1' then
				if vparm(0)='1' then
					vparm := resize(unsigned(bp), vparm'length);
				else
					vparm := vparm - 1;
				end if;
			end if;

			if ena_vcntr='1' then
				if vcntr(0)='1' then
					vcntr  := resize(unsigned(vdata), vcntr'length);
					vcntrp := (others => '0');
				else
					vcntr  := vcntr  - 1;
					vcntrp := vcntrp + 1;
				end if;
			end if;

			if ena_hparm='1' then
				if hparm(0)='1' then
					hparm := resize(unsigned(bp), hparm'length);
				else
					hparm := hparm - 1;
				end if;
			end if;

			if hcntr(0)='1' then
				hcntr  := resize(unsigned(hdata), hcntr'length);
				hcntrp := (others => '0');
			else
				hcntr  := hcntr  - 1;
				hcntrp := hcntrp + 1;
			end if;

			htmg <= std_logic_vector(hparm(1 to 2));
			vtmg <= std_logic_vector(vparm(1 to 2));

			hpos <= std_logic_vector(hcntrp);
			vpos <= std_logic_vector(vcntrp);
			heot <= heoc;
			heoc := hcntr(0);
			veot <= vcntr(0);
			heof <= hparm(0);
			veof <= vparm(0);
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_vga is
	generic (
		n : natural := 12);
	port (
		clk   : in std_logic;
		hsync : out std_logic;
		hcntr : out std_logic_vector(n-1 downto 0);
		vsync : out std_logic;
		vcntr : out std_logic_vector(n-1 downto 0);
		frm   : out std_logic;
		don   : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture arch of video_vga is
	signal hparm : std_logic_vector(0 to 1);
	signal rom_hdata : std_logic_vector(n downto 0);
	signal hdata : std_logic_vector(n downto 0);
	signal vparm : std_logic_vector(0 to 1);
	signal rom_vdata : std_logic_vector(n downto 0);
	signal vdata : std_logic_vector(n downto 0);
	signal heof : std_logic;
	signal heot : std_logic;
	signal veot : std_logic;
	signal veof : std_logic;
	signal vpos : std_logic_vector(n-1 downto 0);
	signal hpos : std_logic_vector(n-1 downto 0);
begin
	sync_rom : entity hdl4fpga.video_timing_rom
	generic map (
		n => n+1,
		mode  => 7)
	port map (

		hparm => hparm,
		hdata => rom_hdata,

		vparm => vparm,
		vdata => rom_vdata);

	sync_gen : entity hdl4fpga.video_timing_gen
	generic map (
		n => n)
	port map (
		clk => clk,

		htmg  => hparm,
		hdata => hdata,
		heot  => heot,
		heof  => heof,
		hpos  => hpos,

		vtmg  => vparm,
		vdata => vdata,
		veot  => veot,
		veof  => veof, 
		vpos  => vpos);

	process (clk)
	begin
		if rising_edge(clk) then
			hdata <= rom_hdata;
			vdata <= rom_vdata;
			vcntr <= vpos;
			hcntr <= hpos;

			if heot='1' then
				don   <= setif(vparm="10" and hparm="11");
				frm   <= setif(vparm="10");
				hsync <= setif(hparm="01");
				if heof='1' then
					vsync <= setif(vparm="00");
				end if;
			end if;
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grid is
	generic (
		row_div  : std_logic_vector;
		row_line : std_logic_vector;
		col_div  : std_logic_vector;
		col_line : std_logic_vector);
	port(
		clk : in std_logic;
		row : in std_logic_vector;
		col : in std_logic_vector;
		dot : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of grid is
	alias row1 : std_logic_vector(row'length-1 downto 0) is row;
	alias col1 : std_logic_vector(col'length-1 downto 0) is col;
begin
	process(clk) 
		variable col_eq : std_logic;
		variable row_eq : std_logic;
		variable draw_row : std_logic;
		variable draw_col : std_logic;
	begin
		if rising_edge(clk) then
			dot      <= setif(draw_row='1' or draw_col='1' or (row_eq='1' and col_eq='1'));
			row_eq   := setif(row1(row_div'length-1 downto 0)=row_div);
			col_eq   := setif(col1(col_div'length-1 downto 0)=col_div);
			draw_row := setif(row1(row_line'length+row_div'length-1 downto 0)=row_line&row_div);
			draw_col := setif(col1(col_line'length+col_div'length-1 downto 0)=col_line&col_div);
		end if;
	end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity draw_vline is
	generic (
		n : natural := 12);
	port(
		video_clk  : in  std_logic;
		video_row1 : in  unsigned(n-1 downto 0);
		video_row2 : in  unsigned(n-1 downto 0);
		video_dot  : out std_logic);
end;

library hdl4fpga;

architecture arc of draw_vline is
	signal le1, le2 : std_logic;
	signal eq1, eq2 : std_logic;
begin
	leq_e : entity hdl4fpga.pipe_le
	generic map (
		n => n)
	port map (
		clk => video_clk,
		a  => video_row1,
		b  => video_row2,
		le => le2,
		eq => eq2);

	process (video_clk)
	begin
		if rising_edge(video_clk) then
			video_dot <= (le1 xor le2) or eq2 or eq1;
			le1 <= le2;
			eq1 <= eq2;
		end if;
	end process;
end;
