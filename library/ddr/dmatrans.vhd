
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
		lrcd           : natural;
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
	constant mask_addr : std_logic_vector(dmatrans_iaddr'range) := std_logic_vector(shift_left(unsigned'(dmatrans_iaddr'range => '1'), burst_bits-coln_align));
	constant mask_len  : std_logic_vector(dmatrans_ilen'range)  := std_logic_vector(shift_left(unsigned'(dmatrans_ilen'range  => '1'), burst_bits-coln_align));

end;

architecture def of dmatrans is

	constant latency    : natural := 2;

	signal ddrdma_col   : std_logic_vector(coln_size-1 downto coln_align);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal row          : std_logic_vector(ddrdma_row'range);
	signal col          : std_logic_vector(ddrdma_col'range);

	signal leoc         : std_logic;
	signal ceoc         : std_logic;
	signal ilen         : std_logic_vector(dmatrans_ilen'range);
	signal iaddr        : std_logic_vector(dmatrans_iaddr'range);
	signal tlen         : std_logic_vector(dmatrans_tlen'range);
	signal taddr        : std_logic_vector(dmatrans_taddr'range);

	signal init         : std_logic;
	signal cancel       : std_logic;
	signal reload       : std_logic;
	signal load         : std_logic;
 	signal act          : std_logic;

	signal ref_req      : std_logic;
	signal ctlr_act     : std_logic;
	signal ctlr_ras     : std_logic;
	signal ctlr_cas     : std_logic;
	signal ctlrdma_irdy : std_logic;
	signal ena          : std_logic;
begin

	process (dmatrans_clk, ctlr_refreq, ctlr_dio_req)
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
			if init='1' then
				load         <= '1';
				reload       <= '0';
				ctlr_frm     <= '0';
				cancel       <= '0';
			elsif cancel='1' then
				load      <= '0';
				reload    <= '0';
				ctlr_frm  <= '0';
				if ctlr_trdy='1' then
					dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
				end if;
			elsif reload='1' then
				if ctlr_trdy='1' then
					load      <= '0';
					reload    <= '0';
					ctlr_frm  <= '1';
				else
					load      <= '1';
					reload    <= '1';
					ctlr_frm  <= '0';
				end if;
				cancel       <= dmatrans_cnl;
			elsif leoc='1' then
				load      <= '0';
				reload    <= '0';
				cancel       <= dmatrans_cnl;
				ctlr_frm  <= '0';
				if ctlr_trdy='1' then
					dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
				end if;
			elsif ceoc='1' then
				load         <= '1';
				reload       <= '1';
				cancel       <= dmatrans_cnl;
				ctlr_frm     <= '0';
			elsif ref_req='1' then
				load         <= '1';
				reload       <= '1';
				cancel       <= '0';
				ctlr_frm     <= '0';
			else
				load         <= '0';
				reload       <= '0';
				cancel       <= dmatrans_cnl;
				ctlr_frm     <= '1';
			end if;
			init <= to_stdulogic(to_bit(dmatrans_rdy)) xnor to_stdulogic(to_bit(dmatrans_req));
		end if;
	end process;

	load_p : process (dmatrans_clk)
	begin
		if rising_edge(dmatrans_clk) then
			if reload='0' then
				if ceoc='1' then
					ilen  <= tlen;
					iaddr <= taddr;
				elsif ref_req='1' then
					ilen  <= tlen;
					iaddr <= taddr;
				else
					ilen  <= dmatrans_ilen  or not mask_len;
					iaddr <= dmatrans_iaddr;
				end if;
			end if;
		end if;
	end process;

	tlenlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_tlen'length,
		d => (0 to dmatrans_tlen'length-1 => latency))
	port map (
		clk => dmatrans_clk,
		ena => ctlr_cas,
		di  => tlen,
		do  => dmatrans_tlen);

	taddrlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_taddr'length,
		d => (0 to dmatrans_taddr'length-1 => latency))
	port map (
		clk => dmatrans_clk,
		ena => ctlr_cas,
		di  => taddr,
		do  => dmatrans_taddr);

	rowlat_e : entity hdl4fpga.align
	generic map (
		n => row'length,
		d => (0 to row'length-1 => 0))
	port map (
		clk => dmatrans_clk,
		ena => ctlr_cas,
		di  => row,
		do  => ddrdma_row);

	collat_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => 0)) --setif(burst_length=0,latency,latency+2)))
	port map (
		clk => dmatrans_clk,
		ena => ctlr_cas,
		di  => col,
		do  => ddrdma_col);

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
		bnk     => ddrdma_bnk,
		row     => row,
		col     => col,
		col_eoc => ceoc);

	ctlr_rw <= not dmatrans_we;

	process (dmatrans_clk)
		variable ras : std_logic;
		variable cas : std_logic;
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_cmd=mpu_act and ctlr_trdy='1' then
				ras := '1';
			else
				ras := '0';
			end if;

			if (ctlr_cmd=mpu_read or ctlr_cmd=mpu_write) and ctlr_trdy='1' then
				ctlr_cas <= '1';
			else
				ctlr_cas <= '0';
			end if;
		end if;
	end process;

	ctlra_p : process (ctlr_ras, dmatrans_clk)
		variable saved_col : unsigned(ctlr_a'range);
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_ras='1' then
				saved_col := resize(unsigned(ddrdma_col), ctlr_a'length) and unsigned(mask_addr(ctlr_a'range));
			end if;
		end if;

		if ctlr_ras='1' then
			ctlr_a <= ddrdma_row;
			ctlr_b <= ddrdma_bnk;
		else
			ctlr_a <= std_logic_vector(shift_left(saved_col,coln_align));
		end if;
	end process;

end;
