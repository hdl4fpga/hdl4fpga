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
		vt_div         : std_logic_vector := b"0_0010_0000";
		hz_div         : std_logic_vector := b"0_0010_0000";
		hz_scales      : scale_vector;
		vt_scales      : scale_vector;
		gauge_labels   : std_logic_vector;
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
	signal video_hzl        : std_logic;
	signal video_vld        : std_logic;
	signal video_vcntr      : std_logic_vector(11-1 downto 0);
	signal video_hcntr      : std_logic_vector(11-1 downto 0);

	signal tracers_on       : std_logic_vector(0 to inputs-1);
	signal objects_bg       : std_logic_vector(0 to 4-1);
	signal objects_fg       : std_logic_vector(0 to 3-1);

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
	signal  vt_pos    : std_logic_vector(0 to inputs*vt_size-1);
	signal  ordinates       : std_logic_vector(vm_inputs'range);
	signal  hz_scale        : std_logic_vector(4-1 downto 0);
	signal  text_data       : std_logic_vector(8-1 downto 0);
	signal  text_addr       : std_logic_vector(10-1 downto 0) := (others => '0');

	subtype mword         is signed(0 to 18-1);
	subtype mdword        is signed(0 to 2*mword'length-1);
	type    mword_vector  is array (natural range <>) of mword;
	type    mdword_vector is array (natural range <>) of mdword;

	signal scales           : std_logic_vector(0 to inputs*mword'length-1);
	signal video_pixel       : std_logic_vector(video_rgb'range);


	signal capture_ena : std_logic;
	constant lat       : natural := 4;

	constant amp_rid     : natural := 1;
	constant trigger_rid : natural := 2;
	constant hzscale_rid : natural := 3;

	subtype amp_rgtr     is natural range 18-1 downto  0;
	subtype trigger_rgtr is natural range 32-1 downto 18;
	subtype hzscale_rgtr is natural range 40-1 downto 32;

	constant rgtr_map : natural_vector := (
		amp_rid     => amp_rtgr'length,
		trigger_rid => trigger_rtgr'length,
		hzscale_rid => hzscale_rtgr'length);

	signal rgtr_file : std_logic_vector(hzscale_rgtr'high downto 0);

	subtype amp_chnl is natural range 10-1 downto  0;
	subtype amp_sel  is natural range 18-1 downto 10;
begin

	miiip_e : entity hdl4fpga.scopeio_miiip
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,

		so_clk   => so_clk,
		so_dv    => so_dv,
		so_data  => so_data);

	scopeio_sin_e : entity hdl4fpga.scopeio_sin
	generic map (
		rgtr_map => rgtr_map)
	port map (
		sin_clk   => so_clk,
		sin_dv    => so_dv,
		sin_data  => so_data,
		rgtr_wttn => rgtr_wttn,
		rgtr_id   => rgtr_id,
		rgtr_file => rgtr_file);

	downsampler_e : entity hdl4fpga.scopeio_downsampler
	port map (
		input_clk   => input_clk,
		input_ena   => input_ena,
		input_data  => input_data,
		factor_data => rgtr_file(hzscale_rgtr'range);
		output_ena  => downsample_ena,
		output_data => downsample_data);

	amp_b : block
	begin
		amp_g : for in 0 to inputs-1 generate
			subtype sample_range is natural i*input_size to (i+1)*input_size-1;

			signal gain_value : std_logic_vector;
		begin

			process (so_clk)
			begin
				if rising_edge(so_clk) then
					if to_integer(unsigned(rgtr_file(amp_chnl)))=i then
						gain_value <= mmm(to_integer(unsigned(rgtr_file(amp_sel))));
					end if;
				end if;
			end process;

			amp_e : entity hdl4fpga.scopeio_amp
			port map (
				input_clk     => input_clk,
				input_ena     => downsample_ena,
				input_sample  => downsample_data(sample_range),
				gain_value    => gain_value,
				output_ena    => ampsample_ena,
				output_sample => ampsample_data(sample_range));

		end generate;
	end block;

	scopeio_trigger_e : entity hdl4fpga.scopeio_trigger
	port map (
		input_clk    => input_clk,
		input_ena    => ampsample_ena,
		input_data   => ampsampe_data,
		trigger_req  => trigger_req,
		trigger_rgtr => rgtr_file(trigger_rgtr'range),
		capture_rdy  => capture_rdy,
		capture_req  => capture_req,
		output_data  => triggersample_data);

	storage_b : block
		signal mem_full : std_logic;
		signal wr_addr  : std_logic_vector(mem_addr'range);
		signal wr_data  : std_logic_vector(triggersample_data'range);
		signal wr_ena   : std_logic;
		signal rd_addr  : std_logic_vector(wr_addr'range);
		signal rd_data  : std_logic_vector(wr_data'range);
	begin

		wr_ena  <= caputure_req;
		wr_data <= triggersample_data;
		process (sin_clk)
			variable aux : unsigned(0 to wr_addr'length);
		begin
			if rising_edge(sin_clk) then
				if wr_ena='0' then
					aux := (others => '0');
				else
					aux := aux + 1;
				end if;
				wr_addr  <= std_logic_vector(aux(1 to wr_addr'length));
				mem_full <= aux(0);
			end if;
		end process;
		caputure_rdy <= mem_full;

		ready_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 => 2))
		port map (
			clk   => mem_clk,
			di(0) => mem_req,
			do(0) => mem_rdy);

		rd_addr_e : entity hdl4fpga.align
		generic map (
			n => rd_addr'length,
			d => (rd_addr'range => 1))
		port map (
			clk => mem_clk,
			di  => mem_addr,
			do  => rd_addr);

		mem_e : entity hdl4fpga.dpram 
		port map (
			wr_clk  => sin_clk,
			wr_ena  => wr_ena,
			wr_addr => wr_addr,
			wr_data => wr_data,
			rd_addr => rd_addr,
			rd_data => rd_data);

		rd_data_e : entity hdl4fpga.align
		generic map (
			n => mem_data'length,
			d => (mem_data'range => 1))
		port map (
			clk => mem_clk,
			di  => rd_data,
			do  => storage_data);
	end block;

	graphics_b : block
	begin
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
			nhl   => video_hzl);

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

		scope_cga_e : entity hdl4fpga.scopeio_cga
		generic map (
			font_bitrom => psf1cp850x8x16,
			font_height => 16,
			font_width  => 8)
		port map (
			clk => video_clk,
			x   =>
			y   =>
			dot => cga_dot);

		scopeio_channel_e : entity hdl4fpga.scopeio_channel
		generic map (
			lat         => lat,
			inputs      => inputs,
			num_of_seg  => ly_dptr(layout_id).num_of_seg,
			chan_x      => ly_dptr(layout_id).chan_x,
			chan_width  => ly_dptr(layout_id).chan_width,
			chan_height => ly_dptr(layout_id).chan_height,
			scr_width   => ly_dptr(layout_id).scr_width,
			height      => ly_dptr(layout_id).chan_y,
		port map (
			video_clk   => video_clk,
			video_hzl   => video_hzl,
			win_frm     => win_frm,
			win_on      => win_don,
			samples     => storage_data,
			vt_pos      => vt_pos,
			trg_lvl     => trg_lvl,
			grid_pxl    => grid_pxl,
			trigger_pxl => trigger_pxl,
			traces_pxls => trace_pxls);

		scopeio_palette_e : entity hdl4fpga.palette
		port map (
			channels_fg  =>,  
			channels_bg  =>, 
			hzaxis_fg    =>, 
			hzaxis_bg    =>, 
			grid_fg      =>, 
			grid_bg      =>, 
			
			tracers_on   =>, 
			objectsfg_on => objects_, 
			objectsbg_on =>, 
			gauges_on    =>, 

			trigger_on   =>, 

			video_clk    => video_clk, 
			video_pixel  => video_pixel);
	end block;

	video_rgb   <= (video_rgb'range => video_io(2)) and video_pixel;
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
