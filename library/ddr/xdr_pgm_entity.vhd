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

entity xdr_pgm is
	port (
		xdr_pgm_rst : in  std_logic := '0';
		xdr_pgm_clk : in  std_logic := '0';
		xdr_pgm_ref : in  std_logic := '0';
		xdr_pgm_rrdy : out  std_logic := '0';
		sys_pgm_ref : out std_logic := '0';
		xdr_pgm_start : in  std_logic := '1';
		xdr_pgm_rdy : out std_logic;
		xdr_pgm_req : in  std_logic := '1';
		xdr_pgm_rw  : in  std_logic := '1';
		xdr_pgm_cas : out std_logic := '0';
		xdr_pgm_cmd : out std_logic_vector(0 to 2));

	constant cacc : natural := 6;
	constant rrdy : natural := 5;
	constant ref  : natural := 4;
	constant rdy  : natural := 3;
	constant ras  : natural := 2;
	constant cas  : natural := 1;
	constant we   : natural := 0;

                        --> xdr_pgm_rdy <---------------------+
                        --> sys_pgm_ref <--------------------+|
                        --                                   ||
                        --                                   VV
	constant xdr_act  : std_logic_vector(6 downto 0)    := "0000" & "011";
	constant xdr_actq : std_logic_vector(xdr_act'range) := "0010" & "011";
	constant xdr_acty : std_logic_vector(xdr_act'range) := "0100" & "011";
	constant xdr_rea  : std_logic_vector(xdr_act'range) := "1000" & "101";
	constant xdr_reaq : std_logic_vector(xdr_act'range) := "1010" & "101";
	constant xdr_wri  : std_logic_vector(xdr_act'range) := "1000" & "100";
	constant xdr_wriq : std_logic_vector(xdr_act'range) := "1010" & "100";
	constant xdr_pre  : std_logic_vector(xdr_act'range) := "0000" & "010";
	constant xdr_preq : std_logic_vector(xdr_act'range) := "0010" & "010";
	constant xdr_prey : std_logic_vector(xdr_act'range) := "0100" & "010";
	constant xdr_aut  : std_logic_vector(xdr_act'range) := "0000" & "001";
	constant xdr_autq : std_logic_vector(xdr_act'range) := "0010" & "001";
	constant xdr_auty : std_logic_vector(xdr_act'range) := "0111" & "001";
	constant xdr_nop  : std_logic_vector(xdr_act'range) := "0001" & "111";
	constant xdr_nopy : std_logic_vector(xdr_act'range) := "0101" & "111";
	constant xdr_dnt  : std_logic_vector(xdr_act'range) := (others => '-');

	constant ddrs_act : std_logic_vector(0 to 2) := "011";
	constant ddrs_rea : std_logic_vector(0 to 2) := "101";
	constant ddrs_wri : std_logic_vector(0 to 2) := "100";
	constant ddrs_pre : std_logic_vector(0 to 2) := "010";
	constant ddrs_aut : std_logic_vector(0 to 2) := "001";
	constant ddrs_dnt : std_logic_vector(0 to 2) := (others => '-');

	type trans_row is record
		state   : std_logic_vector(0 to 2);
		input   : std_logic_vector(0 to 2);
		state_n : std_logic_vector(0 to 2);
		cmd_n   : std_logic_vector(xdr_act'range);
	end record;

	type trans_tab is array (natural range <>) of trans_row;

end;
