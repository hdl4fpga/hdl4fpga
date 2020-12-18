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

entity sio_buffer is
	generic (
		mem_size : natural := 2048*8);
	port (
		si_clk   : in  std_logic;

		si_frm   : in  std_logic := '0';
		si_irdy  : in  std_logic := '0';
		si_trdy  : buffer std_logic;
		si_data  : in  std_logic_vector;

		rollback : in  std_logic;
		commit   : in  std_logic;
		overflow : out std_logic;

		so_clk   : in  std_logic;
		so_frm   : buffer std_logic;
		so_irdy  : out std_logic;
		so_trdy  : in  std_logic := '1';
		so_data  : out std_logic_vector);
end;

architecture def of sio_buffer is

	signal des_data : std_logic_vector(so_data'range);

	constant addr_length : natural := unsigned_num_bits(mem_size/so_data'length-1);
	subtype addr_range is natural range 1 to addr_length;

	signal wr_ptr    : unsigned(0 to addr_length) := (others => '0');
	signal wr_cntr   : unsigned(0 to addr_length) := (others => '0');
	signal rd_cntr   : unsigned(0 to addr_length) := (others => '0');

	signal des_irdy  : std_logic;
	signal so_irdy1 : std_logic;

begin

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => si_clk,
		serdes_frm => si_frm,
		ser_irdy   => si_irdy,
		ser_data   => si_data,

		des_irdy   => des_irdy,
		des_data   => des_data);

	si_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));

	process (si_clk)
	begin
		if rising_edge(si_clk) then
			if commit='1' then
				wr_ptr   <= wr_cntr;
				overflow <= '0';
			elsif rollback='1' then
				wr_cntr   <= wr_ptr;
				overflow <= '0';
			elsif si_trdy='1' then
				if si_irdy='1' then
					if des_irdy='1' then
						wr_cntr <= wr_cntr + 1;
					end if;
				end if;
				overflow <= '0';
			elsif des_irdy='1' then
				overflow <= '1';
			end if;

		end if;
	end process;

	mem_e : entity hdl4fpga.dpram(def)
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => true)
	port map (
		wr_clk  => si_clk,
		wr_ena  => des_irdy,
		wr_addr => std_logic_vector(wr_cntr(addr_range)),
		wr_data => des_data, 

		rd_clk  => so_clk,
		rd_addr => std_logic_vector(rd_cntr(addr_range)),
		rd_data => so_data);

	so_irdy1 <= setif(wr_ptr /= rd_cntr);
	process(so_clk)
	begin
		if rising_edge(so_clk) then
			so_frm <= so_irdy1;
			if so_irdy1='1' and so_trdy='1' then
				rd_cntr <= rd_cntr + 1;
			end if;
		end if;
	end process;
	so_irdy <= so_frm;

end;
