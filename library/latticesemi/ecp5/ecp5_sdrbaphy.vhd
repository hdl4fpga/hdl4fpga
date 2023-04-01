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

library ecp5u;
use ecp5u.components.all;

entity ecp5_sdrbaphy is
	generic (
		gear      : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		rst     : in  std_logic;
		sclk    : in  std_logic;
		eclk    : in  std_logic;

		sys_rst : in  std_logic_vector(0 to gear-1);
		sys_cs  : in  std_logic_vector(0 to gear-1);
		sys_cke : in  std_logic_vector(0 to gear-1);
		sys_b   : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a   : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras : in  std_logic_vector(0 to gear-1);
		sys_cas : in  std_logic_vector(0 to gear-1);
		sys_we  : in  std_logic_vector(0 to gear-1);
		sys_odt : in  std_logic_vector(0 to gear-1);

		sdram_rst : out std_logic;
		sdram_cs  : out std_logic;
		sdram_cke : out std_logic;
		sdram_odt : out std_logic;
		sdram_ras : out std_logic;
		sdram_cas : out std_logic;
		sdram_we  : out std_logic;
		sdram_b   : out std_logic_vector(bank_size-1 downto 0);
		sdram_a   : out std_logic_vector(addr_size-1 downto 0));
end;

library hdl4fpga;

architecture ecp5 of ecp5_sdrbaphy is
begin

	rst_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_rst,
		q(0) => sdram_rst);

	cs_b : block
	begin

		gear1_g : if gear=1 generate
        	cke_i : entity hdl4fpga.ecp5_ogbx
        	generic map (
        		size => 1,
        		gear => gear)
        	port map (
        		rst  => rst,
        		sclk => sclk,
        		d    => sys_cs,
        		q(0) => sdram_cs);
		end generate;

		gear2_g : if gear=2 generate
			signal cs : std_logic;
		begin
			cs_i : oshx2a
			port map (
				rst  => rst,
				sclk => sclk,
				eclk => eclk, 
				d0   => sys_cs(0),
				d1   => sys_cs(1),
				q    => cs);
	
			delay_i : delayg
			generic map (
				del_mode => "DQS_ALIGNED_X2")
			port map (
				a => cs,
				z => sdram_cs);
		end generate;

	end block;

	cke_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_cke,
		q(0) => sdram_cke);

	ras_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_ras,
		q(0) => sdram_ras);

	cas_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_cas,
		q(0) => sdram_cas);

	we_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_we,
		q(0) => sdram_we);

	odt_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => 1,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_odt,
		q(0) => sdram_odt);

	b_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => sdram_b'length,
		gear => gear)
	port map (
		sclk => sclk,
		d    => sys_b,
		q    => sdram_b);

	a_i : entity hdl4fpga.ecp5_ogbx
	generic map (
		size => sdram_a'length,
		gear => gear)
	port map (
		rst  => rst,
		sclk => sclk,
		d    => sys_a,
		q    => sdram_a);

end;
