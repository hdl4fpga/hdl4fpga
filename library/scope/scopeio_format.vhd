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
		binary : in  std_logic_vector);
end;

architecture def of scopeio_format is

	signal bin_ena : std_logic := '1';
    signal bin_dv  : std_logic;
    signal bin_di  : std_logic_vector(0 to 4-1);

    signal bcd_rdy : std_logic := '1';
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

	xxx_b : block
		signal load : std_logic := '1';
		constant num_of_hexdgt : natural := binary'length/bin_di'length;

		signal sel : std_logic_vector(0 to unsigned_num_bits(num_of_hexdgt-1)-1);
	begin
		process (clk)
			variable cntr : unsigned(0 to sel'length);
		begin
			if rising_edge(clk) then
				if load='1' then
					bin_ena <= '0';
					cntr := to_unsigned(num_of_hexdgt-2, cntr'length);
				elsif bcd_rdy='1' then
					if cntr(0)='1' then
						cntr := to_unsigned(num_of_hexdgt-2, cntr'length);
						bin_ena <= '0';
					elsif cntr(0)='0' then
						cntr  := cntr - 1;
					end if;
				else
					bin_ena <= '1';
				end if;
				load <= '0';
				sel <= std_logic_vector(cntr(1 to cntr'right));
			end if;
		end process;


	process (binary, sel)
		variable value : std_logic_vector(bin_di'length*2**sel'length-1 downto 0);
	begin
		value  := (others => '-');
		value(binary'length-1 downto 0) := binary;
		value  := std_logic_vector(unsigned(value) ror bin_di'length);
		bin_di <= word2byte(std_logic_vector(value), not std_logic_vector(sel));
	end process;

	end block;

	scopeioftod_e : entity hdl4fpga.scopeio_ftod
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
	end block;

	wr_ena  <= not bin_ena;
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
