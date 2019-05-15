library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity scopeio_rgtr is
	generic (
		inputs          : in  natural;
		gainid_size     : in  natural);
	port (
		clk             : in  std_logic;
		rgtr_dv         : in  std_logic;
		rgtr_id         : in  std_logic_vector(8-1 downto 0);
		rgtr_data       : in  std_logic_vector;

		hz_dv           : out std_logic;
		hz_scale        : out std_logic_vector;
		hz_offset       : out std_logic_vector;
		vt_dv           : out std_logic;
		vt_chanid       : out std_logic_vector;
		vt_offsets      : out std_logic_vector;

		palette_dv      : out std_logic;
		palette_id      : out std_logic_vector;
		palette_color   : out std_logic_vector;
	
		gain_dv         : out std_logic;
		gain_ids        : out std_logic_vector;

		trigger_dv      : out std_logic;
		trigger_freeze  : out std_logic;
		trigger_chanid  : out std_logic_vector;
		trigger_level   : out std_logic_vector;
		trigger_edge    : out std_logic);

	constant chanid_size  : natural := unsigned_num_bits(inputs-1);
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

	constant rid_hzaxis   : std_logic_vector := x"10";
	constant rid_palette  : std_logic_vector := x"11";
	constant rid_trigger  : std_logic_vector := x"12";
	constant rid_gain     : std_logic_vector := x"13";
	constant rid_vtaxis   : std_logic_vector := x"14";

	constant hzaxis_enid  : natural := 0;
	constant palette_enid : natural := 1;
	constant gain_enid    : natural := 2;
	constant trigger_enid : natural := 3;
	constant vtaxis_enid  : natural := 4;

	constant ena_size     : natural := vtaxis_enid+1;


	signal ena : std_logic_vector(0 to ena_size-1);
begin

	decode_p : process (clk, rgtr_dv)
		variable dec : std_logic_vector(ena'range);
	begin
		if rising_edge(clk) then
			dec := (others => '0');
			case rgtr_id is
			when rid_hzaxis =>
				dec(hzaxis_enid)    := '1';
			when rid_palette =>
				dec(palette_enid) := '1';
			when rid_gain =>
				dec(gain_enid)    := '1';
			when rid_trigger =>
				dec(trigger_enid) := '1';
			when rid_vtaxis =>
				dec(vtaxis_enid) := '1';
			when others =>
			end case;
		end if;

		for id in ena'range loop
			ena(id) <= rgtr_dv and dec(id); 
		end loop;
	end process;

	vtaxis_b : block 
		constant offset_id   : natural := 0;
		constant chanid_id   : natural := 1;

		constant vtoffset_bf : natural_vector := (offset_id => 13, chanid_id => 3);
	begin
		vtaxis_p : process(clk)
			constant offset_size : natural := vt_offsets'length/inputs;
			variable offsets     : unsigned(0 to vt_offsets'length-1); 
			variable chanid      : std_logic_vector(0 to chanid_size-1);
		begin
			if rising_edge(clk) then
				if ena(vtaxis_enid)='1' then
					chanid := bf(rgtr_data, chanid_id, vtoffset_bf);
					for i in 0 to inputs-1 loop
						if to_unsigned(i, chanid_size)=unsigned(chanid) then
							offsets(0 to offset_size-1) := unsigned(bf(rgtr_data, offset_id, vtoffset_bf));
						end if;
						offsets := offsets rol offset_size;
					end loop;
					vt_chanid  <= bf(rgtr_data, chanid_id, vtoffset_bf);
					vt_offsets <= std_logic_vector(offsets);
				end if;
				vt_dv <= ena(vtaxis_enid);
			end if;
		end process;
	end block;

	hzaxis_p : process(clk)
		constant offset_id   : natural := 0;
		constant scale_id    : natural := 1;

		constant hzoffset_bf : natural_vector := (offset_id => 16, scale_id => 4);

	begin
		if rising_edge(clk) then
			if ena(hzaxis_enid)='1' then
				hz_offset <= bf(rgtr_data, offset_id, hzoffset_bf);
				hz_scale  <= bf(rgtr_data, scale_id,  hzoffset_bf);
			end if;
			hz_dv <= ena(hzaxis_enid);
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

		constant gainid_id : natural := 0;
		constant chanid_id : natural := 1;

		constant gain_bf : natural_vector := (gainid_id => gainid_size, chanid_id => 3);
	begin
		process(clk) 
			constant id_size : natural := gain_ids'length/inputs;
			variable ids     : unsigned(0 to gain_ids'length-1); 
			variable chanid  : std_logic_vector(0 to chanid_size-1);
		begin
			if rising_edge(clk) then
				if ena(gain_enid)='1' then
					chanid := bf(rgtr_data, chanid_id, gain_bf);
					for i in 0 to inputs-1 loop
						if to_unsigned(i, chanid_size)=unsigned(chanid) then
							ids(0 to id_size-1) := unsigned(bf(rgtr_data, gainid_id, gain_bf));
						end if;
						ids := ids rol id_size;
					end loop;
				end if;
				gain_dv  <= ena(gain_enid);
				gain_ids <= std_logic_vector(ids);
			end if;
		end process;
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
				if ena(trigger_enid)='1' then
					trigger_freeze <= bf(rgtr_data, ena_id,    trigger_bf)(0);
					trigger_edge   <= bf(rgtr_data, edge_id,   trigger_bf)(0);
					trigger_level  <= std_logic_vector(level);
					trigger_chanid <= bf(rgtr_data, chanid_id, trigger_bf);
				end if;
				trigger_dv <= ena(trigger_enid);
			end if;
		end process;
	end block;

end;
