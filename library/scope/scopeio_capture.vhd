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
		input_ena     : in  std_logic := '1';
		input_trigger : in  std_logic;
		free_running  : in  std_logic;
		capture_addr  : out std_logic_vector;
		capture_data  : in  std_logic_vector;

		video_clk     : in  std_logic;
		video_addr    : in  std_logic_vector;
		video_data    : out std_logic_vector;
		video_sync    : in  std_logic;
		video_vld     : out std_logic);

end;

architecture beh of scopeio is

	constant delay_bits   : natural := unsigned_num_bits(max_delay-1);
	constant counter_bits : natural := unsigned_num_bits(max_delay+2**storage_addr'length-1);

	signal counter   : unsigned(0 to counter_bits);

	signal wr_ena    : std_logic;
	signal null_data : std_logic_vector(wr_data'range);

begin

	gen_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then

			if video_sync='1' and capture_event='0' then
				free_shot <= '1';
			end if;

			if counter(0)='0' orthen
				if input_ena='1' then
					counter <= counter + 1;
				end if;
			elsif sync_video='0' and capture_event='1' then
				capture_addr <= std_logic_vector(hz_delay(capture_addr'reverse_range) + signed(wr_addr));
				counter      <= resize(signed(delay), counter'length)+(2**counter_bits-2**storage_addr'length);
			end if;
			if counter(1 to counter_bits-storage_addr'length)=(1 to counter_bits-storage_addr'length) then
				video_vld <= '1';
			end if;
			if input_ena='1' then
				wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
			end if;

		end if;

	end process;

	wr_ena <= (not counter(0) or free_running) and input_ena;
	mem_e : entity hdl4fpga.bram(inference)
	port map (
		clka  => input_clk,
		addra => capture_addr,
		wea   => wr_ena,
		dia   => capture_data,
		doa   => null_data,

		clkb  => video_clk,
		addrb => video_addr,
		dib   => null_data,
		dob   => video_data);

	video_vld <= setif(counter(1 to counter_bits-storage_addr'length)=(1 to counter_bits-storage_addr'length => '1'));
end;
