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

entity scopeio_btof is
	port (
		clk       : in  std_logic;
		bin_frm   : in  std_logic_vector;
		bin_irdy  : in  std_logic_vector;
		bin_trdy  : out std_logic_vector;
		bin_exp   : in  std_logic_vector;
		bin_neg   : in  std_logic_vector;
		bin_di    : in  std_logic_vector;
		bcd_width : in  std_logic_vector;
		bcd_sign  : in  std_logic_vector;
		bcd_align : in  std_logic_vector;
		bcd_unit  : in  std_logic_vector;
		bcd_prec  : in  std_logic_vector;
		bcd_irdy  : in  std_logic_vector;
		bcd_trdy  : out std_logic_vector;
		bcd_end   : out std_logic;
		bcd_do    : out std_logic_vector);
end;

architecture def of scopeio_btof is
	signal btof_req      : std_logic_vector(bin_frm'range);
	signal btof_gnt      : std_logic_vector(bin_frm'range);

	signal btofbin_frm   : std_logic_vector(0 to 0);
	signal btofbin_irdy  : std_logic_vector(0 to 0);
	signal btofbin_trdy  : std_logic;
	signal btofbin_di    : std_logic_vector(bin_di'length/bin_frm'length-1 downto 0);
	signal btofbin_exp   : std_logic_vector(0 to 0);
	signal btofbin_neg   : std_logic_vector(0 to 0);
	signal btofbcd_unit  : std_logic_vector(bcd_unit'length/bin_frm'length-1 downto 0);
	signal btofbcd_width : std_logic_vector(bcd_width'length/bin_frm'length-1 downto 0);
	signal btofbcd_prec  : std_logic_vector(bcd_prec'length/bin_frm'length-1 downto 0);
	signal btofbcd_sign  : std_logic_vector(0 to 0);
	signal btofbcd_align : std_logic_vector(0 to 0);
	signal btofbcd_irdy  : std_logic_vector(0 to 0);
	signal btofbcd_trdy  : std_logic;
begin

	btof_req <= bin_frm;
	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk => clk,
		req => btof_req,
		gnt => btof_gnt);

	btofbin_frm   <= wirebus(bin_frm,   btof_gnt);
	btofbin_irdy  <= wirebus(bin_irdy,  btof_gnt);
	btofbcd_irdy  <= wirebus(bcd_irdy,  btof_gnt);
	btofbin_di    <= wirebus(bin_di,    btof_gnt);
	btofbin_exp   <= wirebus(bin_exp,   btof_gnt);

	btofbcd_sign  <= wirebus(bcd_sign,  btof_gnt);
	btofbin_neg   <= wirebus(bin_neg,   btof_gnt);
	btofbcd_width <= wirebus(bcd_width, btof_gnt);
	btofbcd_unit  <= wirebus(bcd_unit,  btof_gnt);
	btofbcd_prec  <= wirebus(bcd_prec , btof_gnt);
	btofbcd_align <= wirebus(bcd_align, btof_gnt);
		
	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		frm       => btofbin_frm(0),
		bin_irdy  => btofbin_irdy(0),
		bin_trdy  => btofbin_trdy,
		bin_di    => btofbin_di,
		bin_flt   => btofbin_exp(0),
		bin_neg   => btofbin_neg(0),
		bcd_sign  => btofbcd_sign(0),
		bcd_align => btofbcd_align(0),
		bcd_width => btofbcd_width,
		bcd_unit  => btofbcd_unit,
		bcd_prec  => btofbcd_prec,
		bcd_irdy  => btofbcd_irdy(0),
		bcd_trdy  => btofbcd_trdy,
		bcd_end   => bcd_end,
		bcd_do    => bcd_do);

	bin_trdy <= btof_gnt and (btof_gnt'range => btofbin_trdy);
	bcd_trdy <= btof_gnt and (btof_gnt'range => btofbcd_trdy);

end;
