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
use hdl4fpga.ddr_db.all;
use hdl4fpga.profiles.all;

entity ddr_sch is
	generic (
		profile           : fpga_devices;
		delay_size        : natural := 64;
		registered_output : boolean := false;
		data_phases       : natural := 2;
		clk_phases        : natural := 4;
		clk_edges         : natural := 2;

		data_gear         : natural;
		cmmd_gear         : natural := 1;

		cl_cod            : std_logic_vector;
		cwl_cod           : std_logic_vector;

		strl_tab          : natural_vector;
		rwnl_tab          : natural_vector;
		dqszl_tab         : natural_vector;
		dqsol_tab         : natural_vector;
		dqzl_tab          : natural_vector;
		wwnl_tab          : natural_vector;

		strx_lat          : natural;
		rwnx_lat          : natural;
		dqszx_lat         : natural;
		dqsx_lat          : natural;
		dqzx_lat          : natural;
		wwnx_lat          : natural;
		wid_lat           : natural);
	port (
		sys_clks          : in  std_logic_vector(0 to clk_phases/clk_edges-1);
		sys_cl            : in  std_logic_vector;
		sys_cwl           : in  std_logic_vector;
		sys_rea           : in  std_logic;
		sys_wri           : in  std_logic;

		ddr_rwn           : out std_logic_vector(0 to data_gear-1);
		ddr_st            : out std_logic_vector(0 to data_gear-1);

		ddr_dqsz          : out std_logic_vector(0 to data_gear-1);
		ddr_dqs           : out std_logic_vector(0 to data_gear-1);

		ddr_dqz           : out std_logic_vector(0 to data_gear-1);
		ddr_wwn           : out std_logic_vector(0 to data_gear-1);
		ddr_odt           : out std_logic_vector(0 to cmmd_gear-1));

end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of ddr_sch is
	constant ph90 : natural := 1 mod sys_clks'length;

	signal wphi   : std_logic;
	signal rphi   : std_logic;

	signal rpho   : std_logic_vector(0 to delay_size);
	signal rpho0  : std_logic_vector(0 to delay_size/clk_edges-1);
	signal rpho90 : std_logic_vector(0 to delay_size/clk_edges-1);

	signal wpho   : std_logic_vector(0 to delay_size);
	signal wpho0  : std_logic_vector(0 to delay_size/clk_edges-1);
	signal wpho90 : std_logic_vector(0 to delay_size/clk_edges-1);

	signal stpho  : std_logic_vector(0 to delay_size/clk_edges-1);

begin
	
	rphi <= sys_rea;
	wphi <= sys_wri;

	ddr_rph_e : entity hdl4fpga.ddr_ph
	generic map (
		clk_edges   => clk_edges,
		clk_phases  => clk_phases,
		delay_size  => delay_size,
		delay_phase => 2)
	port map (
		sys_clks    => sys_clks,
		sys_di      => rphi,
		ph_qo       => rpho);

	process(rpho) 
	begin
		for i in 0 to delay_size/clk_phases-1 loop
			for j in 0 to clk_phases/clk_edges-1 loop
				rpho0(i*clk_edges+j) <= rpho(clk_phases*i+clk_edges*j);
			end loop;
		end loop;
		for i in 0 to (delay_size-ph90)/clk_phases-1 loop
			for j in 0 to clk_edges-1 loop
				rpho90(i*clk_edges+j) <= rpho(clk_phases*i+clk_edges*j+ph90);
			end loop;
		end loop;
	end process;

	ddr_wph_e : entity hdl4fpga.ddr_ph
	generic map (
		clk_edges   => clk_edges,
		clk_phases  => clk_phases,
		delay_size  => delay_size,
		delay_phase => 2)
	port map (
		sys_clks    => sys_clks,
		sys_di      => wphi,
		ph_qo       => wpho);

	process(wpho) 
	begin
		for i in 0 to delay_size/clk_phases-1 loop
			for j in 0 to clk_phases/clk_edges-1 loop
				wpho0(i*clk_edges+j) <= wpho(clk_phases*i+clk_edges*j);
			end loop;
		end loop;
		for i in 0 to (delay_size-ph90)/clk_phases-1 loop
			for j in 0 to clk_edges-1 loop
				wpho90(i*clk_edges+j) <= wpho(clk_phases*i+clk_edges*j+ph90);
			end loop;
		end loop;
	end process;

	stpho <= rpho0 when profile=xc7a else rpho90;
--	stpho <= rpho90;

	ddr_st <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cl_cod,
		lat_tab    => strl_tab,
		lat_ext    => strx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cl,
		lat_sch    => stpho);

	ddr_rwn <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cl_cod,
		lat_tab    => rwnl_tab,
		lat_ext    => rwnx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cl,
		lat_sch    => rpho0);

	ddr_dqsz <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cwl_cod,
		lat_tab    => dqszl_tab,
		lat_ext    => dqszx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cwl,
		lat_sch    => wpho0);

	ddr_dqs <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cwl_cod,
		lat_tab    => dqsol_tab,
		lat_ext    => dqsx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cwl,
		lat_sch    => wpho0);

	ddr_dqz <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cwl_cod,
		lat_tab    => dqzl_tab,
		lat_ext    => dqzx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cwl,
		lat_sch    => wpho90);

	ddr_wwn <= ddr_task (
		clk_phases => clk_edges,
		gear       => data_gear,
		lat_cod    => cwl_cod,
		lat_tab    => wwnl_tab,
		lat_ext    => wwnx_lat,
		lat_wid    => wid_lat,

		lat_val    => sys_cwl,
		lat_sch    => wpho90);

	ddr_odt <= ddr_task (
		clk_phases => clk_edges,
		gear       => cmmd_gear,
		lat_cod    => "000",
		lat_tab    => (0 to 0 => 0),
		lat_ext    => 2*cmmd_gear,
		lat_wid    => wid_lat,

		lat_val    => "000",
		lat_sch    => wpho0);
end;
