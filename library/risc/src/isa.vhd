--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2010-2013                                                    --
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

package isa is
 	constant ridlen : natural := 4;

 	constant opcLeft  : natural := 0;
 	constant opcRight : natural := 4-1;

 	constant rs1Left  : natural := opcRight + 1;
 	constant rs1Right : natural := rs1Left  + ridlen-1;

 	constant rs2Left  : natural := rs1Right + 1;
 	constant rs2Right : natural := rs2Left  + ridlen-1;

 	constant funLeft  : natural := rs2Right + 1;
 	constant funRight : natural := funLeft  + 4-1;

 	constant im4Left  : natural := rs2Right + 1;
 	constant im4Right : natural := im4Left  + 4-1;

 	constant im8Left  : natural := rs1Right + 1;
 	constant im8Right : natural := im8Left  + 8-1;

 	constant im12Left  : natural := opcRight + 1;
 	constant im12Right : natural := im12Left + 12-1;

	subtype ridFld  is natural range       0  to ridlen-1;
 	subtype opcFld  is natural range opcLeft  to opcRight;
 	subtype rs1Fld  is natural range rs1Left  to rs1Right;
 	subtype rs2Fld  is natural range rs2Left  to rs2Right;
	subtype rdFld   is rs1Fld;
 	subtype funFld  is natural range funLeft  to funRight;
 	subtype im4Fld  is natural range im4Left  to im4Right;
 	subtype im8Fld  is natural range im8Left  to im8Right;
 	subtype im12Fld is natural range im12Left to im12Right;

 	-- Operation Codes --
 	---------------------

 	constant alu  : std_ulogic_vector(opcFld) := "0000";
 	constant addi : std_ulogic_vector(opcFld) := "1110";
 	constant brt  : std_ulogic_vector(opcFld) := "1010"; -- X"A"
 	constant cpi  : std_ulogic_vector(opcFld) := "1111";

 	constant jal  : std_ulogic_vector(opcFld) := "1000"; -- X"8"
 	constant jral : std_ulogic_vector(opcFld) := "1001";

 	constant li   : std_ulogic_vector(opcFld) := "1011";
 	constant ori  : std_ulogic_vector(opcFld) := "1100";
 	constant rrf  : std_ulogic_vector(opcFld) := "1101";

 	constant ld   : std_ulogic_vector(opcFld) := "0001";
 	constant st   : std_ulogic_vector(opcFld) := "0101";

	constant rt : natural := 0;
	constant rv : natural := 1;
	constant ry : natural := 2;
	subtype flagSet is natural range rt to ry;
	constant rtId : std_ulogic_vector (1 downto 0) := "00";
	constant rvId : std_ulogic_vector (1 downto 0) := "10";
	constant ryId : std_ulogic_vector (1 downto 0) := "01";

	-- Alu functions --
	-------------------

	constant alu_mov  : std_ulogic_vector(funFld) := "0000";		-- 0
	constant alu_add  : std_ulogic_vector(funFld) := "0001";		-- 1
	                                                        		-- 2
	constant alu_sub  : std_ulogic_vector(funFld) := "0011";		-- 3
	constant alu_or   : std_ulogic_vector(funFld) := "0100";		-- 4
	constant alu_and  : std_ulogic_vector(funFld) := "0101";		-- 5
	                                                        		-- 6
	constant alu_xor  : std_ulogic_vector(funFld) := "0111";		-- 7
	                                                        		-- 8
	constant alu_lsli : std_ulogic_vector(funFld) := "1001";		-- 9
	constant alu_lsri : std_ulogic_vector(funFld) := "1010";		-- 10
	constant alu_asri : std_ulogic_vector(funFld) := "1011";		-- 11
	                                                        		-- 12
	constant alu_lsht  : std_ulogic_vector(funFld) := "1101";		-- 13
	constant alu_asht  : std_ulogic_vector(funFld) := "1110";		-- 14
	                                                        		-- 15

	constant alu_arth_sht_bit_num : natural := funFld'right;
	constant alu_dirn_sht_bit_num : natural := funFld'right-1;
	constant alu_immd_sht_bit_num : natural := funFld'right-2;

	constant t_register : std_ulogic_vector(ridFld) := "0000";
	constant y_register : std_ulogic_vector(ridFld) := "0001";
	constant v_register : std_ulogic_vector(ridFld) := "0010";

	constant rrf_rw_bit_num : natural := funFld'right;

end package;
