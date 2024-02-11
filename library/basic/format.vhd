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
use hdl4fpga.base.all;

entity format is
	generic (
		bcd_width  : natural);
	port (
		tab  : in  std_logic_vector := to_ascii("0123456789 +-");
		clk  : in  std_logic;
		frm  : in  std_logic;
		irdy : in  std_logic := '1';
		trdy : buffer std_logic := '1';
		neg  : in  std_logic;
		sign : in  std_logic;
		bcd  : in  std_logic_vector;
		code : out std_logic_vector);

	constant bcd_length : natural := 4;
	constant bcd_digits : natural := 1;
	constant blank      : natural := 10;
	constant plus       : natural := 11;
	constant minus      : natural := 12;

end;

-- Combinatorial version
-- https://github.com/hdl4fpga/hdl4fpga/blob/62b576a8d626e379257136259202cbcdf41c3a45/library/basic/format.vhd#L24

architecture def of format is
	constant addr_size : natural := unsigned_num_bits(bcd_width/bcd_digits-1);
	signal bcd_wraddr  : std_logic_vector(1 to addr_size);
	signal bcd_wrdata  : std_logic_vector(bcd'range);
	signal bcd_rdaddr  : std_logic_vector(1 to addr_size);
	signal bcd_rddata  : std_logic_vector(bcd'range);

	signal code_req    : std_logic;
	signal code_rdy    : std_logic;

	signal code_wraddr : std_logic_vector(1 to addr_size);
	signal code_wrdata : std_logic_vector(code'range);
	signal code_rdaddr : std_logic_vector(1 to addr_size);
	signal code_rddata : std_logic_vector(code'range);
begin

	bcdmem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => bcd_wraddr,
		wr_data => bcd_wrdata,
		rd_addr => bcd_rdaddr,
		rd_data => bcd_rddata);

	codemem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => code_wraddr,
		wr_data => code_wrdata,
		rd_addr => code_rdaddr,
		rd_data => code_rddata);

	bcd_write_p : process (clk)
		type states is (s_nozero);
		variable state : states;
		variable bcd_wrcntr : unsigned(0 to addr_size);
	begin
		if rising_edge(clk) then
			if frm='1' then
				if irdy='1' then
					bcd_wrcntr := bcd_wrcntr + 1;
					if bcd/=x"0" then
					end if;
					-- case state is
					-- when =>
						-- := bcd_wrcntr;
					-- when s_nozero =>
					-- end case;
				end if;
			else
				bcd_wrcntr := (others => '1');
			end if;
			bcd_wraddr <= std_logic_vector(bcd_wrcntr);
		end if;
	end process;

	bcd_read_p : process (clk)
		type states is (s_blank, s_sign, s_blanked);
		variable state : states;

		variable bcd_rdcntr : unsigned(0 to addr_size);
	begin
		if rising_edge(clk) then
			if (to_bit(code_rdy) xor to_bit(code_req))='1' then

				case state is
				when s_sign =>
				when others =>
					if bcd_rdcntr(0)='0' then
						bcd_rdcntr := bcd_rdcntr - 1;
					else
						code_rdy <= to_stdulogic(to_bit(code_req));
					end if;
				end case;

				case state is
				when s_blank =>
					if bcd_rddata=x"0" then
						code_wrdata <= multiplex(tab, blank, code'length);
						code_wraddr <= std_logic_vector(bcd_rdaddr);
						bcd_rdaddr  <= std_logic_vector(bcd_rdcntr);
					elsif neg='1' then
						code_wrdata <= multiplex(tab, minus, code'length);
						state := s_sign;
					elsif sign='1' then
						code_wrdata <= multiplex(tab, plus, code'length);
						state := s_sign;
					end if;
				when s_sign =>
					code_wrdata <= multiplex(tab, bcd_rddata, code'length);
					code_wraddr <= std_logic_vector(bcd_rdaddr);
					bcd_rdaddr  <= std_logic_vector(bcd_rdcntr);
					state := s_blanked;
				when s_blanked =>
					code_wrdata <= multiplex(tab, bcd_rddata, code'length);
					code_wraddr <= std_logic_vector(bcd_rdaddr);
					bcd_rdaddr  <= std_logic_vector(bcd_rdcntr);
				end case;

			else
				bcd_rdcntr := unsigned(bcd_wraddr);
				bcd_rdaddr <= std_logic_vector(bcd_rdcntr);
			end if;
		else
			state := s_blank;
		end if;
	end process;

end;