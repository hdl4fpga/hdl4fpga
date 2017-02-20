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

entity dmabridge is
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
		input_data    : in  std_logic_vector;

		miitx_clk     : in  std_logic;
		miitx_req     : in  std_logic;
		miitx_rdy     : out std_logic;
		miitx_ena     : out std_logic;
		miitx_dat     : out std_logic_vector);
end;

architecture def of dataio is
	constant num_of_dev    : natural := 2;

	signal dmactrl_devid   : std_logic_vector(1-1 downto 0);
	signal dmactrl_devreq  : std_logic;
	signal dmactrl_devaddr : std_logic_vector(num_of_dev*(DDR_BANKSIZE+DDR_ADDRSIZE+DDR_CLNMSIZE)-1 downto 0);
	signal dev_busreq      : std_logic_vector;
	signal bus_id          : std_logic_vector;
	signal bus_gnt         : std_logic_vector;
	signal bus_busy        : std_logic;

begin

	process (bus_req)
		variable id : std_logic_vector(bus_id'range);
	begin
		id := (others => '-');
		for i in bus_req'reverse_range loop
			if bus_req(i)='1' then
				id := std_logic_vector(to_unsigned(i, id'length));
			end if;
		end if;
		bus_id <= id;
	end process;

	process (dmactrl_clk)
	begin
		if rising_edge(dmactrl_clk) then
			for i in bus_req'range loop
				if bus_busy='1' then
					bus_gnt <= (others => '0');
					if bus_gnt=(bus_gnt'range => '0') then
						bus_gnt(i) <= '1';
					end if;
				end if;
			end loop;
		end if;
	end process;

	dmactrl_e : entity hdl4fpga.dmactrl
	generic map (
		DDR_BANKSIZE     => DDR_BANKSIZE,
		DDR_ADDRSIZE     => DDR_ADDRSIZE,
		DDR_CLNMSIZE     => DDR_CLNMSIZE)
	port map (
		dmactrl_rst      => dmabrigge_rst,
		dmactrl_clk      => dmabrigge_clk,
		dmactrl_devreq   => dmactrl_devreq,
		dmactrl_devrdy   => dmactrl_devrdy,
		dmactrl_devid    => dmactrl_devid,
		dmactrl_devaddr  => dmactrl_devaddr,
		dmactrl_devweena => dmactrl_devweena,
		dmactrl_devwereq => dmactrl_devwereq,

		ddr_ref_req      => ddr_ref_req,
		ddr_cmd_req      => ddr_cmd_req,
		ddr_cmd_rdy      => ddr_cmd_rdy,

		ddr_act          => ddr_act,
		ddr_cas          => ddr_cas,
		ddr_bnka         => ddr_bnka,
		ddr_rowa         => ddr_rowa,
		ddr_cola         => ddr_cola);

	dmainput_e : entity hdl4fpga.dmainput
	port map (
		input_clk        => input_clk,
		input_req        => input_req, 
		input_data       => input_data,

		dmainput_clk     => dmabridge_clk,
		dmainput_req     => dmainput_req,
		dmainput_do_req  => inputddr_di_req,
		dmainput_do      => inputddr_di);

	dmamii_e : entity hdl4fpga.dmamii
	generic map (
		BRAM_SIZE => unsigned_num_bits(2**PAGE_SIZE*32/DDR_LINESIZE-1),
		DATA_SIZE => DDR_LINESIZE)
	port map (
		dmamii_clk    => dmabrige_clk,
		dmamii_rdy    => ddr2mii_rdy,
		dmamii_req    => ddr2mii_req,
		dmamii_di_rdy => ddr_do_rdy,
		dmamii_di     => ddr_do,

		miitx_clk     => miitx_clk,
		miitx_rdy     => miitx_rdy,
		miitx_req     => miitx_req,
		miitx_ena     => miitx_ena,
		miitx_dat     => miitx_dat);
end;
