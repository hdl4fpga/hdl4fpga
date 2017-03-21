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

entity cgaram is
	port (
		wr_clk  : in std_logic;
		wr_ena  : in std_logic;
		wr_row  : in std_logic_vector;
		wr_col  : in std_logic_vector;
		wr_code : in std_logic_vector;

		rd_clk  : in std_logic;
		rd_row  : in  std_logic_vector;
		rd_col  : in  std_logic_vector;
		rd_code : out std_logic_vector);

end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of cgaram is

	subtype word is std_logic_vector(rd_code'length-1 downto 0);
	type word_vector is array (natural range <>) of word;

	signal charram  : word_vector(2**(rd_row'length+rd_col'length)-1 downto 0);

	signal wr_addr : std_logic_vector(wr_row'length+wr_col'length-1 downto 0);
	signal rd_addr : std_logic_vector(rd_row'length+rd_col'length-1 downto 0);
	signal dummyoa : std_logic_vector(wr_code'range);
	signal dummyib : std_logic_vector(rd_code'range);

begin

	wr_addr <= wr_row & wr_col;
	rd_addr <= rd_row & rd_col;
	assert rd_addr'length=wr_addr'length
		report "cgaram"
		severity ERROR;
	dpram_e : entity hdl4fpga.bram
	port map (
		clka  => wr_clk,
		wea   => wr_ena,
		addra => wr_addr,
		dia   => wr_code,
		doa   => dummyoa,

		clkb  => rd_clk,
		addrb => rd_addr,
		dib   => dummyib,
		dob   => rd_code);
end;
