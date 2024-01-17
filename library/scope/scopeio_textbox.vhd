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

	constant inputs        : natural := jso(layout)**".inputs";
	constant hzoffset_bits : natural := unsigned_num_bits(max_delay-1);
	constant chanid_bits   : natural := unsigned_num_bits(inputs-1);
	constant font_width    : natural := jso(layout)**".textbox.font_width";

	constant hz_unit : real := jso(layout)**".axis.horizontal.unit";
	constant vt_unit : real := jso(layout)**".axis.vertical.unit";

	-- function htmlToJson(div,obj){
		-- if(!obj){obj=[]}
		-- var tag = {}
		-- tag['tagName']=div.tagName
		-- tag['children'] = []
		-- for(var i = 0; i< div.children.length;i++){
		--    tag['children'].push(htmlToJson(div.children[i]))
		-- }
		-- for(var i = 0; i< div.attributes.length;i++){
		--    var attr= div.attributes[i]
		--    tag['@'+attr.name] = attr.value
		-- }
		-- return tag    
	--    }

	impure function textbox_mask(
		constant width : natural;
		constant size  : natural)
		return string is
		variable data   : string(1 to size);
		variable offset : positive;
		variable length : natural;
		variable i      : natural;
		variable j      : natural;

    	function stralign (
    		constant str       : string;
    		constant width     : natural;
    		constant textalign : string := "left")
    		return string is
    		variable retval : string(1 to width);
    	begin
    		
			retval := strfill(str, width);
			if textalign="right" then
				retval := rotate_left(retval, width-str'length);
			end if; 

    		return retval;
    	end;

	begin
		i := 0;
		j := data'left;
		for i in 0 to inputs-1 loop
			resolve(layout&".vt["&natural'image(i)&"].text", offset, length);
			if length=0 then
				exit;
			else
				data(j to j+width-1) := stralign(layout(offset to offset+length-1), width);
				j := j + width;
			end if;
		end loop;
		return data;
	end;

end;

architecture def of scopeio_textbox is
	subtype ascii is std_logic_vector(8-1 downto 0);
	subtype storage_word is std_logic_vector(unsigned_num_bits(grid_height(layout))-1 downto 0);
	constant division_bits      : natural := unsigned_num_bits(grid_unit(layout)-1);
	constant cgaadapter_latency : natural := 4;

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant textwidth_bits  : natural := unsigned_num_bits(textbox_width(layout)-1);
	constant cga_cols        : natural := textbox_width(layout)/font_width;
	constant cga_rows        : natural := textbox_height(layout)/font_height;
	constant cga_size        : natural := (textbox_width(layout)/font_width)*(textbox_height(layout)/font_height);
	constant cga_bitrom      : std_logic_vector := to_ascii(textbox_mask(cga_cols, cga_size));

	signal cga_we            : std_logic := '0';
	signal cga_addr          : unsigned(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal cga_code          : ascii;

	signal textfg            : std_logic_vector(text_fg'range);
	signal textbg            : std_logic_vector(text_bg'range);
	signal video_on          : std_logic;
	signal video_addr        : std_logic_vector(cga_addr'range);
	signal video_dot         : std_logic;

begin

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

	textfg <= std_logic_vector(to_unsigned(pltid_textfg, textfg'length));
	latfg_e : entity hdl4fpga.latency
	generic map (
		n =>  text_fg'length,
		d => (0 to text_fg'length-1 => latency-cgaadapter_latency+2))
	port map (
		clk => video_clk,
		di => textfg,
		do => text_fg);
	textbg <= std_logic_vector(to_unsigned(pltid_textbg, textbg'length));
	latbg_e : entity hdl4fpga.latency
	generic map (
		n => text_bg'length,
		d => (0 to text_bg'length-1 => latency-cgaadapter_latency+2))
	port map (
		clk => video_clk,
		di => textbg,
		do => text_bg);
end;
