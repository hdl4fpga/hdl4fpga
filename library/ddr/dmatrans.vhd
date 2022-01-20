
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

entity dmatrans is
	generic (
		burst_length   : natural := 0;
		data_gear      : natural;
		bank_size      : natural;
		addr_size      : natural;
		coln_size      : natural);
	port (
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
		ctlr_rw        : out std_logic := '0';
		ctlr_b         : out std_logic_vector;
		ctlr_a         : out std_logic_vector;
		ctlr_dio_req   : in  std_logic);

	constant coln_align : natural := unsigned_num_bits(data_gear)-1;
	constant burst_bits : natural := unsigned_num_bits(setif(burst_length=0,data_gear,burst_length))-1;
	constant mask_len  : std_logic_vector(dmatrans_ilen'range)  := std_logic_vector(shift_left(unsigned'(dmatrans_ilen'range  => '1'), burst_bits-coln_align));

end;

architecture def of dmatrans is

	constant latency    : natural := 2;

	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_col   : std_logic_vector(coln_size-1 downto coln_align);

	signal load         : std_logic;

	signal ref_req      : std_logic;
	signal ctlr_ras     : std_logic;
	signal ctlr_cas     : std_logic;
	signal state_pre    : std_logic;
	signal state_nop    : std_logic;
	signal ctlrdma_irdy : std_logic;
	signal ena          : std_logic;
	signal leoc         : std_logic;
	signal ceoc         : std_logic;
	signal loaded   : std_logic;
begin

	process (dmatrans_clk, ctlr_cmd, ctlr_trdy)
		variable q : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			ref_req <= setif((ctlr_refreq and ctlr_dio_req)='1' and q='0');
			q := ctlr_refreq and ctlr_dio_req;
		end if;
	end process;

	process (dmatrans_clk)
	begin
		if rising_edge(dmatrans_clk) then
			if (to_bit(dmatrans_rdy) xor to_bit(dmatrans_req))='1' then
				if load='0' then
					if leoc='1' then
						ctlr_frm <= '0';
						if ctlr_trdy='1' then
							dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
						end if;
					elsif state_nop='1' then
						ctlr_frm <= '1';
					elsif ceoc='1' then
						ctlr_frm <= '0';
					else
						ctlr_frm <= '1';
					end if;
				end if;
				loaded <= load;
			else
				ctlr_frm <= '0';
				loaded   <= '0';
			end if;
			load <= not to_stdulogic(to_bit(dmatrans_rdy) xor to_bit(dmatrans_req));
		end if;
	end process;

	dma_b : block

		signal bnk   : std_logic_vector(ctlr_b'range);
		signal row   : std_logic_vector(ddrdma_row'range);
		signal col   : std_logic_vector(ddrdma_col'range);
		signal ilen  : std_logic_vector(dmatrans_ilen'range);
		signal iaddr : std_logic_vector(dmatrans_iaddr'range);
		signal tlen  : std_logic_vector(dmatrans_tlen'range);
		signal taddr : std_logic_vector(dmatrans_taddr'range);

		signal pre_load : std_logic;
	begin

		process (loaded, ctlr_cas, ctlr_ras, ceoc, dmatrans_clk)
			variable look_ahead : std_logic;
		begin
			if rising_edge(dmatrans_clk) then
				look_ahead := pre_load;
			end if;
			ena <= pre_load or ((look_ahead or ctlr_cas) and not ceoc);
		end process;

		ilen  <= dmatrans_ilen or not mask_len;
		iaddr <= dmatrans_iaddr;
		dma_e : entity hdl4fpga.ddrdma
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

		fifo_b : block
			constant mask_col : std_logic_vector(col'range) := std_logic_vector(shift_left(unsigned'(col'range => '1'), burst_bits-coln_align));

			signal fifo_frm : std_logic;
			signal bnk_irdy : std_logic;
			signal bnk_trdy : std_logic;
			signal row_irdy : std_logic;
			signal row_trdy : std_logic;
			signal col_irdy : std_logic;
			signal col_in   : std_logic_vector(col'range);
			signal ena1     : std_logic;
		begin

			fifo_frm <= not load;
			process (dmatrans_clk)
			begin
				if rising_edge(dmatrans_clk) then
					pre_load <= loaded or (ceoc and ena1);
					ena1     <= ena;
					row_trdy <= ctlr_ras;
				end if;
			end process;

			bnk_irdy <= loaded or pre_load or ena;
			bnk_trdy <= ctlr_ras or ctlr_cas or (state_pre and ctlr_trdy);
			bnk_e : entity hdl4fpga.fifo
			generic map (
				max_depth => 4,
				latency   => 0,
				check_sov => false,
				check_dov => false,
				gray_code => false)
			port map (
				src_clk   => dmatrans_clk,
				src_mode  => '1',
				src_frm   => fifo_frm,
				src_irdy  => bnk_irdy,
				src_trdy  => open,
				src_data  => bnk,
				dst_clk   => dmatrans_clk,
				dst_mode  => '1',
				dst_frm   => fifo_frm,
				dst_irdy  => open,
				dst_trdy  => bnk_trdy,
				dst_data  => ddrdma_bnk);

			row_irdy <= loaded or (ceoc and ena1);
			row_e : entity hdl4fpga.fifo
			generic map (
				max_depth => 4,
				latency   => 0,
				check_sov => false,
				check_dov => false,
				gray_code => false)
			port map (
				src_clk   => dmatrans_clk,
				src_mode  => '1',
				src_frm   => fifo_frm,
				src_irdy  => row_irdy,
				src_trdy  => open,
				src_data  => row,
				dst_clk   => dmatrans_clk,
				dst_mode  => '1',
				dst_frm   => fifo_frm,
				dst_irdy  => open,
				dst_trdy  => row_trdy,
				dst_data  => ddrdma_row);

			col_in   <= col and mask_col;
			col_irdy <= ena;
			col_e : entity hdl4fpga.fifo
			generic map (
				max_depth => 4,
				latency   => 0,
				check_sov => false,
				check_dov => false,
				gray_code => false)
			port map (
				src_clk   => dmatrans_clk,
				src_mode  => '1',
				src_frm   => fifo_frm,
				src_irdy  => col_irdy,
				src_trdy  => open,
				src_data  => col,
				dst_clk   => dmatrans_clk,
				dst_mode  => '1',
				dst_frm   => fifo_frm,
				dst_irdy  => open,
				dst_trdy  => ctlr_cas,
				dst_data  => ddrdma_col);

		end block;

	end block;

	ctlr_rw <= not dmatrans_we;

	process (ceoc, dmatrans_clk)
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

			state_pre <= pre;
			state_nop <= nop;
		end if;
	end process;

	ctlr_b <= ddrdma_bnk;
	ctlr_a <=
		ddrdma_row when ctlr_ras='1' else
		std_logic_vector(shift_left(resize(unsigned(ddrdma_col), ctlr_a'length), coln_align));

end;
