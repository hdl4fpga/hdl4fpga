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
use hdl4fpga.xdr_param.all;

entity xdr_init is
	generic (
		ddr_stdr : natural;
		timers : natural_vector := (1 to 0 => 0);
		addr_size : natural := 13;
		bank_size : natural := 3);
	port (
		xdr_mr_addr  : out std_logic_vector;
		xdr_mr_data  : in std_logic_vector;
		xdr_refi_rdy : in  std_logic;
		xdr_refi_req : out std_logic;
		xdr_init_clk : in  std_logic;
		xdr_init_wlrdy : in  std_logic;
		xdr_init_wlreq : out std_logic := '0';
		xdr_init_wlr : out std_logic;
		xdr_init_req : in  std_logic;
		xdr_init_rdy : out std_logic;
		xdr_init_rst : out std_logic;
		xdr_init_cke : out std_logic;
		xdr_init_odt : out std_logic := '0';
		xdr_init_cs  : out std_logic;
		xdr_init_ras : out std_logic;
		xdr_init_cas : out std_logic;
		xdr_init_we  : out std_logic;
		xdr_init_a   : out std_logic_vector(ADDR_SIZE-1 downto 0) := (others => '1');
		xdr_init_b   : out std_logic_vector(BANK_SIZE-1 downto 0) := (others => '1'));

--	attribute fsm_encoding : string;
--	attribute fsm_encoding of xdr_init : entity is "compact";

	signal init_rdy : std_logic;
end;

architecture def of xdr_init is

	constant pgm : s_table := choose_pgm(ddr_stdr);

	signal xdr_init_pc : s_code;
	signal xdr_timer_id  : std_logic_vector(unsigned_num_bits(timers'length-1)-1 downto 0);
	signal xdr_timer_rdy : std_logic;
	signal xdr_timer_req : std_logic;

	signal input : std_logic_vector(0 to 0);
begin

	input(0) <= xdr_init_wlrdy;

	process (xdr_init_clk)
		variable row : s_row;
	begin
		if rising_edge(xdr_init_clk) then
			if xdr_init_req='0' then
				row := (
					state => (others => '-'), 
					state_n => (others => '-'),
					mask  => (others => '-'),
					input => (others => '-'),
					output => (others => '-'),
					cmd => (cs => '-', ras => '-', cas => '-', we => '-'), 
					bnk => (others => '-'),
					mr  => (others => '-'),
					tid => to_unsigned(TMR_RST, TMR_SIZE));
				for i in pgm'range loop
					if pgm(i).state=xdr_init_pc then
						if ((pgm(i).input xor input) and pgm(i).mask)=(input'range => '0') then
							 row := pgm(i);
						end if;
					end if;
				end loop;
				if xdr_timer_rdy='1' then
					xdr_init_pc  <= row.state_n;
					xdr_init_rst <= to_sout(row.output).rst;
					init_rdy <= to_sout(row.output).rdy;
					xdr_init_cke <= to_sout(row.output).cke;
					xdr_init_wlreq <= to_sout(row.output).wlq;
					xdr_init_wlr <= to_sout(row.output).wlr;
					xdr_init_odt <= to_sout(row.output).odt;
					xdr_init_cs  <= row.cmd.cs;
					xdr_init_ras <= row.cmd.ras;
					xdr_init_cas <= row.cmd.cas;
					xdr_init_we  <= row.cmd.we;
				else
					xdr_init_cs  <= ddr_nop.cs;
					xdr_init_ras <= ddr_nop.ras;
					xdr_init_cas <= ddr_nop.cas;
					xdr_init_we  <= ddr_nop.we;
					xdr_timer_id <= std_logic_vector(resize(row.tid, xdr_timer_id'length));
				end if;
				xdr_init_b  <= std_logic_vector(unsigned(resize(unsigned(row.bnk), xdr_init_b'length)));
				xdr_mr_addr <= row.mr;
			else
				xdr_init_pc  <= sc_rst;
				xdr_timer_id <= to_unsigned(TMR_RST, xdr_timer_id'length);
				xdr_init_rst <= '0';
				xdr_init_cke <= '0';
				init_rdy <= '0';
				xdr_init_cs  <= '0';
				xdr_init_ras <= '1';
				xdr_init_cas <= '1';
				xdr_init_we  <= '1';
				xdr_init_wlreq <= '0';
				xdr_init_wlr <= '0';
				xdr_mr_addr  <= (xdr_mr_addr'range => '1');
				xdr_init_b   <= std_logic_vector(unsigned(resize(unsigned(ddr_mrx), xdr_init_b'length)));
			end if;
		end if;
	end process;

	process (xdr_init_clk)
	begin
		if rising_edge(xdr_init_clk) then
			xdr_init_a   <= std_logic_vector(unsigned(resize(unsigned(xdr_mr_data), xdr_init_a'length)));
			xdr_init_rdy <= init_rdy;
		end if;
	end process;

	process (xdr_init_clk)
	begin
		if rising_edge(xdr_init_clk)then
			if xdr_init_pc=sc_ref then
				if xdr_timer_rdy='1' then
					xdr_refi_req <= '1';
				elsif xdr_refi_rdy='1' then
					xdr_refi_req <='0';
				end if;
			else
				xdr_refi_req <= '0';
			end if;
		end if;
	end process;

	xdr_timer_req <=
	'1' when xdr_init_req='1' else
	'1' when xdr_timer_rdy='1' else
	'0';

	timer_e : entity hdl4fpga.xdr_timer
	generic map (
		timers => timers)
	port map (
		sys_clk => xdr_init_clk,
		tmr_sel => xdr_timer_id,
		sys_req => xdr_timer_req,
		sys_rdy => xdr_timer_rdy);
end;
