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
		capture_shot   : in  std_logic;
		capture_end    : out std_logic;
		input_dv       : in  std_logic := '1';
		input_data     : in  std_logic_vector;
		input_delay    : in  std_logic_vector;

		capture_clk    : in  std_logic;
		capture_addr   : in  std_logic_vector;
		capture_data   : out std_logic_vector;
		capture_dv     : out std_logic);
end;

architecture beh of scopeio_capture is

	constant delay_size   : natural := 2**input_delay'length;

	constant bram_latency : natural := 2;

	constant capture_size : natural := 2**capture_addr'length;

	signal capture_req : std_logic;

	signal wr_addr : std_logic_vector(capture_addr'range); -- := (others => '0'); -- Debug purpose
	signal wr_ena  : std_logic;
	signal no_data : std_logic_vector(input_data'range);

	signal valid   : std_logic;


begin
 
	valid_b : block
	begin
		capture_valid_p : valid <=
			setif(unsigned(capture_addr) < unsigned(wr_addr));

		valid_e : entity hdl4fpga.align
		generic map (
			n => 1,
			d => (0 to 0 => bram_latency))
		port map (
			clk   => capture_clk,
			di(0) => '1', --valid,
			do(0) => capture_dv);

	--	For debugging
--		debug_b : block
--			signal di : std_logic_vector(capture_data'range);
--		begin
--			di <= (0 to 3-1 => '1') & (3 to capture_data'length-1 => not valid);
--			xxx_e : entity hdl4fpga.align
--			generic map (
--				n => capture_data'length,
--				d => (0 to capture_data'length-1 => bram_latency))
--			port map (
--				clk => capture_clk,
--				di  => di,
--				do  => capture_data);
--		end block;

	end block;


	delay_p : process (input_clk)
		variable cntr : unsigned(input_delay'length downto 0);
	begin
		if rising_edge(input_clk) then
			if input_dv='1' then
				if capture_shot='0' then
					cntr := unsigned(input_delay);
				elsif cntr(cntr'left)='0' then
					cntr := cntr - 1;
				end if;
			end if;
			capture_req <= cntr(0);
		end if;
	end process;


	storage_b : block
		signal capture_req : std_logic;
		signal capture_rdy : std_logic;
	begin

		capture_addr_p : process (input_clk)
			variable cntr : signed(capture_addr'length downto 0); -- := (others => '1'); -- Debug purpose
		begin
			if rising_edge(input_clk) then
				if input_dv='1' then
					if capture_req='0' then
						cntr  := to_signed(-capture_size, cntr'length);
					elsif cntr(cntr'left)='1' then
						cntr := cntr + 1;
					end if;
				end if;
				wr_addr <= std_logic_vector(cntr(wr_addr'range));
				wr_ena  <= cntr(capture_addr'length);
			end if;
		end process;
		capture_rdy <= wr_ena;

		mem_e : entity hdl4fpga.bram(inference)
		port map (
			clka  => input_clk,
			addra => wr_addr,
			wea   => wr_ena,
			dia   => input_data,
			doa   => no_data,

			clkb  => capture_clk,
			addrb => capture_addr,
			dib   => no_data,
			dob   => capture_data);

	end block;
end;
