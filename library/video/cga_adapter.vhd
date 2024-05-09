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
use hdl4fpga.cgafonts.all;

entity cga_adapter is
	generic (
		display_scale  : natural := 1;
		display_width  : natural;
		display_height : natural;
		cga_bitrom     : std_logic_vector := (1 to 0 => '-');
		font_bitrom    : std_logic_vector := psf1cp850x8x16;
		font_height    : natural := 16;
		font_width     : natural := 8);
	port (
		cga_clk        : in  std_logic;
		cga_we         : in  std_logic := '1';
		cga_addr       : in  std_logic_vector;
		cga_base       : in  std_logic_vector(unsigned_num_bits(display_width*display_height/display_scale**2-1)-1 downto 0) := (others => '0');
		cga_data       : in  std_logic_vector;

		video_clk      : in  std_logic;
		video_hon      : in  std_logic;
		video_von      : in  std_logic;

		video_dot      : out std_logic);
end;

architecture struct of cga_adapter is
	constant scale_displaywidth  : natural := display_width/display_scale;
	constant scale_displayheight : natural := display_height/display_scale;
	signal font_col  : unsigned(unsigned_num_bits(font_width-1)-1 downto 0);
	signal font_row  : unsigned(unsigned_num_bits(font_height-1)-1 downto 0);
	signal video_on  : std_logic;

	signal cga_codes : std_logic_vector(cga_data'range);
	signal cga_code  : std_logic_vector(unsigned_num_bits(font_bitrom'length/font_height/font_width-1)-1 downto 0);
	signal mux_code  : std_logic_vector(cga_code'range);
	signal char_addr : unsigned(cga_addr'length-1+(unsigned_num_bits(cga_codes'length/cga_code'length)-1) downto 0);

	signal char_on   : std_logic;
	signal char_dot  : std_logic;

	signal lat_fontcol : std_logic_vector(font_col'range);
	signal lat_fontrow : std_logic_vector(font_row'range);
begin

	cga_sweep_b : block
		signal display_col : unsigned(unsigned_num_bits(scale_displaywidth-1)-1 downto 0);
		signal display_row : unsigned(unsigned_num_bits(scale_displayheight-1)-1 downto 0);
		signal hon_edge    : std_logic;
	begin
    	display_p : process (video_clk)
    	begin
    		if rising_edge(video_clk) then
    			if video_von='0' then
					display_col <= (others => '0');
					display_row <= (others => '0');
				elsif display_row=scale_displayheight-1 then
					display_col <= (others => '0');
					display_row <= (others => '0');
				elsif video_hon='0' then
					display_col <= (others => '0');
				elsif display_col=scale_displaywidth-1 then
					display_col <= (others => '0');
					display_row <= display_row + 1;
    			else
					display_col <= display_col + 1;
				end if;
    		end if;
    	end process;

    	font_col_p : process (video_clk)
    	begin
    		if rising_edge(video_clk) then
				-- if display_row=scale_displayheight-1 then
    				-- font_col  <= (others => '0');
    			-- elsif display_col=scale_displaywidth-1 then
    				-- font_col  <= (others => '0');
    			if video_hon='0' then
    				font_col  <= (others => '0');
    			elsif font_col=font_width-1 then
					font_col <= (others => '0');
				else
					font_col <= font_col + 1;
				end if;
    		end if;
    	end process;

    	font_row_p : process (video_clk)
    	begin
    		if rising_edge(video_clk) then
				-- if display_row=scale_displayheight-1 then
    				-- font_row <= (others => '0');
    			if video_von='0' then
    				font_row <= (others => '0');
    			elsif (hon_edge and not video_hon)='1' then
    			-- elsif display_col=scale_displaywidth-1 then
    				if font_row=font_height-1 then
    					font_row <= (others => '0');
    				else
    					font_row <= font_row + 1;
    				end if;
    			end if;
    			hon_edge <= video_hon;
    		end if;
    	end process;

    	code_p : process (video_clk)
    		variable row_addr : unsigned(char_addr'range);
    	begin
    		if rising_edge(video_clk) then
    			if video_von='0' then
    				row_addr   := (others => '0');
    				char_addr <= unsigned(cga_base) + row_addr;
    			elsif (hon_edge and not video_hon)='1' then
    			-- elsif display_col=scale_displaywidth-1 then
    				if font_row=font_height-1 then
    					row_addr := row_addr + scale_displaywidth;
    				end if;
    				char_addr <= unsigned(cga_base) + row_addr;
    			elsif font_col=font_width-1 then
    				char_addr <= char_addr + 1;
    			end if;
    		end if;
    	end process;

	end block;

	cgamem_e : entity hdl4fpga.dpram
	generic map (
		synchronous_rdaddr => true,
		synchronous_rddata => true,
		bitrom => cga_bitrom)
	port map (
		wr_clk  => cga_clk,
		wr_ena  => cga_we,
		wr_addr => cga_addr,
		wr_data => cga_data,

		rd_clk  => video_clk,
		rd_addr => std_logic_vector(char_addr(char_addr'left downto char_addr'length-cga_addr'length)),
		rd_data => cga_codes);

	muxcode_g : if char_addr'length > cga_addr'length generate
		signal sel : std_logic_vector(char_addr'length-cga_addr'length-1 downto 0);
	begin
		lat_e : entity hdl4fpga.latency
		generic map (
			n => char_addr'length-cga_addr'length,
			d => (0 to char_addr'length-cga_addr'length => 2))
		port map (
			clk => video_clk,
			di  => std_logic_vector(char_addr(char_addr'length-cga_addr'length-1 downto 0)),
			do  => sel);

		mux_code <= multiplex(cga_codes, sel, mux_code'length);
	end generate;
	cga_code <= mux_code when char_addr'length > cga_addr'length else cga_codes; 

	vsync_e : entity hdl4fpga.latency
	generic map (
		n   => lat_fontrow'length,
		d   => (lat_fontrow'range => 2))
	port map (
		clk => video_clk,
		di  => std_logic_vector(font_row),
		do  => lat_fontrow);

	hsync_e : entity hdl4fpga.latency
	generic map (
		n   => lat_fontcol'length,
		d   => (lat_fontcol'range => 2))
	port map (
		clk => video_clk,
		di  => std_logic_vector(font_col),
		do  => lat_fontcol);

	rom_e : entity hdl4fpga.cga_rom
	generic map (
		font_bitrom => font_bitrom,
		font_height => font_height,
		font_width  => font_width)
	port map (
		clk         => video_clk,
		char_col    => lat_fontcol,
		char_row    => lat_fontrow,
		char_code   => cga_code,
		char_dot    => char_dot);

	video_on <= video_von and video_hon;
	don_e : entity hdl4fpga.latency
	generic map (
		n     => 1,
		d     => (1 to 1 => 4))
	port map (
		clk   => video_clk,
		di(0) => video_on,
		do(0) => char_on);

	video_dot <= char_dot and char_on;

end;
