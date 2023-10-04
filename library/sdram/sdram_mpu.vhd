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


-- !! !!!!!!!!!!!!!!!!!!! !! --
-- !! tRAS is not checked !! --
-- !! !!!!!!!!!!!!!!!!!!! !! --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.sdram_param.all;
use hdl4fpga.sdram_db.all;

entity sdram_mpu is
	generic (
		tcp           : real := 0.0;
		latencies     : latency_vector;
		chip          : sdram_chips;
		gear          : natural;
		bl_cod        : std_logic_vector;
		al_cod        : std_logic_vector;
		cl_cod        : std_logic_vector;
		cwl_cod       : std_logic_vector);
	port (
		sdram_mpu_alat  : out std_logic_vector(2 downto 0);
		sdram_mpu_blat  : out std_logic_vector;
		sdram_mpu_al    : in std_logic_vector;
		sdram_mpu_bl    : in std_logic_vector;
		sdram_mpu_cl    : in std_logic_vector;
		sdram_mpu_cwl   : in std_logic_vector;

		sdram_mpu_rst   : in std_logic;
		sdram_mpu_clk   : in std_logic;
		sdram_mpu_cmd   : in std_logic_vector(0 to 2) := (others => '1');
		sdram_mpu_fch   : out std_logic;
		sdram_mpu_trdy  : out std_logic;
		sdram_mpu_act   : out std_logic;
		sdram_mpu_ras   : out std_logic;
		sdram_mpu_cas   : out std_logic;
		sdram_mpu_we    : out std_logic;
		sdram_mpu_cen   : out std_logic;

		sdram_mpu_rea   : out std_logic;
		sdram_mpu_rwin  : out std_logic;
		sdram_mpu_wri   : out std_logic;
		sdram_mpu_wwin  : out std_logic);

end;

architecture arch of sdram_mpu is

	constant stdr    : sdram_standards := sdrmark_standard(chip);

	constant twr1     : real            := ceil((sdram_timing(chip, twr)+real(latencies(dqsxl))*tcp)/tcp);
	constant lwr     : natural          := natural(twr1); -- Diamond 3.11.2.446 crashes when replace twr1 by its expression
	constant lrcd    : natural          := to_sdrlatency(tcp, chip, trcd);
	constant lrfc    : natural          := to_sdrlatency(tcp, chip, trfc);
	constant lrp     : natural          := to_sdrlatency(tcp, chip, trp);
	constant bl_tab  : natural_vector   := sdram_lattab(stdr, bl);
	constant al_tab  : natural_vector   := sdram_lattab(stdr, al);
	constant cl_tab  : natural_vector   := sdram_lattab(stdr, cl);
	constant cwl_tab : natural_vector   := sdram_lattab(stdr, sdram_selcwl(stdr));

	constant ras  : natural := 0;
	constant cas  : natural := 1;
	constant we   : natural := 2;

	function timer_size (
		constant lrcd : natural;
		constant lrfc : natural;
		constant lwr  : natural;
		constant lrp  : natural;
		constant bl_tab : natural_vector;
		constant cl_tab : natural_vector;
		constant cwl_tab : natural_vector)
		return natural is
		variable val : natural;
		variable aux : natural;
	begin
		aux := max(lrcd,lrfc);
		aux := max(aux, lrp);
		for i in bl_tab'range loop
			aux := max(aux, bl_tab(i));
		end loop;
		for i in cl_tab'range loop
			aux := max(aux, cl_tab(i));
		end loop;
		for i in cwl_tab'range loop
			aux := max(aux, cwl_tab(i)+lwr);
		end loop;
		val := 1;
		aux := aux-2;
		while (aux > 0) loop
			aux := aux / 2;
			val := val + 1;
		end loop;
		return val;
	end;


	constant lat_size : natural := timer_size(lrcd, lrfc, lwr, lrp, bl_tab, cl_tab, cwl_tab);
	signal lat_timer : signed(0 to lat_size-1) := (others => '1');

	type cmd_names is (c_nop, c_act, c_read, c_write, c_pre, c_aut, c_dcare);
	signal cmd_name : cmd_names;

	type ddrs_states is (ddrs_act, ddrs_read_bl, ddrs_read_cl, ddrs_write_bl, ddrs_write_cl, ddrs_pre);

	type state_names is (s_act, s_readbl, s_readcl, s_writebl, s_writecl, s_pre, s_none);
	signal mpu_state : state_names;

	signal sdram_state : ddrs_states;

	type lat_id is (id_idle, id_rcd, id_rfc, id_rp, id_bl, id_cl, id_cwl);
	type sdram_state_word is record
		sdram_state   : ddrs_states;
		sdram_state_n : ddrs_states;
		sdram_cmi     : std_logic_vector(0 to 2);
		sdram_cmo     : std_logic_vector(0 to 2);
		sdram_lat     : lat_id;
		sdram_cen     : std_logic;
		sdram_rea     : std_logic;
		sdram_rph     : std_logic;
		sdram_wph     : std_logic;
		sdram_rdy     : std_logic;
		sdram_fch     : std_logic;
	end record;

	signal sdram_rdy_ena : std_logic;
	signal sdram_rdy_fch : std_logic;

	type sdram_state_vector is array(natural range <>) of sdram_state_word;
	constant sdram_state_tab : sdram_state_vector(0 to 14-1) := (

		-------------
		-- mpu_pre --
		-------------

		(sdram_state => ddrs_pre, sdram_state_n => ddrs_pre,
		 sdram_cmi => mpu_nop, sdram_cmo => mpu_nop, sdram_lat => id_idle,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),

		(sdram_state => ddrs_pre, sdram_state_n => ddrs_pre,
		 sdram_cmi => mpu_pre, sdram_cmo => mpu_pre, sdram_lat => id_rp,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),
		(sdram_state => ddrs_pre, sdram_state_n => ddrs_act,
		 sdram_cmi => mpu_act, sdram_cmo => mpu_act, sdram_lat => id_rcd,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),
		(sdram_state => ddrs_pre, sdram_state_n => ddrs_pre,
		 sdram_cmi => mpu_aut, sdram_cmo => mpu_aut, sdram_lat => id_rfc,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),

		-------------
		-- mpu_act --
		-------------

		(sdram_state => ddrs_act, sdram_state_n => ddrs_read_bl,
		 sdram_cmi => mpu_read, sdram_cmo => mpu_read, sdram_lat => id_bl,
		 sdram_rea => '1', sdram_cen => '1', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '1', sdram_wph => '0'),
		(sdram_state => ddrs_act, sdram_state_n => ddrs_write_bl,
		 sdram_cmi => mpu_write, sdram_cmo => mpu_write, sdram_lat => id_bl,
		 sdram_rea => '0', sdram_cen => '1', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '1'),
		(sdram_state => ddrs_act, sdram_state_n => ddrs_read_bl,
		 sdram_cmi => mpu_nop, sdram_cmo => mpu_nop, sdram_lat => id_idle,
		 sdram_rea => '1', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),

		--------------
		-- mpu_read --
		--------------

		(sdram_state => ddrs_read_bl, sdram_state_n => ddrs_read_bl,
		 sdram_cmi => mpu_read, sdram_cmo => mpu_read, sdram_lat => id_bl,
		 sdram_rea => '1', sdram_cen => '1', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '1', sdram_wph => '0'),
		(sdram_state => ddrs_read_bl, sdram_state_n => ddrs_read_bl,
		 sdram_cmi => mpu_nop, sdram_cmo => mpu_nop, sdram_lat => id_idle,
		 sdram_rea => '1', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),
		(sdram_state => ddrs_read_bl, sdram_state_n => ddrs_read_cl,
		 sdram_cmi => mpu_dcare, sdram_cmo => mpu_nop, sdram_lat => id_cl,
		 sdram_rea => '1', sdram_cen => '0', sdram_fch => '1',
		 sdram_rdy => '0', sdram_rph => '0', sdram_wph => '0'),
		(sdram_state => ddrs_read_cl, sdram_state_n => ddrs_pre,
		 sdram_cmi => mpu_dcare, sdram_cmo => mpu_pre, sdram_lat => id_rp,
		 sdram_rea => '1', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'),


		---------------
		-- mpu_write --
		---------------

		(sdram_state => ddrs_write_bl, sdram_state_n => ddrs_write_bl,
		 sdram_cmi => mpu_write, sdram_cmo => mpu_write, sdram_lat => id_bl,
		 sdram_rea => '0', sdram_cen => '1', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '1'),
		(sdram_state => ddrs_write_bl, sdram_state_n => ddrs_write_cl,
		 sdram_cmi => mpu_dcare, sdram_cmo => mpu_nop, sdram_lat => id_cwl,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '1',
		 sdram_rdy => '0', sdram_rph => '0', sdram_wph => '0'),
		(sdram_state => ddrs_write_cl, sdram_state_n => ddrs_pre,
		 sdram_cmi => mpu_dcare, sdram_cmo => mpu_pre, sdram_lat => id_rp,
		 sdram_rea => '0', sdram_cen => '0', sdram_fch => '0',
		 sdram_rdy => '1', sdram_rph => '0', sdram_wph => '0'));

		attribute fsm_encoding : string;
		attribute fsm_encoding of sdram_state : signal is "compact";

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

	function "-" (
		constant off : natural;
		constant tab : natural_vector)
		return natural_vector is
		variable val : natural_vector(tab'range);
	begin
		for i in tab'range loop
			if off > tab(i) then
				val(i) := off-tab(i);
			else
				val(i) := 0;
			end if;
		end loop;
		return val;
	end;

	function "*" (
		constant off : natural;
		constant tab : natural_vector)
		return natural_vector is
		variable val : natural_vector(tab'range);
	begin
		for i in tab'range loop
			val(i) := tab(i)*off;
		end loop;
		return val;
	end;

	function "/" (
		constant tab : natural_vector;
		constant off : natural)
		return natural_vector is
		variable val : natural_vector(tab'range);
	begin
		for i in tab'range loop
			val(i) := tab(i)/off;
		end loop;
		return val;
	end;

	function select_lat (
		constant lat_val : std_logic_vector;
		constant lat_cod : std_logic_vector;
		constant lat_tab : natural_vector;
		constant lat_len : natural :=lat_timer'length)
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

		function select_latword (
			constant lat_val : std_logic_vector;
			constant lat_cod : latword_vector;
			constant lat_tab : natural_vector)
			return signed is
			variable val : signed(0 to lat_len-1);
		begin
			val := (others => '-');
			for i in lat_cod'range loop
				if lat_cod(i)=lat_val then
					val := to_signed((lat_tab(i)+gear-1)/gear-2, lat_len);
					return val;
				end if;
			end loop;
			assert false
			report "select_latword : latency register '" & to_string(lat_val) & "' is invalid"
			severity failure;
			return val;
		end;

	begin
		return select_latword(lat_val, to_latwordvector(lat_cod), lat_tab);
	end;

begin

	-- sdram_mpu_alat <= std_logic_vector(to_unsigned(lrcd, sdram_mpu_alat'length));
	sdram_mpu_alat <= std_logic_vector(select_lat(sdram_mpu_al, al_cod, (gear*lrcd+2*gear)-(gear/2)*al_tab, sdram_mpu_alat'length));
	sdram_mpu_blat <= std_logic_vector(resize(unsigned(signed'(select_lat(sdram_mpu_bl, bl_cod, bl_tab))), sdram_mpu_blat'length));
	sdram_mpu_p: process (sdram_mpu_clk)
		variable state_set : boolean;
		variable lat_id :lat_id ;
		variable timer  : signed(lat_timer'range);
	begin
		if rising_edge(sdram_mpu_clk) then
			if sdram_mpu_rst='0' then

				assert state_set
					report "error -------------------->>>>"
					severity failure;


				if lat_timer(0)='1' then
					state_set     := false;
					lat_timer     <= (others => '-');
					sdram_mpu_ras   <= '-';
					sdram_mpu_cas   <= '-';
					sdram_mpu_we    <= '-';
					sdram_mpu_rea   <= '-';
					sdram_mpu_rwin  <= '-';
					sdram_mpu_wwin  <= '-';
					sdram_rdy_ena   <= '-';
					sdram_rdy_fch   <= '-';
					sdram_mpu_cen   <= '-';
					for i in sdram_state_tab'range loop
						if sdram_state=sdram_state_tab(i).sdram_state then
							if sdram_state_tab(i).sdram_cmi=sdram_mpu_cmd or
							   sdram_state_tab(i).sdram_cmi="000" then
								state_set    := true;
								sdram_state    <= sdram_state_tab(i).sdram_state_n;
								sdram_mpu_cen  <= sdram_state_tab(i).sdram_cen;
								sdram_mpu_ras  <= sdram_state_tab(i).sdram_cmo(ras);
								sdram_mpu_cas  <= sdram_state_tab(i).sdram_cmo(cas);
								sdram_mpu_we   <= sdram_state_tab(i).sdram_cmo(we);
								sdram_mpu_rea  <= sdram_state_tab(i).sdram_rea;
								sdram_mpu_rwin <= sdram_state_tab(i).sdram_rph;
								sdram_mpu_wwin <= sdram_state_tab(i).sdram_wph;
								sdram_rdy_ena  <= sdram_state_tab(i).sdram_rdy;
								sdram_rdy_fch  <= sdram_state_tab(i).sdram_fch;

								lat_id := sdram_state_tab(i).sdram_lat;
								timer  := lat_timer;
								case lat_id is
								when id_bl =>
									timer := select_lat(sdram_mpu_bl, bl_cod, bl_tab);
								when id_cl =>
									timer := select_lat(sdram_mpu_cl, cl_cod, cl_tab);
								when id_cwl =>
									timer := select_lat(sdram_mpu_cwl, cwl_cod, cwl_tab+gear*lwr);
								when id_rcd =>
									-- timer := to_signed(lrcd-2, lat_timer'length);
									timer := select_lat(sdram_mpu_al, al_cod, (gear*lrcd)-(gear/2)*al_tab, timer'length);
								when id_rfc =>
									timer := to_signed(lrfc-2, lat_timer'length);
								when id_rp =>
									timer := to_signed(lrp-2, lat_timer'length);
								when id_idle =>
									timer := (others => '1');
								end case;
								lat_timer <= timer;
								exit;
							end if;
						end if;
					end loop;
				else
					sdram_mpu_cen <= '0';
					sdram_mpu_ras <= mpu_nop(ras);
					sdram_mpu_cas <= mpu_nop(cas);
					sdram_mpu_we  <= mpu_nop(we);
					lat_timer   <= lat_timer - 1;
				end if;
			else
				state_set     := true;
				sdram_state     <= sdram_state_tab(0).sdram_state_n;
				sdram_mpu_cen   <= '0';
				sdram_mpu_ras   <= sdram_state_tab(0).sdram_cmo(ras);
				sdram_mpu_cas   <= sdram_state_tab(0).sdram_cmo(cas);
				sdram_mpu_we    <= sdram_state_tab(0).sdram_cmo(we);
				sdram_mpu_rea   <= sdram_state_tab(0).sdram_rea;
				sdram_mpu_rwin  <= sdram_state_tab(0).sdram_rph;
				sdram_mpu_wwin  <= sdram_state_tab(0).sdram_wph;
				sdram_rdy_ena   <= '1';
				sdram_rdy_fch   <= '1';
				lat_timer     <= (others => '1');
			end if;

		end if;
	end process;

	sdram_mpu_act  <= setif(sdram_state=ddrs_act);
	sdram_mpu_wri  <= setif(sdram_state=ddrs_write_cl or sdram_state=ddrs_write_bl);
	sdram_mpu_trdy <= lat_timer(0) and sdram_rdy_ena;
	sdram_mpu_fch  <= lat_timer(0) and sdram_rdy_fch;

	debug : with sdram_state select
	mpu_state <=
		s_act	  when ddrs_act,
		s_readbl  when ddrs_read_bl,
		s_readcl  when ddrs_read_cl,
		s_writebl when ddrs_write_bl,
		s_writecl when ddrs_write_cl,
		s_pre     when ddrs_pre,
		s_none    when others;

	cmd_debug : with sdram_mpu_cmd select
	cmd_name <=
		c_nop   when mpu_nop,
		c_act	when mpu_act,
		c_read  when mpu_read,
		c_write when mpu_write,
		c_pre   when mpu_pre,
		c_aut   when mpu_aut,
		c_dcare when others;

end;
