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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.base.all;

architecture format_tb of testbench is
	constant bcd_length : natural := 4;
	constant bcd_width  : natural := 8;
	constant bcd_digits : natural := 1;
	constant bin_digits : natural := 3;

	signal clk  : std_logic := '0';
	signal dbdbbl_req  : std_logic := '0';
	signal dbdbbl_rdy  : std_logic := '1';
	signal format_req  : std_logic := '0';
	signal format_rdy  : std_logic := '1';
	signal bin2bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal frm  : std_logic;
	signal trdy : std_logic;

	signal code_frm : std_logic;
	signal code : std_logic_vector(0 to 8-1);
	shared variable xxx : unsigned(0 to 8*8-1);
begin

	clk <= not clk after 1 ns;
	process (clk)
	begin
		if rising_edge(clk) then
			if dbdbbl_req='0' then
				xxx := unsigned(to_ascii("        "));
				dbdbbl_req <= '1';
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if code_frm='1' then
				xxx(0 to 8-1) := unsigned(code);
				xxx := xxx rol 8;
			end if;
		end if;
	end process;

	-- dbdbbl_req <= not to_stdulogic(to_bit(dbdbbl_rdy));

	dbdbbl_seq_e : entity hdl4fpga.dbdbbl_seq
	generic map (
		bcd_width  => bcd_width,
		bin_digits => bin_digits,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		req => dbdbbl_req,
		rdy => dbdbbl_rdy,
		bin => std_logic_vector(to_unsigned(4567,15)), -- b"1001110",
		bcd_irdy => frm,
		bcd_trdy => trdy,
		bcd => bin2bcd);

	lifo_b : block
		generic (
			size : natural := 16);
		port (
			clk       : in  std_logic;
			push_irdy : in  std_logic;
			push_data : in  std_logic_vector;
			pop_irdy  : in  std_logic;
			pop_data  : out  std_logic_vector);
		port map (
			clk       => clk,
			push_irdy => '1',
			push_data => bin2bcd,
			pop_irdy => '1',
			pop_data  => bin2bcd);

		constant addr_size : natural := unsigned_num_bits(size-1);
		signal wr_addr : std_logic_vector(0 to addr_size-1);
		signal rd_addr : std_logic_vector(0 to addr_size-1);
		signal sk_ptr  : unsigned(0 to addr_size-1);

	begin

		wr_addr <= std_logic_vector(sk_ptr + 1);
		rd_addr <= std_logic_vector(sk_ptr);
    	mem_e : entity hdl4fpga.dpram
    	port map (
    		wr_clk  => clk,
    		wr_addr => wr_addr,
    		wr_ena  => push_irdy,
    		wr_data => push_data,
    		rd_addr => rd_addr,
    		rd_data => pop_data);

		process (clk)
		begin
			if rising_edge(clk) then
				if (push_irdy xor pop_irdy)='1' then
					if push_irdy='1' then
						sk_ptr <= unsigned(wr_addr);
					elsif pop_irdy='1' then
						sk_ptr <= sk_ptr - 1;
					end if;
				end if;
			end if;
		end process;
	
	end block;
	dbdbblsrl_ser_e : entity hdl4fpga.dbdbblsrl_ser
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk => clk,
		frm => frm,
		cnt => b"101",
		ini => bin2bcd,
		bcd => bcd);

	du_e : entity hdl4fpga.format
	generic map (
		max_width => bcd_width)
	port map (
		tab      => to_ascii("0123456789 +-,."),
		clk      => clk,
		width    => x"0",
		dec      => x"2",
		bcd_frm  => frm,
		bcd_irdy => frm,
		bcd_trdy => trdy,
		neg      => '1',
		bcd      => bcd,
		code_frm => code_frm,
		code     => code);

	-- process 
	-- begin
		-- report "VALUE : " & ''' & to_string(code) & ''';
		-- wait on code;
	-- end process;
end;
