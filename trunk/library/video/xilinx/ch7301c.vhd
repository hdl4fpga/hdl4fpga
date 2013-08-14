library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga2ch7301c_iob is
	port (
		vga_clk : in std_logic;
		vga_clk90 : in std_logic;
		vga_hsync : in std_logic;
		vga_vsync : in std_logic;
		vga_blank : in std_logic;
		vga_frm   : in std_logic;
		vga_red : in std_logic_vector(8-1 downto 0);
		vga_green : in std_logic_vector(8-1 downto 0);
		vga_blue  : in std_logic_vector(8-1 downto 0);

		dvi_xclk_p : out std_logic;
		dvi_xclk_n : out std_logic;
		dvi_v : inout std_logic;
		dvi_h : inout std_logic;
		dvi_de : out std_logic;
		dvi_d : out std_logic_vector(12-1 downto 0));
end;

library unisim;
use unisim.vcomponents.all;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of vga2ch7301c_iob is
	signal dvi_clk : std_logic;
	signal dvi_rword : std_logic_vector(dvi_d'range);
	signal dvi_fword : std_logic_vector(dvi_d'range);
	signal h : std_logic;
	signal v : std_logic;
begin
	h <= not (vga_hsync and (vga_frm xor vga_vsync));

	dvi_h_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => vga_clk,
		ce => '1',
		d  => h,
		q  => dvi_h);

	v <= not vga_vsync;
	dvi_v_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => vga_clk,
		ce => '1',
		d  => v,
		q  => dvi_v);

	dvi_de_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => vga_clk,
		ce => '1',
		d  => vga_blank,
		q  => dvi_de);

	dvi_xclk_obufds : obufds
	generic map (
		iostandard => "DIFF_SSTL2_I")
	port map (
		i  => dvi_clk,
		o  => dvi_xclk_p,
		ob => dvi_xclk_n);

	dvi_clk_i : oddr
	port map (
		r => '0',
		s => '0',
		c => vga_clk90,
		ce => '1',
		d1 => '1',
		d2 => '0',
		q => dvi_clk);

	dvi_rword <= (vga_green(4-1 downto 0) & vga_blue) and vga_blank;
	dvi_fword <= (vga_red & vga_green(8-1 downto 4)) and vga_blank; 

	dviddr_g : for i in dvi_d'range generate
		dac_clk_i : oddr
		port map (
			r => '0',
			s => '0',
			c => vga_clk,
			ce => '1',
			d1 => dvi_rword(i),
			d2 => dvi_fword(i),
			q => dvi_d(i));
	end generate;
end;
