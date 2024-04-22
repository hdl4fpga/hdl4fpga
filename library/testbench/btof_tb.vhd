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

architecture btof_tb of testbench is
	signal clk      : std_logic := '0';
	signal btof_req : std_logic;
	signal btof_rdy : std_logic;

	signal code_frm : std_logic;
	signal code     : std_logic_vector(0 to 8-1);
	signal bin      : std_logic_vector(0 to 18-1);

	signal btof_ack : std_logic;

begin


	btof_ack <= (btof_rdy xor btof_req);
	process 
		variable xxx : unsigned(0 to 8*8-1);
		variable yyy : natural;
	begin
		if rising_edge(clk) then
			if (to_bit(btof_rdy) xor to_bit(btof_req))='0' then
				xxx := unsigned(std_logic_vector'(to_ascii("        ")));
				-- bin <= std_logic_vector(to_unsigned(yyy,bin'length));
				bin <= std_logic_vector(to_unsigned(4095,bin'length));
				-- yyy := yyy + 18;
				btof_req <= not to_stdulogic(to_bit(btof_rdy));
			elsif code_frm='1' then
				xxx(0 to 8-1) := unsigned(code);
				xxx := xxx rol 8;
			end if;
		end if;
		if falling_edge(code_frm) then
			report "======>  '" & string'(to_ascii(std_logic_vector(xxx))) & ''';
			wait;
		end if;
		clk <= not clk after 0.5 ns;
		wait on clk, code_frm;
	end process;


	du_e : entity hdl4fpga.btof
   	port map (
   		clk      => clk,
   		btof_req => btof_req,
   		btof_rdy => btof_rdy,
		sht      => x"0",
		dec      => x"1",
		exp      => b"000",
		neg      => '1',
		bin      => bin, 
   		code_frm => code_frm,
   		code     => code);


end;
