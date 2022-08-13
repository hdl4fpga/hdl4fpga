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
use hdl4fpga.profiles.all;
use hdl4fpga.sdr_db.all;
use hdl4fpga.sdr_param.all;

entity sdr_mpu is
	generic (
		tcp           : real := 0.0;
		fpga          : fpga_devices;
		chip          : sdram_chips;
		gear          : natural;
		bl_cod        : std_logic_vector;
		cl_cod        : std_logic_vector;
		cwl_cod       : std_logic_vector);
	port (
		sdr_mpu_alat  : out std_logic_vector(2 downto 0);
		sdr_mpu_blat  : out std_logic_vector;
		sdr_mpu_bl    : in std_logic_vector;
		sdr_mpu_cl    : in std_logic_vector;
		sdr_mpu_cwl   : in std_logic_vector;

		sdr_mpu_rst   : in std_logic;
		sdr_mpu_clk   : in std_logic;
		sdr_mpu_cmd   : in std_logic_vector(0 to 2) := (others => '1');
		sdr_mpu_fch   : out std_logic;
		sdr_mpu_trdy  : out std_logic;
		sdr_mpu_act   : out std_logic;
		sdr_mpu_ras   : out std_logic;
		sdr_mpu_cas   : out std_logic;
		sdr_mpu_we    : out std_logic;
		sdr_mpu_cen   : out std_logic;

		sdr_mpu_rea   : out std_logic;
		sdr_mpu_rwin  : out std_logic;
		sdr_mpu_wri   : out std_logic;
		sdr_mpu_wwin  : out std_logic;
		sdr_mpu_rwwin : out std_logic);

end;

architecture arch of sdr_mpu is

	constant stdr         : sdr_standards := sdrmark_standard(chip);

	constant lwr  : natural  := to_sdrlatency(tcp, sdr_timing(chip, twr)+tcp*real(sdr_latency(fpga, dqsxl)));
	constant lrcd : natural  := to_sdrlatency(tcp, chip, trcd);
	constant lrfc : natural  := to_sdrlatency(tcp, chip, trfc);
	constant lrp  : natural  := to_sdrlatency(tcp, chip, trp);
	constant bl_tab  : natural_vector   := sdr_lattab(stdr, bl);
	constant cl_tab  : natural_vector   := sdr_lattab(stdr, cl);
	constant cwl_tab : natural_vector   := sdr_lattab(stdr, cwl);

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

	signal sdr_state : ddrs_states;

	type lat_id is (id_idle, id_rcd, id_rfc, id_rp, id_bl, id_cl, id_cwl);
	type sdr_state_word is record
		sdr_state   : ddrs_states;
		sdr_state_n : ddrs_states;
		sdr_cmi     : std_logic_vector(0 to 2);
		sdr_cmo     : std_logic_vector(0 to 2);
		sdr_lat     : lat_id;
		sdr_cen     : std_logic;
		sdr_rea     : std_logic;
		sdr_rph     : std_logic;
		sdr_wph     : std_logic;
		sdr_rdy     : std_logic;
		sdr_fch     : std_logic;
	end record;

	signal sdr_rdy_ena : std_logic;
	signal sdr_rdy_fch : std_logic;

	type sdr_state_vector is array(natural range <>) of sdr_state_word;
	constant sdr_state_tab : sdr_state_vector(0 to 14-1) := (

		-------------
		-- mpu_pre --
		-------------

		(sdr_state => ddrs_pre, sdr_state_n => ddrs_pre,
		 sdr_cmi => mpu_nop, sdr_cmo => mpu_nop, sdr_lat => id_idle,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),

		(sdr_state => ddrs_pre, sdr_state_n => ddrs_pre,
		 sdr_cmi => mpu_pre, sdr_cmo => mpu_pre, sdr_lat => id_rp,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),
		(sdr_state => ddrs_pre, sdr_state_n => ddrs_act,
		 sdr_cmi => mpu_act, sdr_cmo => mpu_act, sdr_lat => id_rcd,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),
		(sdr_state => ddrs_pre, sdr_state_n => ddrs_pre,
		 sdr_cmi => mpu_aut, sdr_cmo => mpu_aut, sdr_lat => id_rfc,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),

		-------------
		-- mpu_act --
		-------------

		(sdr_state => ddrs_act, sdr_state_n => ddrs_read_bl,
		 sdr_cmi => mpu_read, sdr_cmo => mpu_read, sdr_lat => id_bl,
		 sdr_rea => '1', sdr_cen => '1', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '1', sdr_wph => '0'),
		(sdr_state => ddrs_act, sdr_state_n => ddrs_write_bl,
		 sdr_cmi => mpu_write, sdr_cmo => mpu_write, sdr_lat => id_bl,
		 sdr_rea => '0', sdr_cen => '1', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '1'),
		(sdr_state => ddrs_act, sdr_state_n => ddrs_read_bl,
		 sdr_cmi => mpu_nop, sdr_cmo => mpu_nop, sdr_lat => id_idle,
		 sdr_rea => '1', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),

		--------------
		-- mpu_read --
		--------------

		(sdr_state => ddrs_read_bl, sdr_state_n => ddrs_read_bl,
		 sdr_cmi => mpu_read, sdr_cmo => mpu_read, sdr_lat => id_bl,
		 sdr_rea => '1', sdr_cen => '1', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '1', sdr_wph => '0'),
		(sdr_state => ddrs_read_bl, sdr_state_n => ddrs_read_bl,
		 sdr_cmi => mpu_nop, sdr_cmo => mpu_nop, sdr_lat => id_idle,
		 sdr_rea => '1', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),
		(sdr_state => ddrs_read_bl, sdr_state_n => ddrs_read_cl,
		 sdr_cmi => mpu_dcare, sdr_cmo => mpu_nop, sdr_lat => id_cl,
		 sdr_rea => '1', sdr_cen => '0', sdr_fch => '1',
		 sdr_rdy => '0', sdr_rph => '0', sdr_wph => '0'),
		(sdr_state => ddrs_read_cl, sdr_state_n => ddrs_pre,
		 sdr_cmi => mpu_dcare, sdr_cmo => mpu_pre, sdr_lat => id_rp,
		 sdr_rea => '1', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'),


		---------------
		-- mpu_write --
		---------------

		(sdr_state => ddrs_write_bl, sdr_state_n => ddrs_write_bl,
		 sdr_cmi => mpu_write, sdr_cmo => mpu_write, sdr_lat => id_bl,
		 sdr_rea => '0', sdr_cen => '1', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '1'),
		(sdr_state => ddrs_write_bl, sdr_state_n => ddrs_write_cl,
		 sdr_cmi => mpu_dcare, sdr_cmo => mpu_nop, sdr_lat => id_cwl,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '1',
		 sdr_rdy => '0', sdr_rph => '0', sdr_wph => '0'),
		(sdr_state => ddrs_write_cl, sdr_state_n => ddrs_pre,
		 sdr_cmi => mpu_dcare, sdr_cmo => mpu_pre, sdr_lat => id_rp,
		 sdr_rea => '0', sdr_cen => '0', sdr_fch => '0',
		 sdr_rdy => '1', sdr_rph => '0', sdr_wph => '0'));

		attribute fsm_encoding : string;
		attribute fsm_encoding of sdr_state : signal is "compact";

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

	sdr_mpu_alat <= std_logic_vector(to_unsigned(lrcd, sdr_mpu_alat'length));
	sdr_mpu_blat <= std_logic_vector(resize(unsigned(signed'(select_lat(sdr_mpu_bl, bl_cod, bl_tab))), sdr_mpu_blat'length));
	sdr_mpu_p: process (sdr_mpu_clk)
		variable state_set : boolean;
		variable id :lat_id ;
	begin
		if rising_edge(sdr_mpu_clk) then
			if sdr_mpu_rst='0' then

				assert state_set
					report "error -------------------->>>>"
					severity failure;


				if lat_timer(0)='1' then
					state_set     := false;
					lat_timer     <= (others => '-');
					sdr_mpu_ras   <= '-';
					sdr_mpu_cas   <= '-';
					sdr_mpu_we    <= '-';
					sdr_mpu_rea   <= '-';
					sdr_mpu_rwin  <= '-';
					sdr_mpu_wwin  <= '-';
					sdr_mpu_rwwin <= '-';
					sdr_rdy_ena   <= '-';
					sdr_rdy_fch   <= '-';
					sdr_mpu_cen   <= '-';
					for i in sdr_state_tab'range loop
						if sdr_state=sdr_state_tab(i).sdr_state then
							if sdr_state_tab(i).sdr_cmi=sdr_mpu_cmd or
							   sdr_state_tab(i).sdr_cmi="000" then
								state_set    := true;
								sdr_state    <= sdr_state_tab(i).sdr_state_n;
								sdr_mpu_cen  <= sdr_state_tab(i).sdr_cen;
								sdr_mpu_ras  <= sdr_state_tab(i).sdr_cmo(ras);
								sdr_mpu_cas  <= sdr_state_tab(i).sdr_cmo(cas);
								sdr_mpu_we   <= sdr_state_tab(i).sdr_cmo(we);
								sdr_mpu_rea  <= sdr_state_tab(i).sdr_rea;
								sdr_mpu_rwin <= sdr_state_tab(i).sdr_rph;
								sdr_mpu_wwin <= sdr_state_tab(i).sdr_wph;
								sdr_mpu_rwwin <= sdr_state_tab(i).sdr_wph or sdr_state_tab(i).sdr_rph;
								sdr_rdy_ena  <= sdr_state_tab(i).sdr_rdy;
								sdr_rdy_fch  <= sdr_state_tab(i).sdr_fch;

								id := sdr_state_tab(i).sdr_lat;
								case sdr_state_tab(i).sdr_lat is
								when id_bl =>
									lat_timer <= select_lat(sdr_mpu_bl, bl_cod, bl_tab);
								when id_cl =>
									lat_timer <= select_lat(sdr_mpu_cl, cl_cod, cl_tab);
								when id_cwl =>
									lat_timer <= select_lat(sdr_mpu_cwl, cwl_cod, cwl_tab+gear*lwr);
								when id_rcd =>
									lat_timer <= to_signed(lrcd-2, lat_timer'length);
								when id_rfc =>
									lat_timer <= to_signed(lrfc-2, lat_timer'length);
								when id_rp =>
									lat_timer <= to_signed(lrp-2, lat_timer'length);
								when id_idle =>
									lat_timer <= (others => '1');
								end case;
								exit;
							end if;
						end if;
					end loop;
				else
					sdr_mpu_cen <= '0';
					sdr_mpu_ras <= mpu_nop(ras);
					sdr_mpu_cas <= mpu_nop(cas);
					sdr_mpu_we  <= mpu_nop(we);
					lat_timer   <= lat_timer - 1;
				end if;
			else
				state_set     := true;
				sdr_state     <= sdr_state_tab(0).sdr_state_n;
				sdr_mpu_cen   <= '0';
				sdr_mpu_ras   <= sdr_state_tab(0).sdr_cmo(ras);
				sdr_mpu_cas   <= sdr_state_tab(0).sdr_cmo(cas);
				sdr_mpu_we    <= sdr_state_tab(0).sdr_cmo(we);
				sdr_mpu_rea   <= sdr_state_tab(0).sdr_rea;
				sdr_mpu_rwin  <= sdr_state_tab(0).sdr_rph;
				sdr_mpu_wwin  <= sdr_state_tab(0).sdr_wph;
				sdr_mpu_rwwin <= sdr_state_tab(0).sdr_wph or sdr_state_tab(0).sdr_rph;
				sdr_rdy_ena   <= '1';
				sdr_rdy_fch   <= '1';
				lat_timer     <= (others => '1');
			end if;

		end if;
	end process;

	sdr_mpu_act  <= setif(sdr_state=ddrs_act);
	sdr_mpu_wri  <= setif(sdr_state=ddrs_write_cl or sdr_state=ddrs_write_bl);
	sdr_mpu_trdy <= lat_timer(0) and sdr_rdy_ena;
	sdr_mpu_fch  <= lat_timer(0) and sdr_rdy_fch;

	debug : with sdr_state select
	mpu_state <=
		s_act	  when ddrs_act,
		s_readbl  when ddrs_read_bl,
		s_readcl  when ddrs_read_cl,
		s_writebl when ddrs_write_bl,
		s_writecl when ddrs_write_cl,
		s_pre     when ddrs_pre,
		s_none    when others;

	cmd_debug : with sdr_mpu_cmd select
	cmd_name <=
		c_nop   when mpu_nop,
		c_act	when mpu_act,
		c_read  when mpu_read,
		c_write when mpu_write,
		c_pre   when mpu_pre,
		c_aut   when mpu_aut,
		c_dcare when others;

end;
