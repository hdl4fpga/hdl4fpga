library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_sch is
	generic (
		delay_size : natural := 64;
		sclk_phases : natural;
		sclk_edges  : natural;
		data_phases : natural;
		data_edges  : natural;

		line_size : natural;
		word_size : natural;

		CL_COD  : std_logic_vector;
		CWL_COD : std_logic_vector;

		STRL_TAB   : natural_vector;
		RWNL_TAB   : natural_vector;
		DQSZL_TAB : natural_vector;
		DQSOL_TAB : natural_vector;
		DQZL_TAB  : natural_vector;
		WWNL_TAB  : natural_vector;

		STRX_LAT  : natural;
		RWNX_LAT  : natural;
		DQSZX_LAT : natural;
		DQSX_LAT  : natural;
		DQZX_LAT  : natural;
		WWNX_LAT  : natural;

		WID_LAT   : natural);
	port (
		sys_cl   : in  std_logic_vector;
		sys_cwl  : in  std_logic_vector;
		sys_clks : in  std_logic_vector;
		sys_rea  : in  std_logic;
		sys_wri  : in  std_logic;

		xdr_rwn : out std_logic_vector(0 to (line_size/word_size)*data_phases-1);
		xdr_st  : out std_logic_vector(0 to (line_size/word_size)*data_phases-1);

		xdr_dqsz : out std_logic_vector(0 to (line_size/word_size)*data_phases-1);
		xdr_dqs  : out std_logic_vector(0 to (line_size/word_size)*data_phases-1);

		xdr_dqz  : out std_logic_vector(0 to (line_size/word_size)*data_phases-1);
		xdr_wwn  : out std_logic_vector(0 to (line_size/word_size)*data_phases-1));


end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of xdr_sch is

	signal wphi : std_logic;
	signal wpho : std_logic_vector(0 to delay_size);

	signal rphi : std_logic;
	signal rpho : std_logic_vector(0 to delay_size);

begin
	
	rphi <= sys_wri or sys_rea;
	wphi <= rphi;

	xdr_rph_e : entity hdl4fpga.xdr_ph
	generic map (
		data_phases => sclk_phases,
		data_edges  => sclk_edges,
		delay_size  => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => rphi,
		ph_qo  => rpho);
	wpho <= rpho;

--	xdr_st <= xdr_task (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		line_size => line_size,
--		word_size => word_size,
--
--		lat_val  => sys_cl,
--		lat_cod => cl_cod,
--		lat_tab  => strl_tab,
--		lat_sch => rpho,
--		lat_ext => STRX_LAT,
--		lat_wid => WID_LAT);
--
--	xdr_rwn <= xdr_task (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		line_size => line_size,
--		word_size => word_size,
--
--		lat_val => sys_cl,
--		lat_cod => cl_cod,
--		lat_tab => rwnl_tab,
--		lat_sch => rpho,
--		lat_ext => RWNX_LAT,
--		lat_wid => WID_LAT);
--
--	xdr_dqsz <= xdr_task (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		line_size => line_size,
--		word_size => word_size,
--
--		lat_val => sys_cwl,
--		lat_cod => cwl_cod,
--		lat_tab => dqszl_tab,
--		lat_sch => wpho,
--		lat_ext => DQSZX_LAT,
--		lat_wid => WID_LAT);

	xdr_dqs <= xdr_task (
		data_phases => data_phases,
		data_edges  => data_edges,
		line_size => line_size,
		word_size => word_size,

		lat_val => sys_cwl,
		lat_cod => cwl_cod,
		lat_tab => (0 => 0, 1 => 0, 2 => 1, 3 => 0), --dqsol_tab, --,
		lat_sch => wpho,
		lat_ext => 1, --DQSX_LAT,
		lat_wid => WID_LAT);

--	xdr_dqz <= xdr_task (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		line_size => line_size,
--		word_size => word_size,
--
--		lat_val => sys_cwl,
--		lat_cod => cwl_cod,
--		lat_tab => dqzl_tab,
--		lat_sch => wpho,
--		lat_ext => DQZX_LAT,
--		lat_wid => WID_LAT);
--
--	xdr_wwn <= xdr_task (
--		data_phases => data_phases,
--		data_edges  => data_edges,
--		line_size => line_size,
--		word_size => word_size,
--
--		lat_val => sys_cwl,
--		lat_cod => cwl_cod,
--		lat_tab => WWNL_TAB,
--		lat_sch => wpho,
--		lat_ext => WWNX_LAT,
--		lat_wid => WID_LAT);
end;
