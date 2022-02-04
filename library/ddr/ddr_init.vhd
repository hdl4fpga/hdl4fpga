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
use hdl4fpga.ddr_param.all;

entity ddr_init is
	generic (
		ddr_stdr : natural;
		timers : natural_vector := (0 to 0 => 0);
		ADDR_SIZE : natural := 13;
		BANK_SIZE : natural := 3);
	port (
		ddr_init_bl   : in  std_logic_vector;
		ddr_init_bt   : in  std_logic_vector;
		ddr_init_cl   : in  std_logic_vector;
		ddr_init_ods  : in  std_logic_vector;

		ddr_init_wb   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_al   : in  std_logic_vector(2-1 downto 0) := (others => '0');
		ddr_init_asr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_cwl  : in  std_logic_vector(3-1 downto 0) := (others => '0');
		ddr_init_drtt : in  std_logic_vector(2-1 downto 0) := (others => '0');
		ddr_init_edll : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_mpr  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_mprrf : in std_logic_vector(2-1 downto 0) := (others => '0');
		ddr_init_qoff : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_rtt  : in  std_logic_vector;
		ddr_init_srt  : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_tdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_wl   : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_wr   : in  std_logic_vector(3-1 downto 0) := (others => '0');
		ddr_init_ddqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_rdqs : in  std_logic_vector(1-1 downto 0) := (others => '0');
		ddr_init_ocd  : in  std_logic_vector(3-1 downto 0) := (others => '1');
		ddr_init_pd   : in  std_logic_vector(1-1 downto 0) := (others => '0');

		ddr_refi_rdy : in  std_logic;
		ddr_refi_req : out std_logic;
		ddr_init_clk : in  std_logic;
		ddr_init_wlrdy : in  std_logic;
		ddr_init_wlreq : out std_logic;
		ddr_init_req : in  std_logic;
		ddr_init_rdy : out std_logic;
		ddr_init_rst : out std_logic;
		ddr_init_cke : out std_logic;
		ddr_init_cs  : out std_logic;
		ddr_init_ras : out std_logic;
		ddr_init_cas : out std_logic;
		ddr_init_we  : out std_logic;
		ddr_init_a   : out std_logic_vector(ADDR_SIZE-1 downto 0);
		ddr_init_b   : out std_logic_vector(BANK_SIZE-1 downto 0);
		ddr_init_odt : out std_logic);


	attribute fsm_encoding : string;
	attribute fsm_encoding of ddr_init : entity is "compact";
end;

architecture def of ddr_init is

	signal init_rdy : std_logic;
	constant pgm : s_table := choose_pgm(ddr_stdr);

	signal ddr_init_pc   : s_code;
	signal ddr_timer_id  : std_logic_vector(unsigned_num_bits(timers'length-1)-1 downto 0);
	signal ddr_timer_rdy : std_logic;
	signal ddr_timer_req : std_logic;

	signal input : std_logic_vector(0 to 0);
	signal ddr_mr_addr : ddrmr_addr;
	signal mr_addr : ddrmr_addr;
	signal ddr_mr_data : std_logic_vector(13-1 downto 0);
begin

	input(0) <= ddr_init_wlrdy;

	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			mr_addr <= ddr_mr_addr;
		end if;
	end process;

	ddr_mr_data <= std_logic_vector(resize(unsigned(ddr_mrfile(
		ddr_stdr => ddr_stdr,
		ddr_mr_addr => mr_addr,
		ddr_mr_srt  => ddr_init_srt,
		ddr_mr_bl   => ddr_init_bl,
		ddr_mr_bt   => ddr_init_bt,
		ddr_mr_wb   => ddr_init_wb,
		ddr_mr_cl   => ddr_init_cl,
		ddr_mr_wr   => ddr_init_wr,
		ddr_mr_ods  => ddr_init_ods,
		ddr_mr_rtt  => ddr_init_rtt,
		ddr_mr_al   => ddr_init_al,
		ddr_mr_ocd  => ddr_init_ocd,
		ddr_mr_tdqs => ddr_init_tdqs,
		ddr_mr_rdqs => ddr_init_rdqs,
		ddr_mr_qoff => ddr_init_qoff,
		ddr_mr_drtt => ddr_init_drtt,
		ddr_mr_mprrf=> ddr_init_mprrf,
		ddr_mr_mpr  => ddr_init_mpr,
		ddr_mr_asr  => ddr_init_asr,
		ddr_mr_pd   => ddr_init_pd,
		ddr_mr_cwl  => ddr_init_cwl)),ddr_mr_data'length));

	process (ddr_init_clk)
		variable row : s_row;
	begin
		if rising_edge(ddr_init_clk) then
			if ddr_init_req='0' then
				row := (
					state   => (others => '-'),
					state_n => (others => '-'),
					mask    => (others => '-'),
					input   => (others => '-'),
					output  => (others => '-'),
					cmd     => (cs => '-', ras => '-', cas => '-', we => '-'),
					bnk     => (others => '-'),
					mr      => (others => '-'),
					tid     => to_unsigned(TMR_RST, TMR_SIZE));
				for i in pgm'range loop
					if pgm(i).state=ddr_init_pc then
						if ((pgm(i).input xor input) and pgm(i).mask)=(input'range => '0') then
							 row := pgm(i);
						end if;
					end if;
				end loop;
				if ddr_timer_rdy='1' then
					ddr_init_pc   <= row.state_n;
					ddr_init_rst  <= to_sout(row.output).rst;
					init_rdy      <= to_sout(row.output).rdy;
					ddr_init_cke  <= to_sout(row.output).cke;
					ddr_init_wlreq<= to_sout(row.output).wlq;
					ddr_init_cs   <= row.cmd.cs;
					ddr_init_ras  <= row.cmd.ras;
					ddr_init_cas  <= row.cmd.cas;
					ddr_init_we   <= row.cmd.we;
					ddr_init_odt  <= to_sout(row.output).odt;
				else
					ddr_init_cs   <= ddr_nop.cs;
					ddr_init_ras  <= ddr_nop.ras;
					ddr_init_cas  <= ddr_nop.cas;
					ddr_init_we   <= ddr_nop.we;
					ddr_timer_id  <= std_logic_vector(resize(row.tid, ddr_timer_id'length));
				end if;
				ddr_init_b  <= std_logic_vector(unsigned(resize(unsigned(row.bnk), ddr_init_b'length)));
				ddr_mr_addr <= row.mr;
			else
				ddr_init_pc    <= sc_rst;
				ddr_timer_id   <= std_logic_vector(to_unsigned(TMR_RST, ddr_timer_id'length));
				ddr_init_rst   <= '0';
				ddr_init_cke   <= '0';
				init_rdy       <= '0';
				ddr_init_cs    <= '0';
				ddr_init_ras   <= '1';
				ddr_init_cas   <= '1';
				ddr_init_we    <= '1';
				ddr_init_odt   <= '0';
				ddr_init_wlreq <= '0';
				ddr_mr_addr    <= (ddr_mr_addr'range => '1');
				ddr_init_b     <= std_logic_vector(unsigned(resize(unsigned(ddr_mrx), ddr_init_b'length)));
			end if;
		end if;
	end process;

	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk) then
			ddr_init_a   <= std_logic_vector(resize(unsigned(ddr_mr_data), ddr_init_a'length));
			ddr_init_rdy <= init_rdy;
		end if;
	end process;

	process (ddr_init_clk)
	begin
		if rising_edge(ddr_init_clk)then
			if ddr_init_pc=sc_ref then
				if ddr_timer_rdy='1' then
					ddr_refi_req <= '1';
				elsif ddr_refi_rdy='1' then
					ddr_refi_req <='0';
				end if;
			else
				ddr_refi_req <= '0';
			end if;
		end if;
	end process;

	ddr_timer_req <=
		'1' when ddr_init_req='1' else
		'1' when ddr_timer_rdy='1' else
		'0';

	timer_e : entity hdl4fpga.ddr_timer
	generic map (
		timers => timers)
	port map (
		sys_clk => ddr_init_clk,
		tmr_sel => ddr_timer_id,
		sys_req => ddr_timer_req,
		sys_rdy => ddr_timer_rdy);
end;
