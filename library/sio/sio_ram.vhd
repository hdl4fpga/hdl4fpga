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

entity sio_ram is
	generic (
		mem_data : std_logic_vector := (0 to 0 => '-');
		mem_size : natural := 0);
    port (
		si_clk   : in  std_logic;
        si_frm   : in  std_logic;
        si_irdy  : in  std_logic;
        si_trdy  : out std_logic;
        si_data  : in  std_logic_vector;

		so_clk   : in  std_logic;
        so_frm   : in  std_logic;
        so_irdy  : in  std_logic;
        so_trdy  : out std_logic;
		so_end   : out std_logic;
        so_data  : out std_logic_vector);
end;

architecture def of sio_ram is
	constant mem_length  : natural := setif(mem_size=0, mem_data'length, mem_size)/si_data'length;
	constant addr_length : natural := unsigned_num_bits(mem_length-1);
	subtype addr_range is natural range 1 to addr_length;

	signal wr_addr : unsigned(0 to addr_length);
	signal wr_ena  : std_logic;
	signal rd_addr : unsigned(0 to addr_length);
	signal len     : unsigned(0 to addr_length);

begin

	assert so_data'length=si_data'length
	report "so_data and si_data have different length"
	severity FAILURE;

	assert mem_length > 0
	report "mem_length should be greater than 0"
	severity FAILURE;

	process (si_frm, si_irdy, si_clk)
		variable addr : unsigned(0 to addr_length);
	begin
		if rising_edge(si_clk) then
			if si_frm='0' then
				addr := (others => '0');
			elsif si_irdy='1' then 
				if addr(0)='0' then
					addr := addr + 1;
					len  <= addr;
				end if;
			end if;
			wr_addr <= addr;
		end if;
		wr_ena <= not addr(0) and si_frm and si_irdy;
	end process;

	mem_e : entity hdl4fpga.dpram 
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => false,
		bitrom => mem_data)
	port map (
		wr_clk  => si_clk,
		wr_ena  => wr_ena,
		wr_addr => std_logic_vector(wr_addr(addr_range)),
		wr_data => si_data,

		rd_clk  => so_clk,
		rd_addr => std_logic_vector(rd_addr(addr_range)),
		rd_data => so_data);

	process(so_clk)
	begin
		if rising_edge(so_clk) then
			if so_frm='0' then
				rd_addr <= (others => '0');
			elsif so_irdy='1' then
				if rd_addr < len then
					rd_addr <= rd_addr + 1;
				end if;
			end if;
		end if;
	end process;

	so_trdy <= setif(rd_addr < len);
	so_end  <= setif(rd_addr = len);

end;
