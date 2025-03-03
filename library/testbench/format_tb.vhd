-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

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
	alias rgtr_clk is clk;
	signal dbdbbl_req  : std_logic;
	signal dbdbbl_rdy  : std_logic;

	signal slr_bcd : std_logic_vector(bcd_length*bcd_digits-1 downto 0);
	signal slr_ini : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal sll_frm  : std_logic;
	signal sll_bcd  : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal slr_frm  : std_logic;
	signal slr_irdy : std_logic;
	signal slr_trdy : std_logic;

	signal slrbcd_trdy : std_logic;
	signal slrbcd      : std_logic_vector(bcd_length*bcd_digits-1 downto 0);

	signal code_frm : std_logic;
	signal code     : std_logic_vector(0 to 8-1);
begin

	clk <= not clk after 0.5 ns;

	process (clk)
		variable xxx : unsigned(0 to 8*8-1);
	begin
		if rising_edge(clk) then
			if (to_bit(dbdbbl_rdy) xor to_bit(dbdbbl_req))='0' then
				xxx := unsigned(std_logic_vector'(to_ascii("        ")));
				dbdbbl_req <= not to_stdulogic(to_bit(dbdbbl_rdy));
			elsif code_frm='1' then
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
		bin      => std_logic_vector(to_unsigned(1,15)), -- b"1001110",
		bcd_frm  => sll_frm,
		bcd      => sll_bcd);

	lifo_b : block
		generic (
			max_decimal : natural := 2);
		port (
			clk      : in  std_logic;
			sll_frm  : in  std_logic;
			sll_bcd  : in  std_logic_vector;
			slr_frm  : buffer std_logic;
			slr_dec  : in std_logic_vector := std_logic_vector'(0 to 0 => '0');
			slr_irdy : buffer std_logic;
			slr_trdy : in  std_logic;
			slr_bcd  : buffer std_logic_vector);
		port map (
			clk      => rgtr_clk,
			sll_frm  => sll_frm,
			sll_bcd  => sll_bcd,
			slr_frm  => slr_frm,
			slr_dec  => b"11",
			slr_irdy => slr_irdy,
			slr_trdy => slr_trdy,
			slr_bcd  => slr_bcd);
		signal lifo_ov  : std_logic;
	begin
		lifo_e : entity hdl4fpga.lifo
		port map (
			clk       => clk,
			ov        => lifo_ov,
			push_ena  => sll_frm,
			push_data => sll_bcd,
			pop_ena   => slr_irdy,
			pop_data  => slr_bcd);

		process (sll_frm, slr_trdy, slr_bcd, lifo_ov, clk)
			type states is (s_popped, s_pushed);
			variable state : states;
			variable cntr : integer range -1 to max_decimal := -1;
		begin
			if rising_edge(clk) then
				if sll_frm='0' then
					case state is
					when s_pushed =>
						if lifo_ov='1' then
							if cntr >= 0 then
								cntr := cntr - 1;
							end if;
							state := s_popped;
						else
							cntr := to_integer(unsigned(slr_dec));
						end if;
					when s_popped =>
						if cntr >= 0 then
							cntr := cntr - 1;
						end if;
					end case;
				else
					state := s_pushed;
				end if;
			end if;

			case state is
			when s_popped =>
				if cntr >= 0 then 
					slr_frm  <= '1';
					slr_irdy <= '1';
				else
					slr_frm  <= '0';
					slr_irdy <= '0';
				end if;
				slr_ini  <= (others => '0');
			when s_pushed =>
				if sll_frm='1' then
					slr_frm  <= '0';
					slr_irdy <= '0';
					slr_ini  <= slr_bcd;
				elsif lifo_ov='1' then
					if cntr >= 0 then 
						slr_frm  <= '1';
						slr_irdy <= '1';
						slr_ini  <= x"e";
					else
						slr_frm  <= '0';
						slr_irdy <= '0';
						slr_ini  <= (others => '0');
					end if;
				else
					slr_frm  <= '1';
					if slr_trdy='0' then
						slr_irdy <= '0';
					else
						slr_irdy <= '1';
					end if;
					slr_ini  <= slr_bcd;
				end if;
			end case;

		end process;
	end block;

	dbdbblsrl_ser_e : entity hdl4fpga.dbdbblsrl_ser
	generic map (
		bcd_width  => bcd_width,
		bcd_digits => bcd_digits)
	port map (
		clk  => clk,
		frm  => slr_frm,
		irdy => slr_irdy,
		trdy => slr_trdy,
		cnt  => b"101",
		bcd_ini  => slr_ini,
		bcd_trdy => slrbcd_trdy,
		bcd  => slrbcd);

	du_e : entity hdl4fpga.format
	generic map (
		max_width => bcd_width)
	port map (
		tab      => to_ascii("0123456789 +-,."),
		clk      => clk,
		bcd_frm  => slr_frm,
		bcd_irdy => slr_irdy,
		bcd_trdy => slrbcd_trdy,
		neg      => '0',
		bcd      => slrbcd,
		code_frm => code_frm,
		code     => code);

end;
