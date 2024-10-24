
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
		tp        : out std_logic_vector(1 to 32);
		rgtr_clk  : in  std_logic;
		rgtr_dv   : in  std_logic;
		rgtr_id   : in  std_logic_vector(8-1 downto 0);
		rgtr_data : in  std_logic_vector;
		trigger_chanid : buffer std_logic_vector;

		code_frm  : out std_logic := '0';
		video_row : out std_logic_vector;
		code_irdy : out std_logic := '0';
		code_data : out ascii);

	constant inputs        : natural := hdo(layout)**".inputs";
	constant max_delay     : natural := hdo(layout)**".max_delay=16384.";
	constant hz_unit       : real    := hdo(layout)**".axis.horizontal.unit";
	constant vt_unit       : real    := hdo(layout)**".axis.vertical.unit";
	constant grid_unit     : natural := hdo(layout)**".grid.unit=32.";
	constant grid_height   : natural := hdo(layout)**".grid.height";

	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant vt_labels     : string  := hdo(layout)**".vt";
	constant hz_label      : string  := "TIME";

	constant vt_sfcnds     : natural_vector := get_significand1245(vt_unit);
	constant vt_shts       : integer_vector := get_shr1245(vt_unit);
	constant vt_pnts       : integer_vector := get_characteristic1245(vt_unit);
	constant vt_pfxs       : string         := get_prefix1235(vt_unit);

	constant hz_sfcnds     : natural_vector := get_significand1245(hz_unit);
	constant hz_shts       : integer_vector := get_shr1245(hz_unit);
	constant hz_pnts       : integer_vector := get_characteristic1245(hz_unit);
	constant hz_pfxs       : string         := get_prefix1235(hz_unit);

	constant sfcnd_length  : natural := max(unsigned_num_bits(max(vt_sfcnds)), unsigned_num_bits(max(hz_sfcnds)));

	constant bin_digits    : natural := 3;
	constant bcd_width     : natural := 8;
	constant bcd_length    : natural := 4;
	constant bcd_digits    : natural := 1;

end;

architecture def of scopeio_reading is

	signal hz_ena         : std_logic;
	signal hz_scaleid     : std_logic_vector(4-1 downto 0);
	signal hz_offset      : std_logic_vector(hzoffset_bits-1 downto 0);

	signal vtscale_ena    : std_logic;
	signal vt_scalecid    : std_logic_vector(chanid_bits-1 downto 0);
	signal vt_scaleid     : std_logic_vector(4-1 downto 0);
	signal vt_cid         : std_logic_vector(chanid_bits-1 downto 0);

	signal vtoffset_ena   : std_logic;
	signal vt_offsetcid   : std_logic_vector(vt_cid'range);
	signal vt_offset      : std_logic_vector((5+8)-1 downto 0);

	signal trigger_ena    : std_logic;
	signal trigger_freeze : std_logic;
	signal trigger_slope  : std_logic;
	signal trigger_oneshot : std_logic;
	signal trigger_level  : std_logic_vector(unsigned_num_bits(grid_height)-1 downto 0);

	signal txt_req        : std_logic := '0';
	signal txt_rdy        : std_logic := '0';
	signal scale          : unsigned(0 to sfcnd_length-1);
	signal offset         : signed(0 to max(vt_offset'length, hz_offset'length)-1);

	signal str_req        : bit;
	signal str_rdy        : bit;
	subtype wdtid_range is natural range 0 to (inputs+2)-1;
	signal wdt_id         : wdtid_range;
	signal wdt_row        : unsigned(0 to unsigned_num_bits(inputs+2-1)-1) := (others => '0');

	signal btod_sht       : signed(4-1 downto 0);
	signal btod_dec       : signed(4-1 downto 0);
	signal vt_sht         : signed(4-1 downto 0);
	signal vt_dec         : signed(4-1 downto 0);
	signal vt_scale       : unsigned(scale'range);
	signal vt_wdtid       : wdtid_range;
	signal vt_wdtrow      : unsigned(wdt_row'range);
	signal vtwdt_req      : std_logic := '0';
	signal vtwdt_rdy      : std_logic := '0';
	signal vt_uid         : natural;
	signal vt_chanid      : std_logic_vector(vt_cid'range);
	signal vts_chanid     : std_logic_vector(vt_cid'range);

	signal tgr_sht        : signed(4-1 downto 0);
	signal tgr_dec        : signed(4-1 downto 0);
	signal tgr_scale      : unsigned(scale'range);
	signal tgr_offset     : signed(trigger_level'range);
	signal tgr_slope      : std_logic;
	signal tgr_freeze     : std_logic;
	signal tgr_oneshot    : std_logic;
	signal tgr_wdtid      : wdtid_range;
	signal tgr_wdtrow     : unsigned(wdt_row'range);
	signal tgrwdt_req     : std_logic;
	signal tgrwdt_rdy     : std_logic;

	signal hz_sht         : signed(4-1 downto 0);
	signal hz_dec         : signed(4-1 downto 0);
	signal hz_scale       : unsigned(scale'range);
	signal hz_wdtid       : wdtid_range;
	signal hz_wdtrow      : unsigned(wdt_row'range);
	signal hzwdt_req      : std_logic := '0';
	signal hzwdt_rdy      : std_logic := '0';
	signal hz_uid         : natural;

	signal btod_req       : std_logic := '0';
	signal btod_rdy       : std_logic := '0';
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
	signal str_id         : natural;
	signal str_ids        : natural_vector(0 to 1);

	constant up_id        : natural := (inputs+1)+vt_pfxs'length+hz_pfxs'length;
	constant dn_id        : natural := up_id+1;
	constant free_id      : natural := dn_id+1;
	constant norm_id      : natural := free_id+1;
	constant freeze_id    : natural := norm_id+1;
	constant oneshot_id   : natural := freeze_id+1;

	signal tgrref_req     : bit;
	signal tgrref_rdy     : bit;

	signal b  : signed(0 to offset'length-1);
	type b_vector is array(0 to 1) of signed(b'range);
	signal bs : b_vector;

	constant axis_id : natural := 0;
	constant tgr_id  : natural := 1;

	signal sign : std_logic;
	signal vtstup_req : bit := '0';
	signal vtstup_rdy : bit := '0';
	signal tgrstup_req : bit := '0';
	signal tgrstup_rdy : bit := '0';
	signal hzstup_req : bit := '0';
	signal hzstup_rdy : bit := '0';
	signal chan : integer range -1 to inputs-1 := inputs-1;
begin

	vt_cid <= 
		vt_offsetcid   when vtoffset_ena='1' else 
		vt_scalecid    when vtscale_ena='1'  else
		vts_chanid     when (vtstup_rdy xor vtstup_req)='1' else
		vt_chanid      when (vtwdt_rdy xor vtwdt_req)='1' else
		trigger_chanid when trigger_ena='1'  else
		trigger_chanid when (tgrref_rdy xor tgrref_req)='1'  else
		(others => '-');

	state_e : entity hdl4fpga.scopeio_state
	port map (
		rgtr_clk        => rgtr_clk,
		rgtr_dv         => rgtr_dv,
		rgtr_id         => rgtr_id,
		rgtr_data       => rgtr_data,

		hz_ena          => hz_ena,
		hz_scaleid      => hz_scaleid,
		hz_offset       => hz_offset,
		chan_id         => vt_cid,
		vtscale_ena     => vtscale_ena,
		vt_scalecid     => vt_scalecid,
		vt_scaleid      => vt_scaleid,
		vtoffset_ena    => vtoffset_ena,
		vt_offsetcid    => vt_offsetcid,
		vt_offset       => vt_offset,
				  
		trigger_ena     => trigger_ena,
		trigger_chanid  => trigger_chanid,
		trigger_slope   => trigger_slope,
		trigger_oneshot => trigger_oneshot,
		trigger_freeze  => trigger_freeze,
		trigger_level   => trigger_level);

	startup_p : process (chan, rgtr_clk)
		type states is (s_vt, s_tgr, s_hz);
		variable state : states;
		variable statup_req : std_logic := '1';
		variable statup_rdy : std_logic := '0';
	begin
		if rising_edge(rgtr_clk) then
			if (statup_rdy xor statup_req)='1' then
				if (txt_req xor txt_rdy)='0' then
					case state is
					when s_vt =>
    					if (vtwdt_rdy xor vtwdt_req)='0' then
    						if (vtstup_req xor vtstup_rdy)='0' then
    							if chan >= 0 then
    								vtstup_req <= not vtstup_rdy;
    							else
									tgrstup_req <= not tgrstup_rdy;
    								state := s_tgr;
    							end if;
							else
    							chan <= chan - 1;
    						end if;
    					end if;
					when s_tgr => 
    					if (tgrwdt_rdy xor tgrwdt_req)='0' then
							if (tgrstup_rdy xor tgrstup_req)='0' then
								hzstup_req <= not hzstup_rdy;
								state := s_hz;
							end if;
						end if;
					when s_hz =>
						if (hzstup_rdy xor hzstup_req)='0' then
							state := s_vt;
    						statup_rdy := statup_req;
						end if;
					end case;
				end if;
			else
				state := s_vt;
				chan <= inputs-1;
			end if;
			vts_chanid <= std_logic_vector(to_unsigned(chan mod inputs, vts_chanid'length));
		end if;
	end process;

	vt_p : process (rgtr_clk)
		variable scaleid : natural range 0 to vt_shts'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if vtscale_ena='1' then
					scaleid    := to_integer(unsigned(vt_scaleid));
					vt_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					vt_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					vt_uid     <= (inputs+1)+scaleid;
					vt_wdtid   <= to_integer(unsigned(vt_scalecid));
					vt_wdtrow  <= resize(unsigned(vt_scalecid), vt_wdtrow'length)+2;
					vt_chanid  <= vt_scalecid;
					tgrref_req <= not tgrref_rdy;
					vt_chanid  <= vt_scalecid;
					vtwdt_req  <= not vtwdt_rdy;
				elsif vtoffset_ena='1' then
					scaleid    := to_integer(unsigned(vt_scaleid));
					vt_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					vt_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					vt_wdtid   <= to_integer(unsigned(vt_offsetcid));
					vt_uid     <= (inputs+1)+scaleid;
					vt_wdtrow  <= resize(unsigned(vt_offsetcid), vt_wdtrow'length)+2;
					vt_chanid  <= vt_offsetcid;
					tgrref_req    <= not tgrref_rdy;
					vtwdt_req  <= not vtwdt_rdy;
				elsif (vtstup_rdy xor vtstup_req)='1' then
					scaleid    := to_integer(unsigned(vt_scaleid));
					vt_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					vt_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					vt_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					vt_uid     <= (inputs+1)+scaleid;
					vt_wdtid   <= chan;
					vt_wdtrow  <= to_unsigned(chan, vt_wdtrow'length)+2;
					vtwdt_req  <= not vtwdt_rdy;
					vtstup_rdy <= vtstup_req;
				end if;
			end if;
		end if;
	end process;

	tgr_p : process (trigger_ena, rgtr_clk)
		variable scaleid : natural range 0 to vt_shts'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if trigger_ena='1' then
					scaleid     := to_integer(unsigned(vt_scaleid));
					tgr_sht     <= to_signed(vt_shts(scaleid), btod_sht'length);
					tgr_dec     <= to_signed(vt_pnts(scaleid), btod_dec'length);
					tgr_scale   <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					tgr_offset  <= signed(trigger_level);
					tgr_slope   <= trigger_slope;
					tgr_freeze  <= trigger_freeze;
					tgr_oneshot <= trigger_oneshot;
					tgr_wdtid   <= inputs+1;
					tgr_wdtrow  <= to_unsigned(1, tgr_wdtrow'length);
					tgrwdt_req  <= not tgrwdt_rdy;
				elsif (tgrref_rdy xor tgrref_req)='1' then
					if (vtwdt_rdy xor vtwdt_req)='0' then
						scaleid    := to_integer(unsigned(vt_scaleid));
						tgr_sht    <= to_signed(vt_shts(scaleid), btod_sht'length);
						tgr_dec    <= to_signed(vt_pnts(scaleid), btod_dec'length);
						tgr_scale  <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
						tgr_wdtid  <= inputs+1;
						tgr_wdtrow <= to_unsigned(1, tgr_wdtrow'length);
						tgrwdt_req <= not tgrwdt_rdy;
						tgrref_rdy <= tgrref_req;
					end if;
				elsif (tgrstup_rdy xor tgrstup_req)='1' then
					scaleid    := to_integer(unsigned(vt_scaleid));
					tgr_sht    <= to_signed(vt_shts(scaleid), btod_sht'length);
					tgr_dec    <= to_signed(vt_pnts(scaleid), btod_dec'length);
					tgr_scale  <= to_unsigned(vt_sfcnds(scaleid mod 4), vt_scale'length);
					tgr_wdtid  <= inputs+1;
					tgr_wdtrow <= to_unsigned(1, tgr_wdtrow'length);
					tgrwdt_req <= not tgrwdt_rdy;
					tgrstup_rdy <= tgrstup_req;
				end if;
			end if;
		end if;
	end process;

	hz_p : process (hz_ena, rgtr_clk)
		variable timeid  : natural range 0 to hz_shts'length-1;
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if hz_ena='1' then
					timeid     := to_integer(unsigned(hz_scaleid));
					hz_sht     <= to_signed(hz_shts(timeid), btod_sht'length);
					hz_dec     <= to_signed(hz_pnts(timeid), btod_dec'length);
					hz_scale   <= to_unsigned(hz_sfcnds(timeid mod 4), hz_scale'length);
					hz_wdtrow  <= to_unsigned(0, hz_wdtrow'length);
					hz_uid     <= (inputs+1+vt_pfxs'length)+timeid;
					hz_wdtid   <= inputs+0;
					hzwdt_req  <= not hzwdt_rdy;
				elsif (hzstup_rdy xor hzstup_req)='1' then
					timeid     := to_integer(unsigned(hz_scaleid));
					hz_sht     <= to_signed(hz_shts(timeid), btod_sht'length);
					hz_dec     <= to_signed(hz_pnts(timeid), btod_dec'length);
					hz_scale   <= to_unsigned(hz_sfcnds(timeid mod 4), hz_scale'length);
					hz_wdtrow  <= to_unsigned(0, hz_wdtrow'length);
					hz_uid     <= (inputs+1+vt_pfxs'length)+timeid;
					hz_wdtid   <= inputs+0;
					hzwdt_req  <= not hzwdt_rdy;
					hzstup_rdy <= hzstup_req;
				end if;
			end if;
		end if;
	end process;

	text_b : block

		function textbit_init (
			constant vt_labels : string;
			constant width : natural := 0)
			return std_logic_vector is

			variable data : string(1 to vt_labels'length+4*(vt_pfxs'length+hz_pfxs'length+6));
			variable id   : natural range 0 to vt_labels'length+vt_pfxs'length+hz_pfxs'length+6-1;
			variable ptr  : natural range data'range;

			procedure insert (
				variable id    : inout natural;
				variable ptr   : inout natural;
				constant value : in string) is
			begin
				data(ptr to ptr+value'length-1) := value;
				data(ptr+value'length) := NUL;
				id   := id + 1;
				ptr := (ptr+1) + value'length;
			end;

			variable code   : std_logic_vector(ascii'range);
			variable retval : std_logic_vector(0 to ascii'length*data'length-1);
			variable up_pos : natural;
			variable dn_pos : natural;

			constant label_width : natural := max_textlength(vt_labels, inputs);
		begin

			id := 0;
			ptr := data'left;
			for i in 0 to inputs-1 loop
				insert(id, ptr, textalign(escaped(hdo(vt_labels)**("["&natural'image(i)&"].text")), label_width));
			end loop;

			insert (id, ptr, hz_label);
			for i in vt_pfxs'range loop
				insert(id, ptr,  ' ' & vt_pfxs(i) & 'v');
			end loop;

			for i in hz_pfxs'range loop
				insert(id, ptr, ' ' & hz_pfxs(i) & 's');
			end loop;

			up_pos := ptr;
			insert(id, ptr, "   ");

			dn_pos := ptr;
			insert(id, ptr, "   ");

			insert(id, ptr, "FREE");
			insert(id, ptr, "NORM");
			insert(id, ptr, "HOLD");
			insert(id, ptr, "SHOT");

			ptr := ptr - 1 ;
			retval(0 to ascii'length*ptr-1) := to_ascii(data(data'left to data'left+ptr-1));
			retval := replace(retval, up_pos, x"18");  
			retval := replace(retval, dn_pos, x"19");  

			return retval(0 to ascii'length*ptr-1);
		end;

		function textlut_init (
			constant arg : std_logic_vector)
			return natural_vector is
			alias data : std_logic_vector(0 to arg'length-1) is arg;
			variable lut : natural_vector(0 to 256-1);
			variable n   : natural;
		begin
			n := 0;
			lut(n) := 0;
			for i in 0 to data'length/ascii'length-1 loop
				if data(i*ascii'length to (i+1)*ascii'length-1)=(ascii'range => '0') then
					n := n + 1;
					lut(n) := i+1;
					assert false
						report "table element " & natural'image(lut(n))
						severity note;
				end if;
			end loop;
			assert true
				report "Table size " & natural'image(n)
				severity note;
			return lut(0 to n-1);
		end;

		function textmeta_init (
			constant lut : natural_vector)
			return std_logic_vector is
			constant size   : natural := unsigned_num_bits(max(lut)-1);
			variable retval : unsigned(0 to lut'length*size-1);
		begin
			for i in lut'range loop
				retval(size*i to (i+1)*size-1) := to_unsigned(lut(i), size);
			end loop;
			return std_logic_vector(retval);
		end;

		constant textdata : std_logic_vector := textbit_init(vt_labels);
		constant textlut  : natural_vector   := textlut_init(textdata);
		constant textmeta : std_logic_vector := textmeta_init(textlut);
		signal tbl       : natural_vector(textlut'range) := textlut;
		signal meta      : std_logic_vector(textmeta'range) := textmeta;
		signal textlen   : natural range 0 to 256-1;
		signal meta_addr : unsigned(0 to unsigned_num_bits(textlut'length-1)-1);
		signal meta_data : std_logic_vector(0 to textmeta'length/textlut'length-1);
		signal text_addr : std_logic_vector(meta_data'range);
		signal text_data : std_logic_vector(ascii'range);
	begin

		meta_addr <= to_unsigned(str_id, meta_addr'length);
		lutrom_e : entity hdl4fpga.rom
		generic map (
			bitrom => textmeta)
		port map (
			addr => std_logic_vector(meta_addr),
			data => meta_data);

		textrom_e : entity hdl4fpga.rom
		generic map (
			bitrom => textdata)
		port map (
			addr => text_addr,
			data => text_data);

		textlen <= to_integer(unsigned(meta_data));
		process (rgtr_clk)
    		type states is (s_init, s_run);
    		variable state : states;
    	begin
    		if rising_edge(rgtr_clk) then
    			if (str_rdy xor str_req)='1' then
    				case state is 
    				when s_init =>
						text_addr <= meta_data;
    					state := s_run;
    				when s_run =>
    					if text_data=(text_data'range => '0') then
							text_addr <= meta_data;
    						str_frm <= '0';
    						str_rdy <= str_req;
    						state   := s_init;
						else
							str_frm   <= '1';
							text_addr <= std_logic_vector(unsigned(text_addr) + 1);
    					end if;
    				end case;
    			else
					text_addr <= meta_data;
    				str_frm   <= '0';
    				state     := s_init;
    			end if;
				str_code  <= text_data;
    		end if;
    	end process;

	end block;

	process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if (txt_req xor txt_rdy)='0' then
				if (vtwdt_req xor vtwdt_rdy)='1' then
					btod_sht   <= vt_sht;
					btod_dec   <= vt_dec;
					scale      <= vt_scale;
					offset     <= resize(signed(vt_offset), offset'length);
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
					offset     <= resize(signed(hz_offset), offset'length);
					wdt_id     <= hz_wdtid;
					wdt_row    <= hz_wdtrow;
					hzwdt_rdy  <= hzwdt_req;
					txt_req    <= not txt_req;
				end if;
			end if;
		end if;
	end process;
	video_row <= std_logic_vector(resize(wdt_row, video_row'length));

	process (tgr_wdtid,rgtr_clk)
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

	axis_p : process (rgtr_clk, mul_rdy)
		alias btod_req is btod_reqs(axis_id);
		alias btod_rdy is btod_rdys(axis_id);
		alias mul_req  is mul_reqs(axis_id);
		alias mul_rdy  is mul_rdys(axis_id);
		alias str_req  is str_reqs(axis_id);
		alias str_rdy  is str_rdys(axis_id);
		alias str_id   is str_ids(axis_id);
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
					str_id   <= wdt_id;
					state    := s_offset;
				end if;
			when s_offset =>
				if (mul_req xor mul_rdy)='0' then
					btod_req <= not to_stdulogic(to_bit(btod_rdy));
					state   := s_unit;
				end if;
			when s_unit =>
				bs(axis_id)<= to_signed(grid_unit, b'length);
				if (to_bit(btod_req) xor to_bit(btod_rdy))='0' then
					str_req <= not str_rdy;
					case wdt_id is
					when inputs =>
						str_id  <= hz_uid;
					when others =>
						str_id  <= vt_uid;
					end case;
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

	trigger_p : process (tgrwdt_rdy,rgtr_clk)
		type states is (s_label, s_offset, s_unit, s_slope, s_mode, s_wait);
		variable state : states;
		alias btod_req  is btod_reqs(tgr_id);
		alias btod_rdy  is btod_rdys(tgr_id);
		alias mul_req   is mul_reqs(tgr_id);
		alias mul_rdy   is mul_rdys(tgr_id);
		alias str_req   is str_reqs(tgr_id);
		alias str_rdy   is str_rdys(tgr_id);
		alias str_id    is str_ids(tgr_id);
		variable trigger_mode : std_logic_vector(0 to 2-1);
	begin
		if rising_edge(rgtr_clk) then
			case state is
			when s_label =>
				bs(tgr_id)<= resize(signed(tgr_offset), offset'length);
				if (tgr_rdy xor tgr_req)='1' then
					mul_req <= not mul_rdy;
					str_req <= not str_rdy;
					str_id  <= to_integer(unsigned(trigger_chanid));
					state   := s_offset;
				end if;
			when s_offset =>
				if (mul_req xor mul_rdy)='0' then
					btod_req <= not btod_rdy;
					state    := s_unit;
				end if;
			when s_unit =>
				if (btod_req xor btod_rdy)='0' then
					str_id  <= (inputs+1)+to_integer(unsigned(vt_scaleid));
					str_req <= not str_rdy;
					state   := s_slope;
				end if;
			when s_slope =>
				if (str_req xor str_rdy)='0' then
					if tgr_slope='0' then
						str_id <= up_id;
					else
						str_id <= dn_id;
					end if;
					str_req <= not str_rdy;
					state := s_mode;
				end if;
			when s_mode =>
				if (str_req xor str_rdy)='0' then

					trigger_mode := (tgr_freeze, tgr_oneshot);
					case trigger_mode is
					when "00" =>
						str_id <= free_id;
					when "01" =>
						str_id <= norm_id;
					when "10" =>
						str_id <= freeze_id;
					when "11" =>
						str_id <= oneshot_id;
					when others =>
						report "invalid mode";
					end case;
					str_req <= not str_rdy;
					state := s_wait;
				end if;
			when s_wait =>
				if (str_req xor str_rdy)='0' then
					tgr_rdy  <= tgr_req;
					state    := s_label;
				end if;
			end case;
		end if;
	end process;

	strreq_p : process (hzwdt_rdy,rgtr_clk)
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
						str_id  <= str_ids(i);
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

	btodreq_p : process (vtwdt_rdy,rgtr_clk)
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
						btod_req <= not to_stdulogic(to_bit(btod_rdy));
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

	mulreq_p : process (vtwdt_req,rgtr_clk)
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
						mul_req <= not to_stdulogic(to_bit(mul_rdy));
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

	code_frm  <= txt_req xor txt_rdy;
	code_irdy <= (btod_frm and (btod_req xor btod_rdy)) or str_frm;
	code_data <= multiplex(btod_code & str_code, str_frm);

end;
