
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.jso.all;
use hdl4fpga.scopeiopkg.all;
use hdl4fpga.textboxpkg.all;
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

		time_ena      : in  std_logic;
		time_scale    : in  std_logic_vector;
		time_offset   : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_hcntr   : in  std_logic_vector;
		video_vcntr   : in  std_logic_vector;
		sgmntbox_ena  : in  std_logic_vector;
		text_on       : in  std_logic := '1';
		text_fg       : out std_logic_vector;
		text_bg       : out std_logic_vector;
		text_fgon     : out std_logic);

	constant inputs        : natural := jso(layout)**".inputs";
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant font_width    : natural := jso(layout)**".textbox.font_width";

	constant hz_unit : real := jso(layout)**".axis.horizontal.unit";
	constant vt_unit : real := jso(layout)**".axis.vertical.unit";

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

	impure function textbox_rom (
		constant width  : natural;
		constant size   : natural)
		return string is
		variable data   : string(1 to size);
		variable offset : positive;
		variable length : natural;
		variable i      : natural;
		variable j      : natural;
	begin
		i := 0;
		j := data'left;
		for i in 0 to inputs-1 loop
			resolve(layout&".vt["&natural'image(i)&"].text", offset, length);
			if length=0 then
				exit;
			else
				data(j to j+width-1) := textalign(layout(offset to offset+length-1), width);
				j := j + width;
			end if;
		end loop;
		return data;
	end;

	impure function textbox_field (
		constant width  : natural;
		constant size   : natural)
		return natural_vector is
		variable retval : natural_vector(0 to inputs-1);
	begin
		retval(0) := width;
		for i in 1 to inputs-1 loop
			retval(i) := retval(i-1) + width;
		end loop;
		return retval;
	end;

	function xxx (
		constant unit : real)
		return string is
		variable exp   : integer;
		variable mant  : real;
		variable rndd  : natural; --Lattice Diamond fix
		constant tenth : real := 1.0/10.0;
	begin
		exp  := 0;
		mant := unit;
		assert unit > 0.0 
			report "unit <= 0.0"
			severity failure;
		loop
			if abs(mant-round(mant)) > 1.0e-12 then
				mant := mant / tenth;
				exp  := exp  + 1;
			else
				exit;
			end if;
		end loop;
		rndd := natural(round(mant)); --Lattice Diamond fix
		return "{mant:" & natural'image(rndd) & ",exp:" & integer'image(exp) & "}";
	end;

	function yyy (
		constant unit : real)
		return natural_vector is
		constant zzz    : real_vector(0 to 4-1) := (1.0, 2.0, 4.0, 5.0);
		variable retval : natural_vector(0 to 4-1);
	begin

		for i in zzz'range loop
			retval(i) := (jso(xxx(unit*zzz(i)))**".mant");
		end loop;
		return retval;
	end;

	constant hhh : natural_vector := yyy(vt_unit);
	constant hhh_length : natural := unsigned_num_bits(max(hhh)-1);
end;

architecture def of scopeio_textbox is
	subtype ascii is std_logic_vector(8-1 downto 0);
	constant cgaadapter_latency : natural := 4;
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant textwidth_bits  : natural := unsigned_num_bits(textbox_width(layout)-1);
	constant cga_cols        : natural := textbox_width(layout)/font_width;
	constant cga_rows        : natural := textbox_height(layout)/font_height;
	constant cga_size        : natural := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);
	constant cga_bitrom      : std_logic_vector := to_ascii(textbox_rom(cga_cols, cga_size));

	signal cga_we            : std_logic := '0';
	signal cga_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code          : ascii;

	signal textfg            : std_logic_vector(text_fg'range);
	signal textbg            : std_logic_vector(text_bg'range);
	signal video_on          : std_logic;
	signal video_addr        : std_logic_vector(cga_addr'range);
	signal video_dot         : std_logic;

	signal bcd_code          : ascii;
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

		signal chan_id        : std_logic_vector(chanid_maxsize-1 downto 0);
		signal vt_exp         : integer;
		signal vt_dv          : std_logic;
		signal vt_ena         : std_logic;
		signal vt_offset      : std_logic_vector((5+8)-1 downto 0);
		signal vt_offsets     : std_logic_vector(0 to inputs*vt_offset'length-1);
		signal vt_chanid      : std_logic_vector(chan_id'range);
		signal vt_scale       : std_logic_vector(4-1 downto 0);
		signal tgr_scale      : std_logic_vector(4-1 downto 0);

		constant bin_digits   : natural := 3;
		constant bcd_width    : natural := 8;
		constant bcd_length   : natural := 4;
		constant bcd_digits   : natural := 1;
		signal bcd            : std_logic_vector(0 to bcd_digits*bcd_length-1);
		-- signal bin            : std_logic_vector(0 to bin_digits*((vt_offset'length+vt_scale'length+bin_digits-1)/bin_digits)-1);
		signal bin            : std_logic_vector(0 to bin_digits*((vt_offset'length+hhh_length+bin_digits-1)/bin_digits)-1);
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

		xxx_b : block

			signal positive    : signed(vt_offset'range);
			signal mul_req     : std_logic;
			signal mul_rdy     : std_logic;
			signal dbdbbl_req  : std_logic;
			signal dbdbbl_rdy  : std_logic;

			signal scale : std_logic_vector(0 to hhh_length-1);

        	signal sll_frm  : std_logic;
        	signal sll_bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

       		signal slr_bcd : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
			signal slr_ini : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

        	signal slr_frm  : std_logic;
        	signal slr_irdy : std_logic;
        	signal slr_trdy : std_logic;

        	signal slrbcd_trdy : std_logic;
        	signal slrbcd      : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

        	signal code_frm : std_logic;
        	signal code     : std_logic_vector(0 to 8-1);

		begin

			process (rgtr_clk)
			begin
				if rising_edge(rgtr_clk) then
					if vt_dv='1' then
						mul_req <= not mul_rdy;
					elsif gain_dv='1' then
						mul_req <= not mul_rdy;
					end if;
				end if;
			end process;

			positive <=
				-signed(vt_offset) when vt_offset(vt_offset'left)='1' else
				 signed(vt_offset);

			scale <= std_logic_vector(to_unsigned(hhh(to_integer(unsigned(vt_scale))), scale'length));
			mul_ser_e : entity hdl4fpga.mul_ser
			generic map (
				lsb => true)
			port map (
				clk => rgtr_clk,
				req => mul_req,
				rdy => mul_rdy,
				a   => scale,
				b   => std_logic_vector(positive),
				s   => bin);

			dbdbbl_req <= mul_rdy;
			dbdbbl_seq_e : entity hdl4fpga.dbdbbl_seq
			generic map (
				bcd_width  => bcd_width,
				bcd_digits => bcd_digits)
			port map (
				clk  => rgtr_clk,
				req  => dbdbbl_req,
				rdy  => dbdbbl_rdy,
				-- bin  => bin,
		bin      => std_logic_vector(to_unsigned(1,15)), -- b"1001110",
				bcd_frm => sll_frm,
				bcd  => sll_bcd);
	
    	lifo_b : block
    		port (
    			clk      : in  std_logic;
    			sll_frm  : in  std_logic;
    			sll_bcd  : in  std_logic_vector;
    			slr_frm  : buffer std_logic;
    			slr_irdy : buffer std_logic;
    			slr_trdy : in  std_logic;
    			slr_bcd  : buffer std_logic_vector);
    		port map (
    			clk      => rgtr_clk,
    			sll_frm  => sll_frm,
    			sll_bcd  => sll_bcd,
				slr_frm  => slr_frm,
    			slr_irdy => slr_irdy,
    			slr_trdy => slr_trdy,
    			slr_bcd  => slr_bcd);
    		signal lifo_ov  : std_logic;
    	begin
    		lifo_e : entity hdl4fpga.lifo
    		port map (
    			clk       => clk,
    			ov        => lifo_ov,
    			push_ena  => sll_frm,
    			push_data => sll_bcd,
    			pop_ena   => slr_irdy,
    			pop_data  => slr_bcd);

    		process (sll_frm, slr_trdy, slr_bcd, lifo_ov, clk)
    			type states is (s_popped, s_pushed);
    			variable state : states;
    			variable cntr : integer range -1 to 4 := -1;
    		begin
    			if rising_edge(clk) then
    				if sll_frm='0' then
    					case state is
    					when s_pushed =>
    						if lifo_ov='1' then
    							if cntr >= 0 then
    								cntr := cntr - 1;
    							end if;
    							state := s_popped;
    						else
    							cntr := xxx;
    						end if;
    					when s_popped =>
    						if cntr >= 0 then
    							cntr := cntr - 1;
    						end if;
    					end case;
    				else
    					state := s_pushed;
    				end if;
    			end if;

    			case state is
    			when s_popped =>
    				if cntr >= 0 then 
    					slr_frm  <= '1';
    					slr_irdy <= '1';
    				else
    					slr_frm  <= '0';
    					slr_irdy <= '0';
    				end if;
    				slr_ini  <= (others => '0');
    			when s_pushed =>
    				if sll_frm='1' then
    					slr_frm  <= '0';
    					slr_irdy <= '0';
    					slr_ini  <= slr_bcd;
    				elsif lifo_ov='1' then
    					if cntr >= 0 then 
    						slr_frm  <= '1';
    						slr_irdy <= '1';
    						slr_ini  <= x"e";
    					else
    						slr_frm  <= '0';
    						slr_irdy <= '0';
    						slr_ini  <= (others => '0');
    					end if;
    				else
    					slr_frm  <= '1';
    					if slr_trdy='0' then
    						slr_irdy <= '0';
    					else
    						slr_irdy <= '1';
    					end if;
    					slr_ini  <= slr_bcd;
    				end if;
    			end case;

				slr_ini <= x"e";
    		end process;
    	end block;

        	dbdbblsrl_ser_e : entity hdl4fpga.dbdbblsrl_ser
        	generic map (
        		bcd_width  => bcd_width,
        		bcd_digits => bcd_digits)
        	port map (
        		clk  => rgtr_clk,
        		frm  => slr_frm,
        		irdy => slr_irdy,
        		trdy => slr_trdy,
        		cnt  => b"101",
        		ini  => slr_ini,
        		bcd_trdy => slrbcd_trdy,
        		bcd  => slrbcd);

			format_e : entity hdl4fpga.format
			generic map (
				max_width => bcd_width)
			port map (
				tab      => to_ascii("0123456789 +-,."),
				neg      => vt_offset(vt_offset'left),
				clk      => rgtr_clk,
				bcd_frm  => slr_frm,
				bcd_irdy => slr_irdy,
				bcd_trdy => slrbcd_trdy,
				bcd      => slrbcd,
				code_frm => cga_we,
				code     => cga_code);
		end block;

		process (rgtr_clk)
			constant dn : std_logic := '0';
		begin
			if rising_edge(rgtr_clk) then
				if cga_we='1' then
					if dn='0' then
						cga_addr <= cga_addr + 1;
					else
						cga_addr <= cga_addr - 1;
					end if;
				else
					cga_addr <= to_unsigned(0, cga_addr'length);
				end if;
			end if;
		end process;
	
	end block;

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl fontheight_bits, textbox_width(layout)/font_width) +
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
		cga_data     => cga_code,

		video_clk    => video_clk,
		video_addr   => video_addr,
		font_hcntr   => video_hcntr(unsigned_num_bits(font_width-1)-1 downto 0),
		font_vcntr   => video_vcntr(unsigned_num_bits(font_height-1)-1 downto 0),
		video_on     => video_on,
		video_dot    => video_dot);

	lat_e : entity hdl4fpga.latency
	generic map (
		n => 1,
		d => (0 => latency-cgaadapter_latency))
	port map (
		clk => video_clk,
		di(0) => video_dot,
		do(0) => text_fgon);

	process (video_clk)
		constant field_addr : natural_vector := textbox_field(cga_cols, cga_size);
		variable field_id   : unsigned(0 to unsigned_num_bits(field_addr'length-1)-1);
		variable addr       : std_logic_vector(video_addr'range);
	begin
		if rising_edge(video_clk) then
			textfg <= std_logic_vector(resize(field_id, textfg'length)+pltid_order'length);
			if unsigned(addr)=field_addr(to_integer(field_id)) then
				if video_on='1' then
					if field_id /= field_addr'length-1 then
						field_id := field_id + 1;
					else
						field_id := (others => '0');
					end if;
				end if;
			end if;
			addr := video_addr;
		end if;
	end process;

	textbg <= std_logic_vector(to_unsigned(pltid_textbg, textbg'length));

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
