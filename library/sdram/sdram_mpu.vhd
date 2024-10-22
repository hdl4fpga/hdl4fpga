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
use hdl4fpga.hdo.all;
use hdl4fpga.sdram.all;

entity sdram_mpu is
	generic (
		tcp           : real := 0.0;
		chiptmng_data : string;
		phy : string;
		al_tab        : natural_vector;
		bl_tab        : natural_vector;
		cl_tab        : natural_vector;
		cwl_tab       : natural_vector);
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

	constant tdqsz : real    := hdo(phy)**"tmng.DQSXL=0."*tcp; 
	constant twr   : real    := hdo(chiptmng_data)**".tWR";
	constant lwr   : natural := natural(ceil(twr+tdqsz)/tcp);
	constant lrcd  : natural := natural(ceil(hdo(chiptmng_data)**".tRCD=0."/tcp));
	constant lrfc  : natural := natural(ceil(hdo(chiptmng_data)**".tRFC=0."/tcp));
	constant lrp   : natural := natural(ceil(hdo(chiptmng_data)**".tRP=0."/tcp));
	constant gear  : natural := hdo(phy)**".gear";
end;

architecture arch of sdram_mpu is

	constant ras  : natural := 0;
	constant cas  : natural := 1;
	constant we   : natural := 2;

	signal lat_timer : integer range -1 to max(natural_vector'(max(cwl_tab), max(bl_tab), max(cl_tab), lrcd, lrfc, lrp)) := -1;

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

	function adjst (
		constant tab : natural_vector;
		constant lat : integer)
		return natural_vector is
		variable retval : natural_vector(tab'range);
	begin
		for i in tab'range loop
			retval(i) := tab(i)*lat;
		end loop;
		return retval;
	end;

	constant aladj_tab : natural_vector := adjst(al_tab, (gear*lrcd+2*gear)-(gear/2));
begin

	sdram_mpu_alat <= std_logic_vector(to_unsigned(aladj_tab(to_integer(unsigned(sdram_mpu_al))), sdram_mpu_alat'length));
	sdram_mpu_blat <= std_logic_vector(to_unsigned(bl_tab(to_integer(unsigned(sdram_mpu_bl))), sdram_mpu_blat'length));
	sdram_mpu_p: process (sdram_mpu_clk)
		variable state_set : boolean;
		variable lat_id :lat_id ;
		variable timer  : integer;
	begin
		if rising_edge(sdram_mpu_clk) then
			if sdram_mpu_rst='0' then

				assert state_set
					report "error -------------------->>>>"
					severity failure;


				if lat_timer < 0 then
					state_set     := false;
					-- lat_timer     <= (others => '-');
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
									timer := bl_tab(to_integer(unsigned(sdram_mpu_bl)));
								when id_cl =>
									timer := cl_tab(to_integer(unsigned(sdram_mpu_cl)));
								when id_cwl =>
									timer := cwl_tab(to_integer(unsigned(sdram_mpu_cwl)));
								when id_rcd =>
									-- timer := to_signed(lrcd-2, lat_timer'length);
									timer := aladj_tab(to_integer(unsigned(sdram_mpu_al)));
								when id_rfc =>
									timer := lrfc-2;
								when id_rp =>
									timer := lrp-2;
								when id_idle =>
									timer := -1;
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
				-- lat_timer     <= (others => '1');
			end if;

		end if;
	end process;

	sdram_mpu_act  <= setif(sdram_state=ddrs_act);
	sdram_mpu_wri  <= setif(sdram_state=ddrs_write_cl or sdram_state=ddrs_write_bl);
	sdram_mpu_trdy <= sdram_rdy_ena when lat_timer < 0 else '0';
	sdram_mpu_fch  <= sdram_rdy_fch when lat_timer < 0 else '0';
	-- sdram_mpu_trdy <= lat_timer(0) and sdram_rdy_ena;
	-- sdram_mpu_fch  <= lat_timer(0) and sdram_rdy_fch;

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
