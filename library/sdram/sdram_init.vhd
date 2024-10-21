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
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.sdram_param.all;
use hdl4fpga.sdram_db.all;

entity sdram_init is
	generic (
		debug : boolean;
		tcp   : real;
		chiptmmg_data : string;
		fmly  : string;
		fmlytmmg_data : string);
	port (
		sdram_init_bl   : in  std_logic_vector;
		sdram_init_bt   : in  std_logic_vector;
		sdram_init_cl   : in  std_logic_vector;
		sdram_init_ods  : in  std_logic_vector;

		sdram_init_wb   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_al   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		sdram_init_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rtt  : in  std_logic_vector;
		sdram_init_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdram_init_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdram_init_ocd  : in  std_logic_vector(3-1 downto 0) := (others => '1');
		sdram_init_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		sdram_refi_rdy : in  std_logic;
		sdram_refi_req : out std_logic;
		sdram_init_clk : in  std_logic;
		sdram_init_wlrdy : in  std_logic;
		sdram_init_wlreq : out std_logic;
		sdram_init_req : in  std_logic;
		sdram_init_rdy : out std_logic;
		sdram_init_rst : out std_logic;
		sdram_init_cke : out std_logic;
		sdram_init_cs  : out std_logic;
		sdram_init_ras : out std_logic;
		sdram_init_cas : out std_logic;
		sdram_init_we  : out std_logic;
		sdram_init_a   : out std_logic_vector;
		sdram_init_b   : out std_logic_vector;
		sdram_init_odt : out std_logic);

	attribute fsm_encoding : string;
	attribute fsm_encoding of sdram_init : entity is "compact";

	constant PreRST    : natural := natural(ceil(hdo(fmlytmmg_data)**".tPreRST=0."/tcp));
	constant RP        : natural := natural(ceil(hdo(chipmmg_data)**".tRP=0."/tcp));
	constant PstRST    : natural := natural(ceil(hdo(fmlytmmg_data)**".tPstRST=0."/tcp));
	constant cDLL      : natural := hdo(fmlytmmg_data)**".cDLL=0.";
	constant RPA       : natural := natural(ceil(hdo(fmlytmmg_data)**".tRPA=0."/tcp));
	constant ZQINIT    : natural := hdo(fmlytmmg_data)**".ZQINIT=0.";
	constant MRD       : natural := hdo(fmlytmmg_data)**".MRD=0.";
	constant MODu      : natural := hdo(fmlytmmg_data)**".MODu=0.";
	constant XPR       : natural := hdo(fmlytmmg_data)**".XPR=0.";
	constant WLDQSEN   : natural := hdo(fmlytmmg_data)**".WLDQSEN=0.";
	constant REFi      : natural := natural(ceil(hdo(chiptmmg_data)**".tREFI"/tcp));

end;

architecture def of sdram_init is

	subtype ddrmr_addr is std_logic_vector(3-1 downto 0);

	constant sdrammr_setmr  : ddrmr_addr := "100";

	constant ddr1mr_setemr  : ddrmr_addr := "000";
	constant ddr1mr_rstdll  : ddrmr_addr := "010";
	constant ddr1mr_preall  : ddrmr_addr := "011";
	constant ddr1mr_setmr   : ddrmr_addr := "100";

	constant ddr2mr_setemr2 : ddrmr_addr := "001";
	constant ddr2mr_setemr3 : ddrmr_addr := "110";
	constant ddr2mr_enadll  : ddrmr_addr := "111";
	constant ddr2mr_rstdll  : ddrmr_addr := "101";
	constant ddr2mr_preall  : ddrmr_addr := "100";
	constant ddr2mr_setmr   : ddrmr_addr := "000";
	constant ddr2mr_seteOCD : ddrmr_addr := "010";
	constant ddr2mr_setdOCD : ddrmr_addr := "011";

	constant ddr3mr_setmr0  : ddrmr_addr := "000";
	constant ddr3mr_setmr1  : ddrmr_addr := "001";
	constant ddr3mr_setmr2  : ddrmr_addr := "010";
	constant ddr3mr_setmr3  : ddrmr_addr := "011";
	constant ddr3mr_zqc     : ddrmr_addr := "100";
	constant ddr3mr_enawl   : ddrmr_addr := "101";

	signal init_rdy  : std_logic;

	signal timer_rdy : std_logic;
	signal timer_req : std_logic;

	signal input     : std_logic_vector(0 to 0);
	signal sdram_mr_addr  : ddrmr_addr;
	signal sdram_timer_id : tids;

begin

	---------------------
	-- MEMORY REGISTER --
	---------------------

	mr_p : process (sdram_init_clk, timer_rdy)

		-- Mode Register Field Descriptor --
		------------------------------------
	
		type fd is record	-- Field Descritpor
			sz  : natural;	-- Size
			off : natural;	-- Offset
		end record;
	
		type fd_vector is array (natural range <>) of fd;
	
		constant sdram_a_max : natural := 16;
	
		type mr_row is record
			mr   : ddrmr_addr;
			data : std_logic_vector(sdram_a_max-1 downto 0);
		end record;
	
		type mr_vector is array (natural range <>) of mr_row;
	
		-- SDRAM Mode Register --
		-------------------------
	
		constant sdram_wb   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 1));
	
		-- DDR1 Mode Register --
		------------------------
	
		constant ddr1_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
		constant ddr1_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
		constant ddr1_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
		constant ddr1_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
	
		-- DDR1 Extended Mode Register --
		---------------------------------
	
		constant ddr1_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
		constant ddr1_ods  : fd_vector(0 to 0) := (0 => (off => 1, sz => 1));
	
		-- A10 --
		---------
	
		constant ddr1_preall : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));
	
		-- DDR2 Mode Register --
		------------------------
	
		constant ddr2_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
		constant ddr2_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
		constant ddr2_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
		constant ddr2_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
		constant ddr2_wr   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 3));
		constant ddr2_pd   : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));
	
		-- DDR2 Extended Mode Register --
		---------------------------------
	
		constant ddr2_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
		constant ddr2_ods  : fd_vector(0 to 0) := (0 => (off => 1, sz => 1));
		constant ddr2_rtt  : fd_vector(0 to 1) := (
			0 => (off => 2, sz => 1),
			1 => (off => 6, sz => 1));
		constant ddr2_al   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 3));
		constant ddr2_ocd  : fd_vector(0 to 0) := (0 => (off =>  7, sz => 3));
		constant ddr2_ddqs : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));
		constant ddr2_rdqs : fd_vector(0 to 0) := (0 => (off => 11, sz => 1));
		constant ddr2_out  : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));
	
		-- DDR2 Extended Mode Register 2 --
		-----------------------------------
	
		constant ddr2_srt  : fd_vector(0 to 0) := (0 => (off => 7, sz => 1));
	
		-- A10 --
		---------
	
		constant ddr2_preall : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));
	
		--------------------------
		-- DDR3 Mode Register 0 --
		--------------------------
	
		constant ddr3_bl   : fd_vector(0 to 0) := (0 => (off =>  0, sz => 3));
		constant ddr3_bt   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 1));
		constant ddr3_cl   : fd_vector(0 to 0) := (0 => (off =>  4, sz => 3));
		constant ddr3_rdll : fd_vector(0 to 0) := (0 => (off =>  8, sz => 1));
		constant ddr3_wr   : fd_vector(0 to 0) := (0 => (off =>  9, sz => 3));
		constant ddr3_pd   : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));
	
		-- DDR3 Mode Register 1 --
		--------------------------
	
		constant ddr3_edll : fd_vector(0 to 0) := (0 => (off => 0, sz => 1));
		constant ddr3_ods  : fd_vector(0 to 1) := (
			0 => (off => 1, sz => 1),
			1 => (off => 5, sz => 1));
		constant ddr3_rtt  : fd_vector(0 to 2) := (
			0 => (off => 2, sz => 1),
			1 => (off => 6, sz => 1),
			2 => (off => 9, sz => 1));
		constant ddr3_al   : fd_vector(0 to 0) := (0 => (off =>  3, sz => 2));
		constant ddr3_wl   : fd_vector(0 to 0) := (0 => (off =>  7, sz => 1));
		constant ddr3_tdqs : fd_vector(0 to 0) := (0 => (off => 11, sz => 1));
		constant ddr3_qoff : fd_vector(0 to 0) := (0 => (off => 12, sz => 1));
	
		-- DDR3 Mode Register 2 --
		--------------------------
	
		constant ddr3_cwl  : fd_vector(0 to 0) := (0 => (off => 3, sz => 3));
		constant ddr3_asr  : fd_vector(0 to 0) := (0 => (off => 6, sz => 1));
		constant ddr3_srt  : fd_vector(0 to 0) := (0 => (off => 7, sz => 1));
		constant ddr3_drtt : fd_vector(0 to 0) := (0 => (off => 9, sz => 2));
	
		-- DDR3 Mode Register 3 --
		--------------------------
	
		constant ddr3_mprrf : fd_vector(0 to 0) := (0 => (off => 0, sz => 2));
		constant ddr3_mpr   : fd_vector(0 to 0) := (0 => (off => 2, sz => 1));
	
		constant ddr3_zqc   : fd_vector(0 to 0) := (0 => (off => 10, sz => 1));

		function mr_field (
			constant mask : fd_vector;
			constant src  : std_logic_vector;
			constant size : natural)
			return std_logic_vector is
			variable aux : unsigned(src'range) := unsigned(src);
			variable fld : unsigned(size-1 downto 0) := (others => '0');
			variable val : unsigned(fld'range) := (others => '0');
		begin
			for i in mask'reverse_range loop
				fld := (others => '0');
				for j in 1 to mask(i).sz loop
					fld := fld sll 1;
					fld(0) := aux(aux'left);
					aux := aux sll 1;
				end loop;
				fld := fld sll mask(i).off;
				val := val or  fld;
			end loop;
			return std_logic_vector(val);
		end;

		function mr_field (
			constant mask : fd_vector;
			constant src  : std_logic_vector)
			return std_logic_vector is
		begin
			return mr_field(mask, src, sdram_a_max);
		end;

		function sdram_mrfile (
			constant sdram_mr_addr : ddrmr_addr;
			constant sdram_mr_bl   : std_logic_vector;
			constant sdram_mr_bt   : std_logic_vector;
			constant sdram_mr_cl   : std_logic_vector;
			constant sdram_mr_wb   : std_logic_vector)
			return std_logic_vector is
		begin
	
			case sdram_mr_addr is
			when ddr1mr_preall =>
				return mr_field(mask => ddr1_preall, src => "1", size => sdram_a_max);
			when sdrammr_setmr =>
				return
					mr_field(mask => ddr1_bl,  src => sdram_mr_bl, size => sdram_a_max) or
					mr_field(mask => ddr1_bt,  src => sdram_mr_bt, size => sdram_a_max) or
					mr_field(mask => ddr1_cl,  src => sdram_mr_cl, size => sdram_a_max) or
					mr_field(mask => sdram_wb, src => sdram_mr_wb, size => sdram_a_max);
			when others =>
				return (0 to sdram_a_max-1 => '1');
			end case;
		end;
	
		function ddr_mrfile (
			constant sdram_mr_addr : ddrmr_addr;
			constant sdram_mr_bl   : std_logic_vector;
			constant sdram_mr_bt   : std_logic_vector;
			constant sdram_mr_cl   : std_logic_vector;
			constant sdram_mr_ods  : std_logic_vector)
			return std_logic_vector is
		begin
	
	
			case sdram_mr_addr is
			when ddr1mr_setemr =>
				return
					mr_field(mask => ddr1_edll, src => "0", size => sdram_a_max) or
					mr_field(mask => ddr1_ods,  src => "0", size => sdram_a_max);
			when ddr1mr_preall =>
				return mr_field(mask => ddr1_preall, src => "1", size => sdram_a_max);
			when ddr1mr_rstdll =>
				return
					mr_field(mask => ddr1_bl,   src => sdram_mr_bl, size => sdram_a_max) or
					mr_field(mask => ddr1_bt,   src => sdram_mr_bt, size => sdram_a_max) or
					mr_field(mask => ddr1_cl,   src => sdram_mr_cl, size => sdram_a_max) or
					mr_field(mask => ddr1_rdll, src => "1",         size => sdram_a_max);
			when ddr1mr_setmr =>
				return mr_field(mask => ddr1_bl, src => sdram_mr_bl, size => sdram_a_max) or
					mr_field(mask => ddr1_bt,   src => sdram_mr_bt, size => sdram_a_max) or
					mr_field(mask => ddr1_cl,   src => sdram_mr_cl, size => sdram_a_max) or
					mr_field(mask => ddr1_rdll, src => "0", size => sdram_a_max);
			when others =>
				return (0 to sdram_a_max-1 => '1');
			end case;
		end;
	
		function ddr2_mrfile (
			constant sdram_mr_addr : ddrmr_addr;
			constant sdram_mr_srt  : std_logic_vector;
			constant sdram_mr_bl   : std_logic_vector;
			constant sdram_mr_bt   : std_logic_vector;
			constant sdram_mr_cl   : std_logic_vector;
			constant sdram_mr_wr   : std_logic_vector;
			constant sdram_mr_ods  : std_logic_vector;
			constant sdram_mr_rtt  : std_logic_vector;
			constant sdram_mr_al   : std_logic_vector;
			constant sdram_mr_ocd  : std_logic_vector;
			constant sdram_mr_tdqs : std_logic_vector;
			constant sdram_mr_rdqs : std_logic_vector)
			return std_logic_vector is
		begin
			case sdram_mr_addr is
			when ddr2mr_setemr2 =>
				return mr_field(mask => ddr2_srt, src => sdram_mr_srt);
			when ddr2mr_setemr3 =>
				return (0 to sdram_a_max-1 => '0');
			when ddr2mr_rstdll =>
				return mr_field(mask => ddr2_rdll, src => "1");
			when ddr2mr_enadll =>
				return mr_field(mask => ddr2_edll, src => "0");
			when ddr2mr_setmr =>
				return
					mr_field(mask => ddr2_bl,   src => sdram_mr_bl) or
					mr_field(mask => ddr2_bt,   src => sdram_mr_bt) or
					mr_field(mask => ddr2_cl,   src => sdram_mr_cl) or
					mr_field(mask => ddr2_wr,   src => sdram_mr_wr) or
					mr_field(mask => ddr2_rdll, src => "0");
			when ddr2mr_seteOCD =>
				return
					mr_field(mask => ddr2_edll, src => "0") or
					mr_field(mask => ddr2_ods,  src => sdram_mr_ods)  or
					mr_field(mask => ddr2_rtt,  src => sdram_mr_rtt)  or
					mr_field(mask => ddr2_al,   src => sdram_mr_al)   or
					mr_field(mask => ddr2_ocd,  src => sdram_mr_ocd)  or
					mr_field(mask => ddr2_ddqs, src => sdram_mr_tdqs) or
					mr_field(mask => ddr2_rdqs, src => sdram_mr_rdqs) or
					mr_field(mask => ddr2_out,  src => "0");
			when ddr2mr_setdOCD =>
				return
					mr_field(mask => ddr2_edll, src => "0") or
					mr_field(mask => ddr2_ods,  src => sdram_mr_ods)  or
					mr_field(mask => ddr2_rtt,  src => sdram_mr_rtt)  or
					mr_field(mask => ddr2_al,   src => sdram_mr_al)   or
					mr_field(mask => ddr2_ocd,  src => "000")  or
					mr_field(mask => ddr2_ddqs, src => sdram_mr_tdqs) or
					mr_field(mask => ddr2_rdqs, src => sdram_mr_rdqs) or
					mr_field(mask => ddr2_out,  src => "0");
			when ddr2mr_preall =>
				return
					mr_field(mask => ddr2_preall, src => "1");
			when others =>
				return (0 to sdram_a_max-1 => '1');
			end case;
		end;
	
		function ddr3_mrfile (
			constant sdram_mr_addr : ddrmr_addr;
			constant sdram_mr_srt  : std_logic_vector;
			constant sdram_mr_bl   : std_logic_vector;
			constant sdram_mr_bt   : std_logic_vector;
			constant sdram_mr_cl   : std_logic_vector;
			constant sdram_mr_wr   : std_logic_vector;
			constant sdram_mr_ods  : std_logic_vector;
			constant sdram_mr_rtt  : std_logic_vector;
			constant sdram_mr_al   : std_logic_vector;
			constant sdram_mr_tdqs : std_logic_vector;
			constant sdram_mr_qoff : std_logic_vector;
			constant sdram_mr_drtt : std_logic_vector;
			constant sdram_mr_mprrf : std_logic_vector;
			constant sdram_mr_mpr  : std_logic_vector;
			constant sdram_mr_asr  : std_logic_vector;
			constant sdram_mr_pd   : std_logic_vector;
			constant sdram_mr_cwl  : std_logic_vector)
			return std_logic_vector is
		begin
			case sdram_mr_addr is
			when ddr3mr_setmr0 =>
				return
					mr_field(mask => ddr3_bl, src => sdram_mr_bl) or
					mr_field(mask => ddr3_bt, src => sdram_mr_bt) or
					mr_field(mask => ddr3_cl, src => sdram_mr_cl) or
					mr_field(mask => ddr3_pd, src => sdram_mr_pd) or
					mr_field(mask => ddr3_rdll, src => "1") or
					mr_field(mask => ddr3_wr, src => sdram_mr_wr);
			when ddr3mr_enawl =>
				return
					mr_field(mask => ddr3_al,   src => sdram_mr_al) or
					mr_field(mask => ddr3_edll, src => "0") or
					mr_field(mask => ddr3_ods,  src => sdram_mr_ods) or
					mr_field(mask => ddr3_qoff, src => "0") or
					mr_field(mask => ddr3_rtt,  src => sdram_mr_rtt) or
					mr_field(mask => ddr3_tdqs, src => sdram_mr_tdqs) or
					mr_field(mask => ddr3_wl,   src => "1");
	
			when ddr3mr_setmr1 =>
				return
					mr_field(mask => ddr3_al,   src => sdram_mr_al) or
					mr_field(mask => ddr3_edll, src => "0") or
					mr_field(mask => ddr3_ods,  src => sdram_mr_ods) or
					mr_field(mask => ddr3_qoff, src => "0") or
					mr_field(mask => ddr3_rtt,  src => sdram_mr_rtt) or
					mr_field(mask => ddr3_tdqs, src => sdram_mr_tdqs) or
					mr_field(mask => ddr3_wl,   src => "0");
	
			when ddr3mr_setmr2 =>
				return
					mr_field(mask => ddr3_asr,  src => sdram_mr_asr) or
					mr_field(mask => ddr3_cwl,  src => sdram_mr_cwl) or
					mr_field(mask => ddr3_drtt, src => sdram_mr_drtt) or
					mr_field(mask => ddr3_srt,  src => sdram_mr_srt);
	
			when ddr3mr_setmr3 =>
				return
					mr_field(mask => ddr3_mprrf, src => sdram_mr_mprrf) or
					mr_field(mask => ddr3_mpr,   src => sdram_mr_mpr);
	
			when ddr3mr_zqc =>
				return
					mr_field(mask => ddr3_zqc,   src => "1");
			when others =>
				return (0 to sdram_a_max-1 => '1');
			end case;
		end;

		function sdram_mrfile(
			constant sdram_fmly    : string;
	
			constant sdram_mr_addr : ddrmr_addr;
			constant sdram_mr_srt  : std_logic_vector;
			constant sdram_mr_bl   : std_logic_vector;
			constant sdram_mr_bt   : std_logic_vector;
			constant sdram_mr_cl   : std_logic_vector;
			constant sdram_mr_wb   : std_logic_vector;
			constant sdram_mr_wr   : std_logic_vector;
			constant sdram_mr_ods  : std_logic_vector;
			constant sdram_mr_rtt  : std_logic_vector;
			constant sdram_mr_al   : std_logic_vector;
			constant sdram_mr_ocd  : std_logic_vector;
			constant sdram_mr_tdqs : std_logic_vector;
			constant sdram_mr_rdqs : std_logic_vector;
			constant sdram_mr_qoff : std_logic_vector;
			constant sdram_mr_drtt : std_logic_vector;
			constant sdram_mr_mprrf : std_logic_vector;
			constant sdram_mr_mpr  : std_logic_vector;
			constant sdram_mr_asr  : std_logic_vector;
			constant sdram_mr_pd   : std_logic_vector;
			constant sdram_mr_cwl  : std_logic_vector)
			return std_logic_vector is
		begin
			if sdram_fmly= "sdr" then
				return sdram_mrfile(
					sdram_mr_addr => sdram_mr_addr,
					sdram_mr_bl   => sdram_mr_bl,
					sdram_mr_bt   => sdram_mr_bt,
					sdram_mr_cl   => sdram_mr_cl,
					sdram_mr_wb   => sdram_mr_wb);
			elsif sdram_fmly="ddr" then
				return ddr_mrfile(
					sdram_mr_addr => sdram_mr_addr,
					sdram_mr_bl   => sdram_mr_bl,
					sdram_mr_bt   => sdram_mr_bt,
					sdram_mr_cl   => sdram_mr_cl,
					sdram_mr_ods  => sdram_mr_ods);
			elsif sdram_fmly="ddr2" then
				return ddr2_mrfile(
					sdram_mr_addr => sdram_mr_addr,
					sdram_mr_srt  => sdram_mr_srt,
					sdram_mr_bl   => sdram_mr_bl,
					sdram_mr_bt   => sdram_mr_bt,
					sdram_mr_cl   => sdram_mr_cl,
					sdram_mr_wr   => sdram_mr_wr,
					sdram_mr_ods  => sdram_mr_ods,
					sdram_mr_rtt  => sdram_mr_rtt,
					sdram_mr_al   => sdram_mr_al,
					sdram_mr_ocd  => sdram_mr_ocd,
					sdram_mr_tdqs => sdram_mr_tdqs,
					sdram_mr_rdqs => sdram_mr_rdqs);
			elsif sdram_fmly="ddr3" then
				return ddr3_mrfile(
					sdram_mr_addr  => sdram_mr_addr,
					sdram_mr_srt   => sdram_mr_srt,
					sdram_mr_bl    => sdram_mr_bl,
					sdram_mr_bt    => sdram_mr_bt,
					sdram_mr_cl    => sdram_mr_cl,
					sdram_mr_wr    => sdram_mr_wr,
					sdram_mr_ods   => sdram_mr_ods,
					sdram_mr_rtt   => sdram_mr_rtt,
					sdram_mr_al    => sdram_mr_al,
					sdram_mr_qoff  => sdram_mr_qoff,
					sdram_mr_tdqs  => sdram_mr_tdqs,
					sdram_mr_drtt  => sdram_mr_drtt,
					sdram_mr_mprrf => sdram_mr_mprrf,
					sdram_mr_mpr   => sdram_mr_mpr,
					sdram_mr_asr   => sdram_mr_asr,
					sdram_mr_pd    => sdram_mr_pd,
					sdram_mr_cwl   => sdram_mr_cwl);
			else
				assert false
				report "invalid family"
				severity failure;
				return (0 to 0 => 'X');
			end if;
		end;

		variable mr_addr       : ddrmr_addr;
		variable sdram_mr_data : std_logic_vector(13-1 downto 0);
	begin
		if rising_edge(sdram_init_clk) then
			sdram_mr_data := std_logic_vector(resize(unsigned(sdram_mrfile(
				sdram_fmly  => fmly,
				sdram_mr_addr => mr_addr,
				sdram_mr_srt  => sdram_init_srt,
				sdram_mr_bl   => sdram_init_bl,
				sdram_mr_bt   => sdram_init_bt,
				sdram_mr_wb   => sdram_init_wb,
				sdram_mr_cl   => sdram_init_cl,
				sdram_mr_wr   => sdram_init_wr,
				sdram_mr_ods  => sdram_init_ods,
				sdram_mr_rtt  => sdram_init_rtt,
				sdram_mr_al   => sdram_init_al,
				sdram_mr_ocd  => sdram_init_ocd,
				sdram_mr_tdqs => sdram_init_tdqs,
				sdram_mr_rdqs => sdram_init_rdqs,
				sdram_mr_qoff => sdram_init_qoff,
				sdram_mr_drtt => sdram_init_drtt,
				sdram_mr_mprrf=> sdram_init_mprrf,
				sdram_mr_mpr  => sdram_init_mpr,
				sdram_mr_asr  => sdram_init_asr,
				sdram_mr_pd   => sdram_init_pd,
				sdram_mr_cwl  => sdram_init_cwl)),sdram_mr_data'length));
			mr_addr := sdram_mr_addr;

			sdram_init_a   <= std_logic_vector(resize(unsigned(sdram_mr_data), sdram_init_a'length));
		end if;
	end process;

	input(0) <= sdram_init_wlrdy;

	-----------------
	-- DDR PROGRAM --
	-----------------

	init_b : block
		constant mr0 : std_logic_vector := "000";
		constant mr1 : std_logic_vector := "001";
		constant mr2 : std_logic_vector := "010";
		constant mr3 : std_logic_vector := "011";
		constant mrx : std_logic_vector := "---";

		constant nop : std_logic_vector := "111";
		constant mrs : std_logic_vector := "000";
		constant pre : std_logic_vector := "010";
		constant ref : std_logic_vector := "001";
		constant zqc : std_logic_vector := "110";

				-- +------< rst
				-- |+-----< cke
				-- ||+----< rdy
				-- |||+---< wlq
				-- ||||+--< odt
				-- |||||
				-- vvvvv
		constant sdram_pgm : s_table := 
			"0" & "11000" & nop & mrx & XPR_id  &
			"0" & "11000" & pre & mrx & RP_id   &
			"0" & "11000" & ref & mrx & RFC_id  &
			"0" & "11000" & ref & mrx & RFC_id  &
			"0" & "11001" & mrs & mr0 & MRD_id  &
			"0" & "11110" & nop & mrx & REFi_id &
			"0" & "11110" & nop & mrx & REFi_id;
	
		constant ddr_pgm : s_table := (
			"0" & "11000"  & nop & mrx & XPR_id  &
			"0" & "11000"  & pre & mrx & RP_id   &
			"0" & "11000"  & mrs & mr1 & MRD_id  &
			"0" & "11000"  & mrs & mr0 & MRD_id  &
			"0" & "11000"  & pre & mrx & RPA_id  &
			"0" & "11000"  & ref & mrx & RFC_id  &
			"0" & "11000"  & ref & mrx & RFC_id  &
			"0" & "11001"  & mrs & mr0 & MRD_id  &
			"0" & "11010"  & nop & mrx & DLL_id  &
			"0" & "11110"  & nop & mrx & REFi_id &
			"0" & "11110"  & nop & mrx & REFi_id;
	
		constant ddr2_pgm : std_logic_vector := 
			"0" & "11000" & nop & mrx & XPR_id  &
			"0" & "11000" & pre & mrx & RPA_id  &
			"0" & "11000" & mrs & mr2 & MRD_id  &
			"0" & "11000" & mrs & mr3 & MRD_id  &
			"0" & "11000" & mrs & mr1 & MRD_id  &
			"0" & "11000" & mrs & mr0 & MRD_id  &
			"0" & "11000" & pre & mrx & RPA_id  &
			"0" & "11000" & ref & mrx & RFC_id  &
			"0" & "11000" & ref & mrx & RFC_id  &
			"0" & "11000" & mrs & mr0 & MRD_id  &
			"0" & "11000" & mrs & mr1 & MRD_id  &
			"0" & "11000" & mrs & mr1 & MRD_id  &
			"0" & "11000" & nop & mrx & DLL_id  &
			"0" & "11111" & nop & mrx & REFi_id &
			"0" & "11100" & nop & mrx & REFi_id;
	
		constant ddr3_pgm : std_logic_vector := 
			"0" & "10000" & nop & mrx & PstRST_id  &
			"0" & "11000" & nop & mrx & XPR_id     &
			"0" & "11000" & mrs & mr2 & MRD_id     &
			"0" & "11000" & mrs & mr3 & MRD_id     &
			"0" & "11000" & mrs & mr1 & MRD_id     &
			"0" & "11000" & mrs & mr0 & MRD_id     &
			"0" & "11000" & zqc & mrx & ZQINIT_id  &
			"0" & "11000" & mrs & mr1 & MOD_id     &
			"0" & "11001" & nop & mrx & WLDQSEN_id &
			"0" & "11011" & nop & mrx & MODu_id    &
			"1" & "11011" & nop & mrx & MODu_id    &
			"1" & "11010" & nop & mrx & MRD_id     &
			"0" & "11010" & mrs & mr1 & MOD_id     &
			"0" & "11110" & nop & mrx & DLL_id     &
			"0" & "11110" & nop & mrx & REFi_id    &
			"0" & "11110" & nop & mrx & REFi_id;

		constant rst : natural := 0;
		constant cke : natural := 1;
		constant rdy : natural := 2;
		constant wlq : natural := 3;
		constant odt : natural := 4;

		signal cntr : unsigned();
	begin

		mem_e : entity hdl4fpga.rom 
		port map (
			addr => std_logic_vector(cntr),
			data => data);

		sdram_init_rst  <= output(rst);
		init_rdy        <= output(rdy);
		sdram_init_cke  <= output(cke);
		sdram_init_wlreq<= output(wlq);
		sdram_init_odt  <= output(odt);

		process(sdram_init_clk)
		begin
			if rising_edge(sdram_init_clk) then

			if sdram_init_pc=sc_ref then
				if timer_rdy='1' then
					sdram_refi_req <= not sdram_refi_rdy;
				end if;
			else
				sdram_refi_req <= '0';
			end if;

			if sdram_init_req='1' then
				cntr <= (others => '0');
				sdram_init_rst   <= '0';
				sdram_init_cke   <= '0';
				sdram_init_cs    <= '0';
				sdram_init_wlreq <= '0';
			elsif sdram_init_req='0' then
				if timer_rdy='1' then
					cntr <= cntr + 1;
				else
				end if;
				sdram_init_b  <= std_logic_vector(unsigned(resize(unsigned(row.bnk), sdram_init_b'length)));
				sdram_mr_addr <= row.mr;
			else
			end if;

			sdram_init_rdy <= init_rdy;
		end if;
	end process;

	timer_req <=
		'1' when sdram_init_req='1' else
		'1' when timer_rdy='1' else
		'0';

	-----------------
	--- SDR_TIMERs --
	-----------------

	sdram_timer_b : block

		type timer is record
			tid   : tids;
			value : natural;
		end record;
	
		type timer_vector is array(natural range <>) of timer;

		function get_timertab (
			constant tcp   : real;
			constant chip  : sdram_chips;
			constant debug : boolean)
			return timer_vector is
					(tsdr_rst, to_sdrlatency(tCP, chip, tPreRST)/setif(debug, 20, 1)),
					(tddr_cke, to_sdrlatency(tCP, chip, tXPR)),
					(tddr_mrd, to_sdrlatency(tCP, chip, tMRD)),
					(tddr_rpa, to_sdrlatency(tCP, chip, tRP)),
					(tddr_rfc, to_sdrlatency(tCP, chip, tRFC)),
		begin
			case sdrmark_standard(chip) is
			when sdr|ddr =>
				return (
					(tsdr_rst, to_sdrlatency(tCP, chip, tPreRST)/setif(debug, 20, 1)),
					(tddr_cke, to_sdrlatency(tCP, chip, tXPR)),
					(tddr_mrd, to_sdrlatency(tCP, chip, tMRD)),
					(tddr_rpa, to_sdrlatency(tCP, chip, tRP)),
					(tddr_rfc, to_sdrlatency(tCP, chip, tRFC)),
					(tddr_dll, 200),
					(tddr_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 13678))); -- 166 Mhz
					-- (tddr_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 10850))); -- 133 Mhz
					-- (tddr_ref, to_sdrlatency(tCP, chip, tREFI)));
			when ddr2 =>
				return (
					(tsdr_rst,  to_sdrlatency(tcp, chip, tPreRST)/setif(debug, 100, 1)),
					(tddr2_cke, to_sdrlatency(tcp, chip, tXPR)/setif(debug, 100, 1)),
					(tddr2_mrd, sdram_latency(fmly, mrd)),
					(tddr2_rpa, to_sdrlatency(tcp, chip, tRPA)),
					(tddr2_rfc, to_sdrlatency(tcp, chip, tRFC)),
					(tddr2_dll, 200),
					-- (tddr2_ref, to_sdrlatency(tcp, chip, tREFI)));
					(tddr2_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 7418)));
			when ddr3 =>
				return (
					(tsdr_rst,  to_sdrlatency(tCP, chip, tPreRST)/setif(debug, 100, 1)),
					(tddr3_rstrdy, to_sdrlatency(tCP, chip, tPstRST)/setif(debug, 100, 1)),
					-- (tsdr_rst,  to_sdrlatency(tCP, chip, tPreRST)),
					-- (tddr3_rstrdy, to_sdrlatency(tCP, chip, tPstRST)),
					(tddr3_wlc, sdram_latency(fmly, MODu)),
					(tddr3_wldqsen, 25),
					(tddr3_cke, to_sdrlatency(tCP, chip, tXPR)),
					(tddr3_mrd, to_sdrlatency(tCP, chip, tMRD)),
					(tddr3_mod, sdram_latency(fmly, MODu)),
					(tddr3_dll, sdram_latency(fmly, cDLL)),
					(tddr3_zqinit, sdram_latency(DDR3, ZQINIT)),
					-- (tddr3_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 13796)));
					(tddr3_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 13885)));
			end case;
		end;
	
		function get_timerset (
			constant tab : timer_vector)
			return natural_vector is
			variable retval : natural_vector(tab'range);
		begin
			for i in tab'range loop
				retval(i) := tab(i).value;
--				assert false
--				report "tid "           &
--					tids'image(tids'val(i)) & " is value  " &
--					natural'image(retval(i))
--				severity note;

			end loop;
			return retval;
		end;
			
		constant timer_tab : timer_vector := get_timertab(tcp, chip, debug);
		signal   timer_mem : timer_vector(timer_tab'range) := get_timertab(tcp, chip, debug);
		signal   timer_sel : std_logic_vector(0 to  unsigned_num_bits(timer_tab'length-1));
	begin

		timer_sel_p : process (sdram_timer_id)
		begin
			timer_sel <= (others => '-');
			for i in timer_tab'range loop
				if timer_tab(i).tid = sdram_timer_id then
					timer_sel <= std_logic_vector(to_unsigned(i, timer_sel'length));
					exit;
				else
					assert i/=timer_tab'right
					report ">>>timer_sel_p<<< wrong id : " & tids'image(sdram_timer_id)
					severity failure; 
				end if;
			end loop;
		end process;

		timer_b : block
			-- Even block's generic and port were defined in VHDL 88, they are stil not
			-- implemented on Xilinx ISE and Vivado, likely others tools too

			-- generic (
				-- timers : natural_vector);
			-- generic map (
				-- timers => get_timerset(get_timertab(tcp, chip, debug)));
			constant timers : natural_vector := get_timerset(get_timertab(tcp, chip, debug));

			-- port (
				-- sys_clk : in  std_logic;
				-- tmr_sel : in  std_logic_vector;
				-- sys_req : in  std_logic;
				-- sys_rdy : out std_logic);
			-- port map(
				-- sys_clk => sdram_init_clk,
				-- tmr_sel => timer_sel,
				-- sys_req => timer_req,
				-- sys_rdy => timer_rdy);

			alias sys_clk : std_logic is sdram_init_clk;
			alias tmr_sel : std_logic_vector(timer_sel'range) is timer_sel;
			alias sys_req : std_logic is timer_req;
			alias sys_rdy : std_logic is timer_rdy;

			constant stages     : natural := unsigned_num_bits(max(timers))/4;
			constant timer_size : natural := unsigned_num_bits(max(timers))+stages;
	
			function slices
				return natural_vector is
				variable val : natural_vector(stages downto 0);
				variable quo : natural := timer_size mod stages;
			begin
				val(0) := 0;
				for i in 1 to stages loop
					val(i) := timer_size/stages + val(i-1);
					if i*quo >= stages then
						val(i) := val(i) + 1;
						quo := quo - 1;
					end if;

				end loop;
				return val;
			end;

			signal value : std_logic_vector(timer_size-1 downto 0);

		begin

			assert false
			report 
				"timer_size is value " & natural'image(timer_size)
			severity note;

			assert false
			report 
				"stages      is value " & natural'image(stages)
			severity note;


			process (sys_clk)
				variable timer : natural; 
				variable size  : natural;
				variable data  : std_logic_vector(value'range);
			begin
				if rising_edge(sys_clk) then
					data  := (others => '-');
					timer := timers(to_integer(unsigned(tmr_sel)));
					for j in stages-1 downto 0 loop
						size := slices(j+1)-slices(j);
						data := std_logic_vector(unsigned(data) sll size);
						data(size-1 downto 0) := std_logic_vector(to_unsigned(((2**size-1)+((timer-stages)/2**(slices(j)-j)) mod 2**(size-1)) mod 2**size, size));
					end loop;
					value <= data;
				end if;
			end process;
	
			timer_e : entity hdl4fpga.timer
			generic map (
				slices => slices(stages downto 1))
			port map (
				data => value,
				clk => sys_clk,
				req => sys_req,
				rdy => sys_rdy);

		end block;

	end block;
end;
