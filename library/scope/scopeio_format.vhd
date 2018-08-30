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

entity scopeio_format is
	port (
		clk    : in  std_logic;
		binary : in  std_logic_vector;
end;

architecture def of scopeio_format is
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


	signal wr_ena  : std_logic;
	signal wr_addr : std_logic_vector(0 to 3-1);
	signal rd_addr : std_logic_vector(wr_addr'range);
	signal wr_data : std_logic_vector(0 to 6*4-1);
	signal rd_data : std_logic_vector(wr_data'range);
	

begin

	process (rst, clk, bcd_rdy)
		variable cntr  : unsigned(0 to unsigned_num_bits(binary'length/bin_di'length-1));
		variable value : unsigned(0 to bin_di'length*2**(cntr'length-1)-1);
	begin
		if rising_edge(clk) then
			if bcd_rdy='1' then
				if cntr(0)='1' then
					cntr   := to_unsigned(binary'length/bin_di'length-2, cntr'length);
				elsif cntr(0)='0' then
					cntr   := cntr - 1;
					value  := resize(unsigned(binary), value'length);
					value  := value ror bin_di'length;
					bin_di <= word2byte(value, not cntr(1 to cntr'right));
				end if;
			end if;
		end if;
	end process;

	bin_ena <= not (cntr(0) and bcd_rdy) and not rst;

	du: entity hdl4fpga.scopeio_ftod
	port map (
		clk     => clk,
		bin_ena => bin_ena,
		bin_dv  => bin_dv,
		bin_di  => bin_di,
                           
		bcd_lft => bcd_lft,
		bcd_rgt => bcd_rgt,
		bcd_rdy => bcd_rdy,
		bcd_do  => bcd_do);

	format_b : block
		signal dv      : std_logic;
		signal value   : std_logic_vector(0 to wr_data'length-1);
		signal aligned : std_logic_vector(0 to wr_data'length-1);
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


				dv    <= bcd_rdy and cntr(0);
				value <= std_logic_vector(val);
			end if;
		end process;

		alignbcd_e  : entity hdl4fpga.align_bcd
		port map (
			value  => value,
			align  => aligned);
		
		formatbcd_e : entity hdl4fpga.format_bcd
		port map (
			value  => aligned,
			point  => "110",
			format => wr_data);
		wr_ena <= dv;
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
