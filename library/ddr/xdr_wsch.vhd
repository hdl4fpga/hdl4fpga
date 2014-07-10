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

library hdl4fpga;
use hdl4fpga.xdr_param.all;

architecture def of xdr_wsch is

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

	xdr_dqw <= xdr_task (
		data_phases => data_phases,
		data_edges => data_edges,
		byte_size => byte_size,
		word_size => word_size,
		lat_val => "100",
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => ph_wri,
		lat_extn => 3);

end;
