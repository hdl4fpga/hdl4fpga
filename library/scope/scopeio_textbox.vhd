
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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

		hz_dv         : in  std_logic;
		hz_scale      : in  std_logic_vector;
		hz_offset     : in  std_logic_vector;

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
	constant hzoffset_bits  : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits    : natural := unsigned_num_bits(inputs-1);

	constant cga_cols        : natural := textbox_width/font_width;
	constant cga_rows        : natural := textbox_height/font_height;

	function textbox_rom (
		constant width  : natural;
		constant size   : natural)
		return string is

		function textalign (
			constant text  : string;
			constant width : natural;
			constant align : string := "left")
			return string is
			variable retval : string(1 to width);
		begin
			retval := (others => ' ');
			retval(1 to text'length) := text;
			if align="right" then
				retval := rotate_left(retval, text'length);
			elsif align="center" then
				retval := rotate_left(retval, (text'length+width)/2);
			end if; 

			return retval;
		end;

		variable data   : string(1 to size);
		variable offset : positive;
		variable length : natural;
		variable i      : natural;
		variable j      : natural;

	begin
		data(1 to hz_text'length) := hz_text;
		i := 0;
		j := data'left+cga_cols;
		for i in 0 to inputs-1 loop
			data(j to j+width-1) := textalign(escaped(hdo(vt)**("["&natural'image(i)&"].text")), width);
			j := j + width;
		end loop;
		return data;
	end;

	function textbox_field (
		constant width  : natural;
		constant size   : natural)
		return natural_vector is
		variable retval : natural_vector(0 to inputs);
	begin
		retval(0) := width;
		for i in 1 to inputs loop
			retval(i) := retval(i-1) + width ;
		end loop;
		return retval;
	end;

	constant signfcnds : natural_vector := get_significand1245(vt_unit);
	constant signfcnd_length : natural  := unsigned_num_bits(max(signfcnds));
	constant shrs : integer_vector  := get_shr1245(vt_unit);
	constant pnts : integer_vector  := get_characteristic1245(vt_unit);
end;

architecture def of scopeio_textbox is
	subtype ascii is std_logic_vector(8-1 downto 0);
	constant cga_latency  : natural := 4;
	constant fgbg_latency : natural := 2;
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant textwidth_bits  : natural := unsigned_num_bits(textbox_width-1);
	constant cga_size        : natural := (textbox_width/font_width)*(textbox_height/font_height);
	constant cga_bitrom      : std_logic_vector :=  to_ascii(textbox_rom(cga_cols, cga_size));

	signal btof_frm          : std_logic;
	signal btof_code         : ascii;
	signal cga_we            : std_logic := '0';
	signal cga_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_data          : ascii;

	signal fg_color          : std_logic_vector(text_fg'range);
	signal bg_color          : std_logic_vector(text_bg'range);

	signal video_on          : std_logic;
	signal video_addr        : std_logic_vector(cga_addr'range);
	signal video_dot         : std_logic;

	signal vttxt_req         : bit;
	signal vttxt_rdy         : bit;
	type wdt_types is (wdt_offset, wdt_unit);
	signal wdt_type          : wdt_types;
	signal wdt_req           : bit;
	signal wdt_rdy           : bit;
	signal wdt_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);

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
		signal vt_offset      : std_logic_vector((5+8)-1 downto 0);
		signal vt_offsets     : std_logic_vector(0 to inputs*vt_offset'length-1);
		signal vt_chanid      : std_logic_vector(chanid_maxsize-1 downto 0);
		signal vt_scale       : std_logic_vector(4-1 downto 0);
		signal tgr_scale      : std_logic_vector(4-1 downto 0);

		constant bin_digits   : natural := 3;
		constant bcd_width    : natural := 8;
		constant bcd_length   : natural := 4;
		constant bcd_digits   : natural := 1;
		signal bcd            : std_logic_vector(0 to bcd_digits*bcd_length-1);
		signal bin            : std_logic_vector(0 to bin_digits*((vt_offset'length+signfcnd_length+bin_digits-1)/bin_digits)-1);

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
			signal chanid : std_logic_vector(vt_chanid'range);
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

		vtgain_p : process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if vt_ena='1' then
					vt_offset  <= offset;
					vt_chanid  <= chanid;
					vt_scale   <= multiplex(gain_ids,   chanid, vt_scale'length);
					vt_offsets <= byte2word(vt_offsets, chanid, offset);
					vttxt_req  <= not vttxt_rdy;
				elsif gain_dv='1' then
					vt_offset  <= multiplex(vt_offsets, gain_cid, vt_offset'length);
					vt_chanid  <= std_logic_vector(resize(unsigned(gain_cid), vt_chanid'length));
					vt_scale   <= multiplex(gain_ids,   gain_cid, vt_scale'length);
					vttxt_req  <= not vttxt_rdy;
				end if;
			end if;
		end process;
		end block;
		tgr_scale <= multiplex(gain_ids,   trigger_chanid, tgr_scale'length);

		btof_b : block

			signal offset      : signed(0 to max(vt_offset'length, hz_offset'length)-1);
			signal magnitud    : signed(offset'range);
			signal mul_req     : std_logic;
			signal mul_rdy     : std_logic;
			signal dbdbbl_req  : std_logic;
			signal dbdbbl_rdy  : std_logic;

			signal scale : std_logic_vector(0 to signfcnd_length-1);

			signal code_frm : std_logic;
			signal code     : std_logic_vector(0 to 8-1);
			signal shr      : std_logic_vector(4-1 downto 0);
			signal pnt      : std_logic_vector(4-1 downto 0);

		begin

			process (rgtr_clk)
				type states is (s_init, s_wdtoffset, s_wdtunit);
				variable state : states;
				variable q : std_logic;
			begin
				if rising_edge(rgtr_clk) then
					case state is
					when s_init =>
						if (vttxt_req xor vttxt_rdy)='1' then
							offset   <= resize(signed(vt_offset), offset'length);
							scale    <= std_logic_vector(to_unsigned(signfcnds(to_integer(unsigned(vt_scale(2-1 downto 0)))), scale'length));
							wdt_addr <= resize(mul(unsigned(vt_chanid), cga_cols), wdt_addr'length) + (width + cga_cols);
							mul_req  <= not to_stdulogic(to_bit(mul_rdy));
							wdt_req  <= not wdt_rdy;
							state    := s_wdtoffset;
						elsif hz_dv='1' then
							offset   <= resize(signed(hz_offset), offset'length);
							scale    <= std_logic_vector(to_unsigned(signfcnds(to_integer(unsigned(hz_scale(2-1 downto 0)))), scale'length));
							wdt_addr <= to_unsigned(width, wdt_addr'length);
							mul_req  <= not to_stdulogic(to_bit(mul_rdy));
							wdt_req  <= not wdt_rdy;
							state    := s_wdtoffset;
						end if;
					when s_wdtoffset =>
						if (wdt_rdy xor wdt_req)='0' then
							wdt_addr <= cga_addr + 2;
							offset   <= to_signed(grid_unit, offset'length);
							mul_req  <= not to_stdulogic(to_bit(mul_rdy));
							wdt_req  <= not wdt_rdy;
							state    := s_wdtunit;
						end if;
					when s_wdtunit =>
						if (wdt_rdy xor wdt_req)='0' then
							vttxt_rdy <= vttxt_req;
							state := s_init;
						end if;
					end case;
				end if;
			end process;

			magnitud <= -offset when offset(offset'left)='1' else offset;
			mul_ser_e : entity hdl4fpga.mul_ser
			generic map (
				lsb => true)
			port map (
				clk => rgtr_clk,
				req => mul_req,
				rdy => mul_rdy,
				a   => scale,
				b   => std_logic_vector(magnitud),
				s   => bin);

			shr <= std_logic_vector(to_signed(shrs(to_integer(unsigned(vt_scale))), shr'length));
			pnt <= std_logic_vector(to_signed(pnts(to_integer(unsigned(vt_scale))), pnt'length));
			btof_e : entity hdl4fpga.btof
			port map (
				clk      => rgtr_clk,
				btof_req => mul_rdy,
				btof_rdy => open,
				sht      => shr,
				dec      => pnt,
				left     => '0',
				width    => x"6",
				exp      => b"101",
				neg      => offset(offset'left),
				bin      => bin,
				code_frm => btof_frm,
				code     => btof_code);

		end block;

 		widget_p : process (btof_frm, rgtr_clk)
 			type states is (s_wait, s_vtevent);
 			variable state : states;
 		begin
 			if rising_edge(rgtr_clk) then
 				case state is
 				when s_wait  =>
					cga_we   <= btof_frm;
					cga_data <= btof_code;
					cga_addr <= wdt_addr;
 					if btof_frm='1' then
 						state := s_vtevent;
 					end if;
 				when s_vtevent =>
	 				if btof_frm='1' then
	 					cga_we   <= '1';
	 					cga_addr <= cga_addr + 1;
	 					cga_data <= btof_code;
					else
	 					cga_we   <= '1';
	 					cga_addr <= cga_addr + 1;
	 					cga_data <= to_ascii(vt_prefix(to_integer(unsigned(vt_scale))+1));
	 					state    := s_wait;
						wdt_rdy  <= wdt_req;
						state    := s_wait;
	 				end if;
 				end case;
 			end if;
 		end process;
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
		constant field_addr : natural_vector := textbox_field(cga_cols, cga_size);
		variable field_id   : natural range 0 to 2**fg_color'length-1;
		variable addr       : std_logic_vector(video_addr'range);
	begin
		if rising_edge(video_clk) then
			fg_color <= std_logic_vector(to_unsigned(field_id, fg_color'length));
			if video_on='1' then
				field_id := pltid_textfg;
				for i in field_addr'range loop
					if unsigned(addr)<field_addr(i) then
						if i/=0 then 
							field_id := i-1+pltid_order'length;
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
		d  => (0 to text_fg'length-1 => latency-fgbg_latency))
	port map (
		clk => video_clk,
		di  => fg_color,
		do  => text_fg);
	latbg_e : entity hdl4fpga.latency
	generic map (
		n  => text_bg'length,
		d  => (0 to text_bg'length-1 => latency-fgbg_latency))
	port map (
		clk => video_clk,
		di  => bg_color,
		do  => text_bg);
end;
