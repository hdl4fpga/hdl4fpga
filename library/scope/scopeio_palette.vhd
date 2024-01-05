library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.jso.all;
use hdl4fpga.base.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_palette is
	generic (
		layout      : string);
	port (
		rgtr_clk    : in  std_logic;
		rgtr_dv     : in  std_logic;
		rgtr_id     : in  std_logic_vector(8-1 downto 0);
		rgtr_data   : in  std_logic_vector;
		
		trigger_chanid : in std_logic_vector;

		video_clk   : in  std_logic;
		trigger_dot : in  std_logic;
		grid_dot    : in  std_logic;
		grid_bgon   : in  std_logic;
		hz_dot      : in  std_logic;
		hz_bgon     : in  std_logic;
		vt_dot      : in  std_logic;
		vt_bgon     : in  std_logic;
		text_fg     : in  std_logic_vector;
		text_bg     : in  std_logic_vector;
		text_fgon   : in  std_logic;
		text_bgon   : in  std_logic;
		sgmnt_bgon  : in  std_logic;
		trace_dots  : in  std_logic_vector;
		video_color : out std_logic_vector);

		constant palette_size               : natural := pltid_order'length+trace_dots'length+1;
		constant paletteid_size             : natural := unsigned_num_bits(palette_size-1);

		constant inputs                     : natural          := jso(layout)**".inputs";
		constant grid_color                 : std_logic_vector := jso(layout)**".grid.color";
		constant grid_backgroundcolor       : std_logic_vector := jso(layout)**".grid.background-color";
		constant vertical_color             : std_logic_vector := jso(layout)**".axis.vertical.color";
		constant vertical_backgroundcolor   : std_logic_vector := jso(layout)**".axis.vertical.background-color";
		constant horizontal_color           : std_logic_vector := jso(layout)**".axis.horizontal.color";
		constant horizontal_backgroundcolor : std_logic_vector := jso(layout)**".axis.horizontal.background.color";
		constant textbox_color              : std_logic_vector := jso(layout)**".textbox.color";
		constant textbox_backgroundcolor    : std_logic_vector := jso(layout)**".textbox.background-color";
		constant segment_backgroundcolor    : std_logic_vector := jso(layout)**".segment.background-color";
		constant main_backgroundcolor       : std_logic_vector := jso(layout)**".main.background-color";
end;

architecture beh of scopeio_palette is

	constant scopeio_bgon     : std_logic := '1';
	constant pixel_size : natural := video_color'length;

	impure function init_opacity (
		constant layout : string)
		return std_logic_vector
	is
		-- variable tracesfg      : std_logic_vector(0 to dflt_tracesfg'length-1);
		variable retval        : std_logic_vector(0 to pltid_order'length+trace_dots'length);
	begin
		retval(pltid_gridfg)    := grid_color(0);
		retval(pltid_gridbg)    := grid_backgroundcolor(0);
		retval(pltid_vtfg)      := vertical_color(0);
		retval(pltid_vtbg)      := vertical_backgroundcolor(0);
		retval(pltid_hzfg)      := horizontal_color(0);
		retval(pltid_hzbg)      := horizontal_backgroundcolor(0);
		retval(pltid_textfg)    := textbox_color(0);
		retval(pltid_textbg)    := textbox_backgroundcolor(0);
		retval(pltid_sgmntbg)   := segment_backgroundcolor(0);
		retval(pltid_scopeiobg) := main_backgroundcolor(0);
		-- tracesfg := dflt_tracesfg;
		-- for i in 0 to tracesfg'length/(pixel_size+1)-1 loop
			-- retval(pltid_order'length+i) := tracesfg(i*(pixel_size+1));
		-- end loop;
		return retval;
	end;
		
	signal trigger_opacity : std_logic := '1';
	signal color_opacity   : std_logic_vector(0 to pltid_order'length+trace_dots'length) := init_opacity(layout);

	signal palette_dv         : std_logic;
	signal palette_id         : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+trace_dots'length+1-1)-1);
	signal palette_color      : std_logic_vector(max_pixelsize-1 downto 0);
	signal palette_colorena   : std_logic;
	signal palette_opacity    : std_logic;
	signal palette_opacityena : std_logic;

	signal palette_addr : std_logic_vector(0 to unsigned_num_bits(pltid_order'length+trace_dots'length+1-1)-1);
	signal palette_data : std_logic_vector(video_color'range);
	signal color_addr   : std_logic_vector(palette_addr'range);

	signal vt_fg        : std_logic_vector(palette_id'range);
	signal gain_ena     : std_logic;
	signal gain_cid     : std_logic_vector(vt_fg'range);
	signal gain_id      : std_logic_vector(0 to 4-1);

	signal vt_ena       : std_logic;
	signal vt_cid       : std_logic_vector(vt_fg'range);
	signal vt_offset    : std_logic_vector(0 to 13-1);

	impure function palette_ids 
		return std_logic_vector is
		variable retval : unsigned(0 to palette_size*paletteid_size-1);
	begin
		for i in 0 to trace_dots'length-1 loop
			retval(0 to paletteid_size-1) := to_unsigned(pltid_order'length+i, paletteid_size);
			retval := retval rol paletteid_size;
		end loop;
		retval(0 to paletteid_size-1) := resize(unsigned(trigger_chanid), paletteid_size)+pltid_order'length;
		retval := retval rol paletteid_size;
		for i in pltid_order'range loop
			case pltid_order(i) is
			when pltid_textfg =>
				if unsigned(text_fg)=to_unsigned(trace_dots'length+pltid_order'length, paletteid_size) then
					retval(0 to paletteid_size-1) := resize(unsigned(trigger_chanid), paletteid_size)+pltid_order'length;
				else
					retval(0 to paletteid_size-1) := unsigned(text_fg);
				end if;
			when pltid_textbg =>
				retval(0 to paletteid_size-1) := unsigned(text_bg);
			when pltid_vtfg =>
				if color_opacity(pltid_vtfg)='0' then
					retval(0 to paletteid_size-1) := unsigned(vt_fg);
				else
					retval(0 to paletteid_size-1) := to_unsigned(pltid_order(i), paletteid_size);
				end if;
			when others =>
				retval(0 to paletteid_size-1) := to_unsigned(pltid_order(i), paletteid_size);
			end case;
			retval := retval rol paletteid_size;
		end loop;
		return std_logic_vector(retval);
	end;

	impure function shuffle (
		constant arg : std_logic_vector)
		return std_logic_vector is
		variable temp   : std_logic_vector(0 to arg'length-1) := arg;
		variable retval : unsigned(0 to temp'length-1);
	begin
		for i in 0 to trace_dots'length-1 loop
			retval(0) := temp(pltid_order'length+i);
			retval := retval rol 1;
		end loop;
		retval(0) := temp(pltid_order'length+trace_dots'length);
		retval := retval rol 1;
		for i in pltid_order'range loop
			retval(0) := temp(pltid_order(i));
			retval := retval rol 1;
		end loop;
		return std_logic_vector(retval);
	end;

	function opasity (
		constant pixel : std_logic_vector)
		return std_logic_vector is
	begin
		assert pixel'length mod 4=0
			report "wrong pixel size"
			severity failure;

		return std_logic_vector(resize(shift_right(unsigned(pixel), pixel'length*3/4), pixel'length/4));
	end;

	function color (
		constant pixel : std_logic_vector)
		return std_logic_vector is
	begin
		assert pixel'length mod 4=0
			report "wrong pixel size"
			severity failure;

		return std_logic_vector(resize(unsigned(pixel), pixel'length*3/4));
	end;

	function init_color (
		constant layout : string)
		return std_logic_vector is
		variable pixel  : std_logic_vector(32-1 downto 0);
		variable retval : std_logic_vector(0 to inputs*32*3/4-1);
	begin
		retval :=
    		color(grid_color)                &
    		color(vertical_color)            &
    		color(vertical_backgroundcolor)  &
    		color(horizontal_color)          &
    		color(horizontal_backgroundcolor)&
    		color(textbox_backgroundcolor)   &
    		color(grid_backgroundcolor)      &
    		color(segment_backgroundcolor)   &
    		color(main_backgroundcolor)      &
    		color(textbox_color);
		retval := std_logic_vector(rotate_left(unsigned(retval), 7));
		for i in 0 to inputs-1 loop
			retval := jso(layout)**("vt[" & natural'image(i) & "].color");
			retval := std_logic_vector(rotate_left(unsigned(retval), 32*3/4));
		end loop;
		-- aux := arg;
		-- for i in 0 to n-1 loop
			-- retval(0 to pixel_size-1) := unsigned(color(aux(0 to pixel_size)));
			-- retval := retval rol pixel_size;
			-- aux    := std_logic_vector(unsigned(aux) rol (pixel_size+1));
		-- end loop;
--		assert false
--		report "-----> " & itoa(n) & " " & itoa(arg'length) & " " & itoa(dflt_tracesfg'length)
--		severity failure;
		return std_logic_vector(retval);
	end;

		signal wr_ena  : std_logic;
begin

	rgtrvtaxis_e : entity hdl4fpga.scopeio_rgtrvtaxis
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vt_ena,
		vt_chanid => vt_cid,
		vt_offset => vt_offset);

	scopeio_rgtrgain_e : entity hdl4fpga.scopeio_rgtrgain
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		gain_ena  => gain_ena,
		chan_id   => gain_cid,
		gain_id   => gain_id);
		
	scopeio_rgtrpalette_e : entity hdl4fpga.scopeio_rgtrpalette
	port map (
		rgtr_clk         => rgtr_clk,
		rgtr_dv          => rgtr_dv,
		rgtr_id          => rgtr_id,
		rgtr_data        => rgtr_data,

		palette_dv       => palette_dv,
		palette_id       => palette_id,
		palette_opacity  => palette_opacity,
		palette_colorena => palette_colorena,
		palette_opacityena => palette_opacityena,
		palette_color    => palette_color);

	vtfg_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if vt_ena='1' then
				vt_fg <= std_logic_vector(pltid_order'length+unsigned(vt_cid));
			elsif gain_ena='1' then
				vt_fg <= std_logic_vector(pltid_order'length+unsigned(gain_cid));
			end if;
		end if;
	end process;

	opacity_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if palette_dv='1' then
				if palette_opacityena='1' then
					color_opacity(to_integer(resize(unsigned(palette_id), palette_addr'length))) <= palette_opacity;
				end if;
			end if;
			color_opacity(color_opacity'right) <= color_opacity(to_integer(resize(unsigned(trigger_chanid), paletteid_size)+pltid_order'length));
		end if;
	end process;

	-- palette_data <= std_logic_vector(resize(unsigned(palette_color), palette_data'length));
	process (palette_color)
		alias color : std_logic_vector(0 to palette_color'length-1) is palette_color;
		alias pixel : std_logic_vector(0 to palette_data'length-1)  is palette_data;
	begin
		case palette_data'length is
		when 3*1 =>
			pixel <= color(0*8) & color(1*8) & color(2*8);
		when 3*8 =>
			pixel <= color;
		when others =>
			pixel <= (others => '-');
		end case;
	end process;
	palette_addr <= std_logic_vector(resize(unsigned(palette_id), palette_addr'length));

	trigger_opacity <= multiplex(color_opacity(pltid_order'length to pltid_order'length+trace_dots'length-1), trigger_chanid);
	color_addr <= primux(
		palette_ids,
		shuffle((
			pltid_gridfg    => grid_dot     and color_opacity(pltid_gridfg),
			pltid_gridbg    => grid_bgon    and color_opacity(pltid_gridbg),
			pltid_vtfg      => vt_dot       and color_opacity(to_integer(unsigned(vt_fg))),
			pltid_vtbg      => vt_bgon      and color_opacity(pltid_vtbg),
			pltid_hzfg      => hz_dot       and color_opacity(pltid_hzfg),
			pltid_hzbg      => hz_bgon      and color_opacity(pltid_hzbg),
			pltid_textfg    => text_fgon    and color_opacity(to_integer(unsigned(text_fg))),
			pltid_textbg    => text_bgon    and color_opacity(pltid_textbg),
			pltid_sgmntbg   => sgmnt_bgon   and color_opacity(pltid_sgmntbg),
			pltid_scopeiobg => scopeio_bgon and color_opacity(pltid_scopeiobg)) & 
		(trace_dots  and color_opacity(pltid_order'length to pltid_order'length+trace_dots'length-1)) & 
		(trigger_dot and trigger_opacity)));
	
	lookup_b : block
		signal rd_addr : std_logic_vector(palette_addr'range);
		signal rd_data : std_logic_vector(video_color'range);
		constant bitrom : std_logic_vector := init_color(layout);
	begin

		wr_ena <= palette_colorena and palette_dv;
		mem_e : entity hdl4fpga.dpram
		generic map (
			bitrom => bitrom)
--			bitrom => colors(dflt_gridfg & dflt_vtfg & dflt_vtbg & dflt_hzfg & dflt_hzbg & dflt_textbg & dflt_gridbg & dflt_sgmntbg & dflt_bg & dflt_textfg & dflt_tracesfg))
		port map (
			wr_clk  => rgtr_clk,
			wr_addr => palette_addr,
			wr_ena  => wr_ena,
			wr_data => palette_data,

			rd_addr => rd_addr,
			rd_data => rd_data);

		rd_rgtr_p : process (video_clk)
		begin
			if rising_edge(video_clk) then
				rd_addr <= color_addr;
				video_color <= rd_data;
			end if;
		end process;

	end block;

end;
