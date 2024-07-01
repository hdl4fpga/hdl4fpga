
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
		max_delay     : natural;
		font_bitrom   : std_logic_vector := psf1cp850x8x16;
		font_height   : natural := 16);
	port (
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		gain_ena      : in  std_logic;
		gain_dv       : in  std_logic;
		gain_cid      : in  std_logic_vector;
		gain_ids      : in  std_logic_vector;

		time_dv       : in  std_logic;
		time_id       : in  std_logic_vector;
		time_offset   : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_hcntr   : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		sgmntbox_ena  : in  std_logic_vector;
		text_on       : in  std_logic := '1';
		text_fg       : out std_logic_vector;
		text_bg       : out std_logic_vector;
		text_fgon     : out std_logic);

	constant inputs         : natural := hdo(layout)**".inputs";
	constant hz_unit        : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit        : real    := hdo(layout)**".axis.vertical.unit";
	constant font_width     : natural := hdo(layout)**".textbox.font_width";
	constant textbox_width  : natural := hdo(layout)**".textbox.width";
	constant textbox_height : natural := hdo(layout)**".grid.height";
	constant grid_height    : natural := hdo(layout)**".grid.height";
	constant grid_unit      : natural := hdo(layout)**".grid.unit";
	constant vt             : string  := hdo(layout)**".vt";

	constant hz_text        : string  := "Hztl";
	constant vt_prefix      : string  := get_prefix1235(vt_unit);
	constant hz_prefix      : string  := get_prefix1235(hz_unit);
	constant hzoffset_bits  : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits    : natural := unsigned_num_bits(inputs-1);

	constant cga_cols        : natural := textbox_width/font_width;
	constant cga_rows        : natural := textbox_height/font_height;

	constant textbox_fields : string := compact (
		"{"                                       &
		"    horizontal : { top : 0, left : 0 }," &
		"    trigger    : { top : 1, left : 0 }," &
		"    inputs     : { top : 2, left : 0 }"  &
		"}"
	);

	function textbox_rom (
		constant width  : natural;
		constant size   : natural)
		return string is

		variable data   : string(1 to size);
		variable offset : positive;
		variable length : natural;
		variable i      : natural;
		variable j      : natural;

	begin
		data(1 to hz_text'length) := hz_text;
		i := 0;
		j := data'left+2*cga_cols;
		for i in 0 to inputs-1 loop
			data(j to j+width-1) := textalign(escaped(hdo(vt)**("["&natural'image(i)&"].text")), width);
			j := j + width;
		end loop;
		return data;
	end;

	function textbox_field (
		constant width          : natural)
		return natural_vector is
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

	constant vt_sfcnds : natural_vector := get_significand1245(vt_unit);
	constant vt_shts   : integer_vector := get_shr1245(vt_unit);
	constant vt_pnts   : integer_vector := get_characteristic1245(vt_unit);

	constant hz_sfcnds : natural_vector := get_significand1245(hz_unit);
	constant hz_shrs   : integer_vector := get_shr1245(hz_unit);
	constant hz_pnts   : integer_vector := get_characteristic1245(hz_unit);
end;

architecture def of scopeio_textbox is
	constant cga_latency   : natural := 4;
	constant color_latency : natural := 2;
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant textwidth_bits  : natural := unsigned_num_bits(textbox_width-1);
	constant cga_size        : natural := (textbox_width/font_width)*(textbox_height/font_height);
	constant cga_bitrom      : std_logic_vector :=  to_ascii(textbox_rom(cga_cols, cga_size));

	constant bin_digits      : natural := 3;
	constant bcd_width       : natural := 8;
	constant bcd_length      : natural := 4;
	constant bcd_digits      : natural := 1;

	signal botd_sht          : signed(4-1 downto 0);
	signal botd_dec          : signed(4-1 downto 0);

	constant sfcnd_length    : natural := max(unsigned_num_bits(max(vt_sfcnds)), unsigned_num_bits(max(hz_sfcnds)));

	signal vt_offset         : std_logic_vector((5+8)-1 downto 0);
	signal hz_scale          : unsigned(0 to sfcnd_length-1);
	signal vt_sht            : signed(botd_sht'range);
	signal vt_dec            : signed(botd_dec'range);

	signal hz_offset         : std_logic_vector(time_offset'range);
	signal vt_scale          : unsigned(0 to sfcnd_length-1);
	signal hz_sht            : signed(botd_sht'range);
	signal hz_dec            : signed(botd_dec'range);

	constant offset_length   : natural := max(vt_offset'length, hz_offset'length);

	signal code_frm          : std_logic;
	signal code_irdy         : std_logic;
	signal code_data         : ascii;
	signal cga_we            : std_logic := '0';
	signal cga_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_data          : ascii;

	signal fg_color          : std_logic_vector(text_fg'range);
	signal bg_color          : std_logic_vector(text_bg'range);

	signal video_on          : std_logic;
	signal video_addr        : std_logic_vector(cga_addr'range);
	signal video_dot         : std_logic;

	signal vtwdt_req         : bit;
	signal vtwdt_rdy         : bit;
	signal hzwdt_req         : bit;
	signal hzwdt_rdy         : bit;
	signal tgwdt_req         : bit;
	signal tgwdt_rdy         : bit;
	type wdt_types is (wdt_offset, wdt_unit);
	signal wdt_type          : wdt_types;
	signal wdt_req           : bit;
	signal wdt_rdy           : bit;
	signal wdt_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);

	signal wdt_id      : std_logic_vector(chanid_maxsize-1 downto 0);
begin

	rgtr_b : block

		signal myip_ena       : std_logic;
		signal myip_dv        : std_logic;
		signal myip_num1      : std_logic_vector(8-1 downto 0);
		signal myip_num2      : std_logic_vector(8-1 downto 0);
		signal myip_num3      : std_logic_vector(8-1 downto 0);
		signal myip_num4      : std_logic_vector(8-1 downto 0);

		signal trigger_ena    : std_logic;
		signal trigger_freeze : std_logic;
		signal trigger_slope  : std_logic;
		signal trigger_chanid : std_logic_vector(chanid_bits-1 downto 0);
		signal trigger_level  : std_logic_vector(storage_word'range);

		signal vt_exp         : integer;
		signal vt_dv          : std_logic;
		signal vt_ena         : std_logic;
		signal vt_offsets     : std_logic_vector(0 to inputs*vt_offset'length-1);
		signal tgr_scale      : std_logic_vector(4-1 downto 0);

		function label_width 
			return natural is
			variable offset : positive;
			variable length : natural;
			variable i      : natural;
			variable retval : natural;
		begin
			i := 0;
			retval := 0;
			for i in 0 to inputs-1 loop
				resolve(layout&".vt["&natural'image(i)&"].text", offset, length);
				if length=0 then
					exit;
				elsif retval < length then
					retval := length;
				end if;
			end loop;
			return retval;
		end;

		constant width : natural := label_width + 1;
	
	begin

		myip4_e : entity hdl4fpga.scopeio_rgtrmyip
		port map (
			rgtr_clk  => rgtr_clk,
			rgtr_dv   => rgtr_dv,
			rgtr_id   => rgtr_id,
			rgtr_data => rgtr_data,

			ip4_ena   => myip_ena,
			ip4_dv    => myip_dv,
			ip4_num1  => myip_num1,
			ip4_num2  => myip_num2,
			ip4_num3  => myip_num3,
			ip4_num4  => myip_num4);

		trigger_e : entity hdl4fpga.scopeio_rgtrtrigger
			generic map (
				rgtr      => false)
		port map (
			rgtr_clk       => rgtr_clk,
			rgtr_dv        => rgtr_dv,
			rgtr_id        => rgtr_id,
			rgtr_data      => rgtr_data,

			trigger_ena    => trigger_ena,
			trigger_slope  => trigger_slope,
			trigger_freeze => trigger_freeze,
			trigger_chanid => trigger_chanid,
			trigger_level  => trigger_level);

		rgtrvtaxis_b : block
			signal offset : std_logic_vector(vt_offset'range);
			signal chanid : std_logic_vector(chanid_maxsize-1 downto 0);
		begin
			vtaxis_e : entity hdl4fpga.scopeio_rgtrvtaxis
			generic map (
				rgtr      => false)
			port map (
				rgtr_clk  => rgtr_clk,
				rgtr_dv   => rgtr_dv,
				rgtr_id   => rgtr_id,
				rgtr_data => rgtr_data,
				vt_dv     => vt_dv,
				vt_ena    => vt_ena,
				vt_chanid => chanid,
				vt_offset => offset);

			vtscale_p : process (rgtr_clk)
				variable gain_id : unsigned(4-1 downto 0);
			begin
				if rising_edge(rgtr_clk) then
					if vt_ena='1' then
						gain_id    := unsigned(multiplex(gain_ids, chanid, gain_id'length));
						vt_sht     <= to_signed(vt_shts(to_integer(gain_id)), botd_sht'length);
						vt_dec     <= to_signed(vt_pnts(to_integer(gain_id)), botd_dec'length);
						vt_scale   <= to_unsigned(vt_sfcnds(to_integer(gain_id(2-1 downto 0))), vt_scale'length);
						vt_offset  <= offset;
						vt_offsets <= replace(vt_offsets, chanid, offset);
						wdt_id     <= std_logic_vector(resize(unsigned(chanid), wdt_id'length));
						wdt_addr   <= mul(unsigned(chanid), cga_cols, wdt_addr'length)+ 2*cga_cols;
						vtwdt_req  <= not vtwdt_rdy;
					elsif gain_dv='1' then
						gain_id    := unsigned(multiplex(gain_ids, chanid, gain_id'length));
						vt_sht     <= to_signed(vt_shts(to_integer(gain_id)), botd_sht'length);
						vt_dec     <= to_signed(vt_pnts(to_integer(gain_id)), botd_dec'length);
						vt_scale   <= to_unsigned(vt_sfcnds(to_integer(gain_id(2-1 downto 0))), vt_scale'length);
						vt_offset  <= multiplex(vt_offsets, gain_cid, vt_offset'length);
						wdt_id     <= std_logic_vector(resize(unsigned(gain_cid), wdt_id'length));
						wdt_addr   <= mul(unsigned(gain_cid), cga_cols, wdt_addr'length)+ 2*cga_cols;
						vtwdt_req  <= not vtwdt_rdy;
					elsif time_dv='1' then
						hz_sht     <= to_signed(hz_shrs(to_integer(unsigned(time_id))), botd_sht'length);
						hz_dec     <= to_signed(hz_pnts(to_integer(unsigned(time_id))), botd_dec'length);
						hz_scale   <= to_unsigned(hz_sfcnds(to_integer(unsigned(time_id(2-1 downto 0)))), hz_scale'length);
						hz_offset  <= time_offset;
						hzwdt_req  <= not hzwdt_rdy;
						wdt_id     <= std_logic_vector(to_unsigned(inputs, wdt_id'length));
						wdt_addr   <= (others => '0');
					elsif trigger_ena='1' then
						gain_id    := unsigned(multiplex(gain_ids, trigger_chanid, gain_id'length));
						vt_sht     <= to_signed(vt_shts(to_integer(gain_id)), botd_sht'length);
						vt_dec     <= to_signed(vt_pnts(to_integer(gain_id)), botd_dec'length);
						vt_scale   <= to_unsigned(vt_sfcnds(to_integer(gain_id(2-1 downto 0))), vt_scale'length);
						hz_offset  <= std_logic_vector(resize(signed(trigger_level), hz_offset'length));
						wdt_id     <= std_logic_vector(to_unsigned(inputs+1, wdt_id'length));
						wdt_addr   <= to_unsigned(cga_cols, wdt_addr'length);
						tgwdt_req  <= not tgwdt_rdy;
					end if;
				end if;
			end process;
		end block;

		wdt_b : block

			signal offset     : signed(0 to max(vt_offset'length, hz_offset'length)-1);
			signal magnitud   : signed(offset'range);
			signal btod_req   : std_logic;
			signal btod_rdy   : std_logic;
			signal dbdbbl_req : std_logic;
			signal dbdbbl_rdy : std_logic;

			signal scale      : unsigned(0 to sfcnd_length-1);

			signal txt_rdy  : std_logic := '0';
			signal txt_req  : std_logic := '0';

		begin

			process (rgtr_clk)
			begin
				if rising_edge(rgtr_clk) then
					if (vtwdt_rdy xor vtwdt_req)='1' then
						offset    <= resize(signed(vt_offset), offset'length);
						scale     <= vt_scale;
						botd_sht  <= vt_sht;
						botd_dec  <= vt_dec;
						txt_req   <= not to_stdulogic(to_bit(txt_rdy));
						vtwdt_rdy <= vtwdt_req;
					elsif (tgwdt_rdy xor tgwdt_req)='1' then
						offset    <= resize(signed(hz_offset), offset'length);
						scale     <= vt_scale;
						botd_sht  <= vt_sht;
						botd_dec  <= vt_dec;
						txt_req   <= not to_stdulogic(to_bit(txt_rdy));
						tgwdt_rdy <= tgwdt_req;
					elsif (hzwdt_rdy xor hzwdt_req)='1' then
						offset    <= resize(signed(hz_offset), offset'length);
						scale     <= hz_scale;
						botd_sht  <= hz_sht;
						botd_dec  <= hz_dec;
						txt_req   <= not to_stdulogic(to_bit(txt_rdy));
						hzwdt_rdy <= hzwdt_req;
					end if;
				end if;
			end process;

			xxx_e : entity hdl4fpga.scopeio_axisreading
			generic map (
				inputs   => inputs,
				binary_length => bin_digits*((offset_length+sfcnd_length+bin_digits-1)/bin_digits),
				vt_labels => vt,
				hz_label  => hz_text,
				grid_unit => grid_unit)
			port map (
				rgtr_clk  => rgtr_clk,
				txt_req   => txt_req,
				txt_rdy   => txt_rdy,
				wdt_id => wdt_id,
				botd_sht  => std_logic_vector(botd_sht),
				botd_dec  => std_logic_vector(botd_dec),
				offset    => std_logic_vector(offset),
				scale     => std_logic_vector(scale),
				code_frm  => code_frm,
				code_irdy => code_irdy,
				code_data => code_data);


	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if cga_we='1' then
				cga_addr <= cga_addr + 1;
			elsif code_frm='0' then
				cga_addr <= wdt_addr;
			end if;
			cga_we   <= code_irdy;
			cga_data <= code_data;
		end if;
	end process;
		end block;
	end block;

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl fontheight_bits, cga_cols) +
		(unsigned(video_hcntr(textwidth_bits-1 downto 0)) srl fontwidth_bits),
		video_addr'length));
	video_on <= text_on and sgmntbox_ena(0);

	cgaram_e : entity hdl4fpga.cgaram
	generic map (
		cga_bitrom   => cga_bitrom,
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

	process (video_clk)
		constant xxx : natural := 2;
		constant field_addr : natural_vector := textbox_field(cga_cols);
		variable field_id   : natural range 0 to 2**fg_color'length-1;
		variable addr       : std_logic_vector(video_addr'range);
	begin
		if rising_edge(video_clk) then
			fg_color <= std_logic_vector(to_unsigned(field_id, fg_color'length));
			if video_on='1' then
				field_id := pltid_textfg;
				for i in field_addr'range loop
					if unsigned(addr) < (field_addr(i)+cga_cols) then
						if i >= xxx then 
							field_id := (i-xxx)+pltid_order'length;
						end if;
						exit;
					end if;
				end loop;
			end if;
			addr := video_addr;
		end if;
	end process;

	bg_color <= std_logic_vector(to_unsigned(pltid_textbg, bg_color'length));

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
