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

entity so_data is
	generic (
		mem_size : natural := 4*2048*8);
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

architecture def of so_data is

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

	process(so_clk)
		type states is (st_rid, st_len, st_data);
		variable state : states;
		variable cntr  : unsigned(0 to 8);
	begin
		if rising_edge(so_clk) then
			if src_frm='1' then
				if src_irdy='1' then
					case state is
					when st_rid =>
						src_data <= x"ff";
						state := st_len;
						len   := length(8-1 downto 0);
					when st_len =>
						src_data <= std_logic_vector(len);
						cntr  := length(8-1 downto 0);
						state := st_data;
					when st_data
						if cntr(0)='0' then
							cntr := cntr - 1;
						end if;
					end case;
				end if;
			else
				cntr := (others => '0');
			end if;
			src_trdy <= not cntr(0);
		end if;
	end process;

end;
