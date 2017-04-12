library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.cgafont.all;

entity scopeio is
	port (
		mii_rxc     : in  std_logic;
		mii_rxdv    : in  std_logic;
		mii_rxd     : in  std_logic_vector;
		input_addr  : out std_logic_vector;
		input_data  : in  std_logic_vector;
		video_clk   : in  std_logic;
		video_red   : out std_logic;
		video_green : out std_logic;
		video_blue  : out std_logic;
		video_hsync : out std_logic;
		video_vsync : out std_logic;
		video_blank : out std_logic;
		video_sync  : out std_logic);
end;

architecture beh of scopeio is

	signal hdr_data     : std_logic_vector(288-1 downto 0);
	signal pld_data     : std_logic_vector(288-1 downto 0);
	signal pll_data     : std_logic_vector(0 to hdr_data'length+pld_data'length-1);
	signal ser_data     : std_logic_vector(32-1 downto 0);

	constant cga_zoom   : natural := 0;
	signal cga_we       : std_logic;
	signal cga_row      : std_logic_vector(7-1-cga_zoom downto 0);
	signal cga_col      : std_logic_vector(8-1-cga_zoom downto 0);
	signal cga_code     : std_logic_vector(8-1 downto 0);
	signal char_dot     : std_logic;

	signal video_hs     : std_logic;
	signal video_vs     : std_logic;
	signal video_frm    : std_logic;
	signal video_hon    : std_logic;
	signal video_nhl    : std_logic;
	signal video_vld    : std_logic;
	signal video_vcntr  : std_logic_vector(11-1 downto 0);
	signal video_hcntr  : std_logic_vector(11-1 downto 0);

	signal ca_dot       : std_logic;
	signal video_dot    : std_logic_vector(0 to 19-1);

	signal video_io     : std_logic_vector(0 to 3-1);
	
	signal win_don      : std_logic_vector(0 to 18-1);
	signal win_nhl      : std_logic_vector(0 to 18-1);
	signal win_frm      : std_logic_vector(0 to 18-1);
begin

	miirx_e : entity hdl4fpga.scopeio_miirx
	port map (
		mii_rxc  => mii_rxc,
		mii_rxdv => mii_rxdv,
		mii_rxd  => mii_rxd,
		pll_data => pll_data,
		ser_data => ser_data);

	process (ser_data)
		variable data : unsigned(pll_data'range);
	begin
		data     := unsigned(pll_data);
		data     := data sll hdr_data'length;
		pld_data <= reverse(std_logic_vector(data(pld_data'reverse_range)));
	end process;

	process (pld_data)
		variable data : unsigned(pld_data'range);
	begin
		data     := unsigned(pld_data);
		cga_code <= std_logic_vector(data(cga_code'range));
		data     := data srl cga_code'length;
		cga_row  <= std_logic_vector(data(cga_row'range));
		data     := data srl cga_row'length;
		cga_col  <= std_logic_vector(data(cga_col'range));
	end process;

	video_e : entity hdl4fpga.video_vga
	generic map (
		n => 11)
	port map (
		clk   => video_clk,
		hsync => video_hs,
		vsync => video_vs,
		hcntr => video_hcntr,
		vcntr => video_vcntr,
		don   => video_hon,
		frm   => video_frm,
		nhl   => video_nhl);

	video_vld <= video_hon and video_frm;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => video_io'length,
		i => (video_io'range => '-'),
		d => (video_io'range => 14))
	port map (
		clk   => video_clk,
		di(0) => video_hs,
		di(1) => video_vs,
		di(2) => video_vld,
		do    => video_io);

	video_win_e : entity hdl4fpga.video_win
	port map (
		video_clk  => video_clk,
		video_x    => video_hcntr,
		video_y    => video_vcntr,
		video_don  => video_hon,
		video_frm  => video_frm,
		win_don    => win_don,
		win_nhl    => win_nhl,
		win_frm    => win_frm);

	scopeio_channel_e : entity hdl4fpga.scopeio_channel
	generic map (
		channels   => 2,
		inputs     => 1,
		width      => 1537,
		height     => 257)
	port map (
		video_clk  => video_clk,
		video_nhl  => video_nhl,
		input_data => input_data,
		input_addr => input_addr,
		win_frm    => win_frm,
		win_on     => win_don,
		video_dot  => video_dot);

	cga_e : entity hdl4fpga.cga
	generic map (
		bitrom     => psf1cp850x8x16,
		cga_width  => 240,
		cga_height => 68,
		char_width => 8)
	port map (
		sys_clk    => video_clk,
		sys_we     => video_hon,
		sys_row    => video_vcntr(11-1 downto 11-cga_row'length),
		sys_col    => video_hcntr(11-1 downto 11-cga_col'length),
		sys_code   => cga_code,
		vga_clk    => video_clk,
		vga_row    => video_vcntr(11-1 downto cga_zoom),
		vga_col    => video_hcntr(11-1 downto cga_zoom),
		vga_dot    => char_dot);

	cga_align_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => -4+13))
	port map (
		clk   => video_clk,
		di(0) => char_dot,
		do(0) => ca_dot);

	video_red   <= video_io(2) and (video_dot(1));
	video_green <= video_io(2) and (video_dot(1));
	video_blue  <= video_io(2) and (video_dot(1) or video_dot(0));
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
