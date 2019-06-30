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
		input_clk      : in  std_logic;
		input_ena      : in  std_logic := '1';
		input_trigger  : in  std_logic;
		input_data     : in  std_logic_vector;
		input_delay    : in  std_logic_vector;
		input_captured : out std_logic;

		capture_clk    : in  std_logic;
		capture_addr   : in  std_logic_vector;
		capture_data   : out std_logic_vector;
		capture_vld    : out std_logic);

end;

architecture beh of scopeio_capture is

	constant counter_bits : natural := unsigned_num_bits(input_delay'length-1);

	signal trigger_addr : unsigned(capture_addr'range);
	signal rd_addr      : unsigned(capture_addr'range);
	signal wr_addr      : unsigned(capture_addr'range);
	signal wr_ena       : std_logic;
	signal null_data    : std_logic_vector(input_data'range);

	signal counter      : signed(0 to counter_bits-1);

begin

	capture_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_trigger='1' then
				trigger_addr <= unsigned(input_delay) + wr_addr;
				counter      <= resize(signed(input_delay), counter'length)+(2**counter_bits-2**capture_addr'length);
			elsif counter(0)='0' then
				if input_ena='1' then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;

	wr_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_ena='1' then
				wr_addr <= wr_addr + 1;
			end if;
		end if;
	end process;
	wr_ena  <= (not counter(0) or input_trigger) and input_ena;
	rd_addr <= unsigned(capture_addr) + trigger_addr;

	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => input_clk,
		addra => std_logic_vector(wr_addr),
		wea   => wr_ena,
		dia   => input_data,
		doa   => null_data,

		clkb  => capture_clk,
		addrb => std_logic_vector(rd_addr),
		dib   => null_data,
		dob   => capture_data);

	input_captured <= counter(0);
	capture_vld    <= setif(counter(0 to counter_bits-capture_addr'length)=(0 to counter_bits-capture_addr'length => '1'));
end;
