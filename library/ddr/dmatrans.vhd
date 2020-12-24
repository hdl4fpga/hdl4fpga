
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
use hdl4fpga.ddr_db.all;
use hdl4fpga.ddr_param.all;

entity dmatrans is
	generic (
		fpga          : natural;
		mark          : natural := m6t;
		tcp           : natural := 6000;
 
		bank_size     : natural;
		addr_size     : natural;
		coln_size     : natural);
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

		ctlr_inirdy   : in std_logic;
		ctlr_refreq   : in std_logic;

		ctlr_irdy     : buffer std_logic;
		ctlr_trdy     : in  std_logic;
		ctlr_rw       : out std_logic := '0';
		ctlr_ras      : in  std_logic := '0';
		ctlr_cas      : in  std_logic := '0';
		ctlr_act      : in  std_logic;
		ctlr_b        : out std_logic_vector;
		ctlr_a        : out std_logic_vector;
		ctlr_dio_req  : in  std_logic);

end;

architecture def of dmatrans is

	constant lrcd       : natural := to_ddrlatency(tcp, mark, trcd);
	constant latency    : natural := 2;

	signal ctlrdma_irdy : std_logic;

	signal ddrdma_bnk   : std_logic_vector(ctlr_b'range);
	signal ddrdma_row   : std_logic_vector(ctlr_a'range);
	signal ddrdma_col   : std_logic_vector(dmatrans_iaddr'length-ctlr_a'length-ctlr_b'length-1 downto 0);
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
				ctlr_irdy    <= '0';
				cancel       <= '0';
			elsif cancel='1' then
				load      <= '0';
				reload    <= '0';
				ctlr_irdy <= '0';
				if ctlr_trdy='1' then
					dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
				end if;
			elsif reload='1' then
				if ctlr_trdy='1' then 
					load      <= '0';
					reload    <= '0';
					ctlr_irdy <= '1';
				else
					load      <= '1';
					reload    <= '1';
					ctlr_irdy <= '0';
				end if;
				cancel       <= dmatrans_cnl;
			elsif leoc='1' then
				load      <= '0';
				reload    <= '0';
				cancel       <= dmatrans_cnl;
				ctlr_irdy <= '0';
				if ctlr_trdy='1' then
					dmatrans_rdy <= to_stdulogic(to_bit(dmatrans_req));
				end if;
			elsif ceoc='1' then
				load         <= '1';
				reload       <= '1';
				cancel       <= dmatrans_cnl;
				ctlr_irdy    <= '0';
			elsif ref_req='1' then
				load         <= '1';
				reload       <= '1';
				cancel       <= '0';
				ctlr_irdy    <= '0';
			else
				load         <= '0';
				reload       <= '0';
				cancel       <= dmatrans_cnl;
				ctlr_irdy    <= '1';
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
					ilen  <= dmatrans_ilen;
					iaddr <= dmatrans_iaddr;
				end if;
			end if;
		end if;
	end process;

	act <= ctlr_ras or ctlr_act or ctlr_dio_req;
	dmardy_e : entity hdl4fpga.align
	generic map (
		n => 1,
--		d => (0 to 1-1 => 0),
		d => (0 to 1-1 => lrcd-latency),
		i => (0 to 1-1 => '0'))
	port map (
		clk   => dmatrans_clk,
		ini   => load,
		di(0) => act,
		do(0) => ctlrdma_irdy);

	tlenlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_tlen'length,
		d => (0 to dmatrans_tlen'length-1 => latency))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => tlen,
		do  => dmatrans_tlen);

	taddrlat_e : entity hdl4fpga.align
	generic map (
		n => dmatrans_taddr'length,
		d => (0 to dmatrans_taddr'length-1 => latency))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => taddr,
		do  => dmatrans_taddr);

	collat_e : entity hdl4fpga.align
	generic map (
		n => col'length,
		d => (0 to col'length-1 => latency))
	port map (
		clk => dmatrans_clk,
		ena => ctlrdma_irdy,
		di  => col,
		do  => ddrdma_col);

	dma_e : entity hdl4fpga.ddrdma
	port map (
		clk     => dmatrans_clk,
		load    => load,
		ena     => ctlrdma_irdy,
		iaddr   => iaddr,
		ilen    => ilen,
		taddr   => taddr,
		tlen    => tlen,
		len_eoc => leoc,
		bnk     => ddrdma_bnk,
		row     => ddrdma_row,
		col     => col,
		col_eoc => ceoc);

	ctlr_rw <= dmatrans_we;
	ctlrb_p : process (dmatrans_clk)
	begin
		if rising_edge(dmatrans_clk) then
			if ctlr_ras='1' then
				ctlr_b <= ddrdma_bnk;
			end if;
		end if;
	end process;

	ctlra_p : process (dmatrans_clk)
		variable saved_col : unsigned(ctlr_a'range);
	begin
		if rising_edge(dmatrans_clk) then
			if ctlrdma_irdy='1' then
				saved_col := resize(unsigned(ddrdma_col), ctlr_a'length);
			end if;

			if ctlr_cas='0' then
				ctlr_a <= ddrdma_row;
			else
				if ddr_stdr(mark)=SDRAM then
					ctlr_a <= std_logic_vector(saved_col);
				else
					ctlr_a <= std_logic_vector(shift_left(saved_col,1));
				end if;
			end if;
		end if;
	end process;

end;
