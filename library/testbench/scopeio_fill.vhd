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

architecture scopeio_fill of testbench is
	signal rst     : std_logic := '1';
	signal clk     : std_logic := '0';

	signal fill_req : std_logic;
	signal fill_rdy : std_logic;
	signal point    : std_logic_vector(0 to 3-1) := "111";

	signal bin_dv   : std_logic;
	signal bin_val  : std_logic_vector(4*4-1 downto 0);
	signal bcd_dv   : std_logic;
	signal bcd_val  : std_logic_vector(0 to 4*8-1);

	signal wr_addr : std_logic_vector(0 to 6-1);
	signal rd_addr : std_logic_vector(wr_addr'range);
	signal rd_data : std_logic_vector(bcd_val'range);

begin

	clk <= not clk  after  5 ns;

	grnt_p : block
		port (
			clk : in  std_logic;
			req : in  std_logic_vector;
			rdy : out std_logic_vector);

		port map (
			clk => clk,
			dev_req => (0 => ),
			dev_rdy => (0 => ));

		signal gnt : std_logic_vector(0 to 1);
		signal req : std_logic;

	begin

		process(clk)
		begin
			if rising_edge(clk) then
				for i in req'range loop
					if gnt="0" then
						if req(i)='1' then
							gnt <= i;
						end if;
					elsif rdy='1' then
						gnt <= 0;
					end if;
				end loop
			end if;
		end process;

		process (fill_rdy, gnt)
			variable rdy : std_logic_vector(0 to dev'rdy'range);
		begin
			for i in 1 to dev_rdy'
		end process;

		fill_req <= word2byte("0" & dev_req, gnt);
		dev_rdy  <= demux(gnt, fill_rdy)(1 to dev_rdy'length);
	end block;

	process(clk)
		variable cntr : unsigned(bin_val'range);
	begin
		if rising_edge(clk) then
			if fill_req='0' then
				cntr := (others => '0');
			elsif fill_rdy='0' then
				if bin_dv='1' then
					cntr := cntr + 40;
				end if;
			end if;
			bin_val <= std_logic_vector(cntr);
		end if;
	end process;

	du: entity hdl4fpga.scopeio_fill
	port map (
		clk        => clk,
		fill_req   => fill_req,
		fill_rdy   => fill_rdy,
		point      => point,
		length     => b"1000",
		element    => wr_addr,
		bin_dv     => bin_dv,
		bin_val    => bin_val,
		bcd_dv     => bcd_dv,
		bcd_val    => bcd_val);

	ram_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_ena  => bcd_dv,
		wr_addr => wr_addr,
		wr_data => bcd_val,
		rd_addr => rd_addr,
		rd_data => rd_data);
end;
