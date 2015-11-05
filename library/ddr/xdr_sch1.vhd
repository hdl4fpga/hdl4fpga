--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity xdr_sch is
	generic (
		delay_size : natural := 64;
		registered_output : boolean := false;
		data_phases : natural := 4;
		data_edges  : natural := 2;

		gear : natural;

		CL_COD  : std_logic_vector;
		CWL_COD : std_logic_vector;

		STRL_TAB  : natural_vector;
		RWNL_TAB  : natural_vector;
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
		sys_clks : in  std_logic_vector(0 to data_phases/data_edges-1);
		sys_cl  : in  std_logic_vector;
		sys_cwl : in  std_logic_vector;
		sys_rea : in  std_logic;
		sys_wri : in  std_logic;

		xdr_rwn : out std_logic_vector(0 to gear-1);
		xdr_st  : out std_logic_vector(0 to gear-1);

		xdr_dqsz : out std_logic_vector(0 to gear-1);
		xdr_dqs  : out std_logic_vector(0 to gear-1);

		xdr_dqz  : out std_logic_vector(0 to gear-1);
		xdr_wwn  : out std_logic_vector(0 to gear-1));
end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.xdr_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of xdr_sch is

	signal wphi : std_logic;
	signal rphi : std_logic;

	signal rpho : std_logic_vector(0 to delay_size/data_edges-1);
	signal rpho0 : std_logic_vector(0 to delay_size/data_edges-1);
	signal wpho : std_logic_vector(0 to delay_size/data_edges-1);
	signal wpho0 : std_logic_vector(0 to delay_size/data_edges-1);
	signal st : std_logic_vector(xdr_st'reverse_range);
	constant pp : natural := 1 mod sys_clks'length;
begin
	
	rphi <= sys_rea;
	wphi <= sys_wri;

	xdr_rph_e : entity hdl4fpga.xdr_ph
	generic map (
		data_edges  => data_edges,
		data_phases => data_phases,
		delay_size  => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => rphi,
		ph_qo  => rpho0);

	process(rpho0) 
	begin
		for i in 0 to delay_size/data_phases-1 loop
			for j in 0 to data_phases/data_edges-1 loop
				rpho(i) <= rpho0(data_phases*i+data_edges*j);
			end loop;
		end loop;
	end process;

	xdr_wph_e : entity hdl4fpga.xdr_ph
	generic map (
		data_edges  => data_edges,
		data_phases => data_phases,
		delay_size  => delay_size,
		delay_phase => 2)
	port map (
		sys_clks => sys_clks,
		sys_di => wphi,
		ph_qo  => wpho0);

	process(wpho0) 
	begin
		for i in pp to (delay_size-pp)/data_phases-1 loop
			for j in 0 to data_phases/data_edges-1 loop
				wpho(i) <= wpho0(data_phases*i+data_edges*j+pp);
			end loop;
		end loop;
	end process;

	st <= xdr_task (
		gear => gear,

		lat_val => sys_cl,
		lat_cod => cl_cod,
		lat_tab => strl_tab,
		lat_sch => rpho,
		lat_ext => STRX_LAT,
		lat_wid => WID_LAT);

	process (st)
	begin
		for i in st'range loop
			xdr_st(i) <= st(i);
		end loop;
	end process;

	xdr_rwn <= xdr_task (
		gear => gear,

		lat_val => sys_cl,
		lat_cod => cl_cod,
		lat_tab => rwnl_tab,
		lat_sch => rpho,
		lat_ext => RWNX_LAT,
		lat_wid => WID_LAT);

	xdr_dqsz <= xdr_task (
		gear => gear,

		lat_val => sys_cwl,
		lat_cod => cwl_cod,
		lat_tab => dqszl_tab,
		lat_sch => wpho,
		lat_ext => DQSZX_LAT,
		lat_wid => WID_LAT);

	xdr_dqs <= xdr_task (
		gear => gear,

		lat_val => sys_cwl,
		lat_cod => cwl_cod,
		lat_tab => dqsol_tab,
		lat_sch => wpho,
		lat_ext => DQSX_LAT,
		lat_wid => WID_LAT);

	xdr_dqz <= xdr_task (
		gear => gear,

		lat_val => sys_cwl,
		lat_cod => cwl_cod,
		lat_tab => dqzl_tab,
		lat_sch => wpho,
		lat_ext => DQZX_LAT,
		lat_wid => WID_LAT);

	xdr_wwn <= xdr_task (
		gear => gear,

		lat_val => sys_cwl,
		lat_cod => cwl_cod,
		lat_tab => WWNL_TAB,
		lat_sch => wpho,
		lat_ext => WWNX_LAT,
		lat_wid => WID_LAT);
end;
