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
		input_clk    : in  std_logic;
		input_ena    : in  std_logic := '1';
		input_data   : in  std_logic_vector;
		capture_addr : out std_logic_vector;
		capture_data : out std_logic_vector;
		capture_ena  : out std_logic_vector;
		video_clk    : in  std_logic;

end;

architecture beh of scopeio is

	signal wr_clk    : std_logic;
	signal wr_ena    : std_logic;
	signal wr_addr   : std_logic_vector(storage_addr'range);
	signal wr_cntr   : signed(0 to wr_addr'length+1);
	signal wr_data   : std_logic_vector(0 to storage_word'length*inputs-1);

	signal rd_clk    : std_logic;
	signal rd_addr   : std_logic_vector(wr_addr'range);
	signal rd_data   : std_logic_vector(wr_data'range);
	signal free_shot : std_logic;
	signal sync_tf   : std_logic;
	signal hz_delay  : signed(hz_offset'length-1 downto 0);

begin

	wr_clk  <= input_clk;
	wr_ena  <= (not wr_cntr(0) or free_running) and input_ena;
	wr_data <= input_data;

	process(wr_clk)
	begin
		if rising_edge(wr_clk) then
			sync_tf <= trigger_freeze;
			sync_videofrm <= video_vton;
		end if;
	end process;

	hz_delay <= signed(hz_offset);
	rd_clk   <= video_clk;
	gen_addr_p : process (wr_clk)
	begin
		if rising_edge(wr_clk) then

			free_shot <= '0';
			if sync_videofrm='0' and capture_event='0' then
				free_shot <= '1';
			end if;

			if wr_cntr(0)='0' orthen
				if downsample_ena='1' then
					wr_cntr <= wr_cntr - 1;
				end if;
			elsif sync_video='0' and capture_event='1' then
				capture_addr <= std_logic_vector(resize(unsigned(wr_addr), capture_addr'length));
				wr_cntr      <= resize(hz_delay, wr_cntr'length) + (2**wr_addr'length-1);
			end if;

			if input_ena='1' then
				wr_addr <= std_logic_vector(unsigned(wr_addr) + 1);
			end if;

		end if;

	end process;

end;
