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
		max_width : natural);
	port (
		tab       : in  std_logic_vector := x"0123456789abcde";
		clk       : in  std_logic;
		dec       : in  std_logic_vector := (0 to 0 => '0');
		neg       : in  std_logic := '0';
		sign      : in  std_logic := '0';
		width     : in  std_logic_vector := (0 to 0 => '0');
		bcd_frm   : in  std_logic;
		bcd_irdy  : in  std_logic := '1';
		bcd_trdy  : out std_logic := '1';
		bcd       : in  std_logic_vector(0 to 4-1);
		code_frm  : buffer std_logic;
		code_irdy : out std_logic;
		code_trdy : in  std_logic := '1';
		code      : out std_logic_vector);

	constant bcd_digits : natural := 1;
	constant bcd_tab    : std_logic_vector := x"0123456789abcdef";

	constant blank      : std_logic_vector(0 to bcd'length-1) := x"a";
	constant plus       : std_logic_vector(0 to bcd'length-1) := x"b";
	constant minus      : std_logic_vector(0 to bcd'length-1) := x"c";
	constant comma      : std_logic_vector(0 to bcd'length-1) := x"d";
	constant dot        : std_logic_vector(0 to bcd'length-1) := x"e";

end;

-- Combinatorial version
-- https://github.com/hdl4fpga/hdl4fpga/blob/62b576a8d626e379257136259202cbcdf41c3a45/library/basic/format.vhd#L24

architecture def of format is
	constant addr_size : natural := unsigned_num_bits(max_width/bcd_digits-1);
	signal bcd_width   : unsigned(0 to addr_size);
	signal bcd_wraddr  : std_logic_vector(1 to addr_size);
	signal bcd_wrena   : std_logic;
	signal bcd_wrdata  : std_logic_vector(bcd'range);
	signal bcd_rdaddr  : std_logic_vector(1 to addr_size);
	signal bcd_rddata  : std_logic_vector(bcd'range);

	signal fmt_req     : std_logic;
	signal fmt_rdy     : std_logic;
	signal code_req    : std_logic;
	signal code_rdy    : std_logic;

	signal fmt_wraddr  : std_logic_vector(1 to addr_size);
	signal fmt_wrena   : std_logic;
	signal fmt_wrdata  : std_logic_vector(bcd'range);
	signal fmt_rdaddr  : std_logic_vector(1 to addr_size);
	signal fmt_rddata  : std_logic_vector(bcd'range);

	signal ov : std_logic;
	signal point       : std_logic_vector(bcd_wraddr'range);
begin

	bcd_width <= 
		to_unsigned(max_width,  bcd_width'length) when width=(width'range => '0') else
		resize(unsigned(width), bcd_width'length);

	bcd_write_p : process (fmt_req, clk)
		variable bcd_req    : std_logic;
		variable bcd_rdy    : std_logic;
		variable bcd_wrcntr : unsigned(0 to addr_size);
		type states is (s_frac, s_int);
		variable state : states;

	begin
		if rising_edge(clk) then
			if (to_bit(fmt_req) xor to_bit(fmt_rdy))='0' then
				if to_bit(bcd_frm)='1' then
					if bcd_irdy='1' then
						if bcd_wrcntr(0)='0' then
							bcd_wrcntr := bcd_wrcntr + 1;
						end if;
					end if;
					bcd_req := not to_stdulogic(to_bit(bcd_rdy));
				elsif (to_bit(bcd_req) xor to_bit(bcd_rdy))='1' then
					if bcd_wrcntr/=bcd_width then
						bcd_wrcntr := bcd_wrcntr + 1;
					else
						bcd_rdy := bcd_req;
						fmt_req <= not to_stdulogic(to_bit(fmt_rdy));
					end if;
				else
					bcd_wrcntr := (others => '0');
				end if;
			else 
				state := s_frac;
			end if;
			ov <= bcd_wrcntr(0);

			bcd_wraddr <= std_logic_vector(bcd_wrcntr(bcd_wraddr'range));
		end if;
	end process;

	point <= std_logic_vector(resize(unsigned(dec), point'length));
	bcd_trdy <=
		'1' when bcd_wraddr=(bcd_wraddr'range => '0') else
		'0' when bcd_wraddr=point else
		'1';

	bcd_wrena <= 
		not ov and bcd_irdy when bcd_frm='1' else 
		not ov;

	bcd_wrdata <=
		bcd when bcd_wraddr=(bcd_wraddr'range => '0') else
		dot when bcd_wraddr=point else
		bcd when bcd_frm='1' else
		blank;

	bcdmem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => bcd_wraddr,
		wr_ena  => bcd_wrena,
		wr_data => bcd_wrdata,
		rd_addr => bcd_rdaddr,
		rd_data => bcd_rddata);

	bcd_read_p : process (fmt_rdy, clk)
		type states is (s_init, s_blank, s_blanked);
		variable state : states;

		variable unit       : std_logic_vector(bcd_rdaddr'range);
		variable bcd_rdcntr : unsigned(0 to addr_size);
		variable fmt_wrcntr : unsigned(0 to addr_size);
	begin
		if rising_edge(clk) then
			if (to_bit(fmt_rdy) xor to_bit(fmt_req))='1' then

				case state is
				when s_init =>
					if bcd_rddata=x"0" then
						fmt_wrcntr := fmt_wrcntr - 1;
						fmt_wrdata <= multiplex(bcd_tab, blank, bcd'length);
						bcd_rdcntr := bcd_rdcntr - 1;
						state := s_blank;
					elsif neg='1' then
						fmt_wrdata <= multiplex(bcd_tab, minus, bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_wrdata <= multiplex(bcd_tab, plus, bcd'length);
						state := s_blanked;
					else
						fmt_wrdata <= multiplex(bcd_tab, bcd_rddata, bcd'length);
						bcd_rdcntr := bcd_rdcntr - 1;
						state := s_blanked;
					end if;
				when s_blank =>
					if bcd_rddata=x"0" and bcd_rdaddr/=unit then
						fmt_wrcntr := fmt_wrcntr - 1;
						fmt_wrdata <= multiplex(bcd_tab, blank, bcd'length);
						bcd_rdcntr := bcd_rdcntr - 1;
					elsif neg='1' then
						fmt_wrdata <= multiplex(bcd_tab, minus, bcd'length);
						state := s_blanked;
					elsif sign='1' then
						fmt_wrdata <= multiplex(bcd_tab, plus, bcd'length);
						state := s_blanked;
					else 
						fmt_wrcntr := fmt_wrcntr - 1;
						fmt_wrdata <= multiplex(bcd_tab, bcd_rddata, bcd'length);
						bcd_rdcntr := bcd_rdcntr - 1;
						state := s_blanked;
					end if;
				when s_blanked =>
					fmt_wrcntr := fmt_wrcntr - 1;
					fmt_wrdata <= multiplex(bcd_tab, bcd_rddata, bcd'length);
					bcd_rdcntr := bcd_rdcntr - 1;
					if bcd_rdcntr(0)='1' then
						fmt_rdy  <= to_stdulogic(to_bit(fmt_req));
						code_req <= not to_stdulogic(to_bit(code_rdy));
					end if;

				end case;
				bcd_rdaddr <= std_logic_vector(bcd_rdcntr(bcd_rdaddr'range));
				fmt_wraddr <= std_logic_vector(fmt_wrcntr(fmt_wraddr'range));
			else
				if dec=(dec'range => '0') then
					unit := (others => '0');
				else
					unit := std_logic_vector(resize(unsigned(dec), unit'length)+1);
				end if;
				fmt_wrcntr := resize(unsigned(bcd_wraddr),   fmt_wrcntr'length);
				bcd_rdcntr := resize(unsigned(bcd_wraddr)-1, bcd_rdcntr'length);
				bcd_rdaddr <= std_logic_vector(bcd_rdcntr(bcd_rdaddr'range));
				state := s_init;
			end if;
		end if;
	end process;

	fmtmem_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => clk,
		wr_addr => fmt_wraddr,
		wr_data => fmt_wrdata,
		rd_addr => fmt_rdaddr,
		rd_data => fmt_rddata);

	fmt_read_p : process (clk)
		variable fmt_rdcntr : unsigned(0 to addr_size);
	begin
		if rising_edge(clk) then
			if (to_bit(code_rdy) xor to_bit(code_req))='1' then
				if unsigned(fmt_rdaddr)=0 then
					code_rdy <= to_stdulogic(to_bit(code_req));
				end if;
				if code_trdy='1' then
					fmt_rdcntr := fmt_rdcntr - 1;
				end if;
			elsif (to_bit(fmt_rdy) xor to_bit(fmt_req))='1' then
				fmt_rdcntr := resize(unsigned(bcd_wraddr), fmt_rdcntr'length);
				if code_trdy='1' then
					fmt_rdcntr := fmt_rdcntr - 1;
				end if;
			end if;
			fmt_rdaddr <= std_logic_vector(fmt_rdcntr(fmt_rdaddr'range));
		end if;
	end process;
	code_frm  <= to_stdulogic(to_bit(code_rdy) xor to_bit(code_req));
	code_irdy <= code_frm;
	code      <= multiplex(tab, fmt_rddata, code'length);
end;