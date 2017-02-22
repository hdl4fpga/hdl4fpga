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

entity dmafile is
	generic (
		DDR_BANKSIZE  : natural :=  2;
		DDR_ADDRSIZE  : natural := 13;
		DDR_CLNMSIZE  : natural :=  6);
	port (
		dma_clk       : in  std_logic;
		dma_base_addr : out std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
		dma_ddr_addr  : in  std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
		dma_ddr_rdy   : in  std_logic;
		dma_ddr_act   : in  std_logic_vector;
		dma_reg_id    : in  std_logic_vector;
		dma_reg_we    : in  std_logic;
		dma_addr      : in  std_logic_vector);
end;

architecture def of dmafile is

	function to_dmaaddr (
		constant addr : std_logic_vector)
		return std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0) is 
	begin
		return std_logic_vector(
			resize(
				shift_right(
					unsigned(ddr_addr),
					DDR_ADDRSIZE+DDR_CLNMSIZE+0)(DDR_BANKSIZE+DDR_ADDRSIZE+DDR_CLNMSIZE-1 downto DDR_ADDRSIZE+DDR_CLNMSIZE+0),
				DDR_BANKSIZE+1) &
			resize(
				shift_right(
					unsigned(ddr_addr),
					DDR_CLNMSIZE+0)(DDR_ADDRSIZE+DDR_CLNMSIZE-1 downto DDR_CLNMSIZE+0),
				DDR_ADDRSIZE+1) &
			resize(
				shift_right(
					unsigned(ddr_addr),
					0)(DDR_CLNMSIZE-1 downto 0),
				DDR_CLNMSIZE+1));
	end;

	signal dmafile_raddr : std_logic_vector(dma_wid'range);
	signal dmafile_waddr : std_logic_vector;
	signal ddr_addr      : std_logic_vector(dma_ddr_addr'range);
	signal dma_act       : std_logic_vector(dma_ddr_act'range);
begin

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			if dma_reg_we='0' then
				ddr_addr <= dma_ddr_addr;
			end if;
		end if;
	end process;

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			if dma_ddr_rdy='1' then
				dma_act <= ddr_dma_act;
			end if;
		end if;
	end process;

	dmafile_waddr <= 
		ddr_reg_wid when dma_reg_we='0' else;
		dma_act;

	dmafile_wdata <= 
		ddr_addr when dma_reg_we='0' else
		to_dmaaddr(dev_addr);
	
	dmafile_raddr <= dma_regid;
	dmafile_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => dma_clk,
		wr_ena  => '1',
		wr_addr => dmafile_waddr,
		wr_data => dmafile_wdata,
		rd_addr => dmafile_raddr,
		rd_data => dma_base_addr);
end;
