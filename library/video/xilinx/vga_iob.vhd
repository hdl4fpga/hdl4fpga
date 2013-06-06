library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_iob is
	port (
		sys_clk   : in std_logic;
		sys_hsync : in std_logic;
		sys_vsync : in std_logic;
		sys_sync  : in std_logic;
		sys_blank : in std_logic;
		sys_psave : in std_logic;

		sys_red   : in std_logic_vector;
		sys_green : in std_logic_vector;
		sys_blue  : in std_logic_vector;

		vga_clk   : out std_logic;
		vga_hsync : out std_logic;
		vga_vsync : out std_logic;

		dac_blank : out std_logic;
		dac_sync  : out std_logic;
		dac_psave : out std_logic;

		dac_red   : out std_logic_vector;
		dac_green : out std_logic_vector;
		dac_blue  : out std_logic_vector);
end;

library unisim;
use unisim.vcomponents.all;

architecture def of vga_iob is
	subtype dac_word is std_logic_vector(0 to dac_red'length-1);
	signal sys_fclk : std_logic;

	signal sy_red,   da_red   : dac_word;
	signal sy_green, da_green : dac_word;
	signal sy_blue,  da_blue  : dac_word;

begin
	sys_fclk <= not sys_clk;

	dac_clk_i : oddr2
	port map (
		r  => '0',
		s  => '0',
		c0 => sys_clk,
		c1 => sys_fclk,
		ce => '1',
		d0 => '0',
		d1 => '1',
		q  => vga_clk);

	dac_blank_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => sys_clk,
		ce => '1',
		d  => sys_blank,
		q  => dac_blank);

	dac_hsync_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => sys_clk,
		ce => '1',
		d  => sys_hsync,
		q  => vga_hsync);

	dac_vsync_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => sys_clk,
		ce => '1',
		d  => sys_vsync,
		q  => vga_vsync);

	dac_sync_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => sys_clk,
		ce => '1',
		d  => sys_sync,
		q  => dac_sync);

	dac_psave_i : fdrse
	port map (
		s  => '0',
		r  => '0',
		c  => sys_clk,
		ce => '1',
		d  => sys_psave,
		q  => dac_psave);

	sy_red   <= sys_red;
	sy_green <= sys_green;
	sy_blue  <= sys_blue;

	rgb_g : for i in dac_word'range generate
		ffd_red : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => sys_clk,
			ce => '1',
			d  => sy_red(i),
			q  => da_red(i));

		ffd_green : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => sys_clk,
			ce => '1',
			d  => sy_green(i),
			q  => da_green(i));

		ffd_blue : fdrse
		port map (
			s  => '0',
			r  => '0',
			c  => sys_clk,
			ce => '1',
			d  => sy_blue(i),
			q  => da_blue(i));
	end generate;

	dac_red   <= da_red;
	dac_green <= da_green;
	dac_blue  <= da_blue;
end;
