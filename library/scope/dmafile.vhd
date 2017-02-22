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

		dma_regid     : in  std_logic_vector;
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

	signal dmaid         : std_logic_vector(dma_regid'range);
	signal dmafile_raddr : std_logic_vector(dma_id'range);
	signal dmafile_we    : std_logic;
	signal dmafile_waddr : std_logic_vector;
	signal dmawe_ena     : std_logic;
	signal dly_ddrrdy    : std_logic;

begin

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			dly_ddrrdy <= dma_ddr_rdy;
		end if;
	end process;

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			if dma_ddr_rdy='1' then
				dma_id <= dma_reqid;
			end if;
		end if;
	end process;

	dmawe_dis <= not dly_ddrrdy and dma_ddr_rdy;
	dmafile_we <= 
		'1' when dmawe_dis='1'  else
		'1' when dma_we_req='1' else
		'0';

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then

		end if;
	end process;

	dmafile_waddr <= 
		dma_regid when dmawe_dis='1' else;
		dma_id;

	dmafile_wdata <= 
		dma_ddr_addr when dmawe_dis='1' else
		to_dmaaddr(dev_addr) when dma_ddr_rdy='1' else
	
	dmafile_raddr <= dma_regid;
	dmafile_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => dma_clk,
		wr_ena  => dmafile_we,
		wr_addr => dmafile_waddr,
		wr_data => dmafile_wdata,
		rd_addr => dmafile_raddr,
		rd_data => dma_base_addr);
	dma_we_ena  <= not dmawe_dis;
end;
