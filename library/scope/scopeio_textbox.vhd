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
		font_bitrom   : std_logic_vector := psf1cp850x8x16;
		font_height   : natural := 16;
		font_width    : natural := 8);
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
end;

architecture def of scopeio_textbox is

	constant cgaadapter_latency : natural := 4;

	constant analog_addr : tag_vector := text_analoginputs(inputs, analogtime_layout);
	constant font_wbits  : natural    := unsigned_num_bits(font_width-1);
	constant font_hbits  : natural    := unsigned_num_bits(font_height-1);
	constant cga_cols    : natural    := textbox_width(layout)/font_width;
	constant cga_rows    : natural    := textbox_height(layout)/font_height;
	constant cga_size    : natural    := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);

	signal we       : std_logic;
	signal cga_we       : std_logic;
	signal cga_addr     : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code     : ascii;
	signal video_addr   : std_logic_vector(cga_addr'range);
	signal char_dot     : std_logic;

	signal value        : signed(0 to 12-1);
	signal frac         : signed(value'range);
	signal scale        : std_logic_vector(0 to 2-1) := "00";

	signal field        : unsigned(0 to 2-1);
begin

	process(rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if then
			elsif rgtr_dv='1' then
				case rgtr_id =>
				when rid_gain =>
				when rid_hzaxis =>
				when rid_trigger =>
				when rid_vtaxis =>
				when others =>
				end case;
			end if;
		end if;
	end process;

	with rgtr_id select
	field <= 
		to_unsigned(0, field'length) when rid_hzaxis,
		to_unsigned(1, field'length) when rid_trigger,
		(resize(unsigned(bitfield(rgtr_data, vtchanid_id, vtoffset_bf)), field'length) sll 0)+2 when rid_vtaxis,
		(resize(unsigned(bitfield(rgtr_data, gainchanid_id,   gain_bf)), field'length) sll 0)+3 when rid_gain,
		(others => '-') when others;
   		
	with rgtr_id select
	value <= 
		resize(signed(bitfield(rgtr_data, hzoffset_id,     hzoffset_bf)), value'length) when rid_hzaxis,
--		resize(signed(bitfield(rgtr_data, hzscale_id,      hzoffset_bf)), value'length) when rid_hzaxis,
		resize(signed(bitfield(rgtr_data, trigger_level_id, trigger_bf)), value'length) when rid_trigger,
--		resize(signed(bitfield(rgtr_data, vtoffset_id,     vtoffset_bf)), value'length) when rid_vtaxis,
		resize(signed(bitfield(rgtr_data, gainid_id,           gain_bf)), value'length) when rid_gain,
		(others => '-') when others;
   		
	frm_p : process (rgtr_clk)
	begin
		if rising_edge(rgtr_clk) then
			if btof_binfrm='1' then
				if btof_bcdtrdy='1' then
					if btof_bcdend='1' then
						btof_binfrm  <= '0';
						btof_bcdirdy <= '0';
					end if;
				end if;
			elsif rgtr_dv='1' then
				btof_binfrm  <= '1';
				btof_bcdirdy <= '1';
				frac <= scale_1245(value sll 1, scale);
			end if;
		end if;
	end process;

	scopeio_float2btof_e : entity hdl4fpga.scopeio_float2btof
	port map (
		clk      => rgtr_clk,
		frac     => frac,
		exp      => x"f",
		bin_frm  => btof_binfrm,
		bin_irdy => btof_binirdy,
		bin_trdy => btof_bintrdy,
		bin_neg  => btof_binneg,
		bin_exp  => btof_binexp,
		bin_di   => btof_bindi);

	btof_bcdalign <= '1';
	btof_bcdsign  <= '1';
	btof_bcdprec  <= b"1110";
	btof_bcdunit  <= b"0000";
	btof_bcdwidth <= b"1000";

	cga_we <= btof_binfrm and btof_bcdtrdy and we;
	cga_addr_p : process (rgtr_clk)
		
		variable addr : std_logic_vector(0 to cga_addr'length);
	begin
		if rising_edge(rgtr_clk) then
			if btof_binfrm='0' then
				addr := text_addr(std_logic_vector(field), analog_addr, cga_cols, cga_rows);
				we <= addr(0);
				cga_addr <= unsigned(addr(1 to cga_addr'length));
			elsif cga_we='1' then
				cga_addr <= cga_addr + 1;
			end if;
		end if;
	end process;
	cga_code <= word2byte(to_ascii("0123456789 .+-"), btof_bcddo, ascii'length);

	video_addr <= std_logic_vector(resize(
		mul(unsigned(video_vcntr) srl font_hbits, textbox_width(layout)/font_width) +
		(unsigned(video_hcntr) srl font_wbits),
		video_addr'length));

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		cga_bitrom  => text_content(analogtime_layout, cga_cols, cga_rows, lang),
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
