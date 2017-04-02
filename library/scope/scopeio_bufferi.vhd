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

entity scopeio_bufferi is
	generic (
		FIFO_SIZE : natural := 8);
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

architecture def of scopeio_bufferi is
	signal wr_addr      : std_logic_vector(0 to FIFO_SIZE-1);
	signal rd_addr      : std_logic_vector(0 to FIFO_SIZE-1);
	signal rd_ena       : std_logic;
	signal dummy        : std_logic_vector(output_data'range);
	signal output_flush : std_logic;
	signal output_rst   : std_logic;
begin

	process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_req='0' then
				wr_addr <= (others => '0');
			else
				wr_addr <= inc(gray(wr_addr));
			end if;
		end if;
	end process;

	process (input_req, output_clk)
	begin
		if input_req='0' then
			output_rst <= '1';
		elsif rising_edge(output_clk) then
			output_rst <= '0';
		end if;
	end process;

	process (output_clk)
		variable flush : unsigned(0 to 3-1);
	begin
		if rising_edge(output_clk) then
			if output_rst='1' then
				rd_addr <= (others => '0');
				flush   := to_unsigned(1,flush'length);
			elsif output_flush='1' then
				rd_addr <= inc(gray(rd_addr));
				flush   := flush - 1;
			elsif output_req='1' then
				rd_addr <= inc(gray(rd_addr));
			end if;
			output_flush <= not flush(0);
		end if;
	end process;

	rd_ena <= output_req or output_flush;
	fifo_e : entity hdl4fpga.bram
	port map (
		clka  => input_clk,
		wea   => '1',
		addra => wr_addr, 
		dia   => input_data,
		doa   => dummy,

		clkb  => output_clk,
		enab  => rd_ena,
		web   => '0',
		addrb => rd_addr, 
		dib   => input_data, 
		dob   => output_data);

	process (output_rst, output_clk)
	begin
        if output_rst='1' then
            output_rdy <= '0';
		elsif rising_edge(output_clk) then
			output_rdy <= setif(
				(inc(gray(rd_addr(0 to 1))) /= wr_addr(0 to 1)) and
				(         rd_addr(0 to 1)   /= wr_addr(0 to 1)));
		end if;
	end process;

end;
