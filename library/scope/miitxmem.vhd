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

entity miitxmem is
	generic (
		bram_size : natural := 9;
		data_size : natural := 32);
	port (
		ddrs_clk : in std_logic;
		ddrs_gnt : in std_logic;
		ddrs_di_rdy : in std_logic;
		ddrs_di : in std_logic_vector(data_size-1 downto 0);

		output_clk  : in  std_logic;
		output_a0   : out std_logic;
		output_addr : in  std_logic_vector(bram_size-1 downto 1);
		output_data : out std_logic_vector(data_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

architecture def of miitxmem is
	constant bram_num : natural := 2;

	subtype aword is std_logic_vector(bram_size-1 downto 0);
	type aword_vector is array(natural range <>) of aword;

	subtype dword is std_logic_vector(data_size-1 downto 0);
	type dword_vector is array(natural range <>) of dword;

	signal addri : std_logic_vector(0 to bram_size-1);

	signal wr_address : std_logic_vector(0 to bram_size-1);
	signal wr_ena  : std_logic;
	signal wr_data : dword;

	signal rd_address : std_logic_vector(0 to bram_size-1);

begin

	process (ddrs_clk)
		variable addri0_edge : std_logic;
	begin
		if rising_edge(ddrs_clk) then
			addri <= dec (
				cntr => addri,
				ena  => not ddrs_gnt or ddrs_di_rdy,
				load => not ddrs_gnt,
				data => 2**bram_size/2-1);

			wr_ena <= ddrs_di_rdy;
			rd_address(0) <= not addri(0);
		end if;
	end process; 

	wr_address_d : entity hdl4fpga.align
	generic map (
		n => wr_address'length,
		d => (wr_address'range => 1))
	port map (
		clk => ddrs_clk,
		di  => addri(wr_address'range),
		do  => wr_address);

	wr_data_d : entity hdl4fpga.align
	generic map (
		n => ddrs_di'length,
		d => (ddrs_di'range => 1))
	port map (
		clk => ddrs_clk,
		di  => ddrs_di,
		do  => wr_data);

	output_a0 <= rd_address(0);
	rd_address(1 to bram_size-1) <= output_addr;
	bram_e : entity hdl4fpga.dpram
	port map (
		wr_clk => ddrs_clk,
		wr_addr => wr_address, 
		wr_ena => wr_ena,
		wr_data => wr_data,
		rd_clk => output_clk,
		rd_addr => rd_address,
		rd_data => output_data);
end;
