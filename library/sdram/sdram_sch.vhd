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
use hdl4fpga.hdo.all;
use hdl4fpga.sdram_db.all;

entity sdram_sch is
	generic (
		phy  : string;
		fmly : string;

		delay_size : natural := 64;

		cl_tab     : natural_vector;
		cwl_tab    : natural_vector);
	port (
		sys_clk    : in  std_logic;
		sys_cl     : in  std_logic_vector;
		sys_cwl    : in  std_logic_vector;
		sys_rea    : in  std_logic;
		sys_wri    : in  std_logic;

		sdram_st   : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);
		sdram_dmo  : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);

		sdram_dqsz : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);
		sdram_dqs  : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);

		sdram_dqz  : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);
		sdram_wwn  : out std_logic_vector(hdo(phy)**".gear"-1 downto 0);
		sdram_odt  : out std_logic_vector(1-1    downto 0));

	constant gear_odt : natural := sdram_odt'length;
	constant phytmng_data : string := hdo(phy)**".tmng";
	constant gear: natural := sdram_st'length;

end;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;

library ieee;
use ieee.std_logic_1164.all;

architecture def of sdram_sch is
	function sdram_schtab (
		constant fmly    : string;
		constant latency : string)
		return natural_vector is

		variable lat    : integer := hdo(phytmng_data)**("."&latency);
		variable clval  : natural_vector(cl_tab'range);
		variable cwlval : natural_vector(cwl_tab'range);

	begin
		if latency="WWNL" then
			for i in cwl_tab'range loop
				cwlval(i) := cwl_tab(i) + lat;
			end loop;
			return cwlval;
		elsif latency="STRL" then
			for i in cl_tab'range loop
				clval(i) := cl_tab(i) + lat;
			end loop;
			return clval;
		elsif latency="DQSZL" or latency="DQSL" or latency="DQZL" then
			for i in cwl_tab'range loop
				cwlval(i) := cwl_tab(i)+lat;
				if fmly="ddr2" then
					cwlval(i) := cwl_tab(i)-2;
				end if;
			end loop;
			return cwlval;
		else
		end if;
		return (0 to 0 => 0);
	end;

	function sdram_schtab (
		constant latencies : natural_vector;
		constant latency   : integer)
		return natural_vector is
		variable retval : natural_vector(latencies'range);
	begin
		retval := latencies;
		for i in latencies'range loop
			if retval(i)+latency < 0  then
				retval(i) := 0;
			else
				retval(i) := retval(i) + latency;
			end if;
		end loop;
		return retval;
	end;

	function sdram_task (
		constant gear    : natural;
		constant lat_val : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_sch : std_logic_vector;
		constant lat_ext : natural := 0;
		constant lat_wid : natural := 1)
		return std_logic_vector is

		subtype word is std_logic_vector(0 to gear-1);
		type word_vector is array (natural range <>) of word;

		function select_lat (
			constant lat_val : std_logic_vector;
			constant lat_sch : word_vector)
			return std_logic_vector is
			variable val : word;
		begin
			val := (others => '-');
			for j in word'range loop
				val(j) := lat_sch(to_integer(unsigned(lat_val)))(j);
			end loop;
			return val;
		end;

    	function pulse_delay (
    		constant phase     : std_logic_vector;
    		constant latency   : natural := 0;
    		constant extension : natural := 0;
    		constant word_size : natural := 4;
    		constant width     : natural := 1)
    		return std_logic_vector is

    		variable latency_mod : natural;
    		variable latency_quo : natural;
    		variable delay     : natural;
    		variable pulse     : std_logic;

    		variable distance  : natural;
    		variable width_quo : natural;
    		variable width_mod : natural;
    		variable tail      : natural;
    		variable tail_quo  : natural;
    		variable tail_mod  : natural;
    		variable pulses    : std_logic_vector(0 to word_size-1);
    	begin

    		latency_mod := latency mod pulses'length;
    		latency_quo := latency  /  pulses'length;
    		for j in pulses'range loop
    			distance  := (extension-j+pulses'length-1)/pulses'length;
    			width_quo := (distance+width-1)/width;
    			width_mod := (width_quo*width-distance) mod width;

    			delay := latency_quo+(j+latency_mod)/pulses'length;
    			pulse := phase(delay);

    			if width_quo /= 0 then
    				tail_quo := width_mod  /  width_quo;
    				tail_mod := width_mod mod width_quo;
    				for l in 1 to width_quo loop
    					tail  := tail_quo + (l*tail_mod) / width_quo;
    					pulse := pulse or phase(delay+l*width-tail);
    				end loop;
    			end if;
    			pulses((latency+j) mod pulses'length) := pulse;
    		end loop;
    		return pulses;
    	end;

		variable sel_sch : word_vector(lat_tab'range);

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
		return select_lat(lat_val, sel_sch);
	end;

	constant strl_tab  : natural_vector  := sdram_schtab (fmly, "STRL");
	constant dozl_tab  : natural_vector  := sdram_schtab (strl_tab, -3);
	constant dqszl_tab : natural_vector  := sdram_schtab (fmly, "DQSZL");
	constant dqsol_tab : natural_vector  := sdram_schtab (fmly, "DQSL");
	constant dqzl_tab  : natural_vector  := sdram_schtab (fmly, "DQZL");
	constant wwnl_tab  : natural_vector  := sdram_schtab (fmly, "WWNL");

	signal wri_sr      : std_logic_vector(0 to delay_size-1);
	signal rea_sr      : std_logic_vector(0 to delay_size-1);

	constant STRL   : natural := hdo(phytmng_data)**".STRL";
	constant DQSZL  : natural := hdo(phytmng_data)**".DQSZL";
	constant DQSL   : natural := hdo(phytmng_data)**".DQSL";
	constant DQZL   : natural := hdo(phytmng_data)**".DQZL";
	constant WWNL   : natural := hdo(phytmng_data)**".WWNL";
	constant STRXL  : natural := hdo(phytmng_data)**".STRXL";
	constant DQSZX  : natural := hdo(phytmng_data)**".DQSZX";
	constant DQSXL  : natural := hdo(phytmng_data)**".DQSXL";
	constant DQSZXL : natural := hdo(phytmng_data)**".DQSZXL";
	constant DQZXL  : natural := hdo(phytmng_data)**".DQZXL";
	constant WNXL   : natural := hdo(phytmng_data)**".WNXL";
	constant WWNXL  : natural := hdo(phytmng_data)**".WWNXL";
	constant WIDL   : natural := hdo(phytmng_data)**".WIDL";

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
		lat_tab    => strl_tab,
		lat_ext    => strxl,
		lat_wid    => widl,
		lat_sch    => rea_sr);

	sdram_dmo <= sdram_task (
		gear       => gear,
		lat_val    => sys_cl,
		lat_tab    => dozl_tab, 
		lat_ext    => 0,
		lat_wid    => widl,
		lat_sch    => rea_sr);

	sdram_dqsz <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_tab    => dqszl_tab,
		lat_ext    => dqszxl,
		lat_wid    => widl,
		lat_sch    => wri_sr);

	sdram_dqs <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_tab    => dqsol_tab,
		lat_ext    => dqsxl,
		lat_wid    => widl,
		lat_sch    => wri_sr);

	sdram_dqz <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_tab    => dqzl_tab,
		lat_ext    => dqzxl,
		lat_wid    => widl,
		lat_sch    => wri_sr);

	sdram_wwn <= sdram_task (
		gear       => gear,
		lat_val    => sys_cwl,
		lat_tab    => wwnl_tab,
		lat_ext    => wwnxl,
		lat_wid    => widl,
		lat_sch    => wri_sr);

	sdram_odt <= sdram_task (
		gear       => gear_odt,
		lat_val    => "000",
		lat_tab    => (0 to 0 => 0),
		lat_ext    => 2*gear_odt,
		lat_wid    => widl,
		lat_sch    => wri_sr);
end;
