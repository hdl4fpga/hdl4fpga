library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.textboxpkg.all;
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
		hz_unit       : real;
		vt_unit       : real);
	port (
		rgtr_clk      : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		gain_ena      : in  std_logic;
		gain_dv       : in  std_logic;
		gain_cid      : in  std_logic_vector;
		gain_ids      : in  std_logic_vector;

		time_ena      : in  std_logic;
		time_scale    : in  std_logic_vector;
		time_offset   : in  std_logic_vector;

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
	constant font_width    : natural := layout.textbox_fontwidth;
end;

architecture def of scopeio_textbox is

	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant cgaadapter_latency : natural := 4;

	constant fontwidth_bits  : natural    := unsigned_num_bits(font_width-1);
	constant fontheight_bits  : natural    := unsigned_num_bits(font_height-1);
	constant textwidth_bits : natural := unsigned_num_bits(textbox_width(layout)-1);
	constant cga_cols    : natural    := textbox_width(layout)/font_width;
	constant cga_rows    : natural    := textbox_height(layout)/font_height;
	constant cga_size    : natural    := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);

	constant tags : tag_vector := render_tags(
		analogreadings(
			style  => styles(width(cga_cols) & alignment(right_alignment)),
	   		inputs => inputs));

	constant cga_bitrom  : std_logic_vector := to_ascii(render_content(
		analogreadings(
			style  => styles(width(cga_cols) & alignment(right_alignment)),
			inputs => inputs),
		cga_size));

	signal cgaaddr_init  : std_logic;
	signal cga_av        : std_logic;
	signal cgabcd_req    : std_logic_vector(0 to 5-1);
	signal cgabcd_frm    : std_logic_vector(cgabcd_req'range);
	signal cgabcd_end    : std_logic;
	signal cgachr_req    : std_logic_vector(0 to 5-1);
	signal cgachr_frm    : std_logic_vector(cgachr_req'range);
	signal cgachr_end    : std_logic;
	signal cga_req       : std_logic_vector(0 to cgabcd_req'length+cgachr_req'length-1);
	signal cga_frm       : std_logic_vector(cga_req'range);
	signal cga_we        : std_logic;
	signal cga_addr      : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code      : ascii;
	signal video_addr    : std_logic_vector(cga_addr'range);
	signal char_dot      : std_logic;

	signal frac          : signed(0 to 12-1);
	signal exp           : signed(btof_bindi'range);
	signal scale         : std_logic_vector(0 to 2-1) := "00";

	signal vtdiv_memaddr : std_logic_vector(cga_addr'range);
	signal vtoffset_memaddr : std_logic_vector(cga_addr'range);
	signal vtmag_memaddr : std_logic_vector(cga_addr'range);

	signal bcd_type      : std_logic;
	signal bcd_binvalue  : std_logic_vector(frac'range);
	signal bcd_expvalue  : std_logic_vector(btof_bindi'range);
	signal bcd_precvalue : std_logic_vector(4-1 downto 0);
	signal bcd_unitvalue : std_logic_vector(4-1 downto 0);
	signal bcd_width     : natural;
	signal bcd_alignment : std_logic_vector(0 to 0);
	signal bcd_memaddr   : std_logic_vector(cga_addr'range);

	signal chr_value     : ascii;
	signal chr_memaddr   : std_logic_vector(cga_addr'range);

	signal tag_memaddr   : std_logic_vector(cga_addr'range);

begin

	rgtr_b : block

		signal trigger_ena    : std_logic;
		signal trigger_freeze : std_logic;
		signal trigger_edge   : std_logic;
		signal trigger_chanid : std_logic_vector(chanid_bits-1 downto 0);
		signal trigger_level  : std_logic_vector(storage_word'range);

		signal chan_id        : std_logic_vector(chanid_maxsize-1 downto 0);
		signal vt_exp         : signed(btof_bindi'range);
		signal vt_dv          : std_logic;
		signal vt_ena         : std_logic;
		signal vt_offset      : std_logic_vector((5+8)-1 downto 0);
		signal vt_offsets     : std_logic_vector(0 to inputs*vt_offset'length-1);
		signal vt_chanid      : std_logic_vector(chan_id'range);
		signal vt_scale       : std_logic_vector(4-1 downto 0);

		signal hz_exp         : signed(btof_bindi'range);

	function get_multps (
		constant floats : siofloat_vector)
		return natural_vector is
		constant precs : natural_vector := get_precs(floats);
		variable point : natural;
		variable multp : natural;
		variable rval  : natural_vector(0 to 16-1);
	begin
		for i in floats'range loop
			rval(i) := floats(i).multp + (precs(i) / 3);
		end loop;
		for i in 1 to 4-1 loop
			for j in 0 to 4-1 loop
				rval(4*i+j) := 
					(3*floats(j).multp+floats(j).point+i)/3 + 
					precs(4*i+j) / 3;
			end loop;
		end loop;
		return rval;
	end;

		constant hz_float1245  : siofloat_vector := get_float1245(hz_unit);
		constant hz_precs      : natural_vector := get_precs(hz_float1245);
		constant hz_units      : integer_vector := get_units(hz_float1245);
		constant hz_multps     : natural_vector := get_multps(hz_float1245);

		constant hzfrac_length : natural := unsigned_num_bits(hz_float1245(0).frac)+3;
		signal   hz_frac       : unsigned(0 to hzfrac_length-1);
		signal   hz_scalevalue : std_logic_vector(hz_frac'range);
		signal   hz_multp      : std_logic_vector(0 to 3-1);

		constant vt_float1245  : siofloat_vector := get_float1245(vt_unit);
		constant vt_precs      : natural_vector := get_precs(vt_float1245);
		constant vt_units      : integer_vector := get_units(vt_float1245);
		constant vt_multps     : natural_vector := get_multps(vt_float1245);

		constant vtfrac_length : natural := unsigned_num_bits(vt_float1245(0).frac)+3;
		signal   vt_frac       : unsigned(0 to vtfrac_length-1);
		signal   vt_scalevalue : std_logic_vector(vt_frac'range);
		signal   vt_multp      : std_logic_vector(0 to 3-1);

	begin

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

			vtoffsets_p : process(rgtr_clk)
			begin
				if rising_edge(rgtr_clk) then
					if vt_ena='1' then
						vt_chanid  <= chanid;
						vt_offsets <= byte2word(vt_offsets, chanid, offset);
					end if;
				end if;
			end process;
		end block;

		chainid_p : process (rgtr_clk)
		begin
			if rising_edge(rgtr_clk) then
				if vt_dv='1' then
					chan_id <= vt_chanid;
				elsif gain_dv='1' then
					chan_id <= std_logic_vector(resize(unsigned(gain_cid),chan_id'length));
				end if;
			end if;
		end process;
		vt_offset <= word2byte(vt_offsets, chan_id, vt_offset'length);
		vt_scale  <= word2byte(gain_ids,   chan_id, vt_scale'length);

		process (rgtr_clk)
			variable bcd_req  : std_logic_vector(cgabcd_req'range);
			variable char_req : std_logic_vector(cgachr_req'range);
		begin
			if rising_edge(rgtr_clk) then
				bcd_req := cgabcd_req or (
					0 => time_ena,
					1 => time_ena,
					2 => trigger_ena,
					3 => vt_dv or gain_ena,
					4 => gain_ena);
				cgabcd_req <= bcd_req and not (cgabcd_frm and (cgabcd_frm'range => cgabcd_end));

				char_req := cgachr_req or (
					0 => time_ena,
					1 => trigger_ena,
					2 => trigger_ena,
					3 => trigger_ena,
					4 => gain_ena);
				cgachr_req <= char_req and not (cgachr_frm and (cgachr_frm'range => cgachr_end));
			end if;
		end process;
		bcd_type <= setif(cgabcd_req/=(cgabcd_req'range => '0'));

		cga_req <= cgabcd_req & cgachr_req;
		cga_arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk     => rgtr_clk,
			bus_req => cga_req,
			bus_gnt => cga_frm);
		cgabcd_frm  <= cga_frm(0 to cgabcd_frm'length-1);
		cgachr_frm <= cga_frm(cgabcd_frm'length to cgachr_frm'length+cgabcd_frm'length-1);

		bcd_width <= wirebus (
			width(tagbyid(tags, "hz.offset"   )) &
			width(tagbyid(tags, "hz.div"      )) &
			width(tagbyid(tags, "tgr.level"   )) &
			width(tagbyid(tags, "vt(0).offset")) &
			width(tagbyid(tags, "vt(0).div"   )),
			cgabcd_frm);

		vtoffsetmemaddr_p : process (chan_id)
		begin
			vtoffset_memaddr <= (others => '-');
			for i in 0 to inputs-1 loop
				if i=to_integer(unsigned(chan_id)) then
					vtoffset_memaddr <= memaddr(tagbyid(tags, "vt(" & itoa(i)  & ").offset"), vtoffset_memaddr'length);
				end if;
			end loop;
		end process;

		vtdivmemaddr_p : process (chan_id)
		begin
			vtdiv_memaddr <= (others => '-');
			for i in 0 to inputs-1 loop
				if i=to_integer(unsigned(chan_id)) then
					vtdiv_memaddr <= memaddr(tagbyid(tags, "vt(" & itoa(i)  & ").div"), vtdiv_memaddr'length);
				end if;
			end loop;
		end process;

		vtmagmemaddr_p: process (chan_id)
		begin
			vtmag_memaddr <= (others => '-');
			for i in 0 to inputs-1 loop
				if i=to_integer(unsigned(chan_id)) then
					vtmag_memaddr <= memaddr(tagbyid(tags, "vt(" & itoa(i)  & ").mag"), vtmag_memaddr'length);
				end if;
			end loop;
		end process;

		hz_frac <= to_unsigned(hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).frac, hz_frac'length);
		vt_frac <= to_unsigned(vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).frac,   vt_frac'length);

		hz_exp  <= to_signed(hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).exp, hz_exp'length);
		vt_exp  <= to_signed(vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).exp, vt_exp'length);

		hz_scalevalue <= std_logic_vector(to_unsigned(hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).frac, hz_scalevalue'length));
		vt_scalevalue <= std_logic_vector(to_unsigned(vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).frac, vt_scalevalue'length));

		bcd_binvalue <= wirebus(
			std_logic_vector(resize(mul(signed(time_offset), hz_frac),   bcd_binvalue'length)) &
			std_logic_vector(resize(unsigned(hz_scalevalue),             bcd_binvalue'length)) &
			std_logic_vector(resize(mul(signed(trigger_level), vt_frac), bcd_binvalue'length)) &
			std_logic_vector(resize(mul(signed(vt_offset), vt_frac),     bcd_binvalue'length)) &
			std_logic_vector(resize(unsigned(vt_scalevalue),             bcd_binvalue'length)),
			cgabcd_frm);
				 	
		bcd_expvalue <= wirebus(
			std_logic_vector(hz_exp+signed'(x"b")) & 
			std_logic_vector(hz_exp)               &
			std_logic_vector(vt_exp+signed'(x"b")) &
			std_logic_vector(vt_exp+signed'(x"b")) &
			std_logic_vector(vt_exp),
			cgabcd_frm);
				 	
		bcd_unitvalue <= wirebus(
			std_logic_vector(to_signed(hz_units(to_integer(unsigned(time_scale))), bcd_unitvalue'length)) &
			std_logic_vector(to_signed(hz_units(to_integer(unsigned(time_scale))), bcd_unitvalue'length)) &
			std_logic_vector(to_signed(vt_units(to_integer(unsigned(vt_scale))),   bcd_unitvalue'length)) &
			std_logic_vector(to_signed(vt_units(to_integer(unsigned(vt_scale))),   bcd_unitvalue'length)) &
			std_logic_vector(to_signed(vt_units(to_integer(unsigned(vt_scale))),   bcd_unitvalue'length)),
			cgabcd_frm);

		bcd_precvalue <= wirebus(
			std_logic_vector(to_signed(-hz_precs(to_integer(unsigned(time_scale))), bcd_precvalue'length)) &
			std_logic_vector(to_signed(-hz_precs(to_integer(unsigned(time_scale))), bcd_precvalue'length)) &
			std_logic_vector(to_signed(-vt_precs(to_integer(unsigned(vt_scale))),   bcd_precvalue'length)) &
			std_logic_vector(to_signed(-vt_precs(to_integer(unsigned(vt_scale))),   bcd_precvalue'length)) &
			std_logic_vector(to_signed(-vt_precs(to_integer(unsigned(vt_scale))),   bcd_precvalue'length)),
			cgabcd_frm);

		bcd_alignment <= wirebus (
			setif(left_alignment=alignment(tagbyid(tags, "hz.offset"   ))) &
			setif(left_alignment=alignment(tagbyid(tags, "hz.div"      ))) &
			setif(left_alignment=alignment(tagbyid(tags, "tgr.level"   ))) &
			setif(left_alignment=alignment(tagbyid(tags, "vt(0).offset"))) &
			setif(left_alignment=alignment(tagbyid(tags, "vt(0).div"   ))),
			cgabcd_frm);
		btof_bcdalign <= bcd_alignment(0);

		bcd_memaddr <= wirebus (
			memaddr(tagbyid(tags, "hz.offset"), bcd_memaddr'length) &
			memaddr(tagbyid(tags, "hz.div"   ), bcd_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.level"), bcd_memaddr'length) &
			vtoffset_memaddr                                        &
			vtdiv_memaddr,
			cgabcd_frm);

		hz_multp <= std_logic_vector(to_unsigned(hz_multps(to_integer(unsigned(time_scale))), hz_multp'length));
		vt_multp <= std_logic_vector(to_unsigned(vt_multps(to_integer(unsigned(vt_scale))),   vt_multp'length));
		chr_value <= wirebus(
			word2byte(to_ascii("fpn") & x"e6" &to_ascii("m"), hz_multp,       ascii'length) &
			word2byte(x"1819",                                trigger_edge)                 &
			word2byte(to_ascii(" *"),                         trigger_freeze)               &
			word2byte(to_ascii("fpn") & x"e6" &to_ascii("m"), vt_multp,       ascii'length) &
			word2byte(to_ascii("fpn") & x"e6" &to_ascii("m"), vt_multp,       ascii'length),
			cgachr_frm);

		chr_memaddr <= wirebus (
			memaddr(tagbyid(tags, "hz.mag"),     chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.edge"),   chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.freeze"), chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.mag"),    chr_memaddr'length) &
			vtmag_memaddr,
			cgachr_frm);

		tag_memaddr <= wirebus (
			memaddr(tagbyid(tags, "hz.offset"),  tag_memaddr'length) &
			memaddr(tagbyid(tags, "hz.div"   ),  tag_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.level"),  tag_memaddr'length) &
			vtoffset_memaddr                                         &
			vtdiv_memaddr                                            &

			memaddr(tagbyid(tags, "hz.mag"),     tag_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.edge"),   tag_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.freeze"), tag_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.mag"),    tag_memaddr'length) &
			vtmag_memaddr,
			cga_frm);

--		tag_memaddr <= word2byte (
--			bcd_memaddr &
--			chr_memaddr,
--			not bcd_type);

	end block;

	cgabcd_end <= btof_binfrm and btof_bcdtrdy and btof_bcdend;
	frmbcd_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if btof_binfrm='1' then
				if btof_bcdtrdy='1' then
					if btof_bcdend='1' then
						btof_binfrm  <= '0';
					end if;
				end if;
			elsif cgabcd_frm/=(cgabcd_frm'range => '0') then
				btof_binfrm   <= '1';
				btof_bcdsign  <= '1';
				btof_bcdprec  <= bcd_precvalue;
				btof_bcdunit  <= bcd_unitvalue;
				btof_bcdwidth <= std_logic_vector(to_unsigned(bcd_width, btof_bcdwidth'length));

				frac <= scale_1245(signed(bcd_binvalue), scale);
				exp  <= signed(bcd_expvalue);
			end if;
		end if;
	end process;
	btof_bcdirdy <= btof_binfrm;

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

	frmchar_p :
	cgachr_end <= setif(cga_we='1' and cgachr_frm/=(cgachr_frm'range => '0'));

	cga_addr_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if cga_frm=(cga_frm'range => '0') then
				cgaaddr_init <= '1';
				cga_addr <= (others => '-');
				cga_av   <= '0';
			elsif cgaaddr_init='1' then
				cgaaddr_init <= '0';
				cga_av   <= '1';
				cga_addr <= unsigned(tag_memaddr);
			elsif cga_we='1' then
				cga_addr <= cga_addr + 1;
			end if;
		end if;
	end process;

	cga_we <=
		cga_av when btof_binfrm='1' and btof_bcdtrdy='1'  else
		cga_av when cgachr_frm/=(cgachr_frm'range => '0') else
		'0';

	cga_code <= word2byte(
		word2byte(to_ascii("0123456789 .+-  "), btof_bcddo, ascii'length) &
		chr_value,
		not bcd_type);

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl fontheight_bits, textbox_width(layout)/font_width) +
		(unsigned(video_hcntr(textwidth_bits-1 downto 0)) srl fontwidth_bits),
		video_addr'length));

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		cga_bitrom  => cga_bitrom,
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
		font_hcntr  => video_hcntr(fontwidth_bits-1 downto 0),
		font_vcntr  => video_vcntr(fontheight_bits-1 downto 0),
		video_blankn   => text_on,
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
