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

entity dmadevice is
	generic (
		DDR_BANKSIZE  : natural :=  2;
		DDR_ADDRSIZE  : natural := 13;
		DDR_CLNMSIZE  : natural :=  6;
		DDR_LINESIZE  : natural := 16;
		PAGE_SIZE     : natural :=  9;
		DDR_TESTCORE  : boolean := FALSE);
	port (
		dmabridge_rst : in std_logic;

		ddr_ref_req   : in  std_logic;
		ddr_cmd_req   : out std_logic;
		ddr_cmd_rdy   : in  std_logic;

		ddr_act       : in  std_logic;
		ddr_cas       : in  std_logic;
		ddr_rw        : out std_logic;
		ddr_bnka      : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_rowa      : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_cola      : out std_logic_vector(DDR_ADDRSIZE-1 downto 0));

		ddr_di_req    : in  std_logic;
		ddr_di_rdy    : out std_logic;
		ddr_di        : out std_logic_vector;
		ddr_do_rdy    : in  std_logic;
		ddr_do        : in  std_logic_vector;
		
		input_clk     : in  std_logic;
		input_req     : in  std_logic;
		input_rdy     : out std_logic;
		input_addr    : in  std_logic;
		input_data    : in  std_logic_vector;

		miitx_clk     : in  std_logic;
		miitx_req     : in  std_logic;
		miitx_rdy     : out std_logic;
		miitx_ena     : out std_logic;
		miitx_addr    : in  std_logic_vector;
		miitx_dat     : out std_logic_vector);
end;

architecture def of dmadevice is
	signal dmactrl_req    : std_logic_vector;
	signal dmactrl_reg    : std_logic_vector(1-1 downto 0);
	signal dmactrl_we     : std_logic;
	signal dmabridge_addr : std_logic_vector;
begin

	with dmactrl_reg select
	dmabridge_addr <=
   		input_addr when "0",
		miitx_addr when "1";

	process (dmabridge_clk)
		variable cntr : unsigned(0 to dmacltr_req'length);
	begin
		if rising_edge(dmabridge_clk) then
			if dmabridge_rst='1' then
				cntr := to_unsigned(1, cntr'length);
			elsif cntr(0) = 0 then
				cntr := cntr - 1;
			end if;
			dmactrl_reg <= std_logic_vector(cntr);
			dmactrl_we  <= not cntr(0);
		end if;
	end process;

	dmainput_e : entity hdl4fpga.dmainput
	port map (
		dmainput_clk    => dmabridge_clk,
		dmainput_rdy    => ddrinput_rdy,
		dmainput_req    => ddrinput_req,
		dmainput_do_req => inputddr_di_req,
		dmainput_do     => inputddr_di,

		input_clk       => input_clk,
		input_req       => input_req, 
		input_data      => input_data);

	dmamii_e : entity hdl4fpga.dmamii
	generic map (
		BRAM_SIZE => unsigned_num_bits(2**PAGE_SIZE*32/DDR_LINESIZE-1),
		DATA_SIZE => DDR_LINESIZE)
	port map (
		dmamii_clk    => dmabrige_clk,
		dmamii_rdy    => ddrmii_rdy,
		dmamii_req    => ddrmii_req,
		dmamii_di_rdy => ddr_do_rdy,
		dmamii_di     => ddr_do,

		miitx_clk     => miitx_clk,
		miitx_rdy     => miitx_rdy,
		miitx_req     => miitx_req,
		miitx_ena     => miitx_ena,
		miitx_dat     => miitx_dat);

	dmactrl_req(0) <= ddrinput_req;
	dmactrl_req(1) <= ddrmii_req;

	dmabridge_e : entity hdl4fpga.dmabridge
	generic map (
		DDR_BANKSIZE   => DDR_BANKSIZE,
		DDR_ADDRSIZE   => DDR_ADDRSIZE,
		DDR_CLNMSIZE   => DDR_CLNMSIZE)
	port map (
		dmabridge_rst  => dmabrigge_rst,
		dmabridge_clk  => dmabrigge_clk,
		dmabridge_addr => dmabridge_addr,

		dmactrl_we     => dmactrl_we,
		dmactrl_reg    => dmactrl_reg,
		dmactrl_req    => dmactrl_req,

		ddr_ref_req    => ddr_ref_req,
		ddr_cmd_req    => ddr_cmd_req,
		ddr_cmd_rdy    => ddr_cmd_rdy,

		ddr_act        => ddr_act,
		ddr_cas        => ddr_cas,
		ddr_bnka       => ddr_bnka,
		ddr_rowa       => ddr_rowa,
		ddr_cola       => ddr_cola,

		dev_data       => dev_data,
		dev_req        => dev_req,
		dev_gnt        => dev_gnt);

end;
