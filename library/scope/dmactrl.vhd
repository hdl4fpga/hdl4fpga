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

entity dmactrl is
	generic (
		DDR_BANKSIZE : natural :=  2;
		DDR_ADDRSIZE : natural := 13;
		DDR_CLNMSIZE : natural :=  6;
		DDR_LINESIZE : natural := 16);
	port (

		dmactrl_rst     : in  std_logic;
		dmactrl_clk     : in  std_logic;
		dmactrl_devreq  : in  std_logic_vector;
		dmactrl_devid   : in  std_logic_vector;
		dmactrl_devaddr : in  std_logic_vector;

		ddr_ref_req     : in  std_logic;
		ddr_cmd_req     : out std_logic;
		ddr_cmd_rdy     : in  std_logic;

		ddr_bnka        : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_rowa        : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_cola        : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);

		ddr_act         : in  std_logic;
		ddr_cas         : in  std_logic);

end;


architecture def of dmactrl is
	signal dma_addr      : std_logic_vector(dmactrl_devaddr'length/2**dmactrl_devid'length-1 downto 0);
	signal ddr_base_addr : std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
	signal ddr_dma_addr  : std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1-1 downto 0);
begin

	dma_addr <= word2byte(dmactrl_devaddr, dmactrl_devid);

	dma_e : entity hdl4fpga.dma
	port map (
		dma_clk       => ddrctrl_clk,
		ddr_base_addr => ddr_base_addr,
		ddr_dma_addr  => ddr_dma_addr,
		dma_ddr_req   => dma_ddr_req,
		dma_ddr_rdy   => dma_ddr_rdy,
		dma_devid     => dma_devid,
		dma_devwe_ena => dma_devwe_ena,
		dma_devwe_req => dma_devwe_req,
		dma_devaddr   => dma_addr);

	ddrtans_e : entity hdl4fpga.ddrtrans
	port map (
		ddrtrans_rst  => ddrctrl_rst,
		ddr_clk       => ddrctrl_clk,
		ddr_base_addr => ddr_base_addr,
		ddr_dma_addr  => ddr_dma_addr,
		ddr_ref_req   => ddr_ref_req,
		ddr_cmd_req   => ddr_cmd_req,
		ddr_cmd_rdy   => ddr_cmd_rdy,
		ddr_dma_req   => ddr_dma_req,
		ddr_dma_rdy   => ddr_dma_rdy,
		ddr_act       => ddr_act,
		ddr_cas       => ddr_cas,
		ddr_bnka      => ddr_bnka,
		ddr_rowa      => ddr_rowa,
		ddr_cola      => ddr_cola);

end;
