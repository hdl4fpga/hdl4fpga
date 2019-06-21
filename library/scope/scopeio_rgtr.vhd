library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.scopeiopkg.all;

entity scopeio_rgtr is
	generic (
		inputs          : in  natural);
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
		trigger_edge    : out std_logic;

		pointer_dv      : out std_logic;
		pointer_x       : out std_logic_vector;
		pointer_y       : out std_logic_vector);

end;

architecture def of scopeio_rgtr is

	signal hzaxis_ena  : std_logic;
	signal palette_ena : std_logic;
	signal gain_ena    : std_logic;
	signal trigger_ena : std_logic;
	signal vtaxis_ena  : std_logic;
	signal pointer_ena : std_logic;

begin

	vtaxis_ena  <= rgtr_dv when rgtr_id=rid_vtaxis  else '0';
	vtaxis_p : process(clk)
		constant offset_size : natural := vt_offsets'length/inputs;
		variable offsets     : unsigned(0 to vt_offsets'length-1); 
		variable chanid      : std_logic_vector(0 to chanid_size-1);
	begin
		if rising_edge(clk) then
			if vtaxis_ena='1' then
				chanid := bitfield(rgtr_data, vtchanid_id, vtoffset_bf);
				for i in 0 to inputs-1 loop
					if to_unsigned(i, chanid_size)=unsigned(chanid) then
						offsets(0 to offset_size-1) := unsigned(bitfield(rgtr_data, vtoffset_id, vtoffset_bf));
					end if;
					offsets := offsets rol offset_size;
				end loop;
				vt_chanid  <= std_logic_vector(resize(unsigned(bitfield(rgtr_data, vtchanid_id, vtoffset_bf)), vt_chanid'length));
				vt_offsets <= std_logic_vector(offsets);
			end if;
			vt_dv <= vtaxis_ena;
		end if;
	end process;

	hzaxis_ena  <= rgtr_dv when rgtr_id=rid_hzaxis  else '0';
	hzaxis_p : process(clk)
	begin
		if rising_edge(clk) then
			if hzaxis_ena='1' then
				hz_offset <= std_logic_vector(resize(signed(bitfield(rgtr_data, hzoffset_id, hzoffset_bf)), hz_offset'length));
				hz_scale  <= bitfield(rgtr_data, hzscale_id,  hzoffset_bf);
			end if;
			hz_dv <= hzaxis_ena;
		end if;
	end process;

	palette_ena <= rgtr_dv when rgtr_id=rid_palette else '0';
	palette_p : block
	begin
		palette_dv    <= palette_ena;
		palette_id    <= bitfield(rgtr_data, paletteid_id,    palette_bf);
		palette_color <= bitfield(rgtr_data, palettecolor_id, palette_bf);
	end block;

	gain_ena    <= rgtr_dv when rgtr_id=rid_gain    else '0';
	gain_p : process(clk) 
		variable ids     : unsigned(0 to gain_ids'length-1); 
		variable chanid  : std_logic_vector(0 to chanid_size-1);
	begin
		if rising_edge(clk) then
			if gain_ena='1' then
				chanid := bitfield(rgtr_data, gainchanid_id, gain_bf);
				for i in 0 to inputs-1 loop
					if to_unsigned(i, chanid_size)=unsigned(chanid) then
						ids(0 to gainid_size-1) := unsigned(bitfield(rgtr_data, gainid_id, gain_bf));
					end if;
					ids := ids rol gainid_size;
				end loop;
			end if;
			gain_dv  <= gain_ena;
			gain_ids <= std_logic_vector(ids);
		end if;
	end process;

	trigger_ena <= rgtr_dv when rgtr_id=rid_trigger else '0';
	trigger_p : process(clk)
		variable level : signed(trigger_level'range);
	begin
		if rising_edge(clk) then
			level := -signed(bitfield(rgtr_data, trigger_level_id, trigger_bf));
			if trigger_ena='1' then
				trigger_freeze <= bitfield(rgtr_data, trigger_ena_id,    trigger_bf)(0);
				trigger_edge   <= bitfield(rgtr_data, trigger_edge_id,   trigger_bf)(0);
				trigger_level  <= std_logic_vector(level);
				trigger_chanid <= bitfield(rgtr_data, trigger_chanid_id, trigger_bf);
			end if;
			trigger_dv <= trigger_ena;
		end if;
	end process;

	pointer_ena <= rgtr_dv when rgtr_id=rid_pointer else '0';
	pointer_p : process(clk)
	begin
		if rising_edge(clk) then
			if pointer_ena='1' then
				pointer_x <= bitfield(rgtr_data, pointerx_id, pointer_bf);
				pointer_y <= bitfield(rgtr_data, pointery_id, pointer_bf);
			end if;
			pointer_dv <= pointer_ena;
		end if;
	end process;

end;
