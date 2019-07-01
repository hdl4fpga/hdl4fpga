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
use hdl4fpga.scopeiopkg.all;

entity scopeio_capture is
	port (
		input_clk     : in  std_logic;
		capture_req   : in  std_logic;
		capture_rdy   : out std_logic;
		input_ena     : in  std_logic := '1';
		input_data    : in  std_logic_vector;
		input_delay   : in  std_logic_vector;

		captured_clk  : in  std_logic;
		captured_addr : in  std_logic_vector;
		captured_data : out std_logic_vector;
		captured_vld  : out std_logic);
end;

architecture beh of scopeio_capture is

	signal capture_addr : unsigned(captured_addr'range);
	signal rd_addr      : unsigned(captured_addr'range);
	signal wr_addr      : unsigned(captured_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(input_data'range);

	signal counter      : unsigned(0 to input_delay'length);

begin

	captured_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if capture_req='0' then
				capture_addr <= resize(unsigned(input_delay) + wr_addr, capture_addr'length);
				counter      <= resize(unsigned(input_delay), counter'length)+(2**input_delay'length-2**captured_addr'length);
			elsif counter(0)='0' then
				if input_ena='1' then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;
	capture_rdy  <= counter(0);
	captured_vld <= setif(counter(0 to input_delay'length-captured_addr'length)=(0 to input_delay'length-captured_addr'length => '1'));

	wr_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_ena='1' then
				wr_addr <= wr_addr + 1;
			end if;
		end if;
	end process;
	wr_ena  <= (not counter(0) or not capture_req) and input_ena;
	rd_addr <= unsigned(captured_addr); -- + capture_addr;

	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => input_clk,
		addra => std_logic_vector(wr_addr),
		wea   => wr_ena,
		dia   => input_data,
		doa   => null_data,

		clkb  => captured_clk,
		addrb => std_logic_vector(rd_addr),
		dib   => null_data,
		dob   => captured_data);

end;
