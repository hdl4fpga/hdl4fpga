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
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;
use hdl4fpga.sdram_db.all;

entity sdram_sch is
	generic (
		latencies  : latency_vector;
		chip       : sdram_chips;

		delay_size : natural := 64;
		gear       : natural;
		cmmd_gear  : natural := 1;

		cl_cod     : std_logic_vector;
		cwl_cod    : std_logic_vector);
	port (
		sys_clk    : in  std_logic;
		sys_cl     : in  std_logic_vector;
		sys_cwl    : in  std_logic_vector;
		sys_rea    : in  std_logic;
		sys_wri    : in  std_logic;

		sdram_st   : out std_logic_vector(gear-1 downto 0);
		sdram_dmo  : out std_logic_vector(gear-1 downto 0);

		sdram_dqsz : out std_logic_vector(gear-1 downto 0);
		sdram_dqs  : out std_logic_vector(gear-1 downto 0);

		sdram_dqz  : out std_logic_vector(gear-1 downto 0);
		sdram_wwn  : out std_logic_vector(gear-1 downto 0);
		sdram_odt  : out std_logic_vector(1-1    downto 0));

	constant gear_odt : natural := sdram_odt'length;

end;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of sdram_sch is
	function sdram_task (
		constant gear    : natural;
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to gear-1);
		type word_vector is array (natural range <>) of word;

		subtype latword is std_logic_vector(0 to lat_val'length-1);
		type latword_vector is array (natural range <>) of latword;

		function to_latwordvector(
			constant arg : std_logic_vector)
			return latword_vector is
			variable aux : unsigned(0 to arg'length-1);
			variable val : latword_vector(0 to arg'length/latword'length-1);
		begin
			aux := unsigned(arg);
			for i in val'range loop
				val(i) := std_logic_vector(aux(latword'range));
				aux := aux sll latword'length;
			end loop;
			return val;
		end;

		function select_lat (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for i in 0 to lat_tab'length-1 loop
				if lat_val = lat_cod(i) then
					for j in word'range loop
						val(j) := lat_sch(i)(j);
					end loop;
				end if;
			end loop;
			return val;
		end;

		constant lat_cod1 : latword_vector := to_latwordvector(lat_cod);
		variable sel_sch : word_vector(lat_cod1'range);

	begin
		sel_sch := (others => (others => '-'));
		for i in 0 to lat_tab'length-1 loop
			sel_sch(i) := pulse_delay (
				phase     => lat_sch,
				latency   => lat_tab(i),
				word_size => word'length,
				extension => lat_ext,
				width     => lat_wid);
		end loop;
		return select_lat(lat_val, lat_cod1, sel_sch);
	end;

	constant stdr      : sdram_standards := sdrmark_standard(chip);
	constant strl_tab  : natural_vector  := sdram_schtab(stdr, latencies, strl);
	constant dozl_tab  : natural_vector  := sdram_schtab(-3, strl_tab);
	constant dqszl_tab : natural_vector  := sdram_schtab(stdr, latencies, dqszl);
	constant dqsol_tab : natural_vector  := sdram_schtab(stdr, latencies, dqsl);
	constant dqzl_tab  : natural_vector  := sdram_schtab(stdr, latencies, dqzl);
	constant wwnl_tab  : natural_vector  := sdram_schtab(stdr, latencies, wwnl);

	signal wri_sr      : std_logic_vector(0 to delay_size-1);
	signal rea_sr      : std_logic_vector(0 to delay_size-1);

begin
	
	process (sys_wri, sys_rea, sys_clk)
	begin
		if rising_edge(sys_clk) then
			rea_sr <= std_logic_vector(shift_right(unsigned(rea_sr), 1));
			wri_sr <= std_logic_vector(shift_right(unsigned(wri_sr), 1));
		end if;
		rea_sr(0) <= sys_rea;
		wri_sr(0) <= sys_wri;
	end process;

	sdram_st <= sdram_task (
		gear       => gear,
		lat_val    => sys_cl,
		lat_cod    => cl_cod,
		lat_tab    => strl_tab,
		lat_ext    => latencies(strxl),
		lat_wid    => latencies(widl),
		lat_sch    => rea_sr);

	sdram_dmo <= sdram_task (
		gear       => gear,
		lat_val    => sys_cl,
		lat_cod    => cl_cod,
		lat_tab    => dozl_tab, 
		lat_ext    => 0,
		lat_wid    => latencies(widl),
		lat_sch    => rea_sr);

	sdram_dqsz <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_cod    => cwl_cod,
		lat_tab    => dqszl_tab,
		lat_ext    => latencies(dqszxl),
		lat_wid    => latencies(widl),
		lat_sch    => wri_sr);

	sdram_dqs <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_cod    => cwl_cod,
		lat_tab    => dqsol_tab,
		lat_ext    => latencies(dqsxl),
		lat_wid    => latencies(widl),
		lat_sch    => wri_sr);

	sdram_dqz <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_cod    => cwl_cod,
		lat_tab    => dqzl_tab,
		lat_ext    => latencies(dqzxl),
		lat_wid    => latencies(widl),
		lat_sch    => wri_sr);

	sdram_wwn <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_cod    => cwl_cod,
		lat_tab    => wwnl_tab,
		lat_ext    => latencies(wwnxl),
		lat_wid    => latencies(widl),
		lat_sch    => wri_sr);

	sdram_odt <= sdram_task (
		gear       => gear_odt,
		lat_val    => "000",
		lat_cod    => "000",
		lat_tab    => (0 to 0 => 0),
		lat_ext    => 2*gear_odt,
		lat_wid    => latencies(widl),
		lat_sch    => wri_sr);
end;
