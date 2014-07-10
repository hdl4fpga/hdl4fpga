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

		clat_code : std_logic_vector;
		clat_tab  : natural_vector;

		clat_code : std_logic_vector;
		clat_tab  : natural_vector);
	port (
		sys_cl   : in  std_logic_vector;
		sys_cwl  : in  std_logic_vector;
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_rea  : in  std_logic;
		sys_wri  : in  std_logic;

		xdr_dqw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_stw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

		xdr_dqsz : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqs  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);

		xdr_dqz  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1);
		xdr_dqw  : out std_logic_vector(0 to (word_size/byte_size)*data_phases-1));

	constant delay_size : natural := 16;

end;

library hdl4fpga;
use hdl4fpga.xdr_param.all;

architecture def of xdr_wsch is

	signal wpho : std_logic_vector(0 to delay_size);
	signal wphi : std_logic;

	signal rpho : std_logic_vector(0 to delay_size);
	signal rphi : std_logic;

begin
	
	rphi <= sys_rea or sys_wri;
	wphi <= rphi;

	xdr_rph_e : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => data_phases,
		data_edges  => data_edges,
		delay_size => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => rphi,
		ph_qo  => rpho);
	wpho <= rpho;

	xdr_stw <= xdr_task (
		data_phases => data_phases,
		data_edges  => data_edges,
		word_size => word_size,
		byte_size => byte_size,

		lat_val  => sys_cl,
		lat_code => lat_code,
		lat_tab  => lat_tab,
		lat_schd => rpho,
		lat_extn => 1);

	xdr_dqw <= xdr_task (
		data_phases => data_phases,
		data_edges  => data_edges,
		word_size => word_size,
		byte_size => byte_size,

		lat_val => sys_cl,
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => pho);

	xdr_dqw <= xdr_task (
		data_phases => data_phases,
		data_edges  => data_edges,
		word_size => word_size,
		byte_size => byte_size,

		lat_val => sys_cwl,
		lat_code => lat_code,
		lat_tab => lat_tab,
		lat_schd => pho);

end;
