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
		hz_scale      : out std_logic_vector;
		hz_base       : out std_logic_vector;
		hz_offset     : out std_logic_vector;
		vt_offset     : out std_logic_vector;

		palette_dv    : out std_logic;
		palette_id    : out std_logic_vector;
		palette_color : out std_logic_vector;
	
		gain_dv       : out std_logic;
		gain_id       : out std_logic_vector;
		gain_chanid   : out std_logic_vector;

		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_chanid  : out std_logic_vector;
		trigger_level   : out std_logic_vector;
		trigger_edge    : out std_logic);
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

	constant rid_axis    : std_logic_vector := x"10";
	constant rid_palette : std_logic_vector := x"11";
	constant rid_trigger : std_logic_vector := x"12";
	constant rid_gain    : std_logic_vector := x"13";

	constant axis_enid    : natural := 0;
	constant palette_enid : natural := 1;
	constant gain_enid    : natural := 2;
	constant trigger_enid : natural := 3;

	constant last_id    : natural := trigger_enid+1;

	signal ena : std_logic_vector(0 to last_id-1);
begin

	decode_p : process (clk, rgtr_dv)
		variable dec : std_logic_vector(0 to last_id-1);
	begin
		if rising_edge(clk) then
			dec := (others => '0');
			case rgtr_id is
			when rid_axis =>
				dec(axis_enid)    := '1';
			when rid_palette =>
				dec(palette_enid) := '1';
			when rid_gain =>
				dec(gain_enid)    := '1';
			when rid_trigger =>
				dec(trigger_enid) := '1';
			when others =>
			end case;
		end if;

		for id in 0 to last_id-1 loop
			ena(id) <= rgtr_dv and dec(id); 
		end loop;
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
			if ena(axis_enid)='1' then
				axis_scale <= bf(rgtr_data, scale_id,  axis_bf);
				origin     := bf(rgtr_data, origin_id, axis_bf);
				if bf(rgtr_data, select_id, axis_bf)="1" then
					axis_sel  <= '1';
					axis_base <= bf(origin, base_id,   vtoffset_bf);
					vt_offset <= bf(origin, offset_id, vtoffset_bf);
				else
					axis_sel  <= '0';
					axis_base <= bf(origin,    base_id,   hzoffset_bf);
					hz_base   <= bf(origin,    base_id,   hzoffset_bf);
					hz_offset <= bf(origin,    offset_id, hzoffset_bf);
					hz_scale  <= bf(rgtr_data, scale_id,  axis_bf);
				end if;
			end if;
			axis_dv <= ena(axis_enid);
		end if;
	end process;

	palette_p : block
		constant id_id    : natural := 0;
		constant color_id : natural := 1;

		constant palette_bf : natural_vector := (id_id => palette_id'length, color_id => palette_color'length);
	begin
		palette_dv    <= ena(palette_enid);
		palette_id    <= bf(rgtr_data, id_id,    palette_bf);
		palette_color <= bf(rgtr_data, color_id, palette_bf);
	end block;

	gain_p : block
		constant chanid_id : natural := 0;
		constant gainid_id : natural := 1;

		constant gain_bf : natural_vector := (chanid_id => gain_chanid'length, gainid_id => gain_id'length);
	begin
		gain_dv     <= ena(gain_enid);
		gain_id     <= bf(rgtr_data, gainid_id, gain_bf);
		gain_chanid <= bf(rgtr_data, chanid_id, gain_bf);
	end block;

	trigger_p : block
		constant ena_id    : natural := 0;
		constant edge_id   : natural := 1;
		constant level_id  : natural := 2;
		constant chanid_id : natural := 3;

		constant trigger_bf : natural_vector := (
			ena_id    => 1,
			edge_id   => 1,
			level_id  => trigger_level'length,
			chanid_id => trigger_chanid'length);

		signal level : signed(trigger_level'range);
	begin
		level <= -signed(bf(rgtr_data, level_id, trigger_bf));
		process(clk)
		begin
			if rising_edge(clk) then
				trigger_dv <= ena(trigger_enid);
				if ena(trigger_enid)='1' then
					trigger_freeze <= bf(rgtr_data, ena_id,    trigger_bf)(0);
					trigger_edge   <= bf(rgtr_data, edge_id,   trigger_bf)(0);
					trigger_level  <= std_logic_vector(level);
					trigger_chanid <= bf(rgtr_data, chanid_id, trigger_bf);
				end if;
			end if;
		end process;
	end block;

end;
