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

entity ddrtrans is
	generic (
		DDR_BANKSIZE : natural :=  2;
		DDR_ADDRSIZE : natural := 13;
		DDR_CLNMSIZE : natural :=  6);
	port (
		ddr_rst       : in std_logic;
		ddr_clk       : in  std_logic;

		ddr_base_addr : in  std_logic_vector(DDR_BANKSIZE+DDR_ADDRSIZE+DDR_CLNMSIZE-1 downto 0);
		ddr_ref_req   : in  std_logic;
		ddr_cmd_req   : out std_logic;
		ddr_cmd_rdy   : in  std_logic;

		ddr_bnk       : out std_logic_vector(DDR_BANKSIZE-1 downto 0);
		ddr_row       : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);
		ddr_col       : out std_logic_vector(DDR_ADDRSIZE-1 downto 0);

		ddr_act       : in  std_logic;
		ddr_cas       : in  std_logic;

		ddr_trans_req : in  std_logic);
	);
end;


architecture def of ddrtrans is
	signal ddr_addr      : std_logic_vector(DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE downto 0);
	signal base_co   : std_logic_vector(0 to 3-1);
	signal base_load : std_logic;
	signal base_addr : std_logic_vector(ddr_addr'range);
begin

	process (ddr_clk, ddr_addr(ddr_clnmsize))
	begin
		if ddr_addr(ddr_clnmsize)='1' then
			ddr_cmd_req <= '0';
		elsif rising_edge(ddr_clk) then
			if ddr_rst='1' then
				ddr_cmd_req <= '0';
			elsif ddr_ref_req='1' then
				ddr_cmd_req <= '0';
			elsif ddr_trans_req='0' then
				ddr_cmd_req <= '0';
			elsif ddr_cmd_rdy='1' then
				if ddr_trans_req='1' then
					ddr_cmd_req <= '1';
				end if;
			end if;
		end if;
	end process;

	process (ddr_clk)
	begin
		if rising_edge(ddr_clk) then
			if ddr_act='1' then
				ddr_bnka <= std_logic_vector(resize(shift_right(unsigned(ddr_addr),1+DDR_ADDRSIZE+1+DDR_CLNMSIZE), DDR_BANKSIZE)); 
			end if;
			ddr_rowa <= std_logic_vector(resize(shift_right(unsigned(ddr_addr),1+DDR_CLNMSIZE), DDR_ADDRSIZE)); 
			ddr_cola <= std_logic_vector(resize(resize(shift_left (unsigned(ddr_addr), 3), DDR_CLNMSIZE+3), DDR_ADDRSIZE)); 
		end if;
	end process;

	base_addr <= std_logic_vector(
		resize(shift_right(unsigned(ddr_addr), DDR_ADDRSIZE+DDR_CLNMSIZE+0)(DDR_BANKSIZE+DDR_ADDRSIZE+DDR_CLNMSIZE-1 downto DDR_ADDRSIZE+DDR_CLNMSIZE+0)), DDR_BANKSIZE+1)) &
		resize(shift_right(unsigned(ddr_addr),              DDR_CLNMSIZE+0)(             DDR_ADDRSIZE+DDR_CLNMSIZE-1 downto              DDR_CLNMSIZE+0)), DDR_ADDRSIZE+1)) &
		resize(shift_right(unsigned(ddr_addr),                           0)(                          DDR_CLNMSIZE-1 downto                           0)), DDR_CLNMSIZE+1));

	base_load <= ddr_req or base_co(0);
	dma_cntr_e : entity hdl4fpga.counter
	generic map (
		stage_size => (
			2 => DDR_BANKSIZE+1+DDR_ADDRSIZE+1+DDR_CLNMSIZE+1,
			1 => DDR_ADDRSIZE+1+DDR_CLNMSIZE+1,
			0 => DDR_CLNMSIZE+1))
	port map (
		clk  => ddr_clk,
		load => base_load,
		ena  => ddr_cas,
		data => base_addr,
		qo   => ddr_addr,
		co   => base_co);

end;
