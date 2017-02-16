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

entity dma is
	generic (
		DDR_BANKSIZE   : natural :=  2;
		DDR_ADDRSIZE   : natural := 13;
		DDR_CLNMSIZE   : natural :=  6);
	port (
		dma_rst        : in  std_logic;
		dma_clk        : in  std_logic;
		dma_base_addr  : out std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
		dma_ddr_addr   : in  std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
		dma_trans_req  : out std_logic := '1';

		dev_trans_id   : in  std_logic_vector;
		dev_trans_addr : in  std_logic_vector);
end;

architecture def of dataio is
	subtype addrword_vector is array (natural range <>) of std_logic_vector(dma_base_addr'range);
	signal  dmadev_addr : addrword_vector(2**dev_id'length-1 downto 0);

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

begin

	dma_dev_addr <= 
	   to_dmaaddr(dev_trans_addr) when else
	   dma_ddr_addr;

	dma_file_e : entity hdl4fpga.dpram
	port map (
		wr_clk  => dma_clk,
		wr_ena  => 
		wr_addr => dev_trans_id,
		wr_data => dma_dev_addr,
		rd_addr => dev_trans_id,
		rd_data => dma_base_addr);

end;
