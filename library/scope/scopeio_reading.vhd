
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_reading is
	generic (
		layout    : string);
	port (
		tp            : out std_logic_vector(1 to 32);
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		code_frm  : out std_logic := '0';
		video_row : out std_logic_vector;
		code_irdy : out std_logic := '0';
		code_data : out ascii);

	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay";
	constant min_storage   : natural := hdo(layout)**".min_storage";
	constant hz_unit       : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit       : real    := hdo(layout)**".axis.vertical.unit";
	constant grid_unit     : natural := hdo(layout)**".grid.unit";
	constant grid_height   : natural := hdo(layout)**".grid.height";

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant vt_labels     : string  := hdo(layout)**".vt";
	constant hz_label      : string  := "Time";

	constant vt_sfcnds     : natural_vector := get_significand1245(vt_unit);
	constant vt_shts       : integer_vector := get_shr1245(vt_unit);
	constant vt_pnts       : integer_vector := get_characteristic1245(vt_unit);
	constant vt_pfxs       : string         := get_prefix1235(vt_unit);

	constant hz_sfcnds     : natural_vector := get_significand1245(hz_unit);
	constant hz_shts       : integer_vector := get_shr1245(hz_unit);
	constant hz_pnts       : integer_vector := get_characteristic1245(hz_unit);

	constant sfcnd_length  : natural := max(unsigned_num_bits(max(vt_sfcnds)), unsigned_num_bits(max(hz_sfcnds)));

	constant bin_digits    : natural := 3;
	constant bcd_width     : natural := 8;
	constant bcd_length    : natural := 4;
	constant bcd_digits    : natural := 1;

end;

architecture def of scopeio_reading is

	signal vtscale_ena    : std_logic;
	signal vtl_scalecid   : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_cid         : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid     : std_logic_vector(4-1 downto 0);
	signal tbl_scaleid    : std_logic_vector(vt_scaleid'range);

	signal vtoffset_ena   : std_logic;
	signal vtl_offsetcid  : std_logic_vector(vt_cid'range);
	signal vtl_offset     : std_logic_vector((5+8)-1 downto 0);
	signal tbl_offset     : std_logic_vector(vtl_offset'range);
	signal vt_offset      : signed(vtl_offset'range);

	signal trigger_ena    : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_slope  : std_logic;
	signal trigger_chanid : std_logic_vector(vt_cid'range);
	signal trigger_level  : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

	signal hz_ena         : std_logic;
	signal hz_scaleid     : std_logic_vector(4-1 downto 0);
	signal hztl_offset    : std_logic_vector(hzoffset_bits-1 downto 0);

	signal txt_req        : std_logic;
	signal txt_rdy        : std_logic;
	signal scale          : unsigned(0 to sfcnd_length-1);
	signal offset         : signed(0 to max(vtl_offset'length, hztl_offset'length)-1);

	signal str_req        : std_logic;
	signal str_rdy        : std_logic;
	subtype wdtid_range is natural range 0 to (inputs+1)-1;
	signal wdt_id         : wdtid_range;
	signal wdt_row        : unsigned(0 to unsigned_num_bits(inputs+2-1)-1);

	signal btod_sht       : signed(4-1 downto 0);
	signal btod_dec       : signed(4-1 downto 0);
	signal vt_sht         : signed(4-1 downto 0);
	signal vt_dec         : signed(4-1 downto 0);
	signal vt_scale       : unsigned(scale'range);
	signal vt_wdtid       : wdtid_range;
	signal vt_wdtrow      : unsigned(wdt_row'range);
	signal vtwdt_req      : std_logic;
	signal vtwdt_rdy      : std_logic;

	signal tgr_sht        : signed(4-1 downto 0);
	signal tgr_dec        : signed(4-1 downto 0);
	signal tgr_cid        : std_logic_vector(trigger_chanid'range);
	signal tgr_scale      : unsigned(scale'range);
	signal tgr_offset     : signed(trigger_level'range);
	signal tgr_wdtid      : wdtid_range;
	signal tgr_wdtrow     : unsigned(wdt_row'range);
	signal tgrwdt_req     : std_logic;
	signal tgrwdt_rdy     : std_logic;

	signal hz_sht         : signed(4-1 downto 0);
	signal hz_dec         : signed(4-1 downto 0);
	signal hz_scale       : unsigned(scale'range);
	signal hz_offset      : signed(hztl_offset'range);
	signal hz_wdtid       : wdtid_range;
	signal hz_wdtrow      : unsigned(wdt_row'range);
	signal hzwdt_req      : std_logic;
	signal hzwdt_rdy      : std_logic;

	signal btod_req       : std_logic;
	signal btod_rdy       : std_logic;
	signal mul_req        : std_logic := '0';
	signal mul_rdy        : std_logic := '0';

	constant binary_length : natural := bin_digits*((offset'length+sfcnd_length+bin_digits-1)/bin_digits);
	signal binary         : std_logic_vector(0 to binary_length-1);
	signal btod_frm       : std_logic;
	signal btod_code      : ascii;
	signal str_frm        : std_logic;
	signal str_code       : ascii;
	signal axis_req       : std_logic := '0';
	signal axis_rdy       : std_logic := '0';
	signal tgr_req        : std_logic := '0';
	signal tgr_rdy        : std_logic := '0';
	signal mul_reqs       : std_logic_vector(0 to 1) := (others => '0');
	signal mul_rdys       : std_logic_vector(0 to 1) := (others => '0');
	signal btod_reqs      : std_logic_vector(0 to 1) := (others => '0');
	signal btod_rdys      : std_logic_vector(0 to 1) := (others => '0');
	signal str_reqs       : std_logic_vector(0 to 1) := (others => '0');
	signal str_rdys       : std_logic_vector(0 to 1) := (others => '0');

	signal b  : signed(0 to offset'length-1);
	type b_vector is array(0 to 1) of signed(b'range);
	signal bs : b_vector;

	constant axis_id : natural := 0;
	constant tgr_id  : natural := 1;

	signal sign : std_logic;
begin

	--  tp <= (others => '1');
		tp(1) <= txt_req;
		tp(2) <= txt_rdy;
		tp(3) <= vtwdt_req;
		tp(4) <= vtwdt_rdy;
	hzaxis_e : entity hdl4fpga.scopeio_rgtrhzaxis
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		hz_ena    => hz_ena,
		hz_scale  => hz_scaleid,
		hz_offset => hztl_offset);

	vtscale_e : entity hdl4fpga.scopeio_rgtrvtscale
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vtscale_ena => vtscale_ena,
		vtchan_id   => vtl_scalecid,
		vtscale_id  => vt_scaleid);

	vtoffset_e : entity hdl4fpga.scopeio_rgtrvtoffset
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtoffset_ena,
		vt_chanid => vtl_offsetcid,
		vt_offset => vtl_offset);

	tgr_e : entity hdl4fpga.scopeio_rgtrtrigger
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		trigger_ena    => trigger_ena,
		trigger_chanid => trigger_chanid,
		trigger_slope  => trigger_slope,
		trigger_freeze => trigger_freeze,
		trigger_level  => trigger_level);

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => vtl_offsetcid,
		wr_data => vtl_offset,
		rd_addr => vtl_scalecid,
		rd_data => tbl_offset);

	vt_cid <= 
		vtl_offsetcid  when vtoffset_ena='1' else 
		trigger_chanid when  trigger_ena='1' else 
		tgr_cid;

	vtgains_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => vtl_scalecid,
		wr_data => vt_scaleid,
		rd_addr => vt_cid,
		rd_data => tbl_scaleid);

	process (rgtr_clk)
		variable scaleid : natural range 0 to vt_shts'length-1;
		variable timeid  : natural range 0 to hz_shts'length-1;
		variable ref_req : bit;
		variable ref_rdy : bit;
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if vtscale_ena='1' then
					scaleid    := to_integer(unsigned(vt_scaleid));
					vt_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					vt_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					vt_offset  <= signed(tbl_offset);
					vt_wdtid   <= to_integer(unsigned(vtl_scalecid));
					vt_wdtrow  <= resize(unsigned(vtl_scalecid), vt_wdtrow'length)+2;
					ref_req    := not ref_rdy;
					vtwdt_req  <= not vtwdt_rdy;
				elsif vtoffset_ena='1' then
					scaleid    := to_integer(unsigned(tbl_scaleid));
					vt_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					vt_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					vt_offset  <= signed(vtl_offset);
					vt_wdtid   <= to_integer(unsigned(vtl_offsetcid));
					vt_wdtrow  <= resize(unsigned(vtl_offsetcid), vt_wdtrow'length)+2;
					ref_req    := not ref_rdy;
					vtwdt_req  <= not vtwdt_rdy;
				elsif trigger_ena='1' then
					tgr_cid     <= trigger_chanid;
					scaleid     := to_integer(unsigned(tbl_scaleid));
					tgr_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					tgr_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					tgr_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					tgr_offset  <= -signed(trigger_level);
					tgr_wdtid   <= to_integer(unsigned(trigger_chanid));
					tgr_wdtrow  <= to_unsigned(1, tgr_wdtrow'length);
					tgrwdt_req  <= not tgrwdt_rdy;
				elsif (ref_rdy xor ref_req)='1' then
					if (vtwdt_rdy xor vtwdt_req)='0' then
						scaleid     := to_integer(unsigned(tbl_scaleid));
						tgr_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
						tgr_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
						tgr_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
						tgr_wdtid   <= to_integer(unsigned(tgr_cid));
						tgr_wdtrow  <= to_unsigned(1, tgr_wdtrow'length);
						tgrwdt_req  <= not tgrwdt_rdy;
						ref_rdy     := ref_req;
					end if;
				end if;
				if hz_ena='1' then
					timeid     := to_integer(unsigned(hz_scaleid));
					hz_sht     <= to_signed(hz_shts(timeid), btod_sht'length);
					hz_dec     <= to_signed(hz_pnts(timeid), btod_dec'length);
					hz_scale   <= to_unsigned(hz_sfcnds(timeid mod 4), hz_scale'length);
					hz_offset  <= signed(hztl_offset);
					hz_wdtrow  <= to_unsigned(0, hz_wdtrow'length);
					hz_wdtid   <= inputs+0;
					hzwdt_req  <= not hzwdt_rdy;
				end if;
			end if;
		end if;
	end process;

	process (rgtr_dv, rgtr_clk)

		function textbase_init (
			constant vt_labels : string;
			constant width : natural := 0)
			return string is
			variable left   : natural;
			variable length : natural;
			variable data   : string(1 to vt_labels'length);
		begin
			left := data'left;
			for i in 0 to inputs-1 loop
				escaped(data((left+1) to data'length), length, escaped(hdo(vt_labels)**("["&natural'image(i)&"].text")));
				data(left) := character'val((length+1) mod (character'pos(character'high)+1));
				left := (left+1) + length;
			end loop;
			data((left+1) to (left+1)+hz_label'length-1) := hz_label;
			length := hz_label'length;
			data(left) := character'val((length+1) mod (character'pos(character'high)+1));
			left := left + hz_label'length;
			return data(data'left to data'left+left-1);
		end;

		function textlut_init (
			constant data : string)
			return natural_vector is
			variable ptr  : natural;
			variable tbl  : natural_vector(0 to inputs);
		begin
			ptr := data'left; 
			for i in 0 to inputs loop
				tbl(i) := ptr;
				assert false
					report "table element " & natural'image(tbl(i))
					severity note;
				ptr := ptr + character'pos(data(ptr));
			end loop;
			return tbl;
		end;

		constant textrom : string := textbase_init(vt_labels);
		constant texttbl : natural_vector := textlut_init(textrom);
		variable ptr     : natural range textrom'range;
		variable xxx     : natural range textrom'range;

	begin
		if rising_edge(rgtr_clk) then
			str_code <= to_ascii(textrom(ptr));
			if (str_rdy xor str_req)='1' then
				if ptr < xxx then
					str_frm <= '1';
				else
					str_frm <= '0';
					str_rdy <= str_req;
				end if;
				ptr := ptr + 1;
			else
				ptr := texttbl(wdt_id) + 1;
				xxx := texttbl(wdt_id) + character'pos(textrom(texttbl(wdt_id)));
			end if;
		end if;
	end process;

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if (vtwdt_req xor vtwdt_rdy)='1' then
					btod_sht   <= vt_sht;
					btod_dec   <= vt_dec;
					scale      <= vt_scale;
					offset     <= resize(vt_offset, offset'length);
					wdt_id     <= vt_wdtid;
					wdt_row    <= vt_wdtrow;
					vtwdt_rdy  <= vtwdt_req;
					txt_req    <= not txt_req;
				elsif (tgrwdt_req xor tgrwdt_rdy)='1' then
					btod_sht   <= tgr_sht;
					btod_dec   <= tgr_dec;
					scale      <= tgr_scale;
					offset     <= resize(tgr_offset, offset'length);
					wdt_id     <= tgr_wdtid;
					wdt_row    <= tgr_wdtrow;
					tgrwdt_rdy <= tgrwdt_req;
					txt_req    <= not txt_req;
				elsif (hzwdt_req xor hzwdt_rdy)='1' then
					btod_sht   <= hz_sht;
					btod_dec   <= hz_dec;
					scale      <= hz_scale;
					offset     <= resize(hz_offset, offset'length);
					wdt_id     <= hz_wdtid;
					wdt_row    <= hz_wdtrow;
					hzwdt_rdy  <= hzwdt_req;
					txt_req    <= not txt_req;
				end if;
			end if;
		end if;
	end process;
	video_row <= std_logic_vector(resize(wdt_row, video_row'length));

	process (rgtr_clk)
		type states is (s_rdy, s_req);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_rdy =>
				if (txt_req xor txt_rdy)='1' then
					if wdt_id <= inputs then
						axis_req <= not axis_rdy;
					else 
						tgr_req  <= not tgr_rdy;
					end if;
					state := s_req;
				end if;
			when s_req =>
				if (axis_req xor axis_rdy)='0' then
					if (tgr_req xor tgr_rdy)='0' then
						txt_rdy <= txt_req;
						state   := s_rdy;
					end if;
				end if;
			end case;
		end if;
	end process;

	axis_p : process (rgtr_clk)
		alias btod_req is btod_reqs(axis_id);
		alias btod_rdy is btod_rdys(axis_id);
		alias mul_req  is mul_reqs(axis_id);
		alias mul_rdy  is mul_rdys(axis_id);
		alias str_req  is str_reqs(axis_id);
		alias str_rdy  is str_rdys(axis_id);
		type states is (s_label, s_offset, s_unit, s_scale, s_wait);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				bs(axis_id)<= offset;
				if (axis_rdy xor axis_req)='1' then
					mul_req  <= not mul_rdy;
					str_req  <= not str_rdy;
					state    := s_offset;
				end if;
			when s_offset =>
				if (mul_req xor mul_rdy)='0' then
					btod_req <= not btod_rdy;
					state   := s_unit;
				end if;
			when s_unit =>
				bs(axis_id)<= to_signed(grid_unit, b'length);
				if (btod_req xor btod_rdy)='0' then
					mul_req <= not mul_rdy;
					state   := s_scale;
				end if;
			when s_scale =>
				if (str_req xor str_rdy)='0' then
					if (mul_req xor mul_rdy)='0' then
						btod_req <= not btod_rdy;
						state    := s_wait;
					end if;
				end if;
			when s_wait =>
				if (btod_req xor btod_rdy)='0' then
					axis_rdy <= axis_req;
					state    := s_label;
				end if;
			end case;
		end if;
	end process;

	trigger_p : process (rgtr_clk)
		type states is (s_label, s_offset, s_unit);
		variable state : states;
		alias btod_req  is btod_reqs(tgr_id);
		alias btod_rdy  is btod_rdys(tgr_id);
		alias mul_req   is mul_reqs(tgr_id);
		alias mul_rdy   is mul_rdys(tgr_id);
		alias str_req   is str_reqs(tgr_id);
		alias str_rdy   is str_rdys(tgr_id);
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				bs(tgr_id)<= resize(signed(tgr_offset), offset'length);
				if (tgr_rdy xor tgr_req)='1' then
					mul_req  <= not mul_rdy;
					str_req  <= not str_rdy;
					state    := s_offset;
				end if;
			when s_offset =>
				if (mul_req xor mul_rdy)='0' then
					btod_req <= not btod_rdy;
					state    := s_unit;
				end if;
			when s_unit =>
				if (btod_req xor btod_rdy)='0' then
					-- str_req  <= not str_rdy;
					tgr_rdy  <= tgr_req;
					state    := s_label;
				end if;
			end case;
		end if;
	end process;

	strreq_p : process (rgtr_clk)
		type states is (s_rdy, s_req);
		variable state : states;
		variable id   : natural range 0 to str_reqs'length-1;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_rdy =>
				for i in str_reqs'range loop
					if (str_rdys(i) xor str_reqs(i))='1' then
						id := i;
						str_req <= not str_rdy;
						state := s_req;
						exit;
					end if;
				end loop;
			when s_req =>
				if (str_req xor str_rdy)='0' then
					str_rdys(id) <= str_reqs(id);
					state := s_rdy;
				end if;
			end case;
		end if;
	end process;

	btodreq_p : process (rgtr_clk)
		type states is (s_rdy, s_req);
		variable state : states;
		variable id : natural range 0 to btod_reqs'length-1;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_rdy =>
				for i in btod_reqs'range loop
					if (btod_rdys(i) xor btod_reqs(i))='1' then
						id := i;
						btod_req <= not btod_rdy;
						state := s_req;
						exit;
					end if;
				end loop;
			when s_req =>
				if (btod_req xor btod_rdy)='0' then
					btod_rdys(id) <= btod_reqs(id);
					state := s_rdy;
				end if;
			end case;
		end if;
	end process;

	mulreq_p : process (rgtr_clk)
		type states is (s_rdy, s_req);
		variable state : states;
		variable id    : natural range 0 to mul_reqs'length-1;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_rdy =>
				for i in mul_reqs'range loop
					if (mul_rdys(i) xor mul_reqs(i))='1' then
						sign <= bs(i)(0);
						if bs(i) >= 0 then
							b <=  bs(i);
						else 
							b <= -bs(i);
						end if;
						id := i;
						mul_req <= not mul_rdy;
						state := s_req;
						exit;
					end if;
				end loop;
			when s_req =>
				if (mul_req xor mul_rdy)='0' then
					mul_rdys(id) <= mul_reqs(id);
					state := s_rdy;
				end if;
			end case;
		end if;
	end process;

	mul_ser_e : entity hdl4fpga.mul_ser
	generic map (
		lsb => true)
	port map (
		clk => rgtr_clk,
		req => mul_req,
		rdy => mul_rdy,
		a   => std_logic_vector(scale),
		b   => std_logic_vector(b(1 to b'right)),
		s   => binary);

	btod_e : entity hdl4fpga.btof
	port map (
		clk      => rgtr_clk,
		btof_req => btod_req,
		btof_rdy => btod_rdy,
		sht      => std_logic_vector(btod_sht),
		dec      => std_logic_vector(btod_dec),
		left     => '0',
		width    => x"7",
		exp      => b"101",
		neg      => sign,
		bin      => binary,
		code_frm => btod_frm,
		code     => btod_code);

	code_frm  <= (txt_req xor txt_rdy);
	code_irdy <= btod_frm or str_frm;
	code_data <= multiplex(btod_code & str_code, not btod_frm);

end;
