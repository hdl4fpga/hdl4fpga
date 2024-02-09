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

architecture mul_ser_tb of testbench is
	constant bin_digits : natural := 3;
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;

	signal clk         : std_logic := '0';
	signal ena         : std_logic := '1';
	signal bcd         : std_logic_vector(0 to 4-1);

	signal mul_req     : std_logic := '0';
	signal mul_rdy     : std_logic;
	signal dbdbbl_req  : std_logic;
	signal dbdbbl_rdy  : std_logic;
	signal dbdbbl_trdy : std_logic;

	signal a           : std_logic_vector(4-1 downto 0) := b"0111";
	signal b           : std_logic_vector((5+8)-1 downto 0) := b"0100_0000_01001";
	signal bin         : std_logic_vector(0 to bin_digits*((b'length+a'length+bin_digits-1)/bin_digits)-1);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if mul_req='0' then
				-- mul_req <= '1'; --not to_stdulogic(to_bit(mul_rdy));
			end if;
		end if;
	end process;
	mul_req <= not to_stdulogic(to_bit(dbdbbl_rdy));
	du_e : entity hdl4fpga.mul_ser
	generic map ( lsb => true)
	port map (
		clk => clk,
		ena => ena,
		req => mul_req,
		rdy => mul_rdy,
		a   => a,
		b   => b,
		s   => bin);

	dbdbbl_req <= to_stdulogic(to_bit(mul_rdy));
	bin2bcd_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width => 5,
		bcd_digits => 1)
	port map (
		clk  => clk,
		req  => dbdbbl_req,
		rdy  => dbdbbl_rdy,
		trdy => dbdbbl_trdy,
		bin  => bin,
		bcd  => bcd);
	
	process (bin)
	begin
		report to_string(bin);
	end process;

end;