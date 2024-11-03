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

entity sdram_ctlr is
	generic (
		debug       : boolean := false;

		tcp         : real := 0.0;
		latencies   : latency_vector := (others => 0);
		chip        : sdram_chips;

		gear        : natural :=  2;
		bank_size   : natural :=  2;
		addr_size   : natural := 13;
		word_size   : natural := 16;
		byte_size   : natural :=  8);
	port (
		ctlr_alat   : out std_logic_vector(2 downto 0);
		ctlr_blat   : out std_logic_vector(2 downto 0);
		ctlr_al     : in  std_logic_vector(3-1 downto 0) := (others => '0');
		ctlr_bl     : in std_logic_vector(2 downto 0);
		ctlr_cl     : in std_logic_vector;
		ctlr_cwl    : in std_logic_vector(2 downto 0);
		ctlr_wrl    : in std_logic_vector(2 downto 0);
		ctlr_rtt    : in std_logic_vector := (0 to 0 => '-');

		ctlr_rst    : in  std_logic;
		ctlr_clk    : in  std_logic;
		ctlr_cfgrdy : buffer std_logic;
		ctlr_inirdy : out std_logic;

		ctlr_frm    : in  std_logic;
		ctlr_trdy   : out std_logic;
		ctlr_fch    : out std_logic;
		ctlr_cmd    : out std_logic_vector(0 to 2);
		ctlr_rw     : in  std_logic;
		ctlr_b      : in  std_logic_vector(bank_size-1 downto 0);
		ctlr_a      : in  std_logic_vector(addr_size-1 downto 0);
		ctlr_di_dv  : in  std_logic;
		ctlr_di_req : out std_logic;
		ctlr_do_dv  : out std_logic_vector(gear*word_size/byte_size-1 downto 0);
		ctlr_act    : out std_logic;
		ctlr_dm     : in  std_logic_vector(gear*word_size/byte_size-1 downto 0) := (others => '0');
		ctlr_di     : in  std_logic_vector(gear*word_size-1 downto 0);
		ctlr_do     : out std_logic_vector(gear*word_size-1 downto 0);

		ctlr_refreq : out std_logic;
		phy_frm     : in  std_logic := '0';
		phy_trdy    : out std_logic;
		phy_rw      : in  std_logic := '-';
		phy_inirdy  : in  std_logic := '1';
		phy_wlrdy   : in  std_logic := '-';
		phy_wlreq   : out std_logic;
		phy_rlreq   : out std_logic;
		phy_rlrdy   : in  std_logic := '1';
		phy_rst     : out std_logic;
		phy_cke     : out std_logic;
		phy_cs      : out std_logic;
		phy_ras     : out std_logic;
		phy_cas     : out std_logic;
		phy_we      : out std_logic;
		phy_b       : out std_logic_vector(bank_size-1 downto 0);
		phy_a       : out std_logic_vector(addr_size-1 downto 0);
		phy_odt     : out std_logic;

		phy_dmi     : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_dmo     : out std_logic_vector(gear*word_size/byte_size-1 downto 0);

		phy_dqso    : out std_logic_vector(gear-1 downto 0);
		phy_dqst    : out std_logic_vector(gear-1 downto 0);

		phy_dqt     : buffer std_logic_vector(gear-1 downto 0);
		phy_dqv     : out std_logic_vector(gear-1 downto 0);
		phy_dqo     : out std_logic_vector(gear*word_size-1 downto 0);

		phy_sti     : in  std_logic_vector(gear*word_size/byte_size-1 downto 0);
		phy_sto     : out std_logic_vector(gear-1 downto 0);
		phy_dqi     : in  std_logic_vector(gear*word_size-1 downto 0));


end;

architecture mix of sdram_ctlr is

	constant stdr         : sdram_standards  := sdrmark_standard(chip);
	constant bl_cod       : std_logic_vector := sdram_latcod(stdr, bl);
	constant al_cod       : std_logic_vector := sdram_latcod(stdr, al);
	constant cl_cod       : std_logic_vector := sdram_latcod(stdr, cl);
	constant cwl_cod      : std_logic_vector := sdram_latcod(stdr, sdram_selcwl(stdr));

	signal sdram_refi_rdy : std_logic;
	signal sdram_refi_req : std_logic;
	signal sdram_init_rst : std_logic;
	signal sdram_init_cke : std_logic;
	signal sdram_init_cs  : std_logic;
	signal sdram_init_req : std_logic;
	signal sdram_init_rdy : std_logic;
	signal sdram_init_ras : std_logic;
	signal sdram_init_cas : std_logic;
	signal sdram_init_we  : std_logic;
	signal sdram_init_odt : std_logic;
	signal sdram_init_a   : std_logic_vector(addr_size-1 downto 0);
	signal sdram_init_b   : std_logic_vector(bank_size-1 downto 0);

	signal sdram_pgm_frm  : std_logic;
	signal sdram_pgm_rw   : std_logic;
	signal sdram_pgm_cmd  : std_logic_vector(0 to 2);

	signal sdram_mpu_rst  : std_logic;
	signal sdram_mpu_trdy : std_logic;
	signal sdram_mpu_ras  : std_logic;
	signal sdram_mpu_cas  : std_logic;
	signal sdram_mpu_we   : std_logic;
	signal sdram_mpu_wri  : std_logic;
	signal sdram_mpu_rea  : std_logic;
	signal sdram_mpu_rwin : std_logic;
	signal sdram_mpu_wwin : std_logic;

	signal sdram_sch_odt  : std_logic_vector(1-1 downto 0);
	signal sdram_sch_wwn  : std_logic_vector(gear-1 downto 0);
	signal sdram_sch_dqsz : std_logic_vector(sdram_sch_wwn'range);
	signal sdram_sch_dqs  : std_logic_vector(sdram_sch_wwn'range);
	signal sdram_sch_dqz  : std_logic_vector(sdram_sch_wwn'range);
	signal sdram_sch_st   : std_logic_vector(sdram_sch_wwn'range);
	signal sdram_sch_dmo  : std_logic_vector(sdram_sch_wwn'range);

	signal rot_val        : std_logic_vector(unsigned_num_bits(gear*word_size-1)-1 downto 0);
	signal rot_di         : std_logic_vector(ctlr_di'range);

	signal sdram_cwl      : std_logic_vector(ctlr_cwl'range);

	signal sdram_mr_addr  : std_logic_vector(3-1 downto 0);
	signal sdram_mr_data  : std_logic_vector(13-1 downto 0);

begin

	sdram_pgm_frm  <= ctlr_frm when phy_inirdy='1' else phy_frm;
	sdram_pgm_rw   <= ctlr_rw  when phy_inirdy='1' else phy_rw;
	sdram_cwl      <= ctlr_cl  when stdr=ddr2      else ctlr_cwl;
	sdram_init_req <= ctlr_rst;

	sdram_init_e : entity hdl4fpga.sdram_init
	generic map (
		debug            => debug,
		tcp              => tcp,
		addr_size        => addr_size,
		bank_size        => bank_size,
		chip             => chip)
	port map (
		sdram_init_al    => ctlr_al,
		sdram_init_bl    => ctlr_bl,
		sdram_init_cl    => ctlr_cl,
		sdram_init_cwl   => sdram_cwl,
		sdram_init_bt    => "0",
		sdram_init_ods   => "0",
		sdram_init_wr    => ctlr_wrl,
		sdram_init_rtt   => ctlr_rtt,

		sdram_init_clk   => ctlr_clk,
		sdram_init_req   => sdram_init_req,
		sdram_init_rdy   => sdram_init_rdy,
		sdram_init_rst   => sdram_init_rst,
		sdram_init_cke   => sdram_init_cke,
		sdram_init_cs    => sdram_init_cs,
		sdram_init_ras   => sdram_init_ras,
		sdram_init_cas   => sdram_init_cas,
		sdram_init_we    => sdram_init_we,
		sdram_init_a     => sdram_init_a,
		sdram_init_b     => sdram_init_b,
		sdram_init_odt   => sdram_init_odt,
		sdram_init_wlreq => phy_wlreq,
		sdram_init_wlrdy => phy_wlrdy,
		sdram_refi_req   => sdram_refi_req,
		sdram_refi_rdy   => sdram_refi_rdy);

	ctlr_cfgrdy   <= sdram_init_rdy;
	sdram_mpu_rst <= not ctlr_cfgrdy;
	sdram_pgm_e : entity hdl4fpga.sdram_pgm
	port map (
		ctlr_clk        => ctlr_clk,
		ctlr_rst        => sdram_mpu_rst,
		ctlr_refreq     => ctlr_refreq,
		sdram_pgm_frm   => sdram_pgm_frm ,
		sdram_mpu_trdy  => sdram_mpu_trdy,
		sdram_pgm_cmd   => sdram_pgm_cmd,
		sdram_pgm_rw    => sdram_pgm_rw,
		sdram_ref_req   => sdram_refi_req,
		sdram_ref_rdy   => sdram_refi_rdy);

	sdram_mpu_e : entity hdl4fpga.sdram_mpu
	generic map (
		tcp             => tcp,
		latencies       => latencies,
		chip            => chip,

		gear            => gear,
		bl_cod          => bl_cod,
		al_cod          => al_cod,
		cl_cod          => cl_cod,
		cwl_cod         => cwl_cod)
	port map (
		sdram_mpu_bl    => ctlr_bl,
		sdram_mpu_al    => ctlr_al,
		sdram_mpu_cl    => ctlr_cl,
		sdram_mpu_cwl   => sdram_cwl,

		sdram_mpu_rst   => sdram_mpu_rst,
		sdram_mpu_clk   => ctlr_clk,
		sdram_mpu_cmd   => sdram_pgm_cmd,
		sdram_mpu_trdy  => sdram_mpu_trdy,
		sdram_mpu_fch   => ctlr_fch,
		sdram_mpu_act   => ctlr_act,
		sdram_mpu_cas   => sdram_mpu_cas,
		sdram_mpu_ras   => sdram_mpu_ras,
		sdram_mpu_alat  => ctlr_alat,
		sdram_mpu_blat  => ctlr_blat,
		sdram_mpu_we    => sdram_mpu_we,
		sdram_mpu_rea   => sdram_mpu_rea,
		sdram_mpu_wri   => sdram_mpu_wri,
		sdram_mpu_rwin  => sdram_mpu_rwin,
		sdram_mpu_wwin  => sdram_mpu_wwin);

	sdram_sch_e : entity hdl4fpga.sdram_sch
	generic map (
		latencies => latencies,
		chip      => chip,
		gear      => gear,
		cl_cod    => cl_cod,
		cwl_cod   => cwl_cod)
	port map (
		sys_cl    => ctlr_cl,
		sys_cwl   => sdram_cwl,
		sys_clk   => ctlr_clk,
		sys_rea   => sdram_mpu_rwin,
		sys_wri   => sdram_mpu_wwin,

		sdram_st  => sdram_sch_st,
		sdram_dmo => sdram_sch_dmo,

		sdram_dqsz => sdram_sch_dqsz,
		sdram_dqs  => sdram_sch_dqs,
		sdram_dqz  => sdram_sch_dqz,
		sdram_odt  => sdram_sch_odt,
		sdram_wwn  => sdram_sch_wwn);

	sdram_rotval_b : block
		function sdram_rotval (
			constant line_size : natural;
			constant word_size : natural;
			constant lat_val   : std_logic_vector;
			constant lat_cod   : std_logic_vector;
			constant lat_tab   : natural_vector)
			return std_logic_vector is
	
			subtype word is std_logic_vector(unsigned_num_bits(line_size/word_size-1)-1 downto 0);
			type word_vector is array(natural range <>) of word;
	
			subtype latword is std_logic_vector(0 to lat_val'length-1);
			type latword_vector is array (natural range <>) of latword;
	
			constant algn : natural := unsigned_num_bits(word_size-1);
	
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
	
			constant lc   : latword_vector := to_latwordvector(lat_cod);
	
			variable sel_sch : word_vector(lc'range);
			variable val     : unsigned(unsigned_num_bits(LINE_SIZE-1)-1 downto 0) := (others => '0');
			variable disp    : natural;
	
		begin
	
			setup_l : for i in 0 to lat_tab'length-1 loop
				sel_sch(i) := std_logic_vector(to_unsigned(lat_tab(i) mod (LINE_SIZE/WORD_SIZE), word'length));
			end loop;
	
			val(word'range) := unsigned(select_lat(lat_val, lc, sel_sch));
			val := val sll algn;
			return std_logic_vector(val);
		end;

		constant wwnl_tab : natural_vector := sdram_schtab(stdr, latencies, wwnl);
	begin
		rot_val <= sdram_rotval (
			line_size => gear*word_size,
			word_size => word_size,
			lat_val   => sdram_cwl,
			lat_cod   => cwl_cod,
			lat_tab   => wwnl_tab);
	end block;

	ctlr_trdy   <= sdram_mpu_trdy when phy_inirdy='1' else '0';
	ctlr_cmd    <= sdram_pgm_cmd;
	ctlr_di_req <= sdram_sch_wwn(sdram_sch_wwn'right);
	ctlr_inirdy <= ctlr_cfgrdy when phy_inirdy='1' else '0';

	ctlr_do     <= phy_dqi;
	ctlr_do_dv  <= phy_sti;

	phy_rlreq   <= ctlr_cfgrdy;
	phy_trdy    <= sdram_mpu_trdy   when phy_inirdy='0' else '0';
	phy_rst     <= sdram_init_rst;
	phy_cke     <= sdram_init_cke;
	phy_cs      <= '0'              when ctlr_cfgrdy='1' else sdram_init_cs;
	phy_ras     <= sdram_mpu_ras    when ctlr_cfgrdy='1' else sdram_init_ras;
	phy_cas     <= sdram_mpu_cas    when ctlr_cfgrdy='1' else sdram_init_cas;
	phy_we      <= sdram_mpu_we     when ctlr_cfgrdy='1' else sdram_init_we;
	phy_a       <= ctlr_a           when ctlr_cfgrdy='1' else sdram_init_a;
	phy_b       <= ctlr_b           when ctlr_cfgrdy='1' else sdram_init_b;
	phy_odt     <= sdram_sch_odt(0) when ctlr_cfgrdy='1' else sdram_init_odt; 

	rotate_i : entity hdl4fpga.barrel
	generic map (
		left => false)
	port map (
		shf => rot_val,
		di  => ctlr_di,
		do  => phy_dqo);

	phy_dmo  <= 
		(fill(not sdram_sch_wwn, phy_dmo'length, full => true) or ctlr_dm) and 
		 fill(not sdram_sch_dmo, phy_dmo'length, full => true) when stdr=sdr else
		ctlr_dm;
	phy_dqt  <= not sdram_sch_dqz;
	phy_dqso <= sdram_sch_dqs;
	phy_dqst <= not sdram_sch_dqsz;
	phy_sto  <= sdram_sch_st;
	phy_dqv  <= sdram_sch_wwn;

end;
