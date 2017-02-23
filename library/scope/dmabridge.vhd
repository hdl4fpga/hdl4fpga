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
		DDR_BANKSIZE   : natural :=  2;
		DDR_ADDRSIZE   : natural := 13;
		DDR_CLNMSIZE   : natural :=  6;
		DDR_LINESIZE   : natural := 16;
	port (
		dmabridge_rst  : in  std_logic;
		dmabridge_clk  : in  std_logic;
		dmabridge_addr : in  std_logic_vector;
		dmactrl_we     : out std_logic;
		dmactrl_reg    : in  std_logic_vector;
		dmactrl_req    : in  std_logic_vector;

		ddr_ref_req    : in  std_logic;
		ddr_cmd_req    : out std_logic;
		ddr_cmd_rdy    : in  std_logic;

		ddr_act        : in  std_logic;
		ddr_cas        : in  std_logic;
		ddr_rw         : out std_logic;
		ddr_bnka       : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_rowa       : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_cola       : out std_logic_vector(DDR_ADDRSIZE-1 downto 0));

		dev_data       : in  std_logic_vector;
		dev_req        : in  std_logic_vector;
		dev_gnt        : out std_logic_vector);
end;

architecture def of dmabridge is
	constant num_of_dev : natural := 2;

	signal dmactrl_req  : std_logic;
	signal gnt_id       : unsigned;
	signal req_id       : unsigned;
	signal bus_gnt      : std_logic_vector;
	signal bus_busy     : std_logic;
	signal bus_gntd     : std_logic;

begin

	process (dmctrl_req)
		variable id : unsigned(bus_id'range);
	begin
		id := (others => '1');
		for i in dmctrl_req'reverse_range loop
			if dmctrl_req(i)='1' then
				id := to_unsigned(i, id'length);
			end if;
		end if;
		req_id <= id;
	end process;

	process (dmactrl_clk)
		variable busy : std_logic;
	begin
		if rising_edge(dmactrl_clk) then
			if dmactrl_req='1' then
				if req_id < gnt_id then
					dev_gnt <= (others => '0');
				elsif dmctrl_req = (dmctrl_req'range => '0') then
					dev_gnt <= (others => '0');
				end if;
			elsif dmctrl_req /= (dmctrl_req'range => '0') then
				bus_gnt(to_unsigned(req_id)) <= '1';
			end if;
			gnt_id <= req_id;
		end if;
	end process;
	dmactrl_req <= '1';

	dmactrl_e : entity hdl4fpga.dmactrl
	generic map (
		DDR_BANKSIZE  => DDR_BANKSIZE,
		DDR_ADDRSIZE  => DDR_ADDRSIZE,
		DDR_CLNMSIZE  => DDR_CLNMSIZE)
	port map (
		dmactrl_rst   => dmabridge_rst,
		dmactrl_clk   => dmabridge_clk,
		dmactrl_req   => dmactrl_req,
		dmactrl_rdy   => dmactrl_rdy,
		dmactrl_act   => gnt_id,
		dmactrl_addr  => dmactrl_addr,
		dmactrl_we    => dmactrl_we,
		dmactrl_reg   => dmactrl_reg,

		ddr_ref_req   => ddr_ref_req,
		ddr_cmd_req   => ddr_cmd_req,
		ddr_cmd_rdy   => ddr_cmd_rdy,

		ddr_act       => ddr_act,
		ddr_cas       => ddr_cas,
		ddr_bnka      => ddr_bnka,
		ddr_rowa      => ddr_rowa,
		ddr_cola      => ddr_cola);

end;
