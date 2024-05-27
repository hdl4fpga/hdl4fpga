
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
use hdl4fpga.sdram_param.all;

entity dmatrans is
	generic (
		burst_length   : natural := 0;
		data_gear      : natural;
		bank_size      : natural;
		addr_size      : natural;
		coln_size      : natural);
	port (
		tp             : out std_logic_vector(1 to 32);
		dmatrans_clk   : in  std_logic;
		dmatrans_req   : in  std_logic;
		dmatrans_rdy   : buffer std_logic;
		dmatrans_we    : in  std_logic;
		dmatrans_iaddr : in  std_logic_vector;
		dmatrans_ilen  : in  std_logic_vector;
		dmatrans_taddr : out std_logic_vector;
		dmatrans_tlen  : out std_logic_vector;
		dmatrans_cnl   : in  std_logic := '0';

		ctlr_inirdy    : in std_logic;
		ctlr_refreq    : in std_logic;

		ctlr_frm       : buffer std_logic;
		ctlr_cmd       : in  std_logic_vector(0 to 3-1);
		ctlr_trdy      : in  std_logic;
		ctlr_fch       : in  std_logic;
		ctlr_rw        : out std_logic := '0';
		ctlr_alat      : in  std_logic_vector(2 downto 0);
		ctlr_blat      : in  std_logic_vector(2 downto 0);
		ctlr_b         : out std_logic_vector;
		ctlr_a         : out std_logic_vector);

	constant coln_align : natural := unsigned_num_bits(data_gear)-1;
	constant burst_bits : natural := unsigned_num_bits(setif(burst_length=0, data_gear, burst_length))-1;

end;

architecture def of dmatrans is

	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_col   : std_logic_vector(coln_size-1 downto burst_bits);

	signal load         : std_logic;

	signal ctlr_ras     : std_logic;
	signal ctlr_cas     : std_logic;
	signal state_cas    : std_logic;
	signal state_pre    : std_logic;
	signal state_nop    : std_logic;
	signal ctlrdma_irdy : std_logic;
	signal leoc         : std_logic;
	signal ceoc         : std_logic;
	signal loaded       : std_logic;
	signal restart      : std_logic;
	signal refreq       : std_logic;
begin

	tp(1) <= refreq;
	process (
		ctlr_alat,
		ctlr_inirdy,
		dmatrans_rdy, 
		dmatrans_req, 
		leoc, 
		refreq, 
		state_nop, 
		ceoc, 
		restart, 
		dmatrans_clk)
		variable frm : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_inirdy='0' then
				dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
				frm := '0';
			elsif (to_bit(dmatrans_rdy) xor to_bit(dmatrans_req))='1' then
				if leoc='1' then
					frm := '0';
					if (ctlr_trdy and state_pre)='1' then
						dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
					end if;
				elsif state_nop='1' then
					frm := '1';
				elsif refreq='1' then
					frm := '0';
				elsif ceoc='1' and restart='0' then
					frm := '0';
				else
					frm := '1';
				end if;
				loaded <= load;
			else
				frm := '0';
				loaded <= '0';
			end if;
			load <= not to_stdulogic(to_bit(dmatrans_rdy) xor to_bit(dmatrans_req));
		end if;

		if unsigned(ctlr_alat) > 2 then
			ctlr_frm <= frm;
		elsif ctlr_inirdy='0' then
			ctlr_frm <= '0';
		elsif (to_bit(dmatrans_rdy) xor to_bit(dmatrans_req))='1' then
			if leoc='1' then
				ctlr_frm <= '0';
			elsif refreq='1' then
				ctlr_frm <= '0';
			elsif state_nop='1' then
				ctlr_frm <= '1';
			elsif ceoc='1' and restart='0' then
				ctlr_frm <= '0';
			else
				ctlr_frm <='1';
			end if;
		else
			ctlr_frm <= '0';
		end if;
	end process;

	dma_b : block

		signal reload : std_logic;

		signal ena   : std_logic;
		signal bnk   : std_logic_vector(ctlr_b'range);
		signal row   : std_logic_vector(ddrdma_row'range);
		signal col   : std_logic_vector(ddrdma_col'range);
		signal ilen  : std_logic_vector(dmatrans_ilen'length-1 downto burst_bits-coln_align);
		signal iaddr : std_logic_vector(dmatrans_iaddr'length-1 downto burst_bits-coln_align);
		signal tlen  : std_logic_vector(ilen'range);
		signal taddr : std_logic_vector(iaddr'range);

		signal col_frm : std_logic;

	begin

		cas_p : process(ctlr_alat, ctlr_blat, ceoc, refreq, restart, dmatrans_clk)
			type states is (activate, bursting);
			variable state : states;
			-- variable cntr  : unsigned(0 to unsigned_num_bits(setif(burst_length=0,1,burst_length/data_gear-1)));
			variable cntr  : unsigned(0 to unsigned_num_bits(setif(burst_length=0,1,burst_length/data_gear)));
		begin
			if rising_edge(dmatrans_clk) then

				restart_transfer : if ctlr_frm='0' then
					if ctlr_trdy='1' then
						restart <= ceoc or refreq;
					end if;
				elsif cntr(0)='1' then
					restart <= '0';
				end if;

				sync_refresh_with_cas : if state_cas='1' and (ctlr_cas='0' or burst_length=0 or burst_length=data_gear) then
					refreq <= ctlr_refreq;
				elsif refreq='1' then
					refreq <= ctlr_refreq;
				else
					refreq <= '0';
				end if;

				case state is
				when activate =>
					if ctlr_frm='1' and (ctlr_cmd=mpu_act and ctlr_trdy='1') then
						state := bursting;
					end if;
				when bursting =>
					if ctlr_frm='0' then
						state := activate;
					elsif refreq='1' then
						state := activate;
					end if;
				end case;

				case state is
				when activate =>
					if unsigned(ctlr_alat) > 2 then
						cntr := resize(unsigned(ctlr_alat)-3, cntr'length);
					else
						cntr := resize(unsigned(ctlr_alat)-2, cntr'length);
					end if;
					assert unsigned(ctlr_alat) >= 2
					report ">>>dmatrans<<< : ctlr_alat " & to_string(ctlr_alat) & " lower than 2"
					severity failure;
				when bursting =>
					if cntr(0)='0' then
						cntr := cntr - 1;
					elsif ceoc='0' then
						cntr := resize(unsigned(ctlr_blat), cntr'length);
					end if;
				end case;

				reload <= state_pre and ctlr_fch;
			end if;

			if unsigned(ctlr_alat) > 2 then
				ena <= (cntr(0) and not ceoc and not refreq) or (cntr(0) and restart);
				-- ena <= (cntr(0) and not ceoc) or (cntr(0) and restart);
			else
				case state is
				when activate =>
					ena <= '0';
				when bursting =>
					if ctlr_blat(ctlr_blat'left)='1' then
						ena <= (cntr(0) and not ceoc and not refreq) or (cntr(0) and restart);
					else
						ena <= (cntr(0) and not ceoc) or (cntr(0) and restart);
					end if;
				end case;
			end if;
		end process;

		ilen  <= std_logic_vector(resize(shift_right(unsigned(dmatrans_ilen),  burst_bits-coln_align), ilen'length));
		iaddr <= std_logic_vector(resize(shift_right(unsigned(dmatrans_iaddr), burst_bits-coln_align), iaddr'length));
		dma_e : entity hdl4fpga.dmacntr
		port map (
			clk     => dmatrans_clk,
			load    => load,
			ena     => ena,
			iaddr   => iaddr,
			ilen    => ilen,
			taddr   => taddr,
			tlen    => tlen,
			len_eoc => leoc,
			bnk     => bnk,
			row     => row,
			col     => col,
			col_eoc => ceoc);

		process (dmatrans_clk)
		begin
			if rising_edge(dmatrans_clk) then
				if (loaded or reload)='1' then
					ddrdma_bnk <= bnk;
					ddrdma_row <= row;
				end if;
			end if;
		end process;

		col_frm <= not load;
		col_e : entity hdl4fpga.fifo
		generic map (
			max_depth => 8,
			sync_read => false, 
			latency   => 1, -- RCD latency greater than 2
			check_sov => false,
			check_dov => true,
			gray_code => false)
		port map (
			src_clk   => dmatrans_clk,
			src_irdy  => ena,
			src_trdy  => open,
			src_data  => col,
			dst_clk   => dmatrans_clk,
			dst_frm   => col_frm,
			dst_irdy  => open,
			dst_trdy  => ctlr_cas,
			dst_data  => ddrdma_col);

	end block;

	ctlr_rw <= not dmatrans_we;

	process (dmatrans_clk)
		variable ras  : std_logic;
		variable cas  : std_logic;
		variable pre  : std_logic;
		variable nop  : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_trdy='1' then
				case ctlr_cmd is
				when mpu_act   =>
					ras := '1';
					cas := '0';
					pre := '0';
					nop := '0';
				when mpu_write =>
					ras := '0';
					cas := '1';
					pre := '0';
					nop := '0';
				when mpu_read  =>
					ras := '0';
					cas := '1';
					pre := '0';
					nop := '0';
				when mpu_pre  =>
					ras := '0';
					cas := '0';
					pre := '1';
					nop := '1';
				when others    =>
					ras := '0';
					cas := '0';
					pre := '0';
					nop := '1';
				end case;
				ctlr_ras <= ras;
				ctlr_cas <= cas;
			else
				ctlr_ras <= '0';
				ctlr_cas <= '0';
			end if;

			state_cas <= cas;
			state_pre <= pre;
			state_nop <= nop;
		end if;
	end process;

	ctlr_b <= ddrdma_bnk;
	ctlr_a <=
		(ctlr_a'range => ctlr_ras) and ddrdma_row when (state_pre or ctlr_ras)='1' else
		std_logic_vector(shift_left(resize(unsigned(ddrdma_col), ctlr_a'length), burst_bits));

end;
