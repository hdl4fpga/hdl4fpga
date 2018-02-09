library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio is
	generic (
		inputs         : natural := 1;
		input_preamp   : real_vector;
		layout_id      : natural := 0;
		hz_scales      : scale_vector;
		vt_scales      : scale_vector;
		gauge_labels   : std_logic_vector;
		gauge_frac     : natural := 5;
		unit_symbols   : std_logic_vector;
		channels_fg    : std_logic_vector;
		channels_bg    : std_logic_vector;
		hzaxis_fg      : std_logic_vector;
		hzaxis_bg      : std_logic_vector;
		grid_fg        : std_logic_vector;
		grid_bg        : std_logic_vector);

	port (
		mii_rxc     : in  std_logic := '-';
		mii_rxdv    : in  std_logic := '0';
		mii_rxd     : in  std_logic_vector;
		tdiv        : out std_logic_vector(4-1 downto 0);
		cmd_sel     : in  std_logic_vector(0 to 2-1) := "--";
		cmd_inc     : in  std_logic := '-';
		cmd_rdy     : in  std_logic := '0';
		channel_ena : in  std_logic_vector(0 to inputs-1) := (others => '1');
		input_clk   : in  std_logic;
		input_ena   : in  std_logic := '1';
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_rgb   : out std_logic_vector;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);
end;

architecture beh of scopeio is


	type layout is record 
		mode        : natural;
		scr_width   : natural;
		num_of_seg  : natural;
		chan_x      : natural;
		chan_y      : natural;
		chan_width  : natural;
		chan_height : natural;
	end record;

	type layout_vector is array (natural range <>) of layout;
	constant ly_dptr : layout_vector(0 to 1) := (
--		0 => (mode, scr_width | num_of_seg | chan_x | chan_y | chan_width | chan_height
		0 => (   7,      1920,           4,     320,     270,       50*32,          256),
		1 => (   1,       800,           2,     320,     300,       15*32,          256));

	function to_naturalvector (
		constant arg  : layout)
		return natural_vector is
		variable rval : natural_vector(0 to 4*arg.num_of_seg-1);
	begin
		for i in 0 to arg.num_of_seg-1 loop
			rval(i*4+0) := 0;
			rval(i*4+1) := i*arg.chan_y;
			rval(i*4+2) := arg.scr_width;
			rval(i*4+3) := arg.chan_y-1;
		end loop;
		return rval;
	end;

	constant vt_size : natural := unsigned_num_bits(ly_dptr(layout_id).chan_height-1)+1;

	signal hdr_data         : std_logic_vector(288-1 downto 0);
	signal pld_data         : std_logic_vector(3*8-1 downto 0);
	signal pll_data         : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data         : std_logic_vector(32-1 downto 0);

	constant cga_zoom       : natural := 0;
	signal cga_we           : std_logic;
	signal scope_cmd        : std_logic_vector(8-1 downto 0);
	signal scope_data       : std_logic_vector(8-1 downto 0);
	signal scope_channel    : std_logic_vector(8-1 downto 0);
	signal char_dot         : std_logic;

	signal video_hs         : std_logic;
	signal video_vs         : std_logic;
	signal video_frm        : std_logic;
	signal video_hon        : std_logic;
	signal video_nhl        : std_logic;
	signal video_vld        : std_logic;
	signal video_vcntr      : std_logic_vector(11-1 downto 0);
	signal video_hcntr      : std_logic_vector(11-1 downto 0);

	signal plot_fg          : std_logic_vector(0 to inputs-1);
	signal video_fg         : std_logic_vector(0 to 4-1);
	signal video_bg         : std_logic_vector(0 to 3-1);

	signal video_io         : std_logic_vector(0 to 3-1);
	signal abscisa          : std_logic_vector(0 to unsigned_num_bits(ly_dptr(layout_id).chan_width-1)-1);
	
	signal win_don          : std_logic_vector(0 to 18-1);
	signal win_frm          : std_logic_vector(0 to 18-1);
	signal pll_rdy          : std_logic;

	signal input_addr       : std_logic_vector(0 to unsigned_num_bits(ly_dptr(layout_id).num_of_seg*ly_dptr(layout_id).chan_width-1));
	signal input_we         : std_logic;
	signal input_inc        : std_logic;

	signal vt_scale         : std_logic_vector(4-1 downto 0);
	signal channel_scale    : std_logic_vector(0 to vt_scale'length*inputs-1):= (others => '0');
	signal channel_decas    : std_logic_vector(0 to ascii'length*inputs-1);
	signal gp_vtscale       : std_logic_vector(0 to vt_scale'length*inputs-1);

	signal channel_select   : std_logic_vector(unsigned_num_bits(inputs-1)-1 downto 0);
	signal time_deca        : std_logic_vector(ascii'range);

	signal  vm_inputs       : std_logic_vector(0 to inputs*vt_size-1);
	signal  trigger_level   : std_logic_vector(0 to vt_size-1);
	signal  vm_addr         : std_logic_vector(1 to input_addr'right);
	signal  trigger_offset  : std_logic_vector(0 to vt_size-1);
	signal  trigger_edge    : std_logic;
	signal  trigger_select  : std_logic_vector(channel_select'range);
	signal  trigger_channel : std_logic_vector(trigger_select'range);
	signal  trigger_scale   : std_logic_vector(vt_scale'range);
	signal  trigger_deca    : std_logic_vector(ascii'range);
	signal  full_addr       : std_logic_vector(vm_addr'range);
	signal  channel_offset  : std_logic_vector(0 to inputs*vt_size-1) := (others => '0');
	signal  scale_offset    : std_logic_vector(0 to inputs*vt_size-1);
	signal  ordinates       : std_logic_vector(vm_inputs'range);
	signal  hz_scale        : std_logic_vector(4-1 downto 0);
	signal  text_data       : std_logic_vector(8-1 downto 0);
	signal  text_addr       : std_logic_vector(10-1 downto 0) := (others => '0');

	subtype mword         is signed(0 to 18-1);
	subtype mdword        is signed(0 to 2*mword'length-1);
	type    mword_vector  is array (natural range <>) of mword;
	type    mdword_vector is array (natural range <>) of mdword;

	signal scales           : std_logic_vector(0 to inputs*mword'length-1);
	signal pixel       : std_logic_vector(video_rgb'range);

	signal gpannel_on  : std_logic_vector(0 to ly_dptr(layout_id).num_of_seg-1);
	signal gpannel_x   : std_logic_vector(unsigned_num_bits(ly_dptr(layout_id).scr_width-1)-1 downto 0);
	signal gpannel_y   : std_logic_vector(unsigned_num_bits(ly_dptr(layout_id).chan_y-1)-1 downto 0);

	constant font_width  : natural := 8;
	constant font_height : natural := 16;
	signal   cga_code    : std_logic_vector(ascii'range);
	signal   cga_dot     : std_logic;
	signal   gpannel_row : std_logic_vector(unsigned_num_bits(ly_dptr(layout_id).chan_y)-2 downto unsigned_num_bits(font_height-1));
	signal   gpannel_col : std_logic_vector(unsigned_num_bits(ly_dptr(layout_id).chan_x-1)-1 downto unsigned_num_bits(font_width-1));
	signal   gauge_on    : std_logic_vector(0 to 2+inputs-1);
	signal trigger_ena : std_logic;
	constant delay       : natural := 4;
	signal g_hzscale : std_logic_vector(hz_scale'range);
begin

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		pll_data => pll_data,
		pll_rdy  => pll_rdy,
		ser_data => ser_data);

	process (ser_data, pll_data)
		variable data : unsigned(pll_data'range);
	begin
		data     := unsigned(pll_data);
		data     := data sll hdr_data'length;
		pld_data <= reverse(std_logic_vector(data(pld_data'reverse_range)));
	end process;

	process (pld_data)
		variable data : unsigned(pld_data'range);
	begin
		data        := unsigned(pld_data);
		scope_cmd   <= std_logic_vector(data(scope_cmd'range));
		data        := data srl scope_cmd'length;
		scope_data  <= std_logic_vector(data(scope_data'range));
		data        := data srl scope_data'length;
		scope_channel  <= std_logic_vector(data(scope_channel'range));
	end process;

	process (mii_rxc)
		variable cmd_edge : std_logic;
	begin
		if rising_edge(mii_rxc) then
			trigger_offset <= std_logic_vector(-(
				signed(trigger_level) +
				signed(word2byte(
					channel_offset, 
					trigger_channel,
					vt_size)) -
				signed'(b"0_1000_0000")));

			if pll_rdy='1' then
				for i in 0 to inputs-1 loop
					if i=to_integer(unsigned(scope_channel(channel_select'range))) then
						case scope_cmd(3 downto 0) is
						when "0000" =>
							channel_scale  <= byte2word(channel_scale, 
											  scope_data(vt_scale'range),
											  reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							channel_decas  <= byte2word(channel_decas, 
											  vt_scales(to_integer(unsigned(scope_data(vt_scale'range)))).deca,
											  reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							channel_select <= std_logic_vector(to_unsigned(i, channel_select'length));

							vt_scale       <= scope_data(vt_scale'range);
						when "0001" =>
							channel_offset <= byte2word(channel_offset, std_logic_vector(resize(signed(scope_data), vt_size)), reverse(std_logic_vector(to_unsigned(2**i, inputs))));
							scale_offset   <= std_logic_vector(resize(signed(scope_data), scale_offset'length));
						when others =>
						end case;
					end if;
				end loop;

				case scope_cmd(3 downto 0) is
				when "0010" =>
					trigger_level   <= std_logic_vector(resize(signed(scope_data), vt_size));
					trigger_channel <= std_logic_vector(resize(unsigned(scope_channel and x"7f"),trigger_channel'length));
					trigger_edge    <= scope_channel(scope_channel'left);
					trigger_select  <= scope_channel(trigger_select'range);
				when "0011" =>
					hz_scale        <= scope_data(hz_scale'range);
					time_deca       <= hz_scales(to_integer(unsigned(scope_data(hz_scale'range)))).deca;
					g_hzscale       <= hz_scales(to_integer(unsigned(scope_data(hz_scale'range)))).scale;
				when others =>
				end case;
			end if;
			cmd_edge := cmd_rdy;
		end if;
	end process;
	trigger_scale <= vt_scales(to_integer(unsigned(word2byte(channel_scale, trigger_channel, channel_scale'length/inputs)))).scale;
	trigger_deca  <= word2byte(channel_decas, trigger_channel, ascii'length);
	tdiv <= hz_scale;

	video_e : entity hdl4fpga.video_vga
	generic map (
		mode => ly_dptr(layout_id).mode,
		n    => 11)
	port map (
		clk   => video_clk,
		hsync => video_hs,
		vsync => video_vs,
		hcntr => video_hcntr,
		vcntr => video_vcntr,
		don   => video_hon,
		frm   => video_frm,
		nhl   => video_nhl);

	video_vld <= video_hon and video_frm;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => video_io'length,
		d => (video_io'range => unsigned_num_bits(ly_dptr(layout_id).chan_height-1)+2+delay))
	port map (
		clk   => video_clk,
		di(0) => video_hs,
		di(1) => video_vs,
		di(2) => video_vld,
		do    => video_io);

	win_mngr_e : entity hdl4fpga.win_mngr
	generic map (
		tab => to_naturalvector(ly_dptr(layout_id)))
	port map (
		video_clk  => video_clk,
		video_x    => video_hcntr,
		video_y    => video_vcntr,
		video_don  => video_hon,
		video_frm  => video_frm,
		win_don    => win_don,
		win_frm    => win_frm);

	prescaler_p : process (input_clk)

		function adjtab (
			constant arg : scale_vector)
			return integer_vector is
			variable retval : integer_vector(arg'range);
		begin
			for i in retval'range loop
				retval(i) := arg(i).mult-2;
			end loop;
			return retval;
		end;

		constant table  : integer_vector(hz_scales'range) := adjtab(hz_scales);
		variable scaler : signed(0 to signed_num_bits(max(table)-1)-1);
	begin
		if rising_edge(input_clk) then
			input_we <= scaler(0) and input_ena;
			if input_ena='1' then
				if scaler(0)='1' then
					scaler := to_signed(table(to_integer((unsigned(hz_scale)))), scaler'length);
				else
					scaler := scaler - 1;
				end if;
			end if;
		end if;
	end process;

	process (input_clk)
		variable scales : integer_vector(vt_scales'range);
		variable aux    : std_logic_vector(vm_inputs'range);
		variable m      : mdword_vector(0 to inputs-1);
		variable a      : mword_vector(0 to inputs-1);
		variable s      : mword_vector(0 to inputs-1);
	begin
		if rising_edge(input_clk) then
			for i in 0 to inputs-1 loop

				for j in scales'range loop
					scales(j) := integer(input_preamp(i)*real(vt_scales(j).mult));
				end loop;

				aux := byte2word(
					aux, 
					std_logic_vector(resize(m(i)(0 to a(0)'length-1), vt_size)),
					reverse(std_logic_vector(to_unsigned(2**i, inputs))));
				m(i) := a(i)*s(i);
				s(i) := to_signed(scales(to_integer(unsigned(word2byte(channel_scale, i, channel_scale'length/inputs)))), mword'length);
				a(i) := resize(signed(std_logic_vector'(word2byte(input_data, i, input_data'length/inputs))), mword'length);
			end loop;
			vm_inputs <= aux;
		end if;
	end process;

	trigger_b  : block
		signal input_level : std_logic_vector(0 to vt_size-1);
	begin
		process (input_clk)
			variable input_aux  : std_logic_vector(input_level'range);
			variable input_ge   : std_logic;
			variable input_trgr : std_logic;
		begin
			if rising_edge(input_clk) then
				if trigger_ena='1' then
					if input_addr(0)='1' then
						if video_frm='0' then
							trigger_ena <= '0';
						end if;
					end if;
					input_trgr := '0';
				elsif input_trgr='0' then
					if input_ge='0' then
						input_trgr := '1';
					end if;
				elsif input_ge='1' then
					trigger_ena <= '1';
				end if;
				if input_we='1' then
					input_ge  := trigger_edge xnor setif(signed(input_aux) >= signed(trigger_level));
					input_aux := word2byte(vm_inputs, trigger_channel, vt_size);
				end if;
			end if;
		end process;

		inpwedly_e : entity hdl4fpga.align 
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => input_clk,
			di(0) => input_we,
			do(0) => input_inc);

		process (input_clk) 
		begin
			if rising_edge(input_clk) then
				if trigger_ena='0' then
					input_addr <= (others => '0');
				elsif input_addr(0)='0' then
					if input_inc='1' then
						input_addr <= std_logic_vector(unsigned(input_addr) + 1);
					end if;
				end if;
			end if;
		end process;

	end block;

	videomem_b : block
		signal wr_addr : std_logic_vector(vm_addr'range);
		signal wr_data : std_logic_vector(vm_inputs'range);
		signal rd_addr : std_logic_vector(vm_addr'range);
		signal rd_data : std_logic_vector(vm_inputs'range);
		signal wr_ena  : std_logic;
		signal data1   : std_logic_vector(vm_inputs'range);
	begin

		wr_addr <= input_addr(vm_addr'range);
		wr_ena  <= not input_addr(input_addr'left) and trigger_ena and input_inc;
--		wr_ena  <= input_inc;

		data1_e : entity hdl4fpga.align
		generic map (
			n => wr_data'length,
			d => (wr_data'range => 2))
		port map (
			clk => input_clk,
			ena => input_we,
			di  => vm_inputs,
			do  => data1);

		data_e : entity hdl4fpga.align
		generic map (
			n => wr_data'length,
			d => (wr_data'range => 2))
		port map (
			clk => input_clk,
			di  => data1,
			do  => wr_data);

		process (video_clk)
			variable d : std_logic_vector(rd_data'range);
			variable aux : std_logic_vector(ordinates'range);
		begin
			if rising_edge(video_clk) then
				rd_addr <= full_addr;
--				aux := (others => '0');
				for i in 0 to inputs-1 loop
					aux := byte2word(
						aux, 
						std_logic_vector(
							signed(word2byte(d,              i, vt_size)) + 
							signed(word2byte(channel_offset, i, vt_size))),
						reverse(std_logic_vector(to_unsigned(2**i, inputs))));
				end loop;
				d       := rd_data;
				ordinates <= aux;
			end if;
		end process;

		dpram_e : entity hdl4fpga.dpram
		port map (
			wr_clk  => input_clk,
			wr_ena  => wr_ena,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr => rd_addr,
			rd_data => rd_data);
	end block;

	process (video_clk)
		variable base : unsigned(vm_addr'range);
	begin
		if rising_edge(video_clk) then
			base := (others => '-');
			for i in 0 to 4-1 loop
				if win_don(i)='1' then
					base := to_unsigned(i*ly_dptr(layout_id).chan_width, base'length);
				end if;
			end loop;
			full_addr <= std_logic_vector(resize(unsigned(abscisa),full_addr'length) + base);
		end if;
	end process;

	process(channel_scale)
		variable aux : std_logic_vector(gp_vtscale'range);
	begin
		for i in 0 to inputs-1 loop
			aux := byte2word(
				aux, 
				vt_scales(to_integer(unsigned(word2byte(channel_scale, i, channel_scale'length/inputs)))).scale,
				reverse(std_logic_vector(to_unsigned(2**i, inputs))));
		end loop;
		gp_vtscale <= aux;
	end process;

	scopeio_gpannel_e : entity hdl4fpga.scopeio_gpannel
	generic map (
		inputs         => inputs,
		gauge_labels   => gauge_labels,
		gauge_frac     => gauge_frac,
		unit_symbols   => unit_symbols)
	port map (
		pannel_clk     => mii_rxc,
		time_deca      => time_deca,
		time_scale     => g_hzscale,
		trigger_edge   => trigger_edge,
		trigger_scale  => trigger_scale,
		trigger_deca   => trigger_deca,
		trigger_value  => trigger_level,
		channel_scale  => gp_vtscale,
		channel_level  => channel_offset,
		channel_decas  => channel_decas,
		video_clk      => video_clk,
		gpannel_row    => gpannel_y(gpannel_row'range),
		gpannel_col    => gpannel_x(gpannel_col'range),
		gpannel_on     => gpannel_on,
		gauge_on       => gauge_on,
		gauge_code     => cga_code);

	process(mii_rxc)
	begin
		if rising_edge(mii_rxc) then
			text_addr <= std_logic_vector(unsigned(text_addr) + 1);
		end if;
	end process;

	cga_b : block

		signal   font_code : std_logic_vector(ascii'range);
		signal   font_row  : std_logic_vector(unsigned_num_bits(font_height-1)-1 downto 0);
		signal   font_addr : std_logic_vector(font_code'length+font_row'length-1 downto 0);
		signal   font_col  : std_logic_vector(unsigned_num_bits(font_width-1)-1  downto 0);
		signal   font_line : std_logic_vector(0 to font_width-1);
		signal   font_dot  : std_logic_vector(0 to 0);

	begin

		font_addr <= cga_code & gpannel_y(gpannel_row'right-1 downto 0);

		cgarom : entity hdl4fpga.rom
		generic map (
			synchronous => 2,
			bitrom => psf1cp850x8x16)
		port map (
			clk  => video_clk,
			addr => font_addr,
			data => font_line);

		align_x : entity hdl4fpga.align
		generic map (
			n => font_col'length,
			d => (font_col'range => 4))
		port map (
			clk => video_clk,
			di  => gpannel_x(font_col'range),
			do  => font_col);

		font_dot <= word2byte(font_line, font_col);

		align_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => video_clk,
			di    => font_dot,
			do(0) => cga_dot);

	end block;


	scopeio_channel_e : entity hdl4fpga.scopeio_channel
	generic map (
		delay       => delay,
		inputs      => inputs,
		num_of_seg  => ly_dptr(layout_id).num_of_seg,
		chan_x      => ly_dptr(layout_id).chan_x,
		chan_width  => ly_dptr(layout_id).chan_width,
		chan_height => ly_dptr(layout_id).chan_height,
		scr_width   => ly_dptr(layout_id).scr_width,
		height      => ly_dptr(layout_id).chan_y,
		hz_scales   => hz_scales,
		vt_scales   => vt_scales)
	port map (
		video_clk  => video_clk,
		video_nhl  => video_nhl,
		ordinates  => ordinates,
		offset     => scale_offset,
		trigger    => trigger_offset,
		abscisa    => abscisa,
		hz_scale   => hz_scale,
		vt_scale   => vt_scale,
		win_frm    => win_frm,
		win_on     => win_don,
		gpannel_on => gpannel_on,
		gpannel_x  => gpannel_x,
		gpannel_y  => gpannel_y,
		plot_fg    => plot_fg,
		video_bg   => video_bg,
		video_fg   => video_fg);

	xxx: process(video_clk)
		variable pcolor_sel   : std_logic_vector(0 to unsigned_num_bits(inputs-1)-1);
		variable vcolorfg_sel : std_logic_vector(0 to unsigned_num_bits(video_fg'length-1)-1);
		variable vcolorbg_sel : std_logic_vector(0 to unsigned_num_bits(video_bg'length-1)-1);
		variable gauge_sel    : std_logic_vector(0 to unsigned_num_bits(2+inputs-1)-1);

		variable plot_on      : std_logic;
		variable video_fgon   : std_logic;
		variable video_bgon   : std_logic;
		variable gauges_fgon  : std_logic;

		variable vtaxis_fg    : std_logic_vector(video_rgb'range);
		variable vtaxis_bg    : std_logic_vector(video_rgb'range);
		variable trigger_fg   : std_logic_vector(video_rgb'range);
		variable triggerfg_e  : std_logic_vector(0 to 0);
		variable trigger_bg   : std_logic_vector(video_rgb'range);

	begin
		if rising_edge(video_clk) then
			if plot_on='1' then
				pixel <= word2byte(channels_fg, pcolor_sel, pixel'length);
			elsif video_fgon='1' then
				pixel <= word2byte(hzaxis_fg   & vtaxis_fg  & grid_fg &  trigger_fg, vcolorfg_sel, pixel'length);
			elsif video_bgon='1' then
				pixel <= word2byte(hzaxis_bg   & vtaxis_bg  & grid_bg, vcolorbg_sel, pixel'length);
			elsif gauges_fgon='1' then
				pixel <= word2byte(channels_fg & hzaxis_fg  & trigger_fg, gauge_sel, pixel'length);
			else
--				pixel <= b"00000000_00000000_11111111"; --(others => '1');
				pixel <= (others => '1');
				pixel <= (others => '0');
			end if;

			triggerfg_e := word2byte(channel_ena, trigger_select, 1);
			vtaxis_bg  := word2byte(channels_bg, channel_select, vtaxis_bg'length);
			trigger_fg := word2byte(channels_fg, trigger_select, trigger_fg'length);
			trigger_fg := trigger_fg and (trigger_fg'range => triggerfg_e(0));
			trigger_bg := word2byte(channels_bg, trigger_select, trigger_bg'length);

			vcolorfg_sel := encoder(video_fg);
			vcolorbg_sel := encoder(video_bg);
			gauge_sel    := encoder(gauge_on and (channel_ena & "11"));
			pcolor_sel   := encoder(plot_fg and channel_ena);
			plot_on      := setif((plot_fg and channel_ena)  /= (plot_fg'range  => '0'));
			video_fgon   := setif(video_fg/= (video_fg'range => '0'));
			video_bgon   := setif(video_bg /= (video_bg'range => '0'));
			gauges_fgon  := setif((gauge_on and (channel_ena & "11"))/= (gauge_on'range => '0')) and cga_dot;

		end if;
	end process;

	video_rgb   <= (video_rgb'range => video_io(2)) and pixel;
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
