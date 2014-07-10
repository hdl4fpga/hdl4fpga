library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_sch is
	generic (
		data_phases : natural;
		data_edges  : natural := 2;
		byte_size   : natural;
		word_size   : natural;

		clword_size : natural;
		clword_data : std_logic_vector;
		clword_lat  : natural_vector);
	port (
		sys_cl   : in  std_logic_vector(clword_size-1 downto 0);
		sys_cwl  : in  std_logic_vector(cwlword_size-1 downto 0);
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_rea  : in  std_logic;
		xdr_dqw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_stw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

	constant data_rate : natural := data_phases/data_edges;
	constant delay_size : natural := 32;

end;

architecture def of xdr_sch is
	subtype word is std_logic_vector(0 to word_size/byte_size*data_phases-1);
	type word_vector is array (natural range <>) of word;
	signal ph_rea : std_logic_vector (0 to delay_size);
	constant cycle : natural := data_phases*word_size/byte_size;
	subtype clword is std_logic_vector(0 to clword_size-1);
	type clword_vector is array (natural range <>) of clword;

	function to_clwordvector(
		constant arg : std_logic_vector)
		return clword_vector is
		variable aux : std_logic_vector(0 to arg'length-1) := arg;
		variable val : clword_vector(0 to arg'length/clword'length-1);
	begin
		for i in val'range loop
			val(i) := aux(clword'range);
			aux := aux sll clword'length;
		end loop;
		return val;
	end;

	constant cltab_size : natural := sys_cl'length/clword_size;
	constant cltab_data : clword_vector(0 to cltab_size-1) := to_clwordvector(clword_data);
	constant word_byte : natural := word_size/byte_size;

begin
	
	xdr_ph_read : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		delay_size => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => sys_rea,
		ph_qo => ph_rea);

	xdr_stw <= xdr_task (
		data_phases => data_phases,
		data_edges => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		lat_val => "100",
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => ph_wri,
		lat_extn => 1);

	xdr_stw <= xdr_task (
		data_phases => data_phases,
		data_edges => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		lat_val => "100",
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => ph_wri,
		lat_extn => 1);

	xdr_dqw <= xdr_task (
		data_phases => data_phases,
		data_edges => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		lat_val => "100",
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => ph_wri,
		lat_extn => 1);

end;
