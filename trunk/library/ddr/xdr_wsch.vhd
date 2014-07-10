library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_wsch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		byte_size   : natural;
		word_size   : natural;

		lat_code : std_logic_vector;
		lat_tab  : natural_vector);
	port (
		sys_lat  : in  std_logic_vector;
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_wri  : in  std_logic;

		xdr_dqsz : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqs  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqz  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

	constant data_rate : natural := data_phases/data_edges;
	constant delay_size : natural := 32;

end;

architecture def of xdr_wsch is

	function select_lat (
		constant lat_val  : std_logic_vector;
		constant lat_code : std_logic_vector;
		constant lat_tab  : natural_vector;
		constant lat_schd : std_logic_vector;
		constant lat_extn : natural := 3)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to word_size/byte_size*data_phases-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		variable disp : natural;
		variable disp_mod : natural;
		variable disp_quo : natural;
		variable pha : natural;
		variable aux : std_logic;
		variable sel_schd : word_vector(lat_code'range);

		constant word_byte : natural := word_size/byte_size;
		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : std_logic_vector(0 to arg'length-1) := arg;
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			for i in val'range loop
				val(i) := aux(latword'range);
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		function select_lat (
			constant lat_val  : std_logic_vector;
			constant lat_code : latword_vector;
			constant lat_schd : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length -1 loop
				if lat_val = lat_code(i) then
					for j in word'range loop
						val(j) := lat_schd(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;

	begin
		sel_schd := (others => (others => '-'));
		setup_l : for i in 0 to lat_tab'length-1 loop
			disp := lat_tab(i);
			disp_mod := disp mod word'length;
			disp_quo := disp  / word'length;
			for j in word'range loop
				aux := '0';
				for l in 0 to (lat_extn+word'length-1-j)/word'length loop
					pha := (j+disp_mod+l*word'length)/word_byte;
					aux := aux or lat_schd(disp_quo*word'length+pha);
				end loop;
				sel_schd(i)((disp+j) mod word'length) := aux;
			end loop;
		end loop;
		return select_lat(lat_val, to_latwordvector(lat_code), sel_schd);
	end;


	signal ph_wri : std_logic_vector (0 to delay_size);

begin
	
	xdr_wph_e : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		delay_size => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => sys_wri,
		ph_qo => ph_wri);

	xdr_dqw <= select_lat(sys_lat, lat_code, lat_tab, ph_wri);

end;
