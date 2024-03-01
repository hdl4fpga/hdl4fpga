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
	signal sll_bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal bcd_lifo  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal sll_frm  : std_logic;
	signal trdy : std_logic;
	signal trdy1 : std_logic;

	signal code_frm : std_logic;
	signal code     : std_logic_vector(0 to 8-1);
	shared variable xxx : unsigned(0 to 8*8-1);

	signal slr_frm  : std_logic;
	signal slr_trdy : std_logic;
	signal lifo_ov  : std_logic;
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
		clk      => clk,
		req      => dbdbbl_req,
		rdy      => dbdbbl_rdy,
		bin      => std_logic_vector(to_unsigned(4967,15)), -- b"1001110",
		bcd_frm  => sll_frm,
		bcd      => sll_bcd);

	lifo_e : entity hdl4fpga.lifo
	port map (
		clk       => clk,
		ov        => lifo_ov,
		push_ena  => sll_frm,
		push_data => sll_bcd,
		pop_ena   => slr_trdy,
		pop_data  => bcd_lifo);

	process (sll_frm, lifo_ov, clk)
		type states is (s_popped, s_pushed);
		variable state : states;
	begin
		if rising_edge(clk) then
			if sll_frm='1' then
				state := s_pushed;
				slr_frm <= '0';
			elsif state=s_pushed then
				if lifo_ov='1' then
					state := s_popped;
				end if;
				slr_frm <= not lifo_ov;
			else
				slr_frm <= '0';
			end if;
		end if;

		case state is
		when s_popped =>
			slr_trdy <= '0';
		when s_pushed =>
			slr_trdy <= (not sll_frm and not lifo_ov) and trdy1;
		end case;
	end process;

	dbdbblsrl_ser_e : entity hdl4fpga.dbdbblsrl_ser
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		frm  => slr_frm,
		trdy => trdy1,
		cnt  => b"001",
		ini  => bcd_lifo,
		bcd_trdy => trdy,
		bcd  => bcd);

	du_e : entity hdl4fpga.format
	generic map (
		max_width => bcd_width)
	port map (
		tab      => to_ascii("0123456789 +-,."),
		clk      => clk,
		width    => x"0",
		bcd_frm  => slr_frm,
		bcd_irdy => slr_frm,
		bcd_trdy => trdy,
		neg      => '0',
		bcd      => bcd,
		code_frm => code_frm,
		code     => code);

	-- process 
	-- begin
		-- report "VALUE : " & ''' & to_string(code) & ''';
		-- wait on code;
	-- end process;
end;
