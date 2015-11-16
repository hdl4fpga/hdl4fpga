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
use hdl4fpga.xdr_db.all;
use hdl4fpga.xdr_param.all;

entity xdr_mr is
	generic (
		ddr_stdr : natural);
	port (
		xdr_mr_al   : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_bl   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_bt   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_cl   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_ods  : in  std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		xdr_mr_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_rtt  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_zqc  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		xdr_mr_ocd  : in  std_logic_vector(3-1 downto 0) := (others => '1');
		xdr_mr_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		xdr_mr_addr : in  std_logic_vector(3-1 downto 0) := (others => '0');
		xdr_mr_data : out std_logic_vector(13-1 downto 0) := (others => '0'));
end;

architecture def of xdr_mr is

	function mr_field (
		constant mask : fd_vector;
		constant src  : std_logic_vector)
		return std_logic_vector is
	begin
		return mr_field(mask, src, xdr_mr_data'length);
	end;

	type mr_row is record
		mr   : ddrmr_addr;
		data : std_logic_vector(xdr_mr_data'length-1 downto 0);
	end record;

	type mr_vector is array (natural range <>) of mr_row;

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

	function ddrmr_data (
		constant mr_file : mr_vector;
		constant mr_addr : std_logic_vector)
		return std_logic_vector is
	begin
		for i in mr_file'range loop
			if mr_addr=mr_file(i).mr then
				return mr_file(i).data;
			end if;
		end loop;
		return (xdr_mr_data'range => '0');
	end;

	function ddr2_mrfile (
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_ocd  : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_rdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector)
		return std_logic_vector is
		variable mr_file : mr_vector(0 to 8-1);
	begin
		mr_file := (
			(mr   => ddr2mr_setemr2, 
			 data => (
			 	mr_field(mask => ddr2_srt, src => xdr_mr_srt))),

			(mr   => ddr2mr_setemr3, 
			 data => (others => '0')),
			(mr   => ddr2mr_rstdll, 
			 data => (
				mr_field(mask => ddr2_rdll, src => "1"))),
			(mr   => ddr2mr_enadll, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0"))),

			(mr   => ddr2mr_setmr, 
			 data => (
				mr_field(mask => ddr2_bl,   src => xdr_mr_bl) or
				mr_field(mask => ddr2_bt,   src => xdr_mr_bt) or
				mr_field(mask => ddr2_cl,   src => xdr_mr_cl) or
				mr_field(mask => ddr2_wr,   src => xdr_mr_wr) or
				mr_field(mask => ddr2_rdll, src => "0"))),
			(mr   => ddr2mr_seteOCD, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => xdr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => xdr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => xdr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => xdr_mr_ocd)  or
				mr_field(mask => ddr2_ddqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => xdr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0"))),
			(mr   => ddr2mr_setdOCD, 
			 data => (
				mr_field(mask => ddr2_edll, src => "0") or
				mr_field(mask => ddr2_ods,  src => xdr_mr_ods)  or
				mr_field(mask => ddr2_rtt,  src => xdr_mr_rtt)  or
				mr_field(mask => ddr2_al,   src => xdr_mr_al)   or
				mr_field(mask => ddr2_ocd,  src => "000")  or
				mr_field(mask => ddr2_ddqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr2_rdqs, src => xdr_mr_rdqs) or
				mr_field(mask => ddr2_out,  src => "0"))),
			(mr   => ddr2mr_preall, 
			 data => (
				mr_field(mask => ddr2_preall, src => "1"))));

		return ddrmr_data(
			mr_addr => xdr_mr_addr,
			mr_file => mr_file);
	end;

	function ddr3_mrfile (
		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector;
		constant xdr_mr_qoff : std_logic_vector;
		constant xdr_mr_drtt : std_logic_vector;
		constant xdr_mr_mprrf : std_logic_vector;
		constant xdr_mr_mpr  : std_logic_vector;
		constant xdr_mr_zqc  : std_logic_vector;
		constant xdr_mr_asr  : std_logic_vector;
		constant xdr_mr_pd   : std_logic_vector;
		constant xdr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
		variable mr_file : mr_vector(0 to 5-1);
	begin
		mr_file := (
			(mr   => ddr3mr_setmr0,
			 data => (
				mr_field(mask => ddr3_bl, src => xdr_mr_bl) or
				mr_field(mask => ddr3_bt, src => xdr_mr_bt) or
				mr_field(mask => ddr3_cl, src => xdr_mr_cl) or
				mr_field(mask => ddr3_pd, src => xdr_mr_pd) or
				mr_field(mask => ddr3_rdll, src => "1") or
				mr_field(mask => ddr3_wr, src => xdr_mr_wr))),
			(mr   => ddr3mr_setmr1,
			 data => (
				mr_field(mask => ddr3_al,   src => xdr_mr_al) or
				mr_field(mask => ddr3_edll, src => "0") or
				mr_field(mask => ddr3_ods,  src => xdr_mr_ods) or
				mr_field(mask => ddr3_qoff, src => xdr_mr_qoff) or
				mr_field(mask => ddr3_rtt,  src => xdr_mr_rtt) or
				mr_field(mask => ddr3_tdqs, src => xdr_mr_tdqs) or
				mr_field(mask => ddr3_wl,   src => xdr_mr_wl))),

			(mr   => ddr3mr_setmr2,
			 data => (
				mr_field(mask => ddr3_asr,  src => xdr_mr_asr) or
				mr_field(mask => ddr3_cwl,  src => xdr_mr_cwl) or
				mr_field(mask => ddr3_drtt, src => xdr_mr_drtt) or
				mr_field(mask => ddr3_srt,  src => xdr_mr_srt))),

			(mr   => ddr3mr_setmr3,
			 data => (
				mr_field(mask => ddr3_mprrf, src => xdr_mr_mprrf) or
				mr_field(mask => ddr3_mpr,   src => xdr_mr_mpr))),

			(mr   => ddr3mr_zqc,
			 data => (
				mr_field(mask => ddr3_zqc,   src => xdr_mr_zqc))));

		return ddrmr_data (
			mr_addr => xdr_mr_addr,
			mr_file => mr_file);
	end;

	function ddr_mrfile(
		constant xdr_stdr : natural;

		constant xdr_mr_addr : std_logic_vector;
		constant xdr_mr_srt  : std_logic_vector;
		constant xdr_mr_bl   : std_logic_vector;
		constant xdr_mr_bt   : std_logic_vector;
		constant xdr_mr_cl   : std_logic_vector;
		constant xdr_mr_wr   : std_logic_vector;
		constant xdr_mr_ods  : std_logic_vector;
		constant xdr_mr_rtt  : std_logic_vector;
		constant xdr_mr_al   : std_logic_vector;
		constant xdr_mr_ocd  : std_logic_vector;
		constant xdr_mr_tdqs : std_logic_vector;
		constant xdr_mr_rdqs : std_logic_vector;
		constant xdr_mr_wl   : std_logic_vector;
		constant xdr_mr_qoff : std_logic_vector;
		constant xdr_mr_drtt : std_logic_vector;
		constant xdr_mr_mprrf : std_logic_vector;
		constant xdr_mr_mpr  : std_logic_vector;
		constant xdr_mr_zqc  : std_logic_vector;
		constant xdr_mr_asr  : std_logic_vector;
		constant xdr_mr_pd   : std_logic_vector;
		constant xdr_mr_cwl  : std_logic_vector)
		return std_logic_vector is
	begin
		if xdr_stdr=DDR2 then
			return ddr2_mrfile(
				xdr_mr_addr => xdr_mr_addr,
				xdr_mr_srt  => xdr_mr_srt,
				xdr_mr_bl   => xdr_mr_bl,
				xdr_mr_bt   => xdr_mr_bt,
				xdr_mr_cl   => xdr_mr_cl,
				xdr_mr_wr   => xdr_mr_wr,
				xdr_mr_ods  => xdr_mr_ods,
				xdr_mr_rtt  => xdr_mr_rtt,
				xdr_mr_al   => xdr_mr_al,
				xdr_mr_ocd  => xdr_mr_ocd,
				xdr_mr_tdqs => xdr_mr_tdqs,
				xdr_mr_rdqs => xdr_mr_rdqs,
				xdr_mr_wl   => xdr_mr_wl);
		elsif xdr_stdr=DDR3 then
			return ddr3_mrfile(
				xdr_mr_addr  => xdr_mr_addr,
				xdr_mr_srt   => xdr_mr_srt,
				xdr_mr_bl    => xdr_mr_bl,
				xdr_mr_bt    => xdr_mr_bt,
				xdr_mr_cl    => xdr_mr_cl,
				xdr_mr_wr    => xdr_mr_wr,
				xdr_mr_ods   => xdr_mr_ods,
				xdr_mr_rtt   => xdr_mr_rtt,
				xdr_mr_al    => xdr_mr_al,
				xdr_mr_qoff  => xdr_mr_qoff,
				xdr_mr_tdqs  => xdr_mr_tdqs,
				xdr_mr_drtt  => xdr_mr_drtt,
				xdr_mr_mprrf => xdr_mr_mprrf,
				xdr_mr_mpr   => xdr_mr_mpr,
				xdr_mr_zqc   => xdr_mr_zqc,
				xdr_mr_asr   => xdr_mr_asr,
				xdr_mr_pd    => xdr_mr_pd,
				xdr_mr_cwl   => xdr_mr_cwl,
				xdr_mr_wl    => xdr_mr_wl);
		end if;
		return (1 to 0 => '-');
	end;

begin

	xdr_mr_data <= ddr_mrfile(
		xdr_stdr => ddr_stdr,
		xdr_mr_addr => xdr_mr_addr, 
		xdr_mr_srt  => xdr_mr_srt,
		xdr_mr_bl   => xdr_mr_bl,
		xdr_mr_bt   => xdr_mr_bt,
		xdr_mr_cl   => xdr_mr_cl,
		xdr_mr_wr   => xdr_mr_wr,
		xdr_mr_ods  => xdr_mr_ods,
		xdr_mr_rtt  => xdr_mr_rtt,
		xdr_mr_al   => xdr_mr_al,
		xdr_mr_ocd  => xdr_mr_ocd,
		xdr_mr_tdqs => xdr_mr_tdqs,
		xdr_mr_rdqs => xdr_mr_rdqs,
		xdr_mr_wl   => xdr_mr_wl,
		xdr_mr_qoff => xdr_mr_qoff,
		xdr_mr_drtt => xdr_mr_drtt,
		xdr_mr_mprrf=> xdr_mr_mprrf,
		xdr_mr_mpr  => xdr_mr_mpr,
		xdr_mr_zqc  => xdr_mr_zqc,
		xdr_mr_asr  => xdr_mr_asr,
		xdr_mr_pd   => xdr_mr_pd,
		xdr_mr_cwl  => xdr_mr_cwl);
end;
