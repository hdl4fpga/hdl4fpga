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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture format_tb of testbench is
	constant bcd_width  : natural := 8;
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal dbdbbl_req  : std_logic := '0';
	signal dbdbbl_rdy  : std_logic := '1';
	signal format_req  : std_logic := '0';
	signal format_rdy  : std_logic := '1';
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal frm  : std_logic;
	signal trdy : std_logic;

	signal code : std_logic_vector(0 to 8-1);
begin

	clk <= not clk after 1 ns;
	process (clk)
	begin
		if rising_edge(clk) then
			if dbdbbl_req='0' then
				dbdbbl_req <= '1';
			end if;
		end if;
	end process;
	-- dbdbbl_req <= not to_stdulogic(to_bit(dbdbbl_rdy));

	dbdbbl_seq_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width  => bcd_width,
		bin_digits => bin_digits,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		req => dbdbbl_req,
		rdy => dbdbbl_rdy,
		bin => std_logic_vector(to_unsigned(9664,15)), -- b"1001110",
		bcd_irdy => frm,
		bcd_trdy => trdy,
		bcd => bcd);

	du_e : entity hdl4fpga.format
	generic map (
		max_width => bcd_width)
	port map (
		tab      => to_ascii("0123456789 +-,."),
		clk      => clk,
		width    => x"3",
		dec      => b"0",
		bcd_frm  => frm,
		bcd_irdy => frm,
		bcd_trdy => trdy,
		neg      => '1',
		bcd      => bcd,
		code     => code);

	process 
	begin
		report "VALUE : " & ''' & to_string(code) & ''';
		wait on code;
	end process;
end;
