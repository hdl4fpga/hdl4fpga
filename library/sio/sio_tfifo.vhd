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

entity sio_buff is
	generic (
		mem_size  : natural := 2048*8);
	port (
		sio_clk   : in  std_logic;

		si_frm    : in  std_logic := '0';
		si_irdy   : in  std_logic := '0';
		si_trdy   : buffer std_logic := '0';
		si_data   : in  std_logic_vector;

		fifo_updt : in  std_logic;
		fifo_cmmt : in  std_logic;
		fifo_ovfl : out std_logic;

		so_frm    : out std_logic;
		so_irdy   : out std_logic;
		so_trdy   : in  std_logic := '1';
		so_data   : out std_logic_vector);
end;

architecture struct of sio_udp is

	signal des_data : std_logic_vector(so_data'range);

	constant addr_length : natural := unsigned_num_bits(mem_size/so_data'length-1);
	subtype addr_range is natural range 1 to addr_length;

	signal wr_ptr    : unsigned(0 to addr_length) := (others => '0');
	signal wr_cntr   : unsigned(0 to addr_length) := (others => '0');
	signal rd_cntr   : unsigned(0 to addr_length) := (others => '0');

	signal src_trdy  : std_logic;
	signal des_irdy  : std_logic;
	signal dst_irdy  : std_logic;
	signal dst_irdy1 : std_logic;

begin

	serdes_e : entity hdl4fpga.serdes
	port map (
		serdes_clk => si_clk,
		serdes_frm => si_frm,
		ser_irdy   => si_irdy,
		ser_data   => si_data,

		des_irdy   => des_irdy,
		des_data   => des_data);

	src_trdy <= setif(wr_cntr(addr_range) /= rd_cntr(addr_range) or wr_cntr(0) = rd_cntr(0));

	process (mii_txc)
	begin
		if rising_edge(mii_txc) then
			if fifo_updt='1' then
				if fifo_cmmt='0' then
					wr_cntr <= wr_ptr;
				else
					wr_ptr <= wr_cntr;
				end if;
			elsif ser_irdy='1' then
				if src_trdy='1' then
					if des_irdy='1' then
						wr_cntr <= wr_cntr + 1;
					end if;
				end if;
			end if;

			if fifo_updt='1' then
				fifo_ovfl <= '0';
			elsif src_trdy='0' and des_irdy='1' then
				fifo_ovfl <= '1';
			end if;

		end if;
	end process;

	mem_e : entity hdl4fpga.dpram(def)
	generic map (
		synchronous_rdaddr => false,
		synchronous_rddata => true)
	port map (
		wr_clk  => mii_txc,
		wr_ena  => des_irdy,
		wr_addr => std_logic_vector(wr_cntr(addr_range)),
		wr_data => des_data, 

		rd_clk  => sio_clk,
		rd_addr => std_logic_vector(rd_cntr(addr_range)),
		rd_data => so_data);

	dst_irdy1 <= setif(wr_ptr /= rd_cntr);
	process(sio_clk)
	begin
		if rising_edge(sio_clk) then
			so_frm <= dst_irdy1;
			if dst_irdy1='1' and so_trdy='1' then
				rd_cntr <= rd_cntr + 1;
			end if;
		end if;
	end process;
	so_irdy <= '1';

end;
