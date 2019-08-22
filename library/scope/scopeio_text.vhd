library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_text is
	generic(
		layout      : display_layout;
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_height : natural := 16;
		font_width  : natural := 8);
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
		btof_bcdunit  : out std_logic_vector;
		btof_bcdsign  : out std_logic;
		btof_bcdalign : out std_logic;
		btof_bcdfrm   : in  std_logic;
		btof_bcdirdy  : buffer  std_logic;
		btof_bcdtrdy  : in  std_logic;
		btof_bcdend   : in  std_logic;
		btof_bcddo    : in  std_logic_vector;

		video_hcntr   : in std_logic_vector;
		video_vcntr   : in std_logic_vector;
		text_on       : in  std_logic := '1';
		text_dot      : out std_logic);
end;

architecture def of scopeio_text is

	constant layout        : display_layout := displaylayout_table(video_description(vlayout_id).layout_id);
	constant cga_size      : natural := textbox_width(layout)*textbox_height(layout)/(font_width*font_height);

	signal cga_addr        : std_logic_vector(unsigned_num_bits(cga_size-1)-1 downto 0);
	signal video_addr      : std_logic_vector(cga_addr'range);

	signal font_hcntr      : std_logic_vector(unsigned_num_bits(font_width-1)-1 downto 0);
	signal font_vcntr      : std_logic_vector(unsigned_num_bits(font_height-1)-1 downto 0);

	signal vt_dv           : std_logic;
	signal vt_offsets      : std_logic_vector(inputs*(5+8)-1 downto 0);
	signal vt_chanid       : std_logic_vector(chanid_maxsize-1 downto 0);

	constant division_bits : natural := unsigned_num_bits(division_size-1);
	constant vttick_bits   : natural := unsigned_num_bits(8*font_size-1);
	constant vtstep_bits   : natural := setif(vtaxis_tickrotate(layout)=ccw0, division_bits, vttick_bits);
	constant vtheight_bits : natural := unsigned_num_bits((vt_height-1)-1);

	signal vt_scale     : std_logic_vector(gain_ids'length/inputs-1 downto 0);
	signal vt_offset : std_logic_vector(vt_offsets'length/inputs-1 downto 0);


begin

	scopeio_rgtrvtaxis_e : entity hdl4fpga.scopeio_rgtrvtaxis
	generic map (
		inputs  => inputs)
	port map (
		rgtr_clk   => rgtr_clk,
		rgtr_dv    => rgtr_dv,
		rgtr_id    => rgtr_id,
		rgtr_data  => rgtr_data,

		vt_dv      => vt_dv,
		vt_chanid  => vt_chanid,
		vt_offsets => vt_offsets);

	bindi_p : process (rgtr_clk)
		variable sel : unsigned(0 to unsigned_num_bits(binvalue'length/btof_bindi'length)-1) := (others => '0');
	begin
		if rising_edge(rgtr_clk) then
			if btof_binfrm='0' then
				sel := (others => '0');
			elsif btof_bintrdy='1' then
				sel := sel + 1;
			end if;

			btof_bindi <= word2byte(
				scale_1245(neg(std_logic_vector(binvalue), binvalue(binvalue'left)), scale) & x"f",
				std_logic_vector(sel), 
				btof_bindi'length);
			btof_binexp <= setif(sel >= binvalue'length/btof_bindi'length);

		end if;
	end process;

	cga_we <= btof_bcdfrm and btof_bcdirdy and btof_bcdtrdy and btof_bcdend;
	video_addr_p : process (video_hcntr, video_vcntr)
		variable addr : unsigned(video_vcntr'length-1 downto 0);
		variable col  : unsigned(video_hctnr'length-1 downto 0);
	begin
		addr := unsigned(video_vcntr);
		addr := addr srl font_vcntr'length;
		addr := mul(row, textbox_width/font_width);
		col  := unsigned(video_hcntr) srl font_hcntr'length;
		addr := addr + col;
		video_addr <= addr;
	end process;

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		font_bitrom => font_bitrom,
		font_height => font_height,
		font_width  => font_width)
	port map (
		cga_clk  => rgtr_clk,
		cga_we   => cga_we,
		cga_addr => cga_addr,
		cga_data => 

		video_clk  => video_clk,
		video_addr => video_addr,
		font_hcntr => video_hcntr(font_hcntr'range),
		font_vcntr => video_vcntr(font_vcntr'range),
		video_hon  => text_on,
		video_dot  => text_dot);



end;
