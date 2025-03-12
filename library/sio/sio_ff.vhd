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

entity sio_ff is
    port (
		si_clk   : in  std_logic;
        si_frm   : in  std_logic;
        si_irdy  : in  std_logic;
        si_trdy  : out std_logic;
		si_full  : out std_logic;
        si_data  : in  std_logic_vector;

        so_data  : out std_logic_vector);
end;

architecture def of sio_ff is
	constant max_words   : natural := so_data'length/si_data'length;
	constant cntr_length : natural := unsigned_num_bits(max_words-1);
	constant len         : unsigned(0 to cntr_length) := to_unsigned(max_words, cntr_length+1);
	subtype addr_range is natural range 1 to cntr_length;

	signal wr_addr : unsigned(0 to cntr_length);

begin

	assert max_words > 0
	report "max_words should be greater than 0"
	severity FAILURE;

	process (si_frm, si_irdy, si_clk)
		variable rgtr : unsigned(so_data'range);
		variable cntr : unsigned(0 to cntr_length);
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				cntr := (others => '0');
			elsif si_irdy='1' then 
				if cntr(0)='0' then
					if so_data'ascending and si_data'ascending then
						rgtr := rgtr ror si_data'length;
						rgtr(si_data'range) := unsigned(si_data);
					elsif not so_data'ascending and not si_data'ascending then
						rgtr := rgtr rol si_data'length;
						rgtr(si_data'range) := unsigned(si_data);
					elsif not so_data'ascending and si_data'ascending then
						rgtr(si_data'reverse_range) := unsigned(si_data);
						rgtr := rgtr ror si_data'length;
					else
						rgtr := rgtr rol si_data'length;
						rgtr(si_data'reverse_range) := unsigned(si_data);
					end if;

					cntr := cntr + 1;
				end if;
			end if;
			wr_addr <= cntr;
			so_data <= std_logic_vector(rgtr);
		end if;
	end process;

	si_trdy <= si_frm;
	si_full <= 
		'1' when wr_addr>=(so_data'length+si_data'length-1)/si_data'length else
		'0';

end;
