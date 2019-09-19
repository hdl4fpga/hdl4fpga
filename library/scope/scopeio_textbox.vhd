library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_textbox is
	generic(
		lang          : i18n_langs;
		inputs        : natural;
		layout        : display_layout;
		latency       : natural;
		max_delay     : natural;
		font_bitrom   : std_logic_vector := psf1cp850x8x16;
		font_height   : natural := 16;
		font_width    : natural := 8;
		hz_unit       : real;
		vt_unit       : real);
	port (
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		btof_binfrm   : buffer std_logic;
		btof_binirdy  : out std_logic;
		btof_bintrdy  : in  std_logic;
		btof_bindi    : out std_logic_vector;
		btof_binneg   : out std_logic;
		btof_binexp   : out std_logic;
		btof_bcdwidth : out std_logic_vector;
		btof_bcdprec  : out std_logic_vector;
		btof_bcdunit  : out std_logic_vector;
		btof_bcdsign  : out std_logic;
		btof_bcdalign : out std_logic;
		btof_bcdirdy  : buffer std_logic;
		btof_bcdtrdy  : in  std_logic;
		btof_bcdend   : in  std_logic;
		btof_bcddo    : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_hcntr   : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		text_on       : in  std_logic := '1';
		text_dot      : out std_logic);

--	constant inp : natural := inputs+3;
	constant inp : natural := inputs;
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inp-1);
end;

architecture def of scopeio_textbox is

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant cgaadapter_latency : natural := 4;

	constant analog_addr : tag_vector := text_analoginputs(inp, analogtime_layout);
	constant font_wbits  : natural    := unsigned_num_bits(font_width-1);
	constant font_hbits  : natural    := unsigned_num_bits(font_height-1);
	constant cga_cols    : natural    := textbox_width(layout)/font_width;
	constant cga_rows    : natural    := textbox_height(layout)/font_height;
	constant cga_size    : natural    := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);

	signal cgaaddr_init : std_logic;
	signal cga_av           : std_logic;
	signal cgabcd_req   : std_logic_vector(0 to 5-1);
	signal cgabcd_frm   : std_logic_vector(cgabcd_req'range);
	signal cgabcd_end   : std_logic;
	signal cgastr_req   : std_logic_vector(0 to 5-1);
	signal cgastr_frm   : std_logic_vector(cgastr_req'range);
	signal cgastr_end   : std_logic;
	signal cga_req      : std_logic_vector(0 to cgabcd_req'length+cgastr_req'length-1);
	signal cga_frm      : std_logic_vector(cga_req'range);
	signal cgachar_frm  : std_logic_vector(0 to 1-1);
	signal cga_we       : std_logic;
	signal cga_addr     : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code     : ascii;
	signal video_addr   : std_logic_vector(cga_addr'range);
	signal char_dot     : std_logic;

	signal var_id       : std_logic_vector(0 to 5-1);
	signal var_binvalue : std_logic_vector(0 to 12-1);
	signal var_expvalue : std_logic_vector(btof_bindi'range);
	signal var_strvalue : ascii;
	signal frac         : signed(var_binvalue'range);
	signal exp          : signed(btof_bindi'range);
	signal scale        : std_logic_vector(0 to 2-1) := "00";

	signal val_type     : std_logic;
begin

	rgtr_b : block

		signal trigger_ena    : std_logic;
		signal trigger_freeze : std_logic;
		signal trigger_edge   : std_logic;
		signal trigger_chanid : std_logic_vector(chanid_bits-1 downto 0);
		signal trigger_level  : std_logic_vector(storage_word'range);

		constant vt_frac      : unsigned := to_unsigned(to_siofloat(vt_unit).frac, unsigned_num_bits(to_siofloat(vt_unit).frac));
		constant vt_exp       : signed   := to_signed(to_siofloat(vt_unit).exp, btof_bindi'length);
		signal vt_ena         : std_logic;
		signal vt_offset      : std_logic_vector((5+8)-1 downto 0);
		signal vt_chanid      : std_logic_vector(chanid_maxsize-1 downto 0);
		signal vt_scale       : std_logic_vector(4-1 downto 0);
		signal vt_scalevalue  : std_logic_vector(vt_frac'length+3-1 downto 0);
		signal gain_ena       : std_logic;
		signal gain_chanid    : std_logic_vector(chanid_maxsize-1 downto 0);

		constant hz_frac      : unsigned := to_unsigned(to_siofloat(hz_unit).frac, unsigned_num_bits(to_siofloat(hz_unit).frac));
		constant hz_exp       : signed   := to_signed(to_siofloat(hz_unit).exp, btof_bindi'length);
		signal hz_ena         : std_logic;
		signal hz_slider      : std_logic_vector(hzoffset_bits-1 downto 0);
		signal hz_scale       : std_logic_vector(4-1 downto 0);
		signal hz_scalevalue  : std_logic_vector(hz_frac'length+3 downto 0);

	begin

		hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
		port map (
			rgtr_clk       => rgtr_clk,
			rgtr_dv        => rgtr_dv,
			rgtr_id        => rgtr_id,
			rgtr_data      => rgtr_data,

			hz_ena         => hz_ena,
			hz_scale       => hz_scale,
			hz_slider      => hz_slider);

		trigger_e : entity hdl4fpga.scopeio_rgtrtrigger
		port map (
			rgtr_clk       => rgtr_clk,
			rgtr_dv        => rgtr_dv,
			rgtr_id        => rgtr_id,
			rgtr_data      => rgtr_data,

			trigger_ena    => trigger_ena,
			trigger_edge   => trigger_edge,
			trigger_freeze => trigger_freeze,
			trigger_chanid => trigger_chanid,
			trigger_level  => trigger_level);

		vtaxis_e : entity hdl4fpga.scopeio_rgtrvtaxis
		port map (
			rgtr_clk       => rgtr_clk,
			rgtr_dv        => rgtr_dv,
			rgtr_id        => rgtr_id,
			rgtr_data      => rgtr_data,
			vt_ena         => vt_ena,
			vt_chanid      => vt_chanid,
			vt_offset      => vt_offset);

		vtgain_e : entity hdl4fpga.scopeio_rgtrgain
		port map (
			rgtr_clk       => rgtr_clk,
			rgtr_dv        => rgtr_dv,
			rgtr_id        => rgtr_id,
			rgtr_data      => rgtr_data,
			gain_ena       => gain_ena,
			chan_id        => gain_chanid,
			gain_id        => vt_scale);

		process (rgtr_clk)
			variable bcd_req : std_logic_vector(cgabcd_req'range);
			variable str_req : std_logic_vector(cgastr_req'range);
		begin
			if rising_edge(rgtr_clk) then
				bcd_req := cgabcd_req or (
					0 => hz_ena,
					1 => hz_ena,
					2 => trigger_ena,
					3 => vt_ena,
					4 => gain_ena);
				cgabcd_req <= bcd_req and not (cgabcd_frm and (cgabcd_frm'range => cgabcd_end));

				str_req := cgastr_req or (
					0 => hz_ena,
					1 => trigger_ena,
					2 => trigger_ena,
					3 => trigger_ena,
					4 => gain_ena);
				cgastr_req <= str_req and not (cgastr_frm and (cgastr_frm'range => cgastr_end));
			end if;
		end process;

		cga_req <= cgabcd_req & cgastr_req;
		cga_arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk     => rgtr_clk,
			bus_req => cga_req,
			bus_gnt => cga_frm);

		cgabcd_frm <= cga_frm(0 to cgabcd_frm'length-1);
		cgastr_frm <= cga_frm(cgabcd_frm'length to cgastr_frm'length+cgabcd_frm'length-1);
		val_type <= 
		   '0' when cgabcd_frm/=(cgabcd_frm'range => '0') else
		   '1' when cgastr_frm/=(cgastr_frm'range => '0') else
		   '-';

		var_id <= wirebus(
			std_logic_vector(to_unsigned(var_hzoffsetid,                           var_id'length)) & 
			std_logic_vector(to_unsigned(var_hzdivid,                              var_id'length)) & 
			std_logic_vector(to_unsigned(var_tgrlevelid,                           var_id'length)) &
			std_logic_vector(resize(mul(unsigned(vt_chanid),3)  +var_vtoffsetid+0, var_id'length)) &
			std_logic_vector(resize(mul(unsigned(gain_chanid),3)+var_vtoffsetid+1, var_id'length)) &

			std_logic_vector(to_unsigned(var_hzunitid,                             var_id'length)) &
			std_logic_vector(to_unsigned(var_tgredgeid,                            var_id'length)) &
			std_logic_vector(to_unsigned(var_tgrfreezeid,                          var_id'length)) &
			std_logic_vector(to_unsigned(var_tgrunitid,                            var_id'length)) &
			std_logic_vector(resize(mul(unsigned(gain_chanid),3)+var_vtoffsetid+2, var_id'length)),
			cga_frm);
			
		hz_scalevalue <= std_logic_vector(scale_1245(resize(hz_frac, hz_scalevalue'length), hz_scale));
		vt_scalevalue <= std_logic_vector(scale_1245(resize(vt_frac, vt_scalevalue'length), vt_scale));
		var_binvalue <= wirebus(
			std_logic_vector(resize(unsigned(hz_slider),      var_binvalue'length)) & 
			std_logic_vector(resize(unsigned(hz_scalevalue),  var_binvalue'length)) &
			std_logic_vector(resize(unsigned(trigger_level),  var_binvalue'length)) &
			std_logic_vector(resize(unsigned(vt_offset),      var_binvalue'length)) &
			std_logic_vector(resize(unsigned(vt_scalevalue),  var_binvalue'length)),
			cgabcd_frm);
				 	
		var_expvalue <= wirebus(
			std_logic_vector'(x"b")   & 
			std_logic_vector(hz_exp)  &
			std_logic_vector'(x"b")   &
			std_logic_vector'(x"b")   &
			std_logic_vector(vt_exp),
			cgabcd_frm);
				 	
		var_strvalue <= wirebus(
			word2byte(to_ascii("munp"), hz_scale,       ascii'length) &
			word2byte(x"1819",          trigger_edge)                 &
			word2byte(to_ascii(" *"),   trigger_freeze)               &
			word2byte(to_ascii("munp"), vt_scale,       ascii'length) &
			word2byte(to_ascii("munp"), vt_scale,       ascii'length),
			cgastr_frm);

	end block;

	cgabcd_end <= btof_binfrm and btof_bcdtrdy and btof_bcdend;
	frmbcd_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if btof_binfrm='1' then
				if btof_bcdtrdy='1' then
					if btof_bcdend='1' then
						btof_binfrm  <= '0';
						btof_bcdirdy <= '0';
					end if;
				end if;
			elsif cgabcd_frm/=(cgabcd_frm'range => '0') then
				btof_binfrm  <= '1';
				btof_bcdirdy <= '1';
				frac <= scale_1245(signed(var_binvalue), scale);
				exp  <= signed(var_expvalue);
			end if;
		end if;
	end process;

	scopeio_float2btof_e : entity hdl4fpga.scopeio_float2btof
	port map (
		clk      => rgtr_clk,
		frac     => frac,
		exp      => exp,
		bin_frm  => btof_binfrm,
		bin_irdy => btof_binirdy,
		bin_trdy => btof_bintrdy,
		bin_neg  => btof_binneg,
		bin_exp  => btof_binexp,
		bin_di   => btof_bindi);

	btof_bcdalign <= setif(text_style(var_id, analog_addr, cga_cols, cga_rows).align=left_alignment);
	btof_bcdsign  <= '1';
	btof_bcdprec  <= b"1110";
	btof_bcdunit  <= b"0000";
	btof_bcdwidth <= std_logic_vector(to_unsigned(text_style(var_id, analog_addr, cga_cols, cga_rows).width, 4));

	frmstr_p :
	cgastr_end <= setif(cga_we='1' and cgastr_frm/=(cgastr_frm'range => '0'));

	cga_addr_p : process (rgtr_clk)
		variable addr : std_logic_vector(0 to cga_addr'length);
	begin
		if rising_edge(rgtr_clk) then
			if cga_frm=(cga_frm'range => '0') then
				cgaaddr_init <= '1';
				cga_addr <= (others => '-');
				cga_av   <= '0';
			elsif cgaaddr_init='1' then
				cgaaddr_init <= '0';
				addr     := text_addr(var_id, analog_addr, cga_cols, cga_rows);
				cga_av   <= addr(0);
				cga_addr <= unsigned(addr(1 to cga_addr'length));
			elsif cga_we='1' then
				cga_addr <= cga_addr + 1;
			end if;
		end if;
	end process;

	cga_we <=
		cga_av when btof_binfrm='1' and btof_bcdtrdy='1'  else
		cga_av when cgastr_frm/=(cgastr_frm'range => '0') else
		'0';

	cga_code <= word2byte(
		word2byte(to_ascii("0123456789 .+-"), btof_bcddo, ascii'length) &
		var_strvalue,
		val_type);

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl font_hbits, textbox_width(layout)/font_width) +
		(unsigned(video_hcntr) srl font_wbits),
		video_addr'length));

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		cga_bitrom  => text_content(analog_addr, cga_cols, cga_rows, lang),
		font_bitrom => font_bitrom,
		font_height => font_height,
		font_width  => font_width)
	port map (
		cga_clk     => rgtr_clk,
		cga_we      => cga_we,
		cga_addr    => std_logic_vector(cga_addr),
		cga_data    => cga_code,

		video_clk   => video_clk,
		video_addr  => video_addr,
		font_hcntr  => video_hcntr(font_wbits-1 downto 0),
		font_vcntr  => video_vcntr(font_hbits-1 downto 0),
		video_hon   => text_on,
		video_dot   => char_dot);

	lat_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => latency-cgaadapter_latency))
	port map (
		clk => video_clk,
		di(0) => char_dot,
		do(0) => text_dot);
end;
