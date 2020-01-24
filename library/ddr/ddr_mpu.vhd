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

entity ddr_mpu is
	generic (
		gear : natural;
		lRCD : natural;
		lRFC : natural;
		lWR  : natural;
		lRP  : natural;

		bl_cod : std_logic_vector;
		bl_tab : natural_vector;

		cl_cod : std_logic_vector;
		cl_tab : natural_vector;
		cwl_cod : std_logic_vector;
		cwl_tab : natural_vector);
	port (
		ddr_mpu_bl  : in std_logic_vector;
		ddr_mpu_cl  : in std_logic_vector;
		ddr_mpu_cwl : in std_logic_vector;

		ddr_mpu_rst : in std_logic;
		ddr_mpu_clk : in std_logic;
		ddr_mpu_cmd : in std_logic_vector(0 to 2) := (others => '1');
		ddr_mpu_trdy : out std_logic;
		ddr_mpu_act : out std_logic;
		ddr_mpu_cas : out std_logic;
		ddr_mpu_ras : out std_logic;
		ddr_mpu_we  : out std_logic;
		ddr_mpu_cen : out std_logic;

		ddr_mpu_rea  : out std_logic;
		ddr_mpu_rwin : out std_logic;
		ddr_mpu_wri  : out std_logic;
		ddr_mpu_wwin : out std_logic);

end;

architecture arch of ddr_mpu is
	constant ras : natural := 0;
	constant cas : natural := 1;
	constant we  : natural := 2;

	function timer_size (
		constant lRCD : natural;
		constant lRFC : natural;
		constant lWR  : natural;
		constant lRP  : natural;
		constant bl_tab : natural_vector;
		constant cl_tab : natural_vector;
		constant cwl_tab : natural_vector)
		return natural is
		variable val : natural;
		variable aux : natural;
	begin
		aux := max(lRCD,lRFC);
		aux := max(aux, lRP);
		for i in bl_tab'range loop
			aux := max(aux, bl_tab(i));
		end loop;
		for i in cl_tab'range loop
			aux := max(aux, cl_tab(i));
		end loop;
		for i in cwl_tab'range loop
			aux := max(aux, cwl_tab(i)+lWR);
		end loop;
		val := 1;
		aux := aux-2;
		while (aux > 0) loop
			aux := aux / 2;
			val := val + 1;
		end loop;
		return val;
	end;

		
	constant lat_size : natural := timer_size(lRCD, lRFC, lWR, lRP, bl_tab, cl_tab, cwl_tab);
	signal lat_timer : signed(0 to lat_size-1) := (others => '1');

	signal ddr_rea : std_logic;
	signal ddr_wri : std_logic;

	constant ddr_nop   : std_logic_vector(0 to 2) := "111";
	constant ddr_act   : std_logic_vector(0 to 2) := "011";
	constant ddr_read  : std_logic_vector(0 to 2) := "101";
	constant ddr_write : std_logic_vector(0 to 2) := "100";
	constant ddr_pre   : std_logic_vector(0 to 2) := "010";
	constant ddr_aut   : std_logic_vector(0 to 2) := "001";
	constant ddr_dcare : std_logic_vector(0 to 2) := "000";

	constant xdrs_act      : std_logic_vector(0 to 2) := "011";
	constant xdrs_read_bl  : std_logic_vector(0 to 2) := "101";
	constant xdrs_read_cl  : std_logic_vector(0 to 2) := "001";
	constant xdrs_write_bl : std_logic_vector(0 to 2) := "100";
	constant xdrs_write_cl : std_logic_vector(0 to 2) := "000";
	constant xdrs_pre      : std_logic_vector(0 to 2) := "010";
	signal ddr_state : std_logic_vector(0 to 2);

	type lat_id is (ID_IDLE, ID_RCD, ID_RFC, ID_RP, ID_BL, ID_CL, ID_CWL);
	type ddr_state_word is record
		ddr_state : std_logic_vector(0 to 2);
		ddr_state_n : std_logic_vector(0 to 2);
		ddr_cmi : std_logic_vector(0 to 2);
		ddr_cmo : std_logic_vector(0 to 2);
		ddr_lat : lat_id;
		ddr_cen : std_logic;
		ddr_rea : std_logic;
		ddr_wri : std_logic;
		ddr_act : std_logic;
		ddr_rph : std_logic;
		ddr_wph : std_logic;
		ddr_rdy : std_logic;
	end record;

	signal ddr_rdy_ena : std_logic;

	type ddr_state_vector is array(natural range <>) of ddr_state_word;
	constant ddr_state_tab : ddr_state_vector(0 to 13-1) := (

		-------------
		-- DDR_PRE --
		-------------

		(ddr_state => XDRS_PRE, ddr_state_n => XDRS_PRE,
		 ddr_cmi => ddr_nop, ddr_cmo => ddr_nop, ddr_lat => ID_IDLE,
		 ddr_rea => '0', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),

		(ddr_state => XDRS_PRE, ddr_state_n => XDRS_PRE,
		 ddr_cmi => ddr_pre, ddr_cmo => ddr_pre, ddr_lat => ID_RP,
		 ddr_rea => '0', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),
		(ddr_state => XDRS_PRE, ddr_state_n => XDRS_ACT,
		 ddr_cmi => ddr_act, ddr_cmo => ddr_act, ddr_lat => ID_RCD,
		 ddr_rea => '0', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),
		(ddr_state => XDRS_PRE, ddr_state_n => XDRS_PRE,
		 ddr_cmi => ddr_aut, ddr_cmo => ddr_aut, ddr_lat => ID_RFC,
		 ddr_rea => '0', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),

		-------------
		-- DDR_ACT --
		-------------

		(ddr_state => XDRS_ACT, ddr_state_n => XDRS_READ_BL,
		 ddr_cmi => ddr_read, ddr_cmo => ddr_read, ddr_lat => ID_BL,
		 ddr_rea => '1', ddr_wri => '0', ddr_cen => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '0'),
		(ddr_state => XDRS_ACT, ddr_state_n => XDRS_WRITE_BL,
		 ddr_cmi => ddr_write, ddr_cmo => ddr_write, ddr_lat => ID_BL,
		 ddr_rea => '0', ddr_wri => '1', ddr_cen => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '1'),

		--------------
		-- DDR_READ --
		--------------

		(ddr_state => XDRS_READ_BL, ddr_state_n => XDRS_READ_BL,
		 ddr_cmi => ddr_read, ddr_cmo => ddr_read, ddr_lat => ID_BL,
		 ddr_rea => '1', ddr_wri => '0', ddr_cen => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '1', ddr_wph => '0'),
		(ddr_state => XDRS_READ_BL, ddr_state_n => XDRS_READ_BL,
		 ddr_cmi => ddr_nop, ddr_cmo => ddr_nop, ddr_lat => ID_IDLE,
		 ddr_rea => '1', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),
		(ddr_state => XDRS_READ_BL, ddr_state_n => XDRS_READ_CL,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => ID_CL,
		 ddr_rea => '1', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '0', ddr_rdy => '0', ddr_rph => '0', ddr_wph => '0'),
		(ddr_state => XDRS_READ_CL, ddr_state_n => XDRS_PRE,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_pre, ddr_lat => ID_RP,
		 ddr_rea => '1', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'),


		---------------
		-- DDR_WRITE --
		---------------

		(ddr_state => XDRS_WRITE_BL, ddr_state_n => XDRS_WRITE_BL,
		 ddr_cmi => ddr_write, ddr_cmo => ddr_write, ddr_lat => ID_BL,
		 ddr_rea => '0', ddr_wri => '1', ddr_cen => '1',
		 ddr_act => '0', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '1'),
		(ddr_state => XDRS_WRITE_BL, ddr_state_n => XDRS_WRITE_CL,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_nop, ddr_lat => ID_CWL,
		 ddr_rea => '0', ddr_wri => '1', ddr_cen => '0',
		 ddr_act => '0', ddr_rdy => '0', ddr_rph => '0', ddr_wph => '0'),
		(ddr_state => XDRS_WRITE_CL, ddr_state_n => XDRS_PRE,
		 ddr_cmi => ddr_dcare, ddr_cmo => ddr_pre, ddr_lat => ID_RP,
		 ddr_rea => '0', ddr_wri => '0', ddr_cen => '0',
		 ddr_act => '1', ddr_rdy => '1', ddr_rph => '0', ddr_wph => '0'));

		attribute fsm_encoding : string;
		attribute fsm_encoding of ddr_state : signal is "compact";

	function "+" (
		constant tab : natural_vector;
		constant off : natural)
		return natural_vector is
		variable val : natural_vector(tab'range);
	begin
		for i in tab'range loop
			val(i) := tab(i) + off;
		end loop;
		return val;
	end;

	impure function select_lat (
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector)
		return signed is
		subtype latword is std_logic_vector(0 to lat_cod'length/lat_tab'length-1);
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

		impure function select_latword (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_tab : natural_vector)
			return signed is
			variable val : signed(lat_timer'range);
		begin
			val := (others => '-');
			for i in lat_cod'range loop
				if lat_cod(i)=lat_val then
					val := to_signed((lat_tab(i)+gear-1)/gear-2, lat_timer'length);
					exit;
				end if;
			end loop;
			return val;
		end;
			
	begin
		return select_latword(lat_val, to_latwordvector(lat_cod), lat_tab);
	end;

begin

	ddr_mpu_p: process (ddr_mpu_clk)
		variable ddr_act : std_logic;
	begin
		if rising_edge(ddr_mpu_clk) then
			if ddr_mpu_rst='0' then
				assert ddr_state/=(ddr_state'range => '-')
					report "ERROR -------------------->>>>"
					severity failure;
				ddr_mpu_act <= ddr_act;
				if lat_timer(0)='1' then
					ddr_state <= (others => '-');
					lat_timer <= (others => '-');
					ddr_mpu_ras <= '-';
					ddr_mpu_cas <= '-';
					ddr_mpu_we  <= '-';
					ddr_rea <= '-';
					ddr_wri <= '-';
					ddr_act := '-';
					ddr_mpu_rwin <= '-';
					ddr_mpu_wwin <= '-';
					ddr_rdy_ena <= '-';
					ddr_mpu_cen <= '-';
					for i in ddr_state_tab'range loop
						if ddr_state=ddr_state_tab(i).ddr_state then 
							if ddr_state_tab(i).ddr_cmi=ddr_mpu_cmd or
							   ddr_state_tab(i).ddr_cmi="000" then
								ddr_state <= ddr_state_tab(i).ddr_state_n;
								ddr_mpu_ras <= ddr_state_tab(i).ddr_cmo(ras);
								ddr_mpu_cas <= ddr_state_tab(i).ddr_cmo(cas);
								ddr_mpu_we  <= ddr_state_tab(i).ddr_cmo(we);
								ddr_rea <= ddr_state_tab(i).ddr_rea;
								ddr_wri <= ddr_state_tab(i).ddr_wri;
								ddr_act := ddr_state_tab(i).ddr_act;
								ddr_mpu_cen <= ddr_state_tab(i).ddr_cen;
								ddr_mpu_rwin <= ddr_state_tab(i).ddr_rph;
								ddr_mpu_wwin <= ddr_state_tab(i).ddr_wph;
								ddr_rdy_ena <= ddr_state_tab(i).ddr_rdy;

								case ddr_state_tab(i).ddr_lat is
								when ID_BL =>
									lat_timer <= select_lat(ddr_mpu_bl, bl_cod, bl_tab);
								when ID_CL =>
									lat_timer <= select_lat(ddr_mpu_cl, cl_cod, cl_tab);
								when ID_CWL =>
									lat_timer <= select_lat(ddr_mpu_cwl, cwl_cod, cwl_tab+gear*lWR);
								when ID_RCD =>
									lat_timer <= to_signed(lRCD-2, lat_timer'length);
								when ID_RFC =>
									lat_timer <= to_signed(lRFC-2, lat_timer'length);
								when ID_RP =>
									lat_timer <= to_signed(lRP-2, lat_timer'length);
								when ID_IDLE =>
									lat_timer <= (others => '1');
								end case;
								exit;
							end if;
						end if;
					end loop;
				else
					ddr_mpu_ras <= ddr_nop(ras);
					ddr_mpu_cas <= ddr_nop(cas);
					ddr_mpu_we  <= ddr_nop(we);
					ddr_mpu_cen <= '0';
					lat_timer   <= lat_timer - 1;
				end if;
			else
				ddr_state <= ddr_state_tab(0).ddr_state_n;
				ddr_mpu_ras <= ddr_state_tab(0).ddr_cmo(ras);
				ddr_mpu_cas <= ddr_state_tab(0).ddr_cmo(cas);
				ddr_mpu_we  <= ddr_state_tab(0).ddr_cmo(we);
				ddr_rea <= ddr_state_tab(0).ddr_rea;
				ddr_wri <= ddr_state_tab(0).ddr_wri;
				ddr_act := '1';
				ddr_mpu_act <= ddr_state_tab(0).ddr_act;
				ddr_mpu_cen <= '0';
				ddr_mpu_rwin <= ddr_state_tab(0).ddr_rph;
				ddr_mpu_wwin <= ddr_state_tab(0).ddr_wph;
				ddr_rdy_ena <= '1';
				lat_timer <= (others => '1');
			end if;
		end if;
	end process;

	ddr_mpu_trdy <= lat_timer(0) and ddr_rdy_ena;
	ddr_mpu_rea <= ddr_rea;
	ddr_mpu_wri <= ddr_wri;

end;
