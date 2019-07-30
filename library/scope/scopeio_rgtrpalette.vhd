library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtrpalette is
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		palette_dv      : out std_logic;
		palette_id      : out std_logic_vector;
		palette_color   : out std_logic_vector);
	

end;

architecture def of scopeio_rgtrpalette is
begin

	palette_dv    <= rgtr_dv when rgtr_id=rid_palette else '0';
	palette_id    <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, paletteid_id,    palette_bf)), palette_id'length));
	palette_color <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, palettecolor_id, palette_bf)), palette_color'length));

end;
