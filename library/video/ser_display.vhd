-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.hdo.all;
use hdl4fpga.base.all;
use hdl4fpga.cgafonts.all;
use hdl4fpga.videopkg.all;

entity ser_display is
	generic (
		font_bitdata   : std_logic_vector := psf1cp850x8x16;
		font_width    : natural := 8;
		font_height   : natural := 16;

		timings       : string;
		code_spce     : std_logic_vector;
		code_digits   : std_logic_vector;
		cga_bitdata    : std_logic_vector := (1 to 0 => '-'));
	port (
		phy_clk       : in  std_logic;
		phy_frm       : in  std_logic;
		phy_irdy      : in  std_logic := '1';
		phy_data      : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_dot     : out std_logic;
		video_on      : buffer std_logic;
		video_hzsync  : out std_logic;
		video_vtsync  : out std_logic);
end;

architecture def of ser_display is

	subtype font_code is std_logic_vector(unsigned_num_bits(font_bitdata'length/font_width/font_height-1)-1 downto 0);
	subtype digit     is std_logic_vector(0 to 4-1);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant display_width   : natural := hdo(timings)**".hz.active"/font_width;
	constant display_height  : natural := hdo(timings)**".vt.active"/font_height;

	signal video_von         : std_logic;
	signal video_hon         : std_logic;
	signal video_vcntr       : std_logic_vector(11-1 downto 0);
	signal video_hcntr       : std_logic_vector(11-1 downto 0);

	signal des_irdy          : std_logic;
	signal des_data          : std_logic_vector(2*digit'length-1 downto 0);
	signal cga_codes         : std_logic_vector(font_code'length*des_data'length/digit'length-1 downto 0);
	signal cga_we            : std_logic;
	signal cga_base          : std_logic_vector(unsigned_num_bits(display_width*display_height-1)-1 downto 0);
	signal cga_addr          : std_logic_vector(cga_base'left downto cga_base'right+unsigned_num_bits(des_data'length/digit'length)-1);

	signal hzsync            : std_logic;
	signal vtsync            : std_logic;
	signal von               : std_logic;

begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		timings      => timings)
	port map (
		video_clk    => video_clk,
		video_hzsync => hzsync,
		video_vtsync => vtsync,
		video_hzcntr => video_hcntr,
		video_vtcntr => video_vcntr,
		video_hzon   => video_hon,
		video_vton   => video_von);
	von <= video_hon and video_von;

	sellzr_i : entity hdl4fpga.serlzr
	generic map (
		lsdfirst => false)
	port map (
		src_clk   => phy_clk,
		src_frm   => phy_frm,
		src_irdy  => phy_irdy,
		src_data  => phy_data,
		dst_clk   => phy_clk,
		dst_irdy  => des_irdy,
		dst_data  => des_data);

	process (phy_frm, des_irdy, phy_clk)
		variable we : std_logic;
	begin
		if rising_edge(phy_clk) then
			we := phy_frm or des_irdy;
		end if;
		cga_we <= des_irdy or (we and not phy_frm);
	end process;

	process(phy_frm, phy_clk)
		variable addr  : unsigned(cga_addr'range) := (others => '0');
	begin
		if rising_edge(phy_clk) then
			if cga_we='1' then
				addr := addr + 1;
			end if;
			cga_addr <= std_logic_vector(addr);
			cga_base <= std_logic_vector(shift_left(resize(unsigned(cga_addr), cga_base'length), cga_base'length-cga_addr'length)-display_width*display_height);
		end if;
	end process;

	process(phy_frm, des_irdy, phy_irdy, cga_we, des_data)
		-- variable data : unsigned(des_data'reverse_range); Xilinx 14.7 buggy
		variable data : unsigned(0 to des_data'length-1);
		variable code : unsigned(cga_codes'length-1 downto 0);
	begin
		data := unsigned(des_data);
		code := (code'range => '-');
		for i in 0 to des_data'length/digit'length-1 loop
			code(font_code'range) := unsigned(multiplex(code_digits, reverse(std_logic_vector(data(digit'range))), font_code'length));
			if (cga_we and not (phy_frm or des_irdy))='1' then
				code(font_code'range) := unsigned(code_spce);
			end if;
			code := rotate_left(code, font_code'length);
			data := rotate_left(data, digit'length);
		end loop;
		cga_codes <= std_logic_vector(code);
	end process;

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		display_width  => display_width,
		display_height => display_height,
		cga_bitdata    => cga_bitdata,
		font_bitdata   => psf1cp850x8x16,
		font_height    => font_height,
		font_width     => font_width)
	port map (
		cga_clk   => phy_clk,
		cga_we    => cga_we,
		cga_addr  => cga_addr,
		cga_data  => cga_codes,
		cga_base  => cga_base,

		video_clk => video_clk,
		video_hon => video_hon,
		video_von => video_von,
		video_dot => video_dot);

	video_lat_e : entity hdl4fpga.latency
	generic map (
		n => 3,
		d => (0 to 3-1 => 4))
	port map (
		clk => video_clk,
		di(0) => von,
		di(1) => hzsync,
		di(2) => vtsync,
		do(0) => video_on,
		do(1) => video_hzsync,
		do(2) => video_vtsync);

end;
