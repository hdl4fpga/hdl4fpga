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

entity ddr_sch is
	generic (
		PROFILE           : natural;
		DELAY_SIZE        : natural := 64;
		REGISTERED_OUTPUT : boolean := false;
		DATA_PHASES       : natural := 2;
		CLK_PHASES        : natural := 4;
		CLK_EDGES         : natural := 2;

		DATA_GEAR         : natural;
		CMMD_GEAR         : natural := 1;

		CL_COD            : std_logic_vector;
		CWL_COD           : std_logic_vector;

		STRL_TAB          : natural_vector;
		RWNL_TAB          : natural_vector;
		DQSZL_TAB         : natural_vector;
		DQSOL_TAB         : natural_vector;
		DQZL_TAB          : natural_vector;
		WWNL_TAB          : natural_vector;

		STRX_LAT          : natural;
		RWNX_LAT          : natural;
		DQSZX_LAT         : natural;
		DQSX_LAT          : natural;
		DQZX_LAT          : natural;
		WWNX_LAT          : natural;
		WID_LAT           : natural);
	port (
		sys_clks          : in  std_logic_vector(0 to CLK_PHASES/CLK_EDGES-1);
		sys_cl            : in  std_logic_vector;
		sys_cwl           : in  std_logic_vector;
		sys_rea           : in  std_logic;
		sys_wri           : in  std_logic;

		ddr_rwn           : out std_logic_vector(0 to DATA_GEAR-1);
		ddr_st            : out std_logic_vector(0 to DATA_GEAR-1);

		ddr_dqsz          : out std_logic_vector(0 to DATA_GEAR-1);
		ddr_dqs           : out std_logic_vector(0 to DATA_GEAR-1);

		ddr_dqz           : out std_logic_vector(0 to DATA_GEAR-1);
		ddr_wwn           : out std_logic_vector(0 to DATA_GEAR-1);
		ddr_odt           : out std_logic_vector(0 to CMMD_GEAR-1));

end;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.ddr_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of ddr_sch is
	constant PH90 : natural := 1 mod sys_clks'length;

	signal wphi   : std_logic;
	signal rphi   : std_logic;

	signal rpho   : std_logic_vector(0 to DELAY_SIZE);
	signal rpho0  : std_logic_vector(0 to DELAY_SIZE/CLK_EDGES-1);
	signal rpho90 : std_logic_vector(0 to DELAY_SIZE/CLK_EDGES-1);

	signal wpho   : std_logic_vector(0 to DELAY_SIZE);
	signal wpho0  : std_logic_vector(0 to DELAY_SIZE/CLK_EDGES-1);
	signal wpho90 : std_logic_vector(0 to DELAY_SIZE/CLK_EDGES-1);

	signal stpho  : std_logic_vector(0 to DELAY_SIZE/CLK_EDGES-1);

begin
	
	rphi <= sys_rea;
	wphi <= sys_wri;

	ddr_rph_e : entity hdl4fpga.ddr_ph
	generic map (
		CLK_EDGES   => CLK_EDGES,
		CLK_PHASES  => CLK_PHASES,
		DELAY_SIZE  => DELAY_SIZE,
		DELAY_PHASE => 2)
	port map (
		sys_clks    => sys_clks,
		sys_di      => rphi,
		ph_qo       => rpho);

	process(rpho) 
	begin
		for i in 0 to DELAY_SIZE/CLK_PHASES-1 loop
			for j in 0 to CLK_PHASES/CLK_EDGES-1 loop
				rpho0(i*CLK_EDGES+j) <= rpho(CLK_PHASES*i+CLK_EDGES*j);
			end loop;
		end loop;
		for i in 0 to (DELAY_SIZE-PH90)/CLK_PHASES-1 loop
			for j in 0 to CLK_EDGES-1 loop
				rpho90(i*CLK_EDGES+j) <= rpho(CLK_PHASES*i+CLK_EDGES*j+PH90);
			end loop;
		end loop;
	end process;

	ddr_wph_e : entity hdl4fpga.ddr_ph
	generic map (
		CLK_EDGES   => CLK_EDGES,
		CLK_PHASES  => CLK_PHASES,
		DELAY_SIZE  => DELAY_SIZE,
		DELAY_PHASE => 2)
	port map (
		sys_clks    => sys_clks,
		sys_di      => wphi,
		ph_qo       => wpho);

	process(wpho) 
	begin
		for i in 0 to DELAY_SIZE/CLK_PHASES-1 loop
			for j in 0 to CLK_PHASES/CLK_EDGES-1 loop
				wpho0(i*CLK_EDGES+j) <= wpho(CLK_PHASES*i+CLK_EDGES*j);
			end loop;
		end loop;
		for i in 0 to (DELAY_SIZE-PH90)/CLK_PHASES-1 loop
			for j in 0 to CLK_EDGES-1 loop
				wpho90(i*CLK_EDGES+j) <= wpho(CLK_PHASES*i+CLK_EDGES*j+PH90);
			end loop;
		end loop;
	end process;

	stpho <= rpho0 when PROFILE=VIRTEX7 else rpho90;
--	stpho <= rpho90;

	ddr_st <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CL_COD,
		lat_tab    => STRL_TAB,
		lat_ext    => STRX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cl,
		lat_sch    => stpho);

	ddr_rwn <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CL_COD,
		lat_tab    => RWNL_TAB,
		lat_ext    => RWNX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cl,
		lat_sch    => rpho0);

	ddr_dqsz <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CWL_COD,
		lat_tab    => DQSZL_TAB,
		lat_ext    => DQSZX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cwl,
		lat_sch    => wpho0);

	ddr_dqs <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CWL_COD,
		lat_tab    => DQSOL_TAB,
		lat_ext    => DQSX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cwl,
		lat_sch    => wpho0);

	ddr_dqz <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CWL_COD,
		lat_tab    => DQZL_TAB,
		lat_ext    => DQZX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cwl,
		lat_sch    => wpho90);

	ddr_wwn <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => DATA_GEAR,
		lat_cod    => CWL_COD,
		lat_tab    => WWNL_TAB,
		lat_ext    => WWNX_LAT,
		lat_wid    => WID_LAT,

		lat_val    => sys_cwl,
		lat_sch    => wpho90);

	ddr_odt <= ddr_task (
		clk_phases => CLK_EDGES,
		gear       => CMMD_GEAR,
		lat_cod    => "000",
		lat_tab    => (0 TO 0 => 0),
		lat_ext    => 2*CMMD_GEAR,
		lat_wid    => WID_LAT,

		lat_val    => "000",
		lat_sch    => wpho0);
end;
