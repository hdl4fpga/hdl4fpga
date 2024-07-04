
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

entity scopeio_reading is
	generic (
		layout    : string);
	port (
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;

		code_frm  : out std_logic := '0';
		code_irdy : out std_logic := '0';
		code_data : out ascii);

	constant offset_length   : natural := max(vt_offset'length, time_offset'length);

end;

architecture def of scopeio_reading is

	signal wdt_id     : natural range 0 to (inputs+2)-1;
	signal botd_sht   : std_logic_vector;
	signal botd_dec   : std_logic_vector;
	signal offset     : std_logic_vector;
	signal scale      : std_logic_vector;
	signal txt_req    : std_logic;
	signal txt_rdy    : std_logic;

	signal trigger_ena    : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_slope  : std_logic;
	signal trigger_cid : std_logic_vector(chanid_bits-1 downto 0);
	signal trigger_level  : std_logic_vector(storage_word'range);

	signal vt_dv      : std_logic;
	signal vt_offsets : std_logic_vector(0 to inputs*vt_offset'length-1);
	signal tgr_scale  : std_logic_vector(4-1 downto 0);

	signal str_req    : std_logic;
	signal str_rdy    : std_logic;
	signal btod_frm   : std_logic;
	signal btod_code  : ascii;

	signal btod_req   : std_logic;
	signal btod_rdy   : std_logic;
	signal mul_req    : std_logic := '0';
	signal mul_rdy    : std_logic := '0';
	signal a          : std_logic_vector(0 to scale'length-1);
	signal b          : signed(0 to offset'length-1);

	signal binary     : std_logic_vector(0 to binary_length-1);
	signal botd_frm   : std_logic;
	signal botd_code  : ascii;
	signal str_frm    : std_logic;
	signal str_code   : ascii;
	signal axis_req   : std_logic;
	signal axis_rdy   : std_logic;
	signal tgr_req    : std_logic; -- := '0';
	signal tgr_rdy    : std_logic; -- := '0';
	signal mul_reqs   : std_logic_vector(0 to 1); -- := (others => '0');
	signal mul_rdys   : std_logic_vector(0 to 1); -- := (others => '0');
	signal btod_reqs  : std_logic_vector(0 to 1); -- := (others => '0');
	signal btod_rdys  : std_logic_vector(0 to 1); -- := (others => '0');
	signal str_reqs   : std_logic_vector(0 to 1); -- := (others => '0');
	signal str_rdys   : std_logic_vector(0 to 1); -- := (others => '0');

	type a_vector is array(0 to 1) of std_logic_vector(a'range);
	type b_vector is array(0 to 1) of signed(b'range);
	signal as : a_vector;
	signal bs : b_vector;

	constant axis_id : natural := 0;
	constant tgr_id  : natural := 1;

begin

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
		hz_slider => hz_offset);

	vtgain_e : entity hdl4fpga.scopeio_rgtrvtgain
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => rgtr_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtoffset_ena,
		vt_chanid => offset_cid,
		vt_offset => offset);

	vtoffset_e : entity hdl4fpga.scopeio_rgtrvtoffset
	generic map (
		rgtr      => false)
	port map (
		rgtr_clk  => sio_clk,
		rgtr_dv   => rgtr_dv,
		rgtr_id   => rgtr_id,
		rgtr_data => rgtr_data,

		vt_ena    => vtscale_ena,
		vt_chanid => scale_cid
		vt_scale  => vt_scaleid);

	tgr_e : entity hdl4fpga.scopeio_rgtrtrigger
	port map (
		rgtr_clk       => rgtr_clk,
		rgtr_dv        => rgtr_dv,
		rgtr_id        => rgtr_id,
		rgtr_data      => rgtr_data,

		trigger_ena    => trigger_ena,
		trigger_chanid => trigger_cid,
		trigger_slope  => trigger_slope,
		trigger_freeze => trigger_freeze,
		trigger_level  => trigger_level);

	vtoffsets_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtoffset_ena,
		wr_addr => offset_cid,
		wr_data => offset,
		rd_addr => scale_cid,
		rd_data => tbl_offset);

	vt_cid <= offset_cid when vtoffset_ena='1' else trigger_cid;
	vtgains_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => rgtr_clk,
		wr_ena  => vtscale_ena,
		wr_addr => scale_cid,
		wr_data => vt_scaleid,
		rd_addr => vt_cid,
		rd_data => tbl_scaleid);

	process (rgtr_clk)
		variable scaleid : natural range 0 to vt_shts'length-1;
		variable timeid  : natural range 0 to hz_shts'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
    			if vtscale_ena='1' then
    				scaleid    := to_integer(unsigned(vt_scaleid));
    				vt_sht     <= to_signed(vt_shts(to_integer(scaleid)), botd_sht'length);
    				vt_dec     <= to_signed(vt_pnts(to_integer(scaleid)), botd_dec'length);
    				vt_scale   <= to_unsigned(vt_sfcnds(to_integer(scaleid mod 4)), vt_scale'length);
    				vt_offset  <= tbl_offset;
    				vt_wdtid   <= scaleid+2;
    				vt_wdtaddr <= mul(unsigned(scale_cid), cga_cols, wdt_addr'length) + 2*cga_cols;
    				vtwdt_req  <= not vtwdt_rdy;
    			elsif vtoffset_ena='1' then
    				scaleid    := to_integer(unsigned(tbl_scaleid));
    				vt_sht     <= to_signed(vt_shts(scaleid), botd_sht'length);
    				vt_dec     <= to_signed(vt_pnts(scaleid), botd_dec'length);
    				vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
    				vt_offset  <= offset;
    				vt_wdtid   <= scaleid+2;
    				vt_wdtaddr <= mul(unsigned(scale_cid), cga_cols, wdt_addr'length) + 2*cga_cols;
    				vtwdt_req  <= not vtwdt_rdy;
    			elsif trigger_ena='1' then
    				scaleid     := to_integer(unsigned(tbl_scaleid));
    				tgr_sht     <= to_signed(vt_shts(scaleid), botd_sht'length);
    				tgr_dec     <= to_signed(vt_pnts(scaleid), botd_dec'length);
    				tgr_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
    				tgr_offset  <= tgr_level;
    				tgr_wdtid   <= inputs+1;
    				tgr_wdtaddr <= to_unsigned(1*cga_cols, vt_wdtaddr'length);
    				tgrwdt_req  <= not tgrwdt_rdy;
    			end if;
    			if hz_ena='1' then
    				timeid     := to_integer(unsigned(hz_scaleid));
    				hz_sht     <= to_signed(hz_shts(timeid), botd_sht'length);
    				hz_dec     <= to_signed(hz_pnts(timeid), botd_dec'length);
    				hz_scale   <= to_unsigned(hz_sfcnds(timeid mod 4), hz_scale'length);
    				hz_offset  <= hz_offset;
    				hz_wdtaddr <= to_unsigned(0*cga_cols, hz_wdtaddr'length);
    				hz_wdtid   <= inputs+0;
    				hzwdt_req  <= not hzwdt_rdy;
    			end if;
			end if;
		end if;
	end process;

	process (rgtr_clk)
		function textrom_init (
			constant width : natural)
			return string is
			variable left  : natural;
			variable right : natural;
			variable data  : string(1 to (inputs+2)*width);
		begin
			left  := data'left;
			right := left + (width-1);
			for i in 0 to inputs-1 loop
				data(left to right) := textalign(escaped(hdo(vt_labels)**("["&natural'image(i)&"].text")), width);
				left  := left  + width;
				right := right + width;
			end loop;
			data(left to right) := textalign(hz_label, width);
			left  := left  + width;
			right := right + width;
			data(left to right) := textalign("tgz", width);
			return data;
		end;

		constant width : natural := 4;
		constant textrom : string := textrom_init (width);
		variable i    : natural range 0 to width-1;
		variable cptr : natural range 0 to (1+inputs)*width;

	begin
		if rising_edge(rgtr_clk) then
			str_frm  <= str_req xor str_rdy;
			str_code <= to_ascii(textrom(cptr));
			if (str_rdy xor str_req)='1' then
				if i >= width-1 then
					str_rdy <= str_req;
				end if;
				i    := i + 1;
				cptr := cptr + 1;
			else
				i    := 0;
				cptr := width*wdt_id+1;
			end if;
		end if;
	end process;

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if (vtwdt_req xor vtwdt_rdy)='1' then
					btod_sht   <= vt_sht;
					botd_dec   <= vt_dec;
					scale      <= vt_scale;
					xxx1       <= signed(vt_offset);
					wdt_id     <= vt_wdtid;
					wdt_addr   <= vt_wdtaddr;
					vtwdt_req  <= vtwdt_rdy='1' then
					txt_req    <= not txt_req;
				elsif (tgrwdt_req xor tgrwdt_rdy)='1' then
					btod_sht   <= tgr_sht;
					botd_dec   <= tgr_dec;
					scale      <= tgr_scale;
					xxx1       <= signed(tgr_offset);
					wdt_id     <= tgr_wdtid;
					wdt_addr   <= tgr_wdtaddr;
					tgrwdt_req <= tgrwdt_rdy;
					txt_req    <= not txt_req;
				elsif (hzwdt_req xor hzwdt_rdy)='1' then
					btod_sht   <= hz_sht;
					botd_dec   <= hz_dec;
					scale      <= hz_scale;
					xxx1       <= signed(hz_offset);
					wdt_id     <= hz_wdtid;
					wdt_addr   <= hz_wdtaddr;
					hzwdt_req  <= hzwdt_rdy;
					txt_req    <= not txt_req;
				end if;
			end if;
		end if;
	end process;

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
						if (btod_req xor btod_rdy)='0' then
							if (str_req xor str_rdy)='0' then
						txt_rdy <= txt_req;
						state   := s_rdy;
							end if;
						end if;
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
		type states is (s_label, s_offset, s_unit, s_scale);
		variable state : states;
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				bs(axis_id)<= signed(xxx1);
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
						axis_rdy <= axis_req;
						state    := s_label;
					end if;
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
				bs(tgr_id)<= signed(xxx1);
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

	a <= scale;
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
						if signed(offset) >= 0 then
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
		a   => a,
		b   => std_logic_vector(b(1 to b'right)),
		s   => binary);

	botd_e : entity hdl4fpga.btof
	port map (
		clk      => rgtr_clk,
		btof_req => btod_req,
		btof_rdy => btod_rdy,
		sht      => botd_sht,
		dec      => botd_dec,
		left     => '0',
		width    => x"7",
		exp      => b"101",
		neg      => '0', --sign,
		bin      => binary,
		code_frm => botd_frm,
		code     => botd_code);

	code_frm  <= (txt_req xor txt_rdy) or (btod_req xor btod_rdy) or (str_req xor str_rdy);
	code_irdy <= botd_frm or str_frm;
	code_data <= multiplex(botd_code & str_code, not botd_frm);

end;
