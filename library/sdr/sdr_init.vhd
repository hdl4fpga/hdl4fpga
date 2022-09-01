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
use hdl4fpga.std.all;
use hdl4fpga.sdr_db.all;
use hdl4fpga.sdr_param.all;
use hdl4fpga.profiles.all;

entity sdr_init is
	generic (
		debug : boolean;
		tcp           : real := 0.0;
		fpga          : fpga_devices;
		chip          : sdram_chips;
		ADDR_SIZE : natural := 13;
		BANK_SIZE : natural := 3);
	port (
		sdr_init_bl   : in  std_logic_vector;
		sdr_init_bt   : in  std_logic_vector;
		sdr_init_cl   : in  std_logic_vector;
		sdr_init_ods  : in  std_logic_vector;

		sdr_init_wb   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_al   : in  std_logic_vector(2-1 downto 0) := (others => '0');
		sdr_init_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdr_init_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		sdr_init_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		sdr_init_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_rtt  : in  std_logic_vector;
		sdr_init_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		sdr_init_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		sdr_init_ocd  : in  std_logic_vector(3-1 downto 0) := (others => '1');
		sdr_init_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		sdr_refi_rdy : in  std_logic;
		sdr_refi_req : out std_logic;
		sdr_init_clk : in  std_logic;
		sdr_init_wlrdy : in  std_logic;
		sdr_init_wlreq : out std_logic;
		sdr_init_req : in  std_logic;
		sdr_init_rdy : out std_logic;
		sdr_init_rst : out std_logic;
		sdr_init_cke : out std_logic;
		sdr_init_cs  : out std_logic;
		sdr_init_ras : out std_logic;
		sdr_init_cas : out std_logic;
		sdr_init_we  : out std_logic;
		sdr_init_a   : out std_logic_vector(ADDR_SIZE-1 downto 0);
		sdr_init_b   : out std_logic_vector(BANK_SIZE-1 downto 0);
		sdr_init_odt : out std_logic);


	attribute fsm_encoding : string;
	attribute fsm_encoding of sdr_init : entity is "compact";
end;

architecture def of sdr_init is

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

	type tids is (
		tsdr_rst,

		tddr_cke,
		tddr_mrd,
		tddr_rpa,
		tddr_rfc,
		tddr_dll,
		tddr_ref,
	
		tddr2_cke,
		tddr2_mrd,
		tddr2_rpa,
		tddr2_rfc,
		tddr2_dll,
		tddr2_ref,
	
		tddr3_wlc,
		tddr3_wldqsen,
		tddr3_rstrdy,
		tddr3_cke,
		tddr3_mrd,
		tddr3_mod,
		tddr3_dll,
		tddr3_zqinit,
		tddr3_ref);

	constant stdr : sdr_standards := sdrmark_standard(chip);

	signal init_rdy : std_logic;

	signal timer_rdy    : std_logic;
	signal timer_req    : std_logic;

	signal input        : std_logic_vector(0 to 0);
	signal sdr_mr_addr  : ddrmr_addr;
	signal sdr_timer_id : tids;

begin

	---------------------
	-- MEMORY REGISTER --
	---------------------

	mr_p : process (sdr_init_clk)

		-- Mode Register Field Descriptor --
		------------------------------------
	
		type fd is record	-- Field Descritpor
			sz  : natural;	-- Size
			off : natural;	-- Offset
		end record;
	
		type fd_vector is array (natural range <>) of fd;
	
		constant sdr_a_max : natural := 16;
	
		type mr_row is record
			mr   : ddrmr_addr;
			data : std_logic_vector(sdr_a_max-1 downto 0);
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
			return mr_field(mask, src, sdr_a_max);
		end;

		function sdram_mrfile (
			constant sdr_mr_addr : ddrmr_addr;
			constant sdr_mr_bl   : std_logic_vector;
			constant sdr_mr_bt   : std_logic_vector;
			constant sdr_mr_cl   : std_logic_vector;
			constant sdr_mr_wb   : std_logic_vector)
			return std_logic_vector is
		begin
	
			case sdr_mr_addr is
			when ddr1mr_preall =>
				return mr_field(mask => ddr1_preall, src => "1", size => sdr_a_max);
			when sdrammr_setmr =>
				return
					mr_field(mask => ddr1_bl,  src => sdr_mr_bl, size => sdr_a_max) or
					mr_field(mask => ddr1_bt,  src => sdr_mr_bt, size => sdr_a_max) or
					mr_field(mask => ddr1_cl,  src => sdr_mr_cl, size => sdr_a_max) or
					mr_field(mask => sdram_wb, src => sdr_mr_wb, size => sdr_a_max);
			when others =>
				return (0 to sdr_a_max-1 => '1');
			end case;
		end;
	
		function ddr1_mrfile (
			constant sdr_mr_addr : ddrmr_addr;
			constant sdr_mr_bl   : std_logic_vector;
			constant sdr_mr_bt   : std_logic_vector;
			constant sdr_mr_cl   : std_logic_vector;
			constant sdr_mr_ods  : std_logic_vector)
			return std_logic_vector is
		begin
	
	
			case sdr_mr_addr is
			when ddr1mr_setemr =>
				return
					mr_field(mask => ddr1_edll, src => "0", size => sdr_a_max) or
					mr_field(mask => ddr1_ods,  src => "0", size => sdr_a_max);
			when ddr1mr_preall =>
				return mr_field(mask => ddr1_preall, src => "1", size => sdr_a_max);
			when ddr1mr_rstdll =>
				return
					mr_field(mask => ddr1_bl,   src => sdr_mr_bl, size => sdr_a_max) or
					mr_field(mask => ddr1_bt,   src => sdr_mr_bt, size => sdr_a_max) or
					mr_field(mask => ddr1_cl,   src => sdr_mr_cl, size => sdr_a_max) or
					mr_field(mask => ddr1_rdll, src => "1",       size => sdr_a_max);
			when ddr1mr_setmr =>
				return mr_field(mask => ddr1_bl,   src => sdr_mr_bl, size => sdr_a_max) or
					mr_field(mask => ddr1_bt,   src => sdr_mr_bt, size => sdr_a_max) or
					mr_field(mask => ddr1_cl,   src => sdr_mr_cl, size => sdr_a_max) or
					mr_field(mask => ddr1_rdll, src => "0", size => sdr_a_max);
			when others =>
				return (0 to sdr_a_max-1 => '1');
			end case;
		end;
	
		function ddr2_mrfile (
			constant sdr_mr_addr : ddrmr_addr;
			constant sdr_mr_srt  : std_logic_vector;
			constant sdr_mr_bl   : std_logic_vector;
			constant sdr_mr_bt   : std_logic_vector;
			constant sdr_mr_cl   : std_logic_vector;
			constant sdr_mr_wr   : std_logic_vector;
			constant sdr_mr_ods  : std_logic_vector;
			constant sdr_mr_rtt  : std_logic_vector;
			constant sdr_mr_al   : std_logic_vector;
			constant sdr_mr_ocd  : std_logic_vector;
			constant sdr_mr_tdqs : std_logic_vector;
			constant sdr_mr_rdqs : std_logic_vector)
			return std_logic_vector is
		begin
			case sdr_mr_addr is
			when ddr2mr_setemr2 =>
				return mr_field(mask => ddr2_srt, src => sdr_mr_srt);
			when ddr2mr_setemr3 =>
				return (0 to sdr_a_max-1 => '0');
			when ddr2mr_rstdll =>
				return mr_field(mask => ddr2_rdll, src => "1");
			when ddr2mr_enadll =>
				return mr_field(mask => ddr2_edll, src => "0");
			when ddr2mr_setmr =>
				return
					mr_field(mask => ddr2_bl,   src => sdr_mr_bl) or
					mr_field(mask => ddr2_bt,   src => sdr_mr_bt) or
					mr_field(mask => ddr2_cl,   src => sdr_mr_cl) or
					mr_field(mask => ddr2_wr,   src => sdr_mr_wr) or
					mr_field(mask => ddr2_rdll, src => "0");
			when ddr2mr_seteOCD =>
				return
					mr_field(mask => ddr2_edll, src => "0") or
					mr_field(mask => ddr2_ods,  src => sdr_mr_ods)  or
					mr_field(mask => ddr2_rtt,  src => sdr_mr_rtt)  or
					mr_field(mask => ddr2_al,   src => sdr_mr_al)   or
					mr_field(mask => ddr2_ocd,  src => sdr_mr_ocd)  or
					mr_field(mask => ddr2_ddqs, src => sdr_mr_tdqs) or
					mr_field(mask => ddr2_rdqs, src => sdr_mr_rdqs) or
					mr_field(mask => ddr2_out,  src => "0");
			when ddr2mr_setdOCD =>
				return
					mr_field(mask => ddr2_edll, src => "0") or
					mr_field(mask => ddr2_ods,  src => sdr_mr_ods)  or
					mr_field(mask => ddr2_rtt,  src => sdr_mr_rtt)  or
					mr_field(mask => ddr2_al,   src => sdr_mr_al)   or
					mr_field(mask => ddr2_ocd,  src => "000")  or
					mr_field(mask => ddr2_ddqs, src => sdr_mr_tdqs) or
					mr_field(mask => ddr2_rdqs, src => sdr_mr_rdqs) or
					mr_field(mask => ddr2_out,  src => "0");
			when ddr2mr_preall =>
				return
					mr_field(mask => ddr2_preall, src => "1");
			when others =>
				return (0 to sdr_a_max-1 => '1');
			end case;
		end;
	
		function ddr3_mrfile (
			constant sdr_mr_addr : ddrmr_addr;
			constant sdr_mr_srt  : std_logic_vector;
			constant sdr_mr_bl   : std_logic_vector;
			constant sdr_mr_bt   : std_logic_vector;
			constant sdr_mr_cl   : std_logic_vector;
			constant sdr_mr_wr   : std_logic_vector;
			constant sdr_mr_ods  : std_logic_vector;
			constant sdr_mr_rtt  : std_logic_vector;
			constant sdr_mr_al   : std_logic_vector;
			constant sdr_mr_tdqs : std_logic_vector;
			constant sdr_mr_qoff : std_logic_vector;
			constant sdr_mr_drtt : std_logic_vector;
			constant sdr_mr_mprrf : std_logic_vector;
			constant sdr_mr_mpr  : std_logic_vector;
			constant sdr_mr_asr  : std_logic_vector;
			constant sdr_mr_pd   : std_logic_vector;
			constant sdr_mr_cwl  : std_logic_vector)
			return std_logic_vector is
		begin
			case sdr_mr_addr is
			when ddr3mr_setmr0 =>
				return
					mr_field(mask => ddr3_bl, src => sdr_mr_bl) or
					mr_field(mask => ddr3_bt, src => sdr_mr_bt) or
					mr_field(mask => ddr3_cl, src => sdr_mr_cl) or
					mr_field(mask => ddr3_pd, src => sdr_mr_pd) or
					mr_field(mask => ddr3_rdll, src => "1") or
					mr_field(mask => ddr3_wr, src => sdr_mr_wr);
			when ddr3mr_enawl =>
				return
					mr_field(mask => ddr3_al,   src => sdr_mr_al) or
					mr_field(mask => ddr3_edll, src => "0") or
					mr_field(mask => ddr3_ods,  src => sdr_mr_ods) or
					mr_field(mask => ddr3_qoff, src => "0") or
					mr_field(mask => ddr3_rtt,  src => sdr_mr_rtt) or
					mr_field(mask => ddr3_tdqs, src => sdr_mr_tdqs) or
					mr_field(mask => ddr3_wl,   src => "1");
	
			when ddr3mr_setmr1 =>
				return
					mr_field(mask => ddr3_al,   src => sdr_mr_al) or
					mr_field(mask => ddr3_edll, src => "0") or
					mr_field(mask => ddr3_ods,  src => sdr_mr_ods) or
					mr_field(mask => ddr3_qoff, src => "0") or
					mr_field(mask => ddr3_rtt,  src => sdr_mr_rtt) or
					mr_field(mask => ddr3_tdqs, src => sdr_mr_tdqs) or
					mr_field(mask => ddr3_wl,   src => "0");
	
			when ddr3mr_setmr2 =>
				return
					mr_field(mask => ddr3_asr,  src => sdr_mr_asr) or
					mr_field(mask => ddr3_cwl,  src => sdr_mr_cwl) or
					mr_field(mask => ddr3_drtt, src => sdr_mr_drtt) or
					mr_field(mask => ddr3_srt,  src => sdr_mr_srt);
	
			when ddr3mr_setmr3 =>
				return
					mr_field(mask => ddr3_mprrf, src => sdr_mr_mprrf) or
					mr_field(mask => ddr3_mpr,   src => sdr_mr_mpr);
	
			when ddr3mr_zqc =>
				return
					mr_field(mask => ddr3_zqc,   src => "1");
			when others =>
				return (0 to sdr_a_max-1 => '1');
			end case;
		end;

		function sdr_mrfile(
			constant sdr_stdr    : sdr_standards;
	
			constant sdr_mr_addr : ddrmr_addr;
			constant sdr_mr_srt  : std_logic_vector;
			constant sdr_mr_bl   : std_logic_vector;
			constant sdr_mr_bt   : std_logic_vector;
			constant sdr_mr_cl   : std_logic_vector;
			constant sdr_mr_wb   : std_logic_vector;
			constant sdr_mr_wr   : std_logic_vector;
			constant sdr_mr_ods  : std_logic_vector;
			constant sdr_mr_rtt  : std_logic_vector;
			constant sdr_mr_al   : std_logic_vector;
			constant sdr_mr_ocd  : std_logic_vector;
			constant sdr_mr_tdqs : std_logic_vector;
			constant sdr_mr_rdqs : std_logic_vector;
			constant sdr_mr_qoff : std_logic_vector;
			constant sdr_mr_drtt : std_logic_vector;
			constant sdr_mr_mprrf : std_logic_vector;
			constant sdr_mr_mpr  : std_logic_vector;
			constant sdr_mr_asr  : std_logic_vector;
			constant sdr_mr_pd   : std_logic_vector;
			constant sdr_mr_cwl  : std_logic_vector)
			return std_logic_vector is
		begin
			case sdr_stdr is
			when sdr =>
				return sdram_mrfile(
					sdr_mr_addr => sdr_mr_addr,
					sdr_mr_bl   => sdr_mr_bl,
					sdr_mr_bt   => sdr_mr_bt,
					sdr_mr_cl   => sdr_mr_cl,
					sdr_mr_wb   => sdr_mr_wb);
	
			when DDR =>
				return ddr1_mrfile(
					sdr_mr_addr => sdr_mr_addr,
					sdr_mr_bl   => sdr_mr_bl,
					sdr_mr_bt   => sdr_mr_bt,
					sdr_mr_cl   => sdr_mr_cl,
					sdr_mr_ods  => sdr_mr_ods);
	
			when DDR2 =>
				return ddr2_mrfile(
					sdr_mr_addr => sdr_mr_addr,
					sdr_mr_srt  => sdr_mr_srt,
					sdr_mr_bl   => sdr_mr_bl,
					sdr_mr_bt   => sdr_mr_bt,
					sdr_mr_cl   => sdr_mr_cl,
					sdr_mr_wr   => sdr_mr_wr,
					sdr_mr_ods  => sdr_mr_ods,
					sdr_mr_rtt  => sdr_mr_rtt,
					sdr_mr_al   => sdr_mr_al,
					sdr_mr_ocd  => sdr_mr_ocd,
					sdr_mr_tdqs => sdr_mr_tdqs,
					sdr_mr_rdqs => sdr_mr_rdqs);
	
			when others =>
				return ddr3_mrfile(
					sdr_mr_addr  => sdr_mr_addr,
					sdr_mr_srt   => sdr_mr_srt,
					sdr_mr_bl    => sdr_mr_bl,
					sdr_mr_bt    => sdr_mr_bt,
					sdr_mr_cl    => sdr_mr_cl,
					sdr_mr_wr    => sdr_mr_wr,
					sdr_mr_ods   => sdr_mr_ods,
					sdr_mr_rtt   => sdr_mr_rtt,
					sdr_mr_al    => sdr_mr_al,
					sdr_mr_qoff  => sdr_mr_qoff,
					sdr_mr_tdqs  => sdr_mr_tdqs,
					sdr_mr_drtt  => sdr_mr_drtt,
					sdr_mr_mprrf => sdr_mr_mprrf,
					sdr_mr_mpr   => sdr_mr_mpr,
					sdr_mr_asr   => sdr_mr_asr,
					sdr_mr_pd    => sdr_mr_pd,
					sdr_mr_cwl   => sdr_mr_cwl);
			end case;
		end;

		variable mr_addr       : ddrmr_addr;
		variable sdr_mr_data : std_logic_vector(13-1 downto 0);
	begin
		if rising_edge(sdr_init_clk) then
			sdr_mr_data := std_logic_vector(resize(unsigned(sdr_mrfile(
				sdr_stdr    => stdr,
				sdr_mr_addr => mr_addr,
				sdr_mr_srt  => sdr_init_srt,
				sdr_mr_bl   => sdr_init_bl,
				sdr_mr_bt   => sdr_init_bt,
				sdr_mr_wb   => sdr_init_wb,
				sdr_mr_cl   => sdr_init_cl,
				sdr_mr_wr   => sdr_init_wr,
				sdr_mr_ods  => sdr_init_ods,
				sdr_mr_rtt  => sdr_init_rtt,
				sdr_mr_al   => sdr_init_al,
				sdr_mr_ocd  => sdr_init_ocd,
				sdr_mr_tdqs => sdr_init_tdqs,
				sdr_mr_rdqs => sdr_init_rdqs,
				sdr_mr_qoff => sdr_init_qoff,
				sdr_mr_drtt => sdr_init_drtt,
				sdr_mr_mprrf=> sdr_init_mprrf,
				sdr_mr_mpr  => sdr_init_mpr,
				sdr_mr_asr  => sdr_init_asr,
				sdr_mr_pd   => sdr_init_pd,
				sdr_mr_cwl  => sdr_init_cwl)),sdr_mr_data'length));
			mr_addr := sdr_mr_addr;

			sdr_init_a   <= std_logic_vector(resize(unsigned(sdr_mr_data), sdr_init_a'length));
		end if;
	end process;

	input(0) <= sdr_init_wlrdy;

	-----------------
	-- DDR PROGRAM --
	-----------------

	program_p : process (sdr_init_clk)

		subtype ddrmr_id is std_logic_vector(3-1 downto 0);
		constant sdr_mrx   : ddrmr_id := (others => '1');
		constant sdr_mr0   : ddrmr_id := "000";
		constant sdr_mr1   : ddrmr_id := "001";
		constant sdr_mr2   : ddrmr_id := "010";
		constant sdr_mr3   : ddrmr_id := "011";
		constant ddrmr_mrx : ddrmr_addr := (others => '1');

		subtype s_code is std_logic_vector(0 to 4-1);
		type s_row is record
			state   : s_code;
			state_n : s_code;
			mask    : std_logic_vector(0 to 1-1);
			input   : std_logic_vector(0 to 1-1);
			output  : std_logic_vector(0 to 5-1);
			cmd     : sdr_cmd;
			mr      : ddrmr_addr;
			bnk     : ddrmr_id;
			tid     : tids;
		end record;
	
		type s_table is array (natural range <>) of s_row;

		constant sc_rst  : s_code := "0000";
		constant sc_ref  : s_code := "1000";
	
		constant sc1_cke  : s_code := "0001";
		constant sc1_pre1 : s_code := "0011";
		constant sc1_lm1  : s_code := "0010";
		constant sc1_lm2  : s_code := "0110";
		constant sc1_pre2 : s_code := "0111";
		constant sc1_ref1 : s_code := "0101";
		constant sc1_ref2 : s_code := "0100";
		constant sc1_lm3  : s_code := "1100";
		constant sc1_wai  : s_code := "1101";
	
		constant sdram_pgm : s_table := (
			(sc_rst,   sc1_cke,  "0", "0", "11000", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_CKE),
			(sc1_cke,  sc1_pre1, "0", "0", "11000", sdr_pre, ddr1mr_preall, sdr_mrx, tddr_RPA),
			(sc1_pre1, sc1_ref1, "0", "0", "11000", sdr_ref, ddrmr_mrx,     sdr_mrx, tddr_RFC),
			(sc1_ref1, sc1_ref2, "0", "0", "11000", sdr_ref, ddrmr_mrx,     sdr_mrx, tddr_RFC),
			(sc1_ref2, sc1_lm1,  "0", "0", "11001", sdr_mrs, ddr1mr_setmr,  sdr_mr0, tddr_MRD),
			(sc1_lm1,  sc_ref,   "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_REF),
			(sc_ref,   sc_ref,   "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_REF));
	
		constant ddr1_pgm : s_table := (
			(sc_rst,   sc1_cke,  "0", "0", "11000", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_CKE),
			(sc1_cke,  sc1_pre1, "0", "0", "11000", sdr_pre, ddr1mr_preall, sdr_mrx, tddr_RPA),
			(sc1_pre1, sc1_lm1,  "0", "0", "11000", sdr_mrs, ddr1mr_setemr, sdr_mr1, tddr_MRD),
			(sc1_lm1,  sc1_lm2,  "0", "0", "11000", sdr_mrs, ddr1mr_rstdll, sdr_mr0, tddr_MRD),
			(sc1_lm2,  sc1_pre2, "0", "0", "11000", sdr_pre, ddr1mr_preall, sdr_mrx, tddr_RPA),
			(sc1_pre2, sc1_ref1, "0", "0", "11000", sdr_ref, ddrmr_mrx,     sdr_mrx, tddr_RFC),
			(sc1_ref1, sc1_ref2, "0", "0", "11000", sdr_ref, ddrmr_mrx,     sdr_mrx, tddr_RFC),
			(sc1_ref2, sc1_lm3,  "0", "0", "11001", sdr_mrs, ddr1mr_setmr,  sdr_mr0, tddr_MRD),
			(sc1_lm3,  sc1_wai,  "0", "0", "11010", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_DLL),
			(sc1_wai,  sc_ref,   "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_REF),
			(sc_ref,   sc_ref,   "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr_REF));
	
		constant sc2_cke  : s_code := "0001";
		constant sc2_pre1 : s_code := "0011";
		constant sc2_lm1  : s_code := "0010";
		constant sc2_lm2  : s_code := "0110";
		constant sc2_lm3  : s_code := "0111";
		constant sc2_lm4  : s_code := "0101";
		constant sc2_pre2 : s_code := "0100";
		constant sc2_ref1 : s_code := "1100";
		constant sc2_ref2 : s_code := "1101";
		constant sc2_lm5  : s_code := "1111";
		constant sc2_lm6  : s_code := "1110";
		constant sc2_lm7  : s_code := "1010";
		constant sc2_wai  : s_code := "1011";
	
	
									--    +------< rst
									--    |+-----< cke
									--    ||+----< rdy
									--    |||+---< wlq
									--    ||||+--< odt
									--    |||||
									--    vvvvv
		constant ddr2_pgm : s_table := (
			(sc_rst,   sc2_cke,  "0", "0", "11000", sdr_nop, ddrmr_mrx,      sdr_mrx, tddr2_CKE),
			(sc2_cke,  sc2_pre1, "0", "0", "11000", sdr_pre, ddr2mr_preall,  sdr_mrx, tddr2_RPA),
			(sc2_pre1, sc2_lm1,  "0", "0", "11000", sdr_mrs, ddr2mr_setemr2, sdr_mr2, tddr2_MRD),
			(sc2_lm1,  sc2_lm2,  "0", "0", "11000", sdr_mrs, ddr2mr_setemr3, sdr_mr3, tddr2_MRD),
			(sc2_lm2,  sc2_lm3,  "0", "0", "11000", sdr_mrs, ddr2mr_enadll,  sdr_mr1, tddr2_MRD),
			(sc2_lm3,  sc2_lm4,  "0", "0", "11000", sdr_mrs, ddr2mr_rstdll,  sdr_mr0, tddr2_MRD),
			(sc2_lm4,  sc2_pre2, "0", "0", "11000", sdr_pre, ddr2mr_preall,  sdr_mrx, tddr2_RPA),
			(sc2_pre2, sc2_ref1, "0", "0", "11000", sdr_ref, ddrmr_mrx,      sdr_mrx, tddr2_RFC),
			(sc2_ref1, sc2_ref2, "0", "0", "11000", sdr_ref, ddrmr_mrx,      sdr_mrx, tddr2_RFC),
			(sc2_ref2, sc2_lm5,  "0", "0", "11000", sdr_mrs, ddr2mr_setmr,   sdr_mr0, tddr2_MRD),
			(sc2_lm5,  sc2_lm6,  "0", "0", "11000", sdr_mrs, ddr2mr_seteOCD, sdr_mr1, tddr2_MRD),
			(sc2_lm6,  sc2_lm7,  "0", "0", "11000", sdr_mrs, ddr2mr_setdOCD, sdr_mr1, tddr2_MRD),
			(sc2_lm7,  sc2_wai,  "0", "0", "11000", sdr_nop, ddrmr_mrx,      sdr_mrx, tddr2_DLL),
			(sc2_wai,  sc_ref,   "0", "0", "11111", sdr_nop, ddrmr_mrx,      sdr_mrx, tddr2_REF),
			(sc_ref,   sc_ref,   "0", "0", "11100", sdr_nop, ddrmr_mrx,      sdr_mrx, tddr2_REF));
	
		constant sc3_rstrdy : s_code := "0001";
		constant sc3_cke  : s_code := "0011";
		constant sc3_lmr2 : s_code := "0010";
		constant sc3_lmr3 : s_code := "0110";
	
		constant sc3_lmr1 : s_code := "0111";
		constant sc3_lmr0 : s_code := "0101";
		constant sc3_zqi  : s_code := "0100";
		constant sc3_wle  : s_code := "1100";
	
		constant sc3_wls  : s_code := "1101";
		constant sc3_wlc  : s_code := "1111";
		constant sc3_wlo  : s_code := "1110";
		constant sc3_wlf  : s_code := "1010";
	
		constant sc3_wai  : s_code := "1011";
	
									--    +------< rst
									--    |+-----< cke
									--    ||+----< rdy
									--    |||+---< wlq
									--    ||||+--< odt
									--    |||||
									--    vvvvv
		constant ddr3_pgm : s_table := (
			(sc_rst,   sc3_rstrdy, "0", "0", "10000", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_rstrdy),
			(sc3_rstrdy, sc3_cke,  "0", "0", "11000", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_cke),
			(sc3_cke,  sc3_lmr2,   "0", "0", "11000", sdr_mrs, ddr3mr_setmr2, sdr_mr2, tddr3_mrd),
			(sc3_lmr2, sc3_lmr3,   "0", "0", "11000", sdr_mrs, ddr3mr_setmr3, sdr_mr3, tddr3_mrd),
			(sc3_lmr3, sc3_lmr1,   "0", "0", "11000", sdr_mrs, ddr3mr_setmr1, sdr_mr1, tddr3_mrd),
			(sc3_lmr1, sc3_lmr0,   "0", "0", "11000", sdr_mrs, ddr3mr_setmr0, sdr_mr0, tddr3_mod),
			(sc3_lmr0, sc3_zqi,    "0", "0", "11000", sdr_zqc, ddr3mr_zqc,    sdr_mrx, tddr3_zqinit),
			(sc3_zqi,  sc3_wle,    "0", "0", "11000", sdr_mrs, ddr3mr_enawl,  sdr_mr1, tddr3_mod),
			(sc3_wle,  sc3_wls,    "0", "0", "11001", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_wldqsen),
			(sc3_wls,  sc3_wlc,    "0", "0", "11011", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_wlc),
			(sc3_wlc,  sc3_wlc,    "1", "0", "11011", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_wlc),
			(sc3_wlc,  sc3_wlo,    "1", "1", "11010", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_mrd),
			(sc3_wlo,  sc3_wlf,    "0", "0", "11010", sdr_mrs, ddr3mr_setmr1, sdr_mr1, tddr3_mod),
			(sc3_wlf,  sc3_wai,    "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_dll),
			(sc3_wai,  sc_ref,     "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_ref),
			(sc_ref,   sc_ref,     "0", "0", "11110", sdr_nop, ddrmr_mrx,     sdr_mrx, tddr3_ref));

		function select_pgm (
			constant sdr_stdr : sdr_standards)
			return s_table is
		begin
			case sdr_stdr is
			when sdr =>
				return sdram_pgm;
			when DDR  =>
				return ddr1_pgm;
			when DDR2 =>
				return ddr2_pgm;
			when DDR3 =>
				return ddr3_pgm;
			end case;
		end;

		type s_out is record
			rst     : std_logic;
			cke     : std_logic;
			rdy     : std_logic;
			wlq		: std_logic;
			odt     : std_logic;
		end record;

		function to_sout (
			constant output : std_logic_vector(0 to 5-1))
			return s_out is
		begin
			return (
				rst => output(0),
				cke => output(1),
				rdy => output(2),
				wlq => output(3),
				odt => output(4));
		end;

		constant pgm : s_table := select_pgm(stdr);
		variable row : s_row;
		variable sdr_init_pc   : s_code;

	begin
		if rising_edge(sdr_init_clk) then

			if sdr_init_pc=sc_ref then
				if timer_rdy='1' then
					sdr_refi_req <= not sdr_refi_rdy;
				end if;
			else
				sdr_refi_req <= '0';
			end if;

			if sdr_init_req='0' then
				row := (
					state   => (others => '-'),
					state_n => (others => '-'),
					mask    => (others => '-'),
					input   => (others => '-'),
					output  => (others => '-'),
					cmd     => (cs => '-', ras => '-', cas => '-', we => '-'),
					bnk     => (others => '-'),
					mr      => (others => '-'),
					tid     => tsdr_rst);
				for i in pgm'range loop
					if pgm(i).state=sdr_init_pc then
						if ((pgm(i).input xor input) and pgm(i).mask)=(input'range => '0') then
							 row := pgm(i);
						end if;
					end if;
				end loop;
				if timer_rdy='1' then
					sdr_init_pc   := row.state_n;
					sdr_init_rst  <= to_sout(row.output).rst;
					init_rdy      <= to_sout(row.output).rdy;
					sdr_init_cke  <= to_sout(row.output).cke;
					sdr_init_wlreq<= to_sout(row.output).wlq;
					sdr_init_cs   <= row.cmd.cs;
					sdr_init_ras  <= row.cmd.ras;
					sdr_init_cas  <= row.cmd.cas;
					sdr_init_we   <= row.cmd.we;
					sdr_init_odt  <= to_sout(row.output).odt;
				else
					sdr_init_cs   <= sdr_nop.cs;
					sdr_init_ras  <= sdr_nop.ras;
					sdr_init_cas  <= sdr_nop.cas;
					sdr_init_we   <= sdr_nop.we;
					sdr_timer_id  <= row.tid;
				end if;
				sdr_init_b  <= std_logic_vector(unsigned(resize(unsigned(row.bnk), sdr_init_b'length)));
				sdr_mr_addr <= row.mr;
			else
				sdr_init_pc    := sc_rst;
				sdr_timer_id   <= tsdr_rst;
				sdr_init_rst   <= '0';
				sdr_init_cke   <= '0';
				init_rdy       <= '0';
				sdr_init_cs    <= '0';
				sdr_init_ras   <= '1';
				sdr_init_cas   <= '1';
				sdr_init_we    <= '1';
				sdr_init_odt   <= '0';
				sdr_init_wlreq <= '0';
				sdr_mr_addr    <= (sdr_mr_addr'range => '1');
				sdr_init_b     <= std_logic_vector(unsigned(resize(unsigned(sdr_mrx), sdr_init_b'length)));
			end if;

			sdr_init_rdy <= init_rdy;
		end if;
	end process;

	timer_req <=
		'1' when sdr_init_req='1' else
		'1' when timer_rdy='1' else
		'0';

	-----------------
	--- SDR_TIMERs --
	-----------------

	sdr_timer_b : block

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
					(tddr_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 40631)));
					-- (tddr_ref, to_sdrlatency(tCP, chip, tREFI)));
			when ddr2 =>
				return (
					(tsdr_rst,  to_sdrlatency(tcp, chip, tPreRST)/setif(debug, 100, 1)),
					(tddr2_cke, to_sdrlatency(tcp, chip, tXPR)),
					(tddr2_mrd, sdr_latency(stdr, mrd)),
					(tddr2_rpa, to_sdrlatency(tcp, chip, tRPA)),
					(tddr2_rfc, to_sdrlatency(tcp, chip, tRFC)),
					(tddr2_dll, 200),
					(tddr2_ref, to_sdrlatency(tcp, chip, tREFI)));
			when ddr3 =>
				return (
					(tsdr_rst,  to_sdrlatency(tCP, chip, tPreRST)/setif(debug, 100, 1)),
					(tddr3_rstrdy, to_sdrlatency(tCP, chip, tPstRST)/setif(debug, 100, 1)),
					(tddr3_wlc, sdr_latency(stdr, MODu)),
					(tddr3_wldqsen, 25),
					(tddr3_cke, to_sdrlatency(tCP, chip, tXPR)),
					(tddr3_mrd, to_sdrlatency(tCP, chip, tMRD)),
					(tddr3_mod, sdr_latency(stdr, MODu)),
					(tddr3_dll, sdr_latency(stdr, cDLL)),
					(tddr3_zqinit, sdr_latency(DDR3, ZQINIT)),
					(tddr3_ref, setif(not debug, to_sdrlatency(tCP, chip, tREFI), 1725)));
			end case;
		end;
	
		function get_timerset (
			constant tab : timer_vector)
			return natural_vector is
			variable rval : natural_vector(tab'range);
		begin
			for i in tab'range loop
				rval(i) := tab(i).value;
			end loop;
			return rval;
		end;
			
		constant timer_tab : timer_vector := get_timertab(tcp, chip, debug);
		signal   timer_sel : std_logic_vector(0 to  unsigned_num_bits(timer_tab'length-1));
	begin

		timer_sel_p : process (sdr_timer_id)
		begin
			for i in timer_tab'range loop
				if timer_tab(i).tid = sdr_timer_id then
					timer_sel <= std_logic_vector(to_unsigned(i, timer_sel'length));
					exit;
				else
					assert i/=timer_tab'right
					report ">>>timer_sel_p<<< wrong id : " & tids'image(sdr_timer_id)
					severity failure; 
				end if;
			end loop;
		end process;

		timer_b : block
			-- Even block generics and ports were defined in VHDL 88, they stil are not
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
				-- sys_clk => sdr_init_clk,
				-- tmr_sel => timer_sel,
				-- sys_req => timer_req,
				-- sys_rdy => timer_rdy);

			alias sys_clk : std_logic is sdr_init_clk;
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
