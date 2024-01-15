library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.jso.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.textboxpkg.all;
use hdl4fpga.cgafonts.all;

entity scopeio_textbox is
	generic(
		inputs        : natural;
		input_names   : tag_vector;
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
		sgmntbox_ena  : in  std_logic_vector;
		text_on       : in  std_logic := '1';
		text_fg       : out std_logic_vector;
		text_bg       : out std_logic_vector;
		text_fgon     : out std_logic);

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant font_width    : natural := jso(layout)**".textbox.font_width";

	constant hz_unit : real := jso(layout)**".axis.horizontal.unit";
	constant vt_unit : real := jso(layout)**".axis.vertical.unit";
end;

architecture def of scopeio_textbox is

	subtype ascii is std_logic_vector(8-1 downto 0);
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant division_bits : natural := unsigned_num_bits(grid_unit(layout)-1);
	constant cgaadapter_latency : natural := 4;

	constant fontwidth_bits  : natural    := unsigned_num_bits(font_width-1);
	constant fontheight_bits  : natural    := unsigned_num_bits(font_height-1);
	constant textwidth_bits : natural := unsigned_num_bits(textbox_width(layout)-1);
	constant cga_cols    : natural    := textbox_width(layout)/font_width;
	constant cga_rows    : natural    := textbox_height(layout)/font_height;
	constant cga_size    : natural    := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);

	constant tags : tag_vector := render_tags(
		analogreadings(
			style  => styles(
				width(cga_cols) & alignment(right_alignment) &
				text_palette(pltid_textfg) & bg_palette(pltid_textbg)),
			input_names => input_names,
	   		inputs => inputs));

	constant cga_bitrom  : std_logic_vector := to_ascii(render_content(
		analogreadings(
			style  => styles(width(cga_cols) & alignment(right_alignment)),
			input_names => input_names,
			inputs => inputs),
		cga_size));

	function addr_attr (
		constant table : attr_table;
		constant addr  : std_logic_vector)
		return natural
	is
		variable retval : natural;
	begin
		retval := 0; --table(table'left).attr;
		for i in table'range loop
			if unsigned(addr) >= table(i).addr then
				-- report "*****************  " & itoa(table(i).attr);
				retval := table(i).attr;
			end if;
		end loop;
		return retval;
	end;

	signal cgaaddr_init  : std_logic;
	signal cga_av        : std_logic;
	signal cgabcd_req    : std_logic_vector(0 to 4+5-1);
	signal cgabcd_frm    : std_logic_vector(cgabcd_req'range);
	signal cgabcd_end    : std_logic;
	signal cgachr_req    : std_logic_vector(0 to 5-1);
	signal cgachr_frm    : std_logic_vector(cgachr_req'range);
	signal cgachr_end    : std_logic;
	signal cga_req       : std_logic_vector(0 to cgabcd_req'length+cgachr_req'length-1);
	signal cga_frm       : std_logic_vector(cga_req'range);
	signal cga_we        : std_logic;
	signal cga_on        : std_logic;
	signal cga_addr      : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code      : ascii;
	signal video_addr    : std_logic_vector(cga_addr'range);
	signal char_dot      : std_logic;

	signal frac          : signed(0 to 4*4-1);
	signal exp           : signed(btof_bindi'range);
	signal scale         : std_logic_vector(0 to 2-1) := "00";

	signal vtdiv_memaddr : std_logic_vector(cga_addr'range);
	signal vtoffset_memaddr : std_logic_vector(cga_addr'range);
	signal vtmag_memaddr : std_logic_vector(cga_addr'range);

	signal bcd_type      : std_logic;
	signal bcd_binvalue  : std_logic_vector(frac'range);
	signal bcd_expvalue  : integer;                      -- Xilnx's ISE workaround data type;
	signal bcd_sign      : std_logic_vector(0 to 0);     -- Xilnx's ISE workaround data type;
	signal bcd_precvalue : integer;                      -- Xilnx's ISE workaround data type;
	signal bcd_unitvalue : integer;                      -- Xilnx's ISE workaround data type;
	signal bcd_width     : natural;                      -- Xilnx's ISE workaround data type;
	signal bcd_alignment : std_logic_vector(0 to 0);
	signal bcd_memaddr   : std_logic_vector(cga_addr'range);

	signal chr_value     : ascii;
	signal chr_memaddr   : std_logic_vector(cga_addr'range);

	signal tag_memaddr   : std_logic_vector(cga_addr'range);

	signal textfg       : std_logic_vector(text_fg'range);
	signal textbg       : std_logic_vector(text_bg'range);
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
		signal tgr_exp        : integer;

		signal chan_id        : std_logic_vector(chanid_maxsize-1 downto 0);
		signal vt_exp         : integer;
		signal vt_dv          : std_logic;
		signal vt_ena         : std_logic;
		signal vt_offset      : std_logic_vector((5+8)-1 downto 0);
		signal vt_offsets     : std_logic_vector(0 to inputs*vt_offset'length-1);
		signal vt_chanid      : std_logic_vector(chan_id'range);
		signal vt_scale       : std_logic_vector(4-1 downto 0);
		signal tgr_scale      : std_logic_vector(4-1 downto 0);

		signal hz_exp         : integer;

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

		constant hz_float1245  : siofloat_vector := get_float1245(hz_unit*1.0e15);
		constant hz_precs      : natural_vector := get_precs(hz_float1245);
		constant hz_units      : integer_vector := get_units(hz_float1245);
		constant hz_multps     : natural_vector := get_multps(hz_float1245);

		constant hzfrac_length : natural := max(unsigned_num_bits(hz_float1245(0).frac),5);
		signal   hz_frac       : unsigned(0 to hzfrac_length-1);
		signal   hz_scalevalue : natural;
		signal   hz_multp      : std_logic_vector(0 to 3-1);

		constant vt_float1245  : siofloat_vector := get_float1245(vt_unit*1.0e15);
		constant vt_precs      : natural_vector := get_precs(vt_float1245);
		constant vt_units      : integer_vector := get_units(vt_float1245);
		constant vt_multps     : natural_vector := get_multps(vt_float1245);

		constant vtfrac_length : natural := max(unsigned_num_bits(vt_float1245(0).frac),5);
		signal   vt_frac       : unsigned(0 to vtfrac_length-1);
		signal   tgr_frac      : unsigned(0 to vtfrac_length-1);
		signal   vt_scalevalue : natural;
		signal   vt_multp      : std_logic_vector(0 to 3-1);
		signal   tgr_multp     : std_logic_vector(0 to 3-1);

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
		vt_offset <= multiplex(vt_offsets, chan_id,        vt_offset'length);
		vt_scale  <= multiplex(gain_ids,   chan_id,        vt_scale'length);
		tgr_scale <= multiplex(gain_ids,   trigger_chanid, tgr_scale'length);

		process (rgtr_clk)
			variable bcd_req  : std_logic_vector(cgabcd_req'range);
			variable char_req : std_logic_vector(cgachr_req'range);
		begin
			if rising_edge(rgtr_clk) then
				bcd_req := cgabcd_req or (
					0 => myip_ena,
					1 => myip_ena,
					2 => myip_ena,
					3 => myip_ena,
					4 => time_ena,
					5 => time_ena,
					6 => trigger_ena or vt_dv or gain_ena,
					7 => vt_dv or gain_ena,
					8 => gain_ena);
				cgabcd_req <= bcd_req and not (cgabcd_frm and (cgabcd_frm'range => cgabcd_end));

				char_req := cgachr_req or (
					0 => time_ena,
					1 => trigger_ena,
					2 => trigger_ena,
					3 => trigger_ena or vt_dv or gain_ena,
					4 => gain_ena);
				cgachr_req <= char_req and not (cgachr_frm and (cgachr_frm'range => cgachr_end));
			end if;
		end process;
		bcd_type <= setif(cgabcd_req/=(cgabcd_req'range => '0'));

		cga_req <= cgabcd_req & cgachr_req;
		cga_arbiter_e : entity hdl4fpga.arbiter
		port map (
			clk => rgtr_clk,
			req => cga_req,
			gnt => cga_frm);
		cgabcd_frm  <= cga_frm(0 to cgabcd_frm'length-1);
		cgachr_frm <= cga_frm(cgabcd_frm'length to cgachr_frm'length+cgabcd_frm'length-1);

		bcd_width <= wirebus (natural_vector'(
			width(tagbyid(tags, "ip4.num1"    )),
			width(tagbyid(tags, "ip4.num2"    )),
			width(tagbyid(tags, "ip4.num3"    )),
			width(tagbyid(tags, "ip4.num4"    )),
			width(tagbyid(tags, "hz.offset"   )),
			width(tagbyid(tags, "hz.div"      )),
			width(tagbyid(tags, "tgr.level"   )),
			width(tagbyid(tags, "vt(0).offset")),
			width(tagbyid(tags, "vt(0).div"   ))),
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

		hz_frac  <= to_unsigned(hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).frac, hz_frac'length);
		vt_frac  <= to_unsigned(vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).frac,   vt_frac'length);
		tgr_frac <= to_unsigned(vt_float1245(to_integer(unsigned(tgr_scale(2-1 downto 0)))).frac,  tgr_frac'length);

		hz_exp  <= hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).exp;
		vt_exp  <= vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).exp;
		tgr_exp <= vt_float1245(to_integer(unsigned(tgr_scale(2-1 downto 0)))).exp;

		hz_scalevalue <= hz_float1245(to_integer(unsigned(time_scale(2-1 downto 0)))).frac;
		vt_scalevalue <= vt_float1245(to_integer(unsigned(vt_scale(2-1 downto 0)))).frac;

		bcd_binvalue <= wirebus(
			std_logic_vector(resize(unsigned(myip_num1),      bcd_binvalue'length))  &
			std_logic_vector(resize(unsigned(myip_num2),      bcd_binvalue'length))  &
			std_logic_vector(resize(unsigned(myip_num3),      bcd_binvalue'length))  &
			std_logic_vector(resize(unsigned(myip_num4),      bcd_binvalue'length))  &
			std_logic_vector(resize(mul(signed(time_offset), hz_frac),   bcd_binvalue'length))      &
			std_logic_vector(to_unsigned(hz_scalevalue,                  bcd_binvalue'length))      &
			std_logic_vector(resize(mul(-signed(trigger_level), tgr_frac), bcd_binvalue'length))      &
			std_logic_vector(resize(mul(signed(vt_offset), vt_frac),     bcd_binvalue'length))      &
			std_logic_vector(to_unsigned(vt_scalevalue,                  bcd_binvalue'length)),
			cgabcd_frm);
				 	
		bcd_expvalue <= wirebus(integer_vector'(
			0, 0, 0, 0,
			hz_exp-division_bits,
			hz_exp,
			tgr_exp-division_bits,
			vt_exp-division_bits,
			vt_exp),
			cgabcd_frm);
				 	
		bcd_unitvalue <= wirebus(integer_vector'(
			0, 0, 0, 0,
			hz_units(to_integer(unsigned(time_scale))),
			hz_units(to_integer(unsigned(time_scale))),
			vt_units(to_integer(unsigned(tgr_scale))), 
			vt_units(to_integer(unsigned(vt_scale))),
			vt_units(to_integer(unsigned(vt_scale)))),
			cgabcd_frm);

		bcd_precvalue <= wirebus(integer_vector'(
			0, 0, 0, 0,
			-hz_precs(to_integer(unsigned(time_scale))),
			-hz_precs(to_integer(unsigned(time_scale))),
			-vt_precs(to_integer(unsigned(tgr_scale))),  
			-vt_precs(to_integer(unsigned(vt_scale))),  
			-vt_precs(to_integer(unsigned(vt_scale)))),  
			cgabcd_frm);

		bcd_sign <= wirebus(std_logic_vector'(
			'0',
			'0',
			'0',
			'0',
			'1',
			'1',
			'1',
			'1',
			'1'),
			cgabcd_frm);

		bcd_alignment <= wirebus (std_logic_vector'(
			setif(left_alignment=alignment(tagbyid(tags, "ip4.num1"    ))),
			setif(left_alignment=alignment(tagbyid(tags, "ip4.num2"    ))),
			setif(left_alignment=alignment(tagbyid(tags, "ip4.num3"    ))),
			setif(left_alignment=alignment(tagbyid(tags, "ip4.num4"    ))),
			setif(left_alignment=alignment(tagbyid(tags, "hz.offset"   ))),
			setif(left_alignment=alignment(tagbyid(tags, "hz.div"      ))),
			setif(left_alignment=alignment(tagbyid(tags, "tgr.level"   ))),
			setif(left_alignment=alignment(tagbyid(tags, "vt(0).offset"))),
			setif(left_alignment=alignment(tagbyid(tags, "vt(0).div"   )))),
			cgabcd_frm);
		btof_bcdalign <= bcd_alignment(0);

		bcd_memaddr <= wirebus (
			memaddr(tagbyid(tags, "ip4.num1"),  bcd_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num2"),  bcd_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num3"),  bcd_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num4"),  bcd_memaddr'length) &
			memaddr(tagbyid(tags, "hz.offset"), bcd_memaddr'length) &
			memaddr(tagbyid(tags, "hz.div"   ), bcd_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.level"), bcd_memaddr'length) &
			vtoffset_memaddr                                        &
			vtdiv_memaddr,
			cgabcd_frm);

		hz_multp  <= std_logic_vector(to_unsigned(hz_multps(to_integer(unsigned(time_scale))), hz_multp'length));
		vt_multp  <= std_logic_vector(to_unsigned(vt_multps(to_integer(unsigned(vt_scale))),   vt_multp'length));
		tgr_multp <= std_logic_vector(to_unsigned(vt_multps(to_integer(unsigned(tgr_scale))),  tgr_multp'length));

		chr_value <= wirebus(
			std_logic_vector'(multiplex(to_ascii("fpn") & x"e6" &to_ascii("m "), hz_multp,       ascii'length)) &
			std_logic_vector'(multiplex(x"1819",                                trigger_slope))                 &
			std_logic_vector'(multiplex(to_ascii(" *"),                         trigger_freeze))                &
			std_logic_vector'(multiplex(to_ascii("fpn") & x"e6" &to_ascii("m "), tgr_multp,      ascii'length)) &
			std_logic_vector'(multiplex(to_ascii("fpn") & x"e6" &to_ascii("m "), vt_multp,       ascii'length)),
			cgachr_frm);

		chr_memaddr <= wirebus (
			memaddr(tagbyid(tags, "hz.mag"),     chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.edge"),   chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.freeze"), chr_memaddr'length) &
			memaddr(tagbyid(tags, "tgr.mag"),    chr_memaddr'length) &
			vtmag_memaddr,
			cgachr_frm);

		tag_memaddr <= wirebus (
			memaddr(tagbyid(tags, "ip4.num1"),   tag_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num2"),   tag_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num3"),   tag_memaddr'length) &
			memaddr(tagbyid(tags, "ip4.num4"),   tag_memaddr'length) &
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
				btof_bcdsign  <= bcd_sign(0);
				btof_bcdprec  <= std_logic_vector(to_signed(bcd_precvalue, btof_bcdprec'length));
				btof_bcdunit  <= std_logic_vector(to_signed(bcd_unitvalue, btof_bcdunit'length));
				btof_bcdwidth <= std_logic_vector(to_unsigned(bcd_width,   btof_bcdwidth'length));

				frac <= signed(bcd_binvalue);
				exp  <= to_signed(bcd_expvalue, exp'length);
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

	process (video_clk)
		variable addr : std_logic_vector(video_addr'range);
	begin
		if rising_edge(video_clk) then
			textfg <= std_logic_vector(to_unsigned(addr_attr(tagattr_tab(tags, key_textpalette), addr), textfg'length));
			textbg <= std_logic_vector(to_unsigned(addr_attr(tagattr_tab(tags, key_bgpalette),   addr), textbg'length));
			addr := video_addr;
		end if;
	end process;

	cga_we <=
		cga_av when btof_binfrm='1' and btof_bcdtrdy='1'  else
		cga_av when cgachr_frm/=(cgachr_frm'range => '0') else
		'0';

	cga_code <= multiplex(
		multiplex(to_ascii("0123456789 .+-  "), btof_bcddo, ascii'length) &
		chr_value,
		not bcd_type);

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl fontheight_bits, textbox_width(layout)/font_width) +
		(unsigned(video_hcntr(textwidth_bits-1 downto 0)) srl fontwidth_bits),
		video_addr'length));

	cga_on <= text_on and sgmntbox_ena(0);
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
		cga_data     => cga_code,

		video_clk    => video_clk,
		video_addr   => video_addr,
		font_hcntr   => video_hcntr(unsigned_num_bits(font_width-1)-1 downto 0),
		font_vcntr   => video_vcntr(unsigned_num_bits(font_height-1)-1 downto 0),
		video_on     => cga_on,
		video_dot    => char_dot);

	lat_e : entity hdl4fpga.latency
	generic map (
		n => 1,
		d => (0 => latency-cgaadapter_latency))
	port map (
		clk => video_clk,
		di(0) => char_dot,
		do(0) => text_fgon);

	latfg_e : entity hdl4fpga.latency
	generic map (
		n =>  text_fg'length,
		d => (0 to text_fg'length-1 => latency-cgaadapter_latency+2))
	port map (
		clk => video_clk,
		di => textfg,
		do => text_fg);

	latbg_e : entity hdl4fpga.latency
	generic map (
		n => text_bg'length,
		d => (0 to text_bg'length-1 => latency-cgaadapter_latency+2))
	port map (
		clk => video_clk,
		di => textbg,
		do => text_bg);
end;
