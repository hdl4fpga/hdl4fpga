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

	format_b : block
		constant order : std_logic_vector(0 to 1) := "10";
		signal num_dv  : std_logic;
		signal num_val : std_logic_vector(0 to wr_data'length-1);
		signal num_lft : std_logic_vector(bcd_lft'range);
		signal num_rgt : std_logic_vector(bcd_rgt'range);
	begin

		process (clk)
			variable val : unsigned(0 to wr_data'length-1);
			variable ena : std_logic;
		begin
			if rising_edge(clk) then
				if ena='1' then
					val := (others => '1'); 
				else
					val := val ror bcd_do'length;
				end if;
				ena := bcd_rdy;
				val(bcd_do'range) := unsigned(bcd_do);
				num_lft <= bcd_lft;
				num_rgt <= bcd_rgt;
				num_dv  <= bcd_rdy and cntr(0);
				num_val <= std_logic_vector(val);
			end if;
		end process;

		format_p : process(order, num_val, num_rgt, num_lft) 
			variable temp  : std_logic_vector(num_val'range);
			variable digit : std_logic_vector(0 to 4-1);
		begin
			temp  := num_val;
			digit := (others => '-');
			if num_lft/=num_rgt or temp(0 to 4-1)/=x"0" then
				for i in 0 to num_val'length/4-1 loop
					if signed(order) > i then
						if signed(num_lft) > signed(num_rgt)+i then
							digit := temp(0 to 4-1);
							temp  := std_logic_vector(unsigned(temp) ror 4);
						else 
							temp(0 to 4-1) := x"0";
							temp  := std_logic_vector(unsigned(temp) ror 4);
						end if;
					end if;
				end loop;
				temp := std_logic_vector(unsigned(temp) rol 4);
				temp(0 to 4-1) := x"b";
				for i in 0 to num_val'length/4-1 loop
					if signed(order) > i then
						temp := std_logic_vector(unsigned(temp) rol 4);
						swap(digit, temp(0 to 4-1));
					end if;
				end loop;
			end if;
			wr_data <= temp;
		end process;
	end block;

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
