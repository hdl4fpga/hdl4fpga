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
		capture_start  : in  std_logic;
		capture_finish : out std_logic;
		input_ena      : in  std_logic := '1';
		input_data     : in  std_logic_vector;
		input_delay    : in  std_logic_vector;

		capture_clk    : in  std_logic;
		capture_addr   : in  std_logic_vector;
		capture_data   : out std_logic_vector;
		capture_valid  : inout std_logic);
end;

architecture beh of scopeio_capture is

	constant bram_latency : natural := 2;
	constant bias : natural := (2**input_delay'length-2**capture_addr'length);

	signal base_addr : unsigned(capture_addr'range);
	signal rd_addr   : unsigned(capture_addr'range);
	signal wr_addr   : unsigned(capture_addr'range);
	signal wr_ena    : std_logic;
	signal null_data : std_logic_vector(input_data'range);

	signal counter   : unsigned(0 to input_delay'length);
	signal delay     : unsigned(input_delay'range);
	constant bias1 : natural := (2**delay'length-2**capture_addr'length);
	signal valid     : std_logic;

begin
 
	capture_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if capture_start='0' then
				base_addr <= unsigned(wr_addr);
				counter   <= resize(unsigned(input_delay)+bias+1, counter'length);
				delay     <= resize(unsigned(input_delay), delay'length);
			elsif counter(0)='0' then
				if input_ena='1' then
					counter <= counter + 1;
				end if;
			end if;
		end if;
	end process;
	capture_finish <= counter(0);

	capture_valid_p : process (delay, input_delay, capture_addr, counter)
		variable idelay : unsigned(delay'range);
		variable addr   : unsigned(capture_addr'range);
	begin
		idelay := resize(unsigned(input_delay), idelay'length);
		addr   := resize(unsigned(capture_addr), addr'length);
		valid  <= '0';
		if counter(0)='1' then
			if delay < addr and bias < idelay+addr then
				valid <= '1';
			elsif delay+unsigned(addr) < bias then
				valid <=  '0';
						  -- setif((bias+delay) <= (bias+addr+idelay));
				--and 
						  -- setif((idelay+bias+addr) < (delay+bias+2**capture_addr'length));
--			else
--				valid <= setif(delay <= idelay+addr) and setif(addr < (counter-bias));
			end if;
--			valid <= '1';
--		else
--			if counter(0)='1' then
--				valid <= setif(addr+idelay < 2**input_delay'length);
--			else
--				valid <= setif(addr+idelay < counter);
--			end if;
--			valid <= '0';
		end if;
	end process;

	valid_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to 0 => bram_latency))
	port map (
		clk   => capture_clk,
		di(0) => valid,
		do(0) => capture_valid);

	capture_data <= (0 to 3-1 => '1') & (3 to capture_data'length-1 => not capture_valid);

	wr_addr_p : process (input_clk)
	begin
		if rising_edge(input_clk) then
			if input_ena='1' then
				wr_addr <= wr_addr + 1;
			end if;
		end if;
	end process;
	wr_ena  <= (not counter(0) or not capture_start) and input_ena;
	rd_addr <= unsigned(capture_addr) + base_addr + resize(unsigned(input_delay), capture_addr'length);

--	mem_e : entity hdl4fpga.bram(inference)
--	port map (
--		clka  => input_clk,
--		addra => std_logic_vector(wr_addr),
--		wea   => wr_ena,
--		dia   => input_data,
--		doa   => null_data,
--
--		clkb  => capture_clk,
--		addrb => std_logic_vector(rd_addr),
--		dib   => null_data,
--		dob   => capture_data);

end;
