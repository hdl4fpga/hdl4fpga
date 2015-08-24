--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                    --
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

library hdl4fpga;
use hdl4fpga.std.all;

entity ddrio is
	generic (
		fifo_size  : natural := 5;
		bank_size  : natural := 2;
		addr_size  : natural := 13;
		col_size   : natural := 6);
	port (
		sys_clk : in  std_logic;
		sys_ini : in  std_logic;
		sys_eoc : out std_logic;

		sys_addr : in std_logic_vector(0 to (bank_size+1+addr_size+1+col_size+1)-1);

		sys_brst_req : in  std_logic;

		ddrs_ref_req : in  std_logic;
		ddrs_cmd_req : out std_logic;
		ddrs_cmd_rdy : in  std_logic;
		ddrs_ba  : out std_logic_vector(bank_size-1 downto 0);
		ddrs_a   : out std_logic_vector(addr_size-1 downto 0);
		ddrs_act : in  std_logic;
		ddrs_cas : in  std_logic;
		ddrs_pre : in  std_logic;
		tp : out nibble_vector(0 to 7-1));
end;


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of ddrio is

	signal sys_ba_cnt : std_logic_vector(0 to bank_size);
	signal sys_ba_ena : std_logic;
	signal sys_ba_se  : std_logic;

	signal sys_row_cnt : std_logic_vector(0 to addr_size);
	signal sys_row_ena : std_logic;
	signal sys_row_se  : std_logic;

	signal sys_col_cnt : std_logic_vector(0 to col_size);
	signal sys_col_ena : std_logic;

	signal sys_ena : std_logic;

	signal cmd_req : std_logic;
	signal sys_ba_dat  : std_logic_vector(sys_ba_cnt'range);
	signal sys_row_dat : std_logic_vector(sys_row_cnt'range);
	signal sys_col_dat : std_logic_vector(sys_col_cnt'range);
begin
	process (sys_addr)
		variable addr : std_logic_vector(sys_addr'range);
	begin
		addr := sys_addr;
		sys_ba_dat  <= addr(sys_ba_dat'range);
		addr := addr sll sys_ba_dat'length;
		sys_row_dat <= addr(sys_row_dat'range);
		addr := addr sll sys_row_dat'length;
		sys_col_dat <= addr(sys_col_dat'range);
	end process;

	ddrs_ba <= sys_ba_cnt(1 to sys_ba_cnt'right);
	ddrs_a <=
		sys_row_cnt(1 to sys_row_cnt'right) when ddrs_act='1' else
		resize(sys_col_cnt(1 to sys_col_cnt'right), ddrs_a'length) sll 3;

	sys_ena <= ddrs_cas;
	ddrs_cmd_req <= cmd_req and not sys_col_cnt(0);
	
	-- End Of Count --
	------------------
	
	process (sys_clk)
		variable eoc : std_logic;
	begin
		if rising_edge(sys_clk) then
			if sys_ini='1' then
				eoc := '0';
			elsif eoc='0' then
				eoc := sys_ba_cnt(0);
			end if;
			sys_eoc <= eoc;
		end if;
	end process;

	-- Bank Address --
	------------------
	
	process (sys_clk)	
	begin
		if rising_edge(sys_clk) then

			sys_ba_cnt <= dec (
				cntr => sys_ba_cnt,
				ena  => sys_ini or sys_ba_cnt(0) or (ddrs_act and sys_ba_ena),
				load => sys_ini or sys_ba_cnt(0),
				data => sys_ba_dat);

			if sys_ba_ena='0' then
				sys_ba_ena <= sys_row_cnt(0);
			elsif ddrs_act='1' then
				sys_ba_ena <= '0';
			end if;

		end if;
	end process;

	-- Row Address --
	-----------------

	process (sys_clk)
		variable data : std_logic_vector(sys_row_dat'range);
	begin
		if rising_edge(sys_clk) then

			if sys_ini='0' then
				data := to_unsigned(2**addr_size-1, sys_row_dat);
			else
				data := sys_row_dat;
			end if;

			sys_row_cnt <= dec (
				cntr => sys_row_cnt,
				ena  => sys_ini or sys_col_cnt(0) or sys_row_cnt(0),
				load => sys_ini or sys_row_cnt(0),
				data => data);

		end if;
	end process;

	-- Column Address --
	--------------------

	process (sys_clk)
		variable data : std_logic_vector(sys_col_dat'range);
	begin
		if rising_edge(sys_clk) then

			if sys_ini='0' then
				data := to_unsigned(2**col_size-1, sys_col_dat);
			else
				data := sys_col_dat;
			end if;

			sys_col_cnt <= dec (
				cntr => sys_col_cnt,
				ena  => sys_ini or sys_col_cnt(0) or sys_ena,
				load => sys_ini or sys_col_cnt(0),
				data => data);

		end if;
	end process;

	process (sys_clk)
	begin
		if rising_edge(sys_clk) then
			if sys_ini='1'then
				cmd_req <= '0';
			elsif cmd_req='0' then
				if ddrs_cmd_rdy='1' then
					if sys_brst_req='1' then
						cmd_req <= '1';
					end if;
				end if;
			elsif ddrs_ref_req='1' then
				cmd_req <= '0';
			elsif sys_brst_req='0' then
				cmd_req <= '0';
			elsif sys_col_cnt(0)='1' then
				cmd_req <= '0';
			end if;
		end if;
	end process;

	-----------
	-- DEBUG --
	-----------

	tp(0 to 1-1) <= to_nibble(sys_ba_cnt);
	tp(1 to 5-1) <= to_nibble(sys_row_cnt);
	tp(5 to 7-1) <= to_nibble(sys_col_cnt);
end;
