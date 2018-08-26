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

architecture scopeio_btod of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';

	signal bin_ena : std_logic;
    signal bin_dv  : std_logic;
    signal bin_di  : std_logic_vector(0 to 4-1);

    signal bcd_rdy : std_logic;
    signal bin_fix : std_logic;
    signal bcd_do  : std_logic_vector(0 to 4-1);

	signal bcd_lft : std_logic_vector(1 to 4);
	signal bcd_rgt : std_logic_vector(1 to 4);

	signal cntr    : unsigned(0 to 2);

	signal wr_ena  : std_logic;
	signal wr_addr : std_logic_vector(0 to 3-1);
	signal rd_addr : std_logic_vector(wr_addr'range);
	signal wr_data : std_logic_vector(0 to 5*4-1);
	signal rd_data : std_logic_vector(wr_data'range);
begin

	clk <= not clk  after  5 ns;
	rst <= '1', '0' after 12 ns;

	process (rst, clk, bcd_rdy)
	begin
		if rst='1' then
			cntr    <= (others => '1');
			bin_fix <= '0';
		elsif rising_edge(clk) then
			if bcd_rdy='1' then
				if cntr(0)='1' then
					cntr <= to_unsigned(2, cntr'length);
				elsif cntr(0)='0' then
					cntr <= cntr - 1;
				end if;
			end if;
		end if;
	end process;

	bin_ena <= not (cntr(0) and bcd_rdy) and not rst;
	bin_di <= word2byte(std_logic_vector(unsigned'(x"0123") ror 4), not std_logic_vector(cntr(1 to 2)));

	process (clk)
		variable ena  : std_logic;
		variable num  : unsigned(0 to wr_data'length-1);
		variable mask : unsigned(0 to wr_data'length-1);
	begin
		if rising_edge(clk) then
			if ena='1' then
				num  := (others => '1'); 
			else
				num  := num  ror bcd_do'length;
			end if;
			ena := bcd_rdy;
			mask := (others '1');
			num (bcd_do'range) := unsigned(bcd_do);
			wr_data <= std_logic_vector(num);
			wr_ena  <= bcd_rdy and cntr(0);
		end if;
	end process;

	align_b : process 
		variable temp  : std_logic_vector(num'range);
		variable digit : std_logic_vector(0 to 4-1);
	begin
		temp  :=
		digit := (others => '-');
		for i in 0 to loop
			if  i <  then
				digit := temp(0 to 4-1);
				temp  := std_logic_vector(unsigned(temp) ror 4);
			end if;
		end loop;
		temp := temp rol 4;
		temp(0 to 4-1) := '.';
		for i in 0 to loop
			if  i <  then
				temp := std_logic_vector(unsigned(temp) rol 4);
				swap(digit, temp(0 to 4-1));
			end if;
		end loop;
		wr_data <= temp;
	end process;

	du: entity hdl4fpga.scopeio_ftod
	port map (
		clk     => clk,
		bin_ena => bin_ena,
		bin_dv  => bin_dv,
		bin_di  => bin_di,
		bin_pnt => x"0",
                           
		bcd_lft => bcd_lft,
		bcd_rgt => bcd_rgt,
		bcd_rdy => bcd_rdy,
		bcd_do  => bcd_do);

	wr_addr <= (others => '0');
	mem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => wr_ena,
		wr_addr => wr_addr,
		wr_data => wr_data,

		rd_addr => rd_addr,
		rd_data => rd_data);


end;
