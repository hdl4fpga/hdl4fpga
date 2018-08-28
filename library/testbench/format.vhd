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
	signal wr_data : std_logic_vector(0 to 6*4-1);
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
	bin_di <= word2byte(std_logic_vector(unsigned'(x"ffff") ror 4), not std_logic_vector(cntr(1 to 2)));

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
		constant order : std_logic_vector(0 to 2) := "011";
		signal num_dv  : std_logic;
		signal num_val : std_logic_vector(0 to wr_data'length-1);
		signal num_lft : std_logic_vector(bcd_lft'range);
		signal num_rgt : std_logic_vector(bcd_rgt'range);
	begin

		function bcd_format (
			constant value : std_logic_vector;
			constant right : std_logic_vector;
			constant left  : std_logic_vector;
			constant point : std_logic_vector;
			constant align : std_logic := '0') 
			return std_logic_vector is
			variable temp  : std_logic_vector(value'length-1 downto 0);
			variable digit : std_logic_vector(4-1 downto 0);

			constant dot   := std_logic_vector(digit'range) := x"b";
			constant space := std_logic_vector(digit'range) := x"f";

		begin

			temp  := value;
			digit := dot;

			if left/=right or temp(digit'range)/=x"0" then

				for i in 0 to value'length/4-1 loop
					if signed(point) > i then
						if signed(left) > signed(right)+i then
							temp := std_logic_vector(unsigned(temp) ror 4);
						else 
							temp := std_logic_vector(unsigned(temp) ror 4);
							temp(digit'range) := x"0";
						end if;
					end if;
				end loop;

				if to_integer(signed(point))/=0 then
					temp := std_logic_vector(unsigned(temp) rol 4);
					swap(digit, temp(digit'range));
				end if;

				for i in 0 to value'length/4-1 loop
					if signed(point) > i then
						temp := std_logic_vector(unsigned(temp) rol 4);
						swap(digit, temp(digit'range));
					end if;
				end loop;

			end if;

			if align='1' then
				for i in 0 to value'length/4-1 loop
					temp := std_logic_vector(unsigned(temp) rol 4);
					if temp(digit'range) /= space then
						temp := std_logic_vector(unsigned(temp) ror 4);
						exit;
					end if;
				end loop;
			end if;

			return temp;
		end;

	wr_ena  <= num_dv;
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
