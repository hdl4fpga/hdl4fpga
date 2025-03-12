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

library hdl4fpga;
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;
use hdl4fpga.scopeiopkg.all;

architecture btof_tb of testbench is
	signal clk      : std_logic := '0';
	signal btof_req : std_logic;
	signal btof_rdy : std_logic;

	signal code_frm : std_logic;
	signal code     : std_logic_vector(0 to 8-1);
	signal bin      : std_logic_vector(0 to 18-1);

	signal btof_ack : std_logic;

	constant grid_height : natural := 32;
	constant vt_step : real := 3.3/(2**12);
	constant vt_unit : real := 0.05;
	constant xxx : string:= hdo(significand(vt_step*32.0)); --**".sgfc";
	constant sgfc : natural := hdo(xxx)**".sgfc";
	constant exp  : integer := hdo(xxx)**".exp";
	constant len  : natural := hdo(xxx)**".len";
	constant pfx  : integer := 3*((exp+(len-1)-2)/3);
	constant prc  : natural := 1;

	constant vt_sfcnds    : natural_vector := get_significand1245(vt_unit);
	constant vt_explen    : integer_vector := get_explen1245(vt_unit);
	constant vt_pfxprc    : integer_vector := get_pfxprc1245(vt_sfcnds, vt_explen);

	signal sht : signed(0 to 4-1);
	signal dec : signed(0 to 4-1);
begin
	sht <= to_signed(pfx-exp-prc, sht'length);
	dec <= sht+prc;
	btof_ack <= (btof_rdy xor btof_req);
	process 
		variable str : unsigned(0 to 8*8-1);
	begin
		if rising_edge(clk) then
			if (to_bit(btof_rdy) xor to_bit(btof_req))='0' then
				str := unsigned(std_logic_vector'(to_ascii("        ")));
				bin <= std_logic_vector(to_unsigned(hdo(xxx)**".sgfc",bin'length));
				btof_req <= not to_stdulogic(to_bit(btof_rdy));
			elsif code_frm='1' then
				str(0 to 8-1) := unsigned(code);
				str := str rol 8;
			end if;
		end if;
		if falling_edge(code_frm) then
			report "======>  '" & string'(to_ascii(std_logic_vector(str))) & ''';
			-- wait;
		end if;
		clk <= not clk after 0.5 ns;
		wait on clk, code_frm;
	end process;

	du_e : entity hdl4fpga.btof
   	port map (
   		clk      => clk,
   		btof_req => btof_req,
   		btof_rdy => btof_rdy,
		width    => x"9",
		left     => '0',
		sht      => std_logic_vector(sht),
		dec      => std_logic_vector(dec),
		exp      => b"101",
		neg      => '0',
		bin      => bin, 
   		code_frm => code_frm,
   		code     => code);

end;
