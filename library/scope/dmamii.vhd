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

entity dmamii is
	generic (
		BRAM_SIZE  : natural := 9;
		DATA_SIZE  : natural := 32);
	port (
		dmamii_clk    : in  std_logic;
		dmamii_gnt    : in  std_logic;
		dmamii_rdy    : out std_logic;

		dmamii_di_req : in  std_logic;
		dmamii_di     : out std_logic;
		dmamii_do_req : in  std_logic;
		dmamii_do_rdy : out std_logic;
		dmamii_do     : out std_logic;

		mii_clk       : in  std_logic;
		mii_req       : in  std_logic;
		mii_rdy       : out std_logic;
		miirx_ena     : in  std_logic;
		miirx_dat     : in  std_logic;
		miitx_ena     : out std_logic;
		miitx_dat     : out std_logic);
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of dmaii is
	constant bram_num : natural := (unsigned_num_bits(ddrs_di'length-1)+bram_size)-(unsigned_num_bits(1024/2**0*8-1));

	signal dma_addr   : unsigned(0 to bram_size-1);
	signal mii_addr   : unsigned(0 to bram_size-1);

	signal byte_sel   : unsigned(0 to unsigned_nun_bits(dmamii_di'length/miitx_dat'length-1));
	signal byte_addr  : std_logic_vector(1 to unsigned_nun_bits(dmamii_di'length/miitx_dat'length-1));
begin

	process (dmamii_clk)
		variable addr : unsigned(addri'range);
	begin
		if rising_edge(ddrs_clk) then
			if dmamii_gnt='0' then
				addr := (others => '0');
				dmamii_rdy <= '0';
			elsif dmamii_di_rdy='1' then
				if addr(0)='0' then
					addr := addr + 1;
				end if;
				dmamii_rdy <= addr(0);
			end if;
			dma_addr <= addr;
		end if;
	end process; 

	process (mii_clk)
		variable addr : unsigned(addri'range);
	begin
		if rising_edge(mii_clk) then
			if mii_req='0' then
				addr     := (others => '0');
				byte_sel <= (others => '0');
			elsif byte_sel(0)='1' then
				byte_sel <= (others => '0');
				if addr(0)='0' then
					addr := addr + 1;
				end if;
			else
				byte_sel <= byte_sel + 1;
			end if;
			mii_rdy  <= addr(0);
			mii_addr <= addr;
		end if;
	end process;

	bram_e : entity hdl4fpga.bram
	port map (
		clka  => dmamii_clk,
		wea   => dmamii_di_req,
		addra => dma_addr, 
		dia   => dmamii_di,
		doa   => dmamii_do,

		clkb  => mii_clk,
		web   => miirx_ena,
		addrb => mii_addr
		dib   => miirx_dat, 
		dob   => miitx_dat);

	dmamiidordy_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => 2))
	port map (
		clk   => dmamii_clk,
		di(0) => dmamii_do_req
		do(0) => dmamii_do_rdy);

	miitxena_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 => 2))
	port map (
		clk   => mii_clk,
		di(0) => mii_req
		do(0) => miitx_ena);

	bytesel_e : entity hdl4fpga.align
	generic map (
		n => byte_sel'range,
		d => (0 => 2))
	port map (
		clk => mii_clk,
		di  => byte_sel(1 to byte_sel'right),
		do  => byte_addr);

	txd <= word2byte(
		reverse(miitx_dat),
		not byte_addr);
	miitx_dat <= txd;
end;
