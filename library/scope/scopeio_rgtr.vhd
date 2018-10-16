library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_rgtr is
	port (
		clk           : in  std_logic;
		rgtr_dv       : in  std_logic;
		rgtr_id       : in  std_logic_vector(8-1 downto 0);
		rgtr_data     : in  std_logic_vector;

		axis_dv       : out std_logic;
		axis_sel      : out std_logic;
		axis_scale    : out std_logic_vector;
		axis_base     : out std_logic_vector;
		hz_offset     : out std_logic_vector;
		vt_offset     : out std_logic_vector;

		palette_dv    : out std_logic;
		palette_id    : out std_logic_vector;
		palette_color : out std_logic_vector);


end;

architecture def of scopeio_rgtr is

	function bf (
		constant bf_data   : std_logic_vector;
		constant bf_id     : natural;
		constant bf_dscptr : natural_vector)
		return   std_logic_vector is
		variable retval : unsigned(bf_data'length-1 downto 0);
		variable dscptr : natural_vector(0 to bf_dscptr'length-1);
	begin
		dscptr := bf_dscptr;
		retval := unsigned(bf_data);
		if bf_data'left > bf_data'right then
			for i in bf_dscptr'range loop
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
				retval := retval ror bf_dscptr(i);
			end loop;
		else
			for i in bf_dscptr'range loop
				retval := retval rol bf_dscptr(i);
				if i=bf_id then
					return std_logic_vector(retval(bf_dscptr(i)-1 downto 0));
				end if;
			end loop;
		end if;
		return (0 to 0 => '-');
	end;

	constant palette_bf  : natural_vector := (0, 4);
	constant rid_axis    : std_logic_vector := x"10";
	constant rid_palette : std_logic_vector := x"11";

	signal axis_ena    : std_logic;
	signal palette_ena : std_logic;
begin

	decode_p : process (clk, rgtr_dv)
		variable axis_dec    : std_logic;
		variable palette_dec : std_logic;
	begin
		if rising_edge(clk) then
			axis_dec    := '0';
			palette_dec := '0';
			case rgtr_id is
			when rid_axis =>
				axis_dec    := '1';
			when rid_palette =>
				palette_dec := '1';
			when others =>
			end case;

		end if;
		axis_ena    <= rgtr_dv and axis_dec; 
		palette_ena <= rgtr_dv and palette_dec; 
	end process;

	axis_p : process(clk)
		constant origin_id   : natural := 0;
		constant scale_id    : natural := 1;
		constant select_id   : natural := 2;
		constant axis_bf     : natural_vector := (origin_id  => 16, scale_id => 4, select_id => 1);

		constant offset_id   : natural := 0;
		constant base_id     : natural := 1;
		constant vtoffset_bf : natural_vector := (offset_id => 8, base_id => 5);
		constant hzoffset_bf : natural_vector := (offset_id => 9, base_id => 5);

		variable origin : std_logic_vector(16-1 downto 0);
	begin
		if rising_edge(clk) then
			axis_dv <= '0';
			if axis_ena='1' then
				axis_scale <= bf(rgtr_data, scale_id,  axis_bf);
				origin     := bf(rgtr_data, origin_id, axis_bf);
				if bf(rgtr_data, select_id, axis_bf)="1" then
					axis_sel  <= '1';
					origin    := std_logic_vector(unsigned(origin)-(3*32));
					axis_base <= bf(origin, base_id,   vtoffset_bf);
					vt_offset <= bf(origin, offset_id, vtoffset_bf);
				else
					axis_sel  <= '0';
					axis_base <= bf(origin, base_id,   hzoffset_bf);
					hz_offset <= bf(origin, offset_id, hzoffset_bf);
				end if;
				axis_dv <= axis_ena;
			end if;
		end if;
	end process;

	palette_p : block
		constant id_id    : natural := 0;
		constant color_id : natural := 1;

		constant palette_bf : natural_vector := (id_id => palette_id'length, color_id => palette_id'length);
	begin
		palette_dv    <= palette_ena;
		palette_id    <= bf(rgtr_data, id_id,    palette_bf);
		palette_color <= bf(rgtr_data, color_id, palette_bf);
	end block;

end;
