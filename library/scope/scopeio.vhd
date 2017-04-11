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
	signal video_don    : std_logic;
	signal video_nhl    : std_logic;
	signal video_vld    : std_logic;
	signal video_vcntr  : std_logic_vector(11-1 downto 0);
	signal video_hcntr  : std_logic_vector(11-1 downto 0);

	signal ca_dot       : std_logic;
	signal video_dot    : std_logic;

	signal video_io     : std_logic_vector(0 to 3-1);
	signal input_addr   : std_logic_vector(11-1 downto 0);
	
	constant sample_size : natural := 11;

	function sinctab (
		constant x0 : integer;
		constant x1 : integer;
		constant n  : integer)
		return std_logic_vector is
		variable y   : real;
		variable aux : std_logic_vector(0 to n*(x1-x0+1)-1);
	begin
		for i in 0 to x1-x0 loop
			if (i+x0) /= 0 then
				y := sin(real((i+x0))/100.0)/(real((i+x0))/100.0);
			else
				y := 1.0;
			end if;
			aux(i*n to (i+1)*n-1) := std_logic_vector(to_unsigned(integer(-real(2**(n-3))*y)+2**(n-3),n));
		end loop;
		return aux;
	end;

	signal samples_doa : std_logic_vector(sample_size-1 downto 0);
	signal samples_dib : std_logic_vector(sample_size-1 downto 0);
	signal sample      : std_logic_vector(sample_size-1 downto 0);

	signal sys_clk     : std_logic;
	signal win_don     : std_logic_vector(0 to 18-1);
	signal win_nhl     : std_logic_vector(0 to 18-1);
	signal win_frm     : std_logic_vector(0 to 18-1);
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
		don   => video_don,
		frm   => video_frm,
		nhl   => video_nhl);

	video_vld <= video_don and video_frm;

	vgaio_e : entity hdl4fpga.align
	generic map (
		n => video_io'length,
		i => (video_io'range => '-'),
		d => (video_io'range => 13))
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
		video_don  => video_don,
		video_frm  => video_frm,
		win_don    => win_don,
		win_nhl    => win_nhl,
		win_frm    => win_frm);

	samples_e : entity hdl4fpga.rom
	generic map (
		bitrom => sinctab(-960, 1087, sample_size))
	port map (
		clk  => video_clk,
		addr => input_addr,
		data => sample);

	scopeio_channel_e : entity hdl4fpga.scopeio_channel
	generic map (
		channels   => 2,
		inputs     => 1,
		width      => 1536,
		height     => 1080)
	port map (
		video_clk  => video_clk,
		video_nhl  => video_nhl,
		input_data => sample,
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
		sys_we     => video_don,
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

	video_red   <= video_io(2) and video_dot;
	video_green <= video_io(2) and video_dot;
	video_blue  <= video_io(2) and video_dot;
	video_blank <= video_io(2);
	video_hsync <= video_io(0);
	video_vsync <= video_io(1);
	video_sync  <= not video_io(1) and not video_io(0);

end;
