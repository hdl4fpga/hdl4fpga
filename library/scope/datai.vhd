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

entity datai is
	generic (
		FIFO_SIZE : natural := 8;
		BUFFERED_OUTPUT : boolean := TRUE);
	port (
		input_clk   : in std_logic;
		input_data  : in std_logic_vector;
		input_req   : in std_logic;

		output_clk  : in std_logic;
		output_rdy  : out std_logic;
		output_req  : in std_logic;
		output_data : out std_logic_vector);
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture def of datai is
	signal wr_addr    : std_logic_vector(0 to FIFO_SIZE-1);
	signal rd_addr    : std_logic_vector(0 to FIFO_SIZE-1);
	signal rd_data    : std_logic_vector(output_data'range);
	signal rd_ena     : std_logic;
	signal output_flush : std_logic;
	signal output_rst : std_logic;
begin

	process (input_clk)
		variable flush_cycles : unsigned(0 to 3-1);
	begin
		if rising_edge(input_clk) then
			if input_req='0' then
				wr_addr <= (others => '0');
				if not BUFFERED_OUTPUT then
					flush_cycles := to_unsigned(0,flush_cycles'length);
				else
					flush_cycles := to_unsigned(3,flush_cycles'length);
				end if;
			else
				if output_rst='1' then
					flush_cycles := flush_cycles - 1;
				end if;
				wr_addr <= inc(gray(wr_addr));
			end if;
			output_rst <= not flush_cycles(0);
		end if;
	end process;

	process (output_clk)
		variable flush_cycles : unsigned(0 to 2-1);
		variable rst : std_logic;
		variable sync_rst : std_logic;
	begin
		if rising_edge(output_clk) then
			if rst='1' then
				rd_addr <= (others => '0');
				if not BUFFERED_OUTPUT then
					flush_cycles := to_unsigned(0,flush_cycles'length);
				else
					flush_cycles := to_unsigned(0,flush_cycles'length);
				end if;
			elsif output_flush='1' then
				rd_addr <= inc(gray(rd_addr));
				flush_cycles := flush_cycles - 1;
			elsif output_req='1' then
				rd_addr <= inc(gray(rd_addr));
			end if;
			output_flush <= not flush_cycles(0);
			rst := sync_rst;
			sync_rst := output_rst;
		end if;
	end process;

	rd_ena <= output_req or output_flush;
	fifo_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => input_clk,
		wr_addr => wr_addr, 
		wr_data => input_data,

		rd_addr => rd_addr,
		rd_data => rd_data);

	reg_output_e : entity hdl4fpga.align
	generic map (
		n => input_data'length,
		d => (1 to input_data'length => 2))
	port map (
		clk => output_clk,
		ena => rd_ena,
		di  => rd_data,
		do  => output_data);
	
--	process (output_clk, rd_data)
--	begin
--		if BUFFERED_OUTPUT then	
--			if rising_edge(output_clk) then
--				if rd_ena='1' then
--					output_data <= rd_data;
--				end if;
--			end if;
--		else
--			output_data <= rd_data;
--		end if;
--	end process;

	process (output_clk)
	begin
		if rising_edge(output_clk) then
			output_rdy <= setif(
				(inc(gray((rd_addr(0 to 1)))) /= wr_addr(0 to 1)) and
				(wr_addr(0 to 1) /= rd_addr(0 to 1)));
		end if;
	end process;

end;
