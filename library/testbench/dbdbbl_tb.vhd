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
	du_e : entity hdl4fpga.dbdbbl_sll
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

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_srlfix_tb of testbench is
	signal bcd : std_logic_vector(6*4-1 downto 0);
	signal bin : std_logic_vector(0 to 4-1);
begin
	du_e : entity hdl4fpga.dbdbbl_srlfix
	port map (
		rnd => '0',
		ini => b"0001_0010_0000",
		bin => bin,
		bcd => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_srl_tb of testbench is
	signal bcd : std_logic_vector(6*4-1 downto 0);
	signal bin : std_logic_vector(0 to 4-1);
begin
	du_e : entity hdl4fpga.dbdbbl_srl
	port map (
		ini => b"0001_0010_1000",
		cnt => b"100",
		bcd => bcd);
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture dbdbbl_seqshr_tb of testbench is
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

	du_e : entity hdl4fpga.dbdbbl_seqshr
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

architecture dbdbbl_seq_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal req  : std_logic := '0';
	signal rdy  : std_logic := '1';
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
begin
	clk <= not clk after 1 ns;

	process (clk)
	begin
		if rising_edge(clk) then
			if req='0' then
				req <= '1';
			end if;
		end if;
	end process;
	-- req <= not to_stdulogic(to_bit(rdy));

	du_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width  => 5,
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