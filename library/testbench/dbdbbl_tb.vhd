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

architecture dbdbbl_tb of testbench is
	signal bcd : std_logic_vector(5*4-1 downto 0);
begin
	du_e : entity hdl4fpga.dbdbbl
	port map (
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		report to_string(bcd);
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_ser_tb of testbench is
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;
	constant bcd_length : natural := 4;

	signal clk  : std_logic := '0';
	signal ena  : std_logic := '1';
	signal load : std_logic := '1';
	signal feed : std_logic := '0';
	signal bin_slice : std_logic_vector(bin_digits-1 downto 0);
	signal bcd  : std_logic_vector(bcd_length*bcd_digits*((5+bcd_digits-1)/bcd_digits)-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
		constant bin_num : unsigned := to_unsigned(32767,15);
		variable shr  : unsigned(0 to bin_digits*((bin_num'length+bin_digits-1)/bin_digits)-1) := to_unsigned(32767,15);
		variable cntr : integer range -1 to shr'length/bin_slice'length-2;
	begin
		if rising_edge(clk) then
			if load='1' then
				load <= '0';
				shr  := shr sll bin_slice'length;
				cntr := shr'length/bin_slice'length-2;
			elsif feed='1' then
				shr := shr sll bin_slice'length;
				if cntr < 0 then
					-- cntr := shr'length/bin_slice'length-2;
					-- ena <= '0';
				else
					cntr := cntr - 1;
				end if;
			end if;
		end if;
		bin_slice <= std_logic_vector(shr(0 to bin_slice'length-1));
	end process;

	du_e : entity hdl4fpga.dbdbbl_ser
	generic map (
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		irdy  => ena,
		load => load,
		trdy => feed,
		bin  => bin_slice,
		bcd  => bcd);

	process (bcd)
	begin
		report to_string(bcd);
	end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_seq_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal req  : std_logic := '0';
	signal rdy  : std_logic := '1';
	signal bcd  : std_logic_vector(bcd_length*bcd_digits*((5+bcd_digits-1)/bcd_digits)-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				-- req <= '1';
			end if;
		end if;
	end process;

	req <= not to_stdulogic(to_bit(rdy));
	du_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bin_digits => bin_digits,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		req => req,
		rdy => rdy,
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		-- report to_string(bcd);
	end process;

end;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_seq1_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal req  : std_logic := '0';
	signal rdy  : std_logic := '1';
	signal bcd  : std_logic_vector(bcd_length*bcd_digits*((5+bcd_digits-1)/bcd_digits)-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				-- req <= '1';
			end if;
	req <= not to_stdulogic(to_bit(rdy));
		end if;
	end process;

	du_e : entity hdl4fpga.dbdbbl_seq1
	generic map (
		bin_digits => bin_digits,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		req => req,
		rdy => rdy,
		bin => std_logic_vector(to_unsigned(32035,15)), -- b"1001110",
		bcd => bcd);

	process (bcd)
	begin
		-- report to_string(bcd);
	end process;

end;


