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

entity scopeio_btof is
	port (
		clk      : in  std_logic;
		bin_frm  : in  std_logic_vector;
		bin_irdy : in  std_logic_vector;
		bin_trdy : in  std_logic_vector;
		float    : in  std_logic_vector;
		width    : in  std_logic_vector := b"1000";
		neg      : in  std_logic;
		sign     : in  std_logic;
		align    : in  std_logic;
		unit     : in  std_logic_vector := b"0000";
		prec     : in  std_logic_vector := b"1101";
		bcd_frm  : out std_logic_vector;
		bcd_irdy : out std_logic_vector;
		bcd_trdy : out std_logic_vector;
		bcd_do   : out std_logic_vector);
end;

architecture def of scopeio_btof is
	signal flt          : std_logic := '0';
	signal btofbcd_irdy : std_logic;
	signal btofbcd_end  : std_logic;
	signal btofbcd_do   : std_logic_vector(4-1 downto 0);
begin

	arbiter_e : entity hdl4fpga.arbiter
	port map (
		clk     => clk,
		bus_req => bus_req,
		bus_gnt => bus_gnt,

	btofbin_frm  <= wirebus(bin_frm,  bus_gnt and bin_frm);
	btofbin_irdy <= wirebus(bin_irdy, bus_gnt and bin_irdy);
	bin_trdy     <= bus_gnt and btofbin_trdy;
		
	btof_e : entity hdl4fpga.btof
	port map (
		clk       => clk,
		frm       => btofbin_frm,
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
		bcd_trdy  => btofbcd_trdy,
		bcd_end   => btofbcd_end,
		bcd_do    => btofbcd_do);

	bcd_do   <= btofbcd_do;

end;

entity scopeio_write is
	port (
		clk        : in  std_logic;
		bcd_frm    : in  std_logic;
		bcd_irdy   : in  std_logic;
		bcd_trdy   : buffer std_logic := '1';
		bcd_di     : in  std_logic_vector;
		ascii_frm  : in  std_logic;
		ascii_irdy : in  std_logic;
		ascii_trdy : buffer std_logic := '1';
		ascii_di   : in  std_logic_vector;
		cga_we     : out std_logic_vector;
		cga_addr   : out std_logic_vector;
		cga_do     : out std_logic_vector);
		
architecture mix of scopeio_write is
begin
	cga_we <= bcd_irdy or ascii_irdy;
	process (clk)
	begin
		if rising_edge(clk) then
			if bcd_irdy='1' then
				if bcd_trdy='1' then
					cga_addr <= cga_addr + 1;
				end if;
			end if;
		end if;
	end process;
	cga_do <= 
		 word2byte(to_ascii("0123456789 .+-"), bcd_di, ascii'length) when bcd_frm='1' else
		 ascii_di when ascii_frm='1' else
		 (others => '-');
end;
