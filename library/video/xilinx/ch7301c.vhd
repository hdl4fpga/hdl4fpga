library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga2ch7301c_iob is
	port (
		vga_clk : in std_logic;
		vga_hsync : in std_logic;
		vga_vsync : in std_logic;
		vga_blank : in std_logic;
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

architecture def of vga2ch7301_iob is
	signal sys_fclk  : std_logic;
	signal dvi_rword : std_logic_vector(dvi_d'range);
	signal dvi_fword : std_logic_vector(dvi_d'range);
begin
	vga_clk <= not vga_clk;

	dvi_h_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => vga_clk,
		ce => '1',
		d  => vga_hsync,
		q  => dvi_h);

	dvi_v_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => vga_clk,
		ce => '1',
		d  => vga_vsync,
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
		i  => vga_clk,
		o  => dvi_xclk_p,
		ob => dvi_xclk_n);

	dvi_rword <= sys_green(4-1 downto 0) & sys_blue;
	dvi_fword <= sys_read & sys_green(8-1 downto 4); 

	dviddr_g : for i in dvi_d'range generate
		dac_clk_i : oddr2
		port map (
			r  => '0',
			s  => '0',
			c0 => vga_clk,
			c1 => vga_fclk,
			ce => '1',
			d0 => dvi_rword,
			d1 => dvi_fword,
			q  => dvi_d);
	end generate;
end;
