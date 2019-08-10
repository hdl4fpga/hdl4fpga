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

entity scopeio_formatu is
	port (
		clk    : in  std_logic;
		bin_frm    : in  std_logic;
		bin_irdy   : in  std_logic := '1';
		trdy   : out std_logic;
		float  : in  std_logic_vector;
		width  : in  std_logic_vector := b"1000";
		neg    : in  std_logic;
		sign   : in  std_logic;
		align  : in  std_logic;
		unit   : in  std_logic_vector := b"0000";
		prec   : in  std_logic_vector := b"1101";
		format : out std_logic_vector);
end;

architecture def of scopeio_formatu is
	signal ser_irdy : std_logic;
	signal ser_trdy : std_logic;
	signal ser_data : std_logic_vector(4-1 downto 0);
	signal flt      : std_logic := '0';
	signal bcd_irdy : std_logic;
	signal bcd_end  : std_logic;
	signal bcd_do   : std_logic_vector(4-1 downto 0);
begin

	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk     => clk,
		bus_req => bus_req,
		bus_gnt => bus_gnt,

	btofbin_frm  <= wirebus(bin_frm,  bus_gnt and frm);
	btofbin_irdy <= wirebus(bin_irdy, bus_gnt and irdy);
	btofbin_trdy <= bus_gnt and bin_trdy;
		
	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		frm       => frm,
		bin_irdy  => btofbin_irdy,
		bin_trdy  => btofbin_trdy,
		bin_di    => btofbin_data,
		bin_flt   => flt,
		bin_sign  => sign,
		bin_neg   => neg,
		bcd_align => align,
		bcd_width => width,
		bcd_unit  => unit,
		bcd_prec  => prec,
		bcd_irdy  => btofbcd_irdy,
		bcd_end   => btofbcd_end,
		bcd_do    => btofbcd_do);

	bin_frm  <= wirebus(frm,  bus_gnt and frm);
	bin_irdy <= wirebus(irdy, bus_gnt and irdy);
end;
