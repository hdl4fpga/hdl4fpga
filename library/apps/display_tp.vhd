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
use hdl4fpga.cgafonts.all;
use hdl4fpga.videopkg.all;

library ieee;
use ieee.std_logic_1164.all;

entity display_tp is
	generic (
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_width  : natural := 8;
		font_height : natural := 16;
		timing_id   : videotiming_ids;
		video_gear  : natural := 2;
		cols        : natural;
		field_widths : natural_vector;
		labels      : string);
	port (
		sweep_clk   : in std_logic;
		tp          : std_logic_vector;
		video_clk   : in  std_logic;
		video_shift_clk : in std_logic := '-';
		video_hs    : buffer std_logic;
		video_vs    : buffer std_logic;
		video_blank : buffer std_logic;
		video_pixel : buffer std_logic_vector;
		dvid_crgb   : out std_logic_vector(4*video_gear-1 downto 0));
end;

architecture def of display_tp is

	function romdata (
		constant display_width  : natural;
		constant display_height : natural;
		constant cols   : natural;
		constant field_widths : natural_vector;
		constant labels : string)
	return string is
		constant debug : boolean := false;
		variable sx : natural;
		variable dx : natural;
		variable data : string(1 to display_width*display_height);
	begin
		sx := 1;
		dx := 1;
		loop
    		for i in 0 to cols-1 loop
    			for j in 1 to field_widths(i) loop
					if labels'length < sx then
						exit;
    				elsif labels(sx)/=NUL then
    					data(dx) := labels(sx);
						assert not debug 
						report CR & "*******" & data
						severity note;
    					sx := sx + 1;
    					dx := dx + 1;
    				else
    					data(dx) := '*';
    					dx := dx + 1;
    				end if;
    			end loop;

				while sx < labels'length loop
					if labels(sx)=NUL then
						exit;
					end if;
					sx := sx + 1;
				end loop;

				for j in 0 to 1-1 loop
					data(dx) := '+';
					dx := dx + 1;
				end loop;

				sx := sx + 1;

				if labels'length < sx then
					assert false and not debug
					report CR &
						"data => " & CR & data
					severity note;
					return data;
				end if;
				data(dx) := '|';
				dx := dx + 1;

				assert not debug 
				report CR & "(" & 
					"sx => " & natural'image(sx) & ", " &
					"dx => " & natural'image(dx) & ")"
				severity note;
    		end loop;
			while dx mod display_width /= 0 loop
				data(dx) := '*';
				dx := dx + 1;
			end loop;
			data(dx) := CR;
			dx := dx + 1;
		end loop;
	end;

	function num_of_fields (
		constant labels : string)
		return natural is
		variable retval : natural;
	begin
		retval := 0;
		for i in labels'range loop
			if labels(i)=NUL then
				retval := retval + 1;
			end if;
		end loop;
		return retval;
	end;

	function addr_of_fields (
		constant num_of_cols   : natural;
		constant display_width : natural;
		constant field_widths  : natural_vector;
		constant labels        : string)
		return natural_vector is
		variable field_num     : natural;
		variable row_addr      : natural;
		variable retval        : natural_vector(0 to num_of_fields(labels)-1);
	begin
		field_num := 0;
		row_addr  := 0;
		for i in 0 to cols-1 loop
			for j in 0 to field_widths(i)-1 loop
				retval(field_num) := row_addr + field_widths(i);
				if field_num < num_of_fields(labels) then
					field_num := field_num + 1;
				else
					return retval;
				end if;
			end loop;
			row_addr := row_addr + display_width;
		end loop;
		return retval;
	end;

	subtype font_code is std_logic_vector(unsigned_num_bits(font_bitrom'length/font_width/font_height-1)-1 downto 0);
	subtype digit     is std_logic_vector(0 to 4-1);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant display_width   : natural := modeline_tab(timing_id)(0)/font_width;
	constant display_height  : natural := modeline_tab(timing_id)(4)/font_height;
	constant data : string :=  romdata(display_width, display_height, cols, field_widths, labels);
	constant cga_bitrom : std_logic_vector := to_ascii(data);

	signal video_von   : std_logic;
	signal video_hon   : std_logic;
	signal video_addr  : unsigned(unsigned_num_bits(display_width*display_height-1)-1 downto 0);
	signal video_vcntr : std_logic_vector(11-1 downto 0);
	signal video_hcntr : std_logic_vector(11-1 downto 0);
	signal video_base  : unsigned(video_addr'range);
	signal video_on    : std_logic;
	signal video_dot   : std_logic;
	signal hzsync      : std_logic;
	signal vtsync      : std_logic;
	signal von         : std_logic;

	signal cga_codes   : std_logic_vector(font_code'range);
	signal cga_code    : std_logic_vector(font_code'range);
	signal cga_we      : std_logic;
	signal cga_addr    : std_logic_vector(video_addr'length-1 downto unsigned_num_bits(cga_codes'length/cga_code'length)-1);
	signal font_row    : unsigned(0 to fontheight_bits-1);
	signal font_col    : unsigned(0 to  fontwidth_bits-1);

	signal dvid_blank  : std_logic;
	signal rgb         : std_logic_vector(3*8-1 downto 0) := (others => '0');
begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		timing_id   => timing_id)
	port map (
		video_clk    => video_clk,
		video_hzsync => hzsync,
		video_vtsync => vtsync,
		video_hzcntr => video_hcntr,
		video_vtcntr => video_vcntr,
		video_hzon   => video_hon,
		video_vton   => video_von);
	von <= video_hon and video_von;

	-- VGA --
	---------

	process(sweep_clk)
		constant addr : natural_vector := addr_of_fields(cols, display_width, field_widths, labels);
		variable cntr : unsigned(unsigned_num_bits(num_of_fields(labels)-1)-1 downto 0) := (others => '0');
		variable we   : std_logic;
	begin
		if rising_edge(sweep_clk) then
			cga_addr <= std_logic_vector(to_unsigned(addr(to_integer(cntr)), cga_addr'length));
			cga_we   <= '1';
			if tp(to_integer(cntr))='1' then
				cga_code <= to_ascii("*");
			else
				cga_code <= to_ascii("0");
			end if;
			if cntr < num_of_fields(labels)-1 then
				cntr := cntr + 1;
			else
				cntr := (others => '0');
			end if;
			
		end if;
	end process;

	-- process (video_clk)
	-- begin
		-- if rising_edge(video_clk) then
			-- if video_hon='0' then
				-- font_col <= (others => '0');
			-- elsif font_col=font_width-1 then
				-- font_col <= (others => '0');
			-- else
				-- font_col <= font_col + 1;
			-- end if;
		-- end if;
	-- end process;
-- 
	-- process (video_clk)
		-- variable hon : std_logic;
	-- begin
		-- if rising_edge(video_clk) then
			-- if video_von='0' then
				-- font_row <= (others => '0');
			-- elsif (hon and not video_hon)='0' then
				-- if font_row=font_height-1 then
					-- font_row <= (others => '0');
				-- else
					-- font_row <= font_row + 1;
				-- end if;
			-- end if;
			-- hon := video_hon;
		-- end if;
	-- end process;
-- 
	-- process (video_clk)
	-- begin
		-- if rising_edge(video_clk) then
			-- if video_von='0' then
				-- video_addr <= (others => '0');
			-- elsif font_row=(font_row'range => '0') then
				-- if font_col=font_width-1 then
					-- video_addr <= video_addr + 1;
				-- end if;
			-- end if;
		-- end if;
	-- end process;

	video_addr <= 
		resize(mul(unsigned(video_vcntr(video_vcntr'left downto fontheight_bits)),display_width), video_addr'length) +
		unsigned(video_hcntr(video_hcntr'left downto fontwidth_bits)) + video_base;

	video_pixel <= (video_pixel'range => video_dot);
	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		cga_bitrom  => cga_bitrom,
	  	font_bitrom => psf1cp850x8x16,
		font_height => font_height,
		font_width  => font_width)
	port map (
		cga_clk     => sweep_clk,
		cga_we      => cga_we,
		cga_addr    => cga_addr,
		cga_data    => cga_codes,

		video_clk   => video_clk,
		video_addr  => std_logic_vector(video_addr),
		font_hcntr  => video_hcntr(fontwidth_bits-1 downto 0),
		font_vcntr  => video_vcntr(fontheight_bits-1 downto 0),
		video_on    => von,
		video_dot   => video_dot);

	video_lat_e : entity hdl4fpga.latency
	generic map (
		n => 3,
		d => (0 to 3-1 => 4))
	port map (
		clk => video_clk,
		di(0) => von,
		di(1) => hzsync,
		di(2) => vtsync,
		do(0) => video_on,
		do(1) => video_hs,
		do(2) => video_vs);

	video_blank <= not video_on;
	dvid_blank  <= video_blank;
	dvi_e : entity hdl4fpga.dvi
	generic map (
		gear => video_gear)
	port map (
		clk   => video_clk,
		rgb   => rgb,
		hsync => video_hs,
		vsync => video_vs,
		blank => dvid_blank,
		cclk  => video_shift_clk,
		chnc  => dvid_crgb(video_gear*4-1 downto video_gear*3),
		chn2  => dvid_crgb(video_gear*3-1 downto video_gear*2),  
		chn1  => dvid_crgb(video_gear*2-1 downto video_gear*1),  
		chn0  => dvid_crgb(video_gear*1-1 downto video_gear*0));

end;
