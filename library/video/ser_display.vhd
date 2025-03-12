--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.cgafonts.all;
use hdl4fpga.videopkg.all;

entity ser_display is
	generic (
		font_bitrom : std_logic_vector := psf1cp850x8x16;
		font_width  : natural := 8;
		font_height : natural := 16;

		timing_id   : videotiming_ids;
		code_spce   : std_logic_vector;
		code_digits : std_logic_vector;
		cga_bitrom  : std_logic_vector := (1 to 0 => '-'));
	port (
		phy_clk     : in  std_logic;
		phy_frm     : in  std_logic;
		phy_irdy    : in  std_logic := '1';
		phy_data    : in  std_logic_vector;

		video_clk   : in  std_logic;
		video_dot   : out std_logic;
		video_on    : buffer std_logic;
		video_hs    : out std_logic;
		video_vs    : out std_logic);
end;

architecture def of ser_display is

	subtype font_code is std_logic_vector(unsigned_num_bits(font_bitrom'length/font_width/font_height-1)-1 downto 0);
	subtype digit     is std_logic_vector(0 to 4-1);

	constant fontwidth_bits  : natural := unsigned_num_bits(font_width-1);
	constant fontheight_bits : natural := unsigned_num_bits(font_height-1);
	constant display_width   : natural := modeline_tab(timing_id)(0)/font_width;
	constant display_height  : natural := modeline_tab(timing_id)(4)/font_height;

	signal video_von         : std_logic;
	signal video_hon         : std_logic;
	signal video_vcntr       : std_logic_vector(11-1 downto 0);
	signal video_hcntr       : std_logic_vector(11-1 downto 0);

	signal des_data          : std_logic_vector(2*digit'length-1 downto 0);
	signal cga_codes         : std_logic_vector(font_code'length*des_data'length/digit'length-1 downto 0);
	signal cga_code          : std_logic_vector(font_code'range);
	signal cga_we            : std_logic;
	signal cga_base          : std_logic_vector(unsigned_num_bits(display_width*display_height-1)-1 downto 0);
	signal cga_addr          : std_logic_vector(cga_base'left downto cga_base'right+unsigned_num_bits(des_data'length/digit'length)-1);

	signal des_irdy          : std_logic;

	signal hzsync            : std_logic;
	signal vtsync            : std_logic;
	signal von               : std_logic;

begin

	video_e : entity hdl4fpga.video_sync
	generic map (
		timing_id   => timing_id)
	port map (
		video_clk    => video_clk,
		video_hzsync => hzsync,
		video_vtsync => vtsync,
		video_hzcntr => video_hcntr,
		video_vtcntr => video_vcntr,
		video_hzon   => video_hon,
		video_vton   => video_von);
	von <= video_hon and video_von;

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => phy_clk,
		serdes_frm => phy_frm,
		ser_irdy   => phy_irdy,
		ser_data   => phy_data,

		des_irdy   => des_irdy,
		des_data   => des_data);

	process(phy_clk)
		variable code  : std_logic_vector(cga_codes'length-1 downto 0);
		variable addr  : unsigned(cga_addr'range) := (others => '0');
		variable we    : std_logic;
		variable data  : unsigned(des_data'reverse_range);
	begin
		if rising_edge(phy_clk) then
			cga_addr <= std_logic_vector(addr);
			cga_we   <= (phy_frm and des_irdy) or (not phy_frm and we);
			data     := unsigned(des_data);
			for i in 0 to des_data'length/digit'length-1 loop
				if phy_frm='1' then
					if des_irdy='1' then
						code(font_code'range) := multiplex(code_digits, reverse(std_logic_vector(data(digit'range))), font_code'length);
					end if;
				elsif we='1' then
					code(font_code'range) := code_spce;
				end if;
				code := std_logic_vector(unsigned(code) rol font_code'length);
				data := data rol digit'length;
			end loop;
			if phy_frm='1' then
				if des_irdy='1' then
					addr := addr + 1;
				end if;
			elsif we='1' then
				addr := addr + 1;
			end if;
			we := phy_frm;
			cga_codes <= std_logic_vector(code);
			cga_base  <= std_logic_vector(shift_left(resize(unsigned(cga_addr), cga_base'length), cga_base'length-cga_addr'length)-display_width*display_height);
		end if;
	end process;

	cga_adapter_e : entity hdl4fpga.cga_adapter
	generic map (
		display_width  => display_width,
		display_height => display_height,
		cga_bitrom     => cga_bitrom,
		font_bitrom    => psf1cp850x8x16,
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
		do(1) => video_hs,
		do(2) => video_vs);

end;
