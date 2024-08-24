
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_textbox is
	generic(
		layout        : string;
		latency       : natural;
		font_bitrom   : std_logic_vector := psf1cp850x8x16;
		font_height   : natural := 16);
	port (
		tp            : out std_logic_vector(1 to 32);
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_hcntr   : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		video_vton    : in  std_logic;
		sgmntbox_ena  : in  std_logic_vector;
		text_on       : in  std_logic := '1';
		text_fg       : out std_logic_vector;
		text_bg       : out std_logic_vector;
		text_fgon     : out std_logic);

	constant font_width     : natural := hdo(layout)**".textbox.font_width=8.";
	constant textbox_width  : natural := hdo(layout)**".textbox.width";
	constant textbox_height : natural := hdo(layout)**".grid.height";
	constant grid_height    : natural := hdo(layout)**".grid.height";

	constant cga_cols       : natural := textbox_width/font_width;
	constant cga_rows       : natural := textbox_height/font_height;
	constant cga_size       : natural := cga_rows*cga_cols;

end;

architecture def of scopeio_textbox is
	constant cga_latency    : natural := 4;
	constant color_latency  : natural := 1;

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant textwidth_bits  : natural := unsigned_num_bits(textbox_width-1);

	signal code_frm  : std_logic;
	signal code_irdy : std_logic;
	signal code_data : ascii;
	signal cga_we    : std_logic := '0';
	signal cga_addr  : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_data  : ascii;

	signal fg_color  : std_logic_vector(text_fg'range);
	signal bg_color  : std_logic_vector(text_bg'range);

	signal video_on  : std_logic;
	signal video_addr: std_logic_vector(cga_addr'range);
	signal video_dot : std_logic;
	signal blink     : std_logic;

	signal video_row : std_logic_vector(0 to unsigned_num_bits(cga_rows-1)-1);
	signal focus_wid : std_logic_vector(6-1 downto 0);
	signal wid       : std_logic_vector(8-1 downto 0);


begin

	assert false
		report CR &
		"textbox rows " & natural'image(cga_rows) & CR &
		"textbox cols " & natural'image(cga_cols) & CR &
		"textbox size " & natural'image(cga_size) & CR &
		"textbox mem  " & natural'image(2**cga_addr'length) 
		severity note;

	focus_e : entity hdl4fpga.scopeio_rgtrfocus
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		focus_wid => wid);
	focus_wid <= wid(focus_wid'range);

	tp(1 to focus_wid'length) <= focus_wid;
	readings_e : entity hdl4fpga.scopeio_reading
	generic map (
		layout => layout)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,
		video_row => video_row,
		code_frm  => code_frm,
		code_irdy => code_irdy,
		code_data => code_data);

	process (rgtr_clk)
		type states is (s_init, s_run);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_init =>
				cga_addr <= mul(unsigned(video_row), cga_cols, cga_addr'length);
				if code_frm='1' then
					cga_we <= code_irdy;
					if code_irdy='1' then
						state := s_run;
					end if;
				else
					cga_we <= '0';
				end if;
			when s_run =>
				if code_irdy='1' then
					cga_addr <= cga_addr + 1;
				end if;
				if code_frm='1' then
					cga_we <= code_irdy;
				else
					state := s_init;
				end if;
			end case;
			cga_data <= code_data;
		end if;
	end process;

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl fontheight_bits, cga_cols) +
		(unsigned(video_hcntr(textwidth_bits-1 downto 0)) srl fontwidth_bits),
		video_addr'length));
	video_on <= text_on and sgmntbox_ena(0);

	cgaram_e : entity hdl4fpga.cgaram
	generic map (
		font_bitrom  => font_bitrom,
		font_height  => font_height,
		font_width   => font_width)
	port map (
		cga_clk      => rgtr_clk,
		cga_we       => cga_we,
		cga_addr     => std_logic_vector(cga_addr),
		cga_data     => cga_data,

		video_clk    => video_clk,
		video_addr   => video_addr,
		font_hcntr   => video_hcntr(unsigned_num_bits(font_width-1)-1 downto 0),
		font_vcntr   => video_vcntr(unsigned_num_bits(font_height-1)-1 downto 0),
		video_on     => video_on,
		video_dot    => video_dot);

	lat_e : entity hdl4fpga.latency
	generic map (
		n => 1,
		d => (0 => latency-cga_latency))
	port map (
		clk   => video_clk,
		di(0) => video_dot,
		do(0) => text_fgon);

	blink_p : process (rgtr_clk)
		type states is (s_fg, s_bg);
		variable state : states;
		variable cntr : integer range -1 to 31;
		variable edge : std_logic;
	begin
		if rising_edge(rgtr_clk) then
			if (edge and not video_vton)='1' then
    			case state is
    			when s_fg =>
    				if cntr >=0 then 
    					cntr := cntr - 1;
    				else
    					cntr  := 30-1;
    					state := s_bg;
    					blink <= '1' and wid(wid'left);
    				end if;
    			when s_bg =>
    				if cntr >=0 then 
    					cntr := cntr - 1;
    				else
    					cntr  := 30-1;
    					state := s_fg;
    					blink <= '0';
    				end if;
    			end case;
			end if;
			edge := video_vton;
		end if;
	end process;

	widgets_b : block
		constant inputs : natural := hdo(layout)**".inputs";
		constant vt     : string  := hdo(layout)**".vt";

		function top_borders
			return natural_vector is
			variable table : natural_vector(0 to wid_inscale+3*(inputs-1));
		begin
			table(0 to wid_static) := (
				wid_time       => 0,
				wid_trigger    => 1,
				wid_tmposition => 0,
				wid_tmscale    => 0,
				wid_tgchannel  => 1,
				wid_tgposition => 1,
				wid_tgslope    => 1,
				wid_tgmode     => 1,
				wid_input      => 2,
				wid_inposition => 2,
				wid_inscale    => 2);
			for i in wid_static+1 to table'right loop
				table(i) := table(i-3) + 1;
			end loop;
			return table;
		end;

		function width_borders
			return natural_vector is
			variable table : natural_vector(0 to wid_inscale+3*(inputs-1));
		begin
			table(0 to wid_static) := (
				wid_time       => cga_cols,
				wid_trigger    => cga_cols,
				wid_tmposition => 7,
				wid_tmscale    => 7,
				wid_tgchannel  => 4,
				wid_tgposition => 7,
				wid_tgslope    => 1,
				wid_tgmode     => 4,
				wid_input      => cga_cols,
				wid_inposition => 7,
				wid_inscale    => 7);
			for i in wid_static+1 to table'right loop
				table(i) := table(i-3);
			end loop;
			return table;
		end;

		function left_borders
			return natural_vector is
			variable table : natural_vector(0 to wid_inscale+3*(inputs-1));
			constant vt_labels  : string  := hdo(layout)**".vt";
			function text_length (
				constant i : natural)
				return natural is
				constant retval : string := escaped(hdo(vt_labels)**("["&natural'image(i)&"].text"));
			begin
				return retval'length;
			end;
		begin
			table(wid_time)       := 0;
			table(wid_trigger)    := 0;
			table(wid_tmposition) := 4;
			table(wid_tmscale)    := table(wid_tmposition)+3+width_borders(wid_tmposition);
			table(wid_tgchannel)  := 0;
			table(wid_tgposition) := 4;
			table(wid_tgslope)    := table(wid_tgposition)+4+width_borders(wid_tgposition);
			table(wid_tgmode)     := table(wid_tgslope)+2;
			table(wid_input)      := 0;
			table(wid_inposition) := text_length(0);
			table(wid_inscale)    := table(wid_inposition)+3+width_borders(wid_inposition);
			for i in wid_static+1 to table'right loop
				case (i-wid_input) mod 3 is
				when 0 =>
					table(i) := table(i-3);
				when 1 =>
					table(i) := text_length((i-wid_input)/3);
				when 2 =>
					table(i) := table(1-1)+3+width_borders(wid_inposition);
				when others =>
				end case;
			end loop;

			return table;
		end;

		constant top_tab    : natural_vector(0 to wid_inscale+3*(inputs-1)) := top_borders;
		constant left_tab   : natural_vector(0 to wid_inscale+3*(inputs-1)) := left_borders;
		constant height_tab : natural_vector(0 to wid_inscale+3*(inputs-1)) := (others => 1);
		constant width_tab  : natural_vector(0 to wid_inscale+3*(inputs-1)) := width_borders;

		signal left   : natural range 0 to cga_cols-1;
		signal right  : natural range 0 to cga_cols;
		signal top    : natural range 0 to cga_rows-1;
		signal bottom : natural range 0 to cga_rows;
		signal row    : natural range 0 to cga_rows-1;
		signal col    : natural range 0 to cga_cols-1;
		signal x : std_logic;
		signal y : std_logic;
		signal s : std_logic;
	begin

		top    <=  top_tab(to_integer(unsigned(focus_wid)));
		left   <= left_tab(to_integer(unsigned(focus_wid)));
		right  <= left + width_tab(to_integer(unsigned(focus_wid)));
		bottom <= top  + height_tab(to_integer(unsigned(focus_wid)));
		row <= to_integer(shift_right(unsigned(video_vcntr), fontheight_bits));
		col <= to_integer(shift_right(unsigned(video_hcntr), fontwidth_bits));

		x <= ('1' xor blink) when left <= col and col < right  else '0';
		y <= ('1' xor blink) when top  <= row and row < bottom else '0';
		s <= (x and y);

		process (video_clk)
			function textbox_field (
				constant width          : natural)
				return natural_vector is
				constant inputs         : natural := hdo(layout)**".inputs";
				constant textbox_fields : string := compact (
					"{"                                       &
					"    horizontal : { top : 0, left : 0 }," &
					"    trigger    : { top : 1, left : 0 }," &
					"    inputs     : { top : 2, left : 0 }"  &
					"}");

				constant wdt_horizontal : string  := hdo(textbox_fields)**".horizontal";
				constant wdt_trigger    : string  := hdo(textbox_fields)**".trigger";
				constant wdt_inputs     : string  := hdo(textbox_fields)**".inputs";
				constant wdtinputs_top  : natural := hdo(wdt_inputs)**".top";
				constant wdtinputs_left : natural := hdo(wdt_inputs)**".left";
				variable retval         : natural_vector(0 to 2+inputs-1);
			begin
				retval(0) := hdo(wdt_horizontal)**".top"*width;
				retval(0) := hdo(wdt_horizontal)**".left" + retval(0);
				retval(1) := hdo(wdt_trigger)**".top"*width;
				retval(1) := hdo(wdt_trigger)**".left" + retval(1);
				for i in 0 to inputs-1 loop
					retval(i+2) := (wdtinputs_top+i)*width;
					retval(i+2) := wdtinputs_left + retval(i+2);
				end loop;
				return retval;
			end;

			constant input_labels : natural := 2;
			constant field_addr : natural_vector := textbox_field(cga_cols);
			variable addr       : std_logic_vector(video_addr'range);
			variable bg_id      : natural range 0 to 2**fg_color'length-1;
			variable field_id   : natural range 0 to 2**fg_color'length-1;
		begin
			if rising_edge(video_clk) then
				if sgmntbox_ena(0)='0' then
					fg_color <= std_logic_vector(to_unsigned(field_id, fg_color'length));
					bg_color <= std_logic_vector(to_unsigned(bg_id,    bg_color'length));
				elsif s='0' then
					fg_color <= std_logic_vector(to_unsigned(field_id, fg_color'length));
					bg_color <= std_logic_vector(to_unsigned(bg_id,    bg_color'length));
				else
					fg_color <= std_logic_vector(to_unsigned(bg_id,    fg_color'length));
					bg_color <= std_logic_vector(to_unsigned(field_id, bg_color'length));
				end if;
				if video_on='1' then
					field_id := pltid_textfg;
					for i in field_addr'range loop
						if unsigned(addr) < (field_addr(i)+cga_cols) then
							if i >= input_labels then 
								field_id := (i-input_labels)+pltid_order'length;
							end if;
							exit;
						end if;
					end loop;
					bg_id := pltid_textbg;
				end if;
				addr := video_addr;
			end if;
		end process;

	end block;

	latfg_e : entity hdl4fpga.latency
	generic map (
		n  =>  text_fg'length,
		d  => (0 to text_fg'length-1 => latency-color_latency))
	port map (
		clk => video_clk,
		di  => fg_color,
		do  => text_fg);
	latbg_e : entity hdl4fpga.latency
	generic map (
		n  => text_bg'length,
		d  => (0 to text_bg'length-1 => latency-color_latency))
	port map (
		clk => video_clk,
		di  => bg_color,
		do  => text_bg);
end;
