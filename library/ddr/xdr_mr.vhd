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
use hdl4fpga.xdr_db.all;
use hdl4fpga.xdr_param.all;

entity xdr_mr is
	generic (
		ddr_stdr : natural := DDR1);
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

		xdr_mr_addr : in  std_logic_vector(3-1 downto 0);
		xdr_mr_data : out std_logic_vector(13-1 downto 0));
end;

architecture def of xdr_mr is

begin

	xdr_mr_data <= resize(ddr_mrfile(
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
		xdr_mr_cwl  => xdr_mr_cwl),xdr_mr_data'length);
end;
