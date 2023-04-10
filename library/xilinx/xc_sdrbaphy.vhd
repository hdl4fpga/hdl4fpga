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

library hdl4fpga;
use hdl4fpga.profiles.all;

entity xc_sdrbaphy is
	generic (
		bank_size  : natural;
		addr_size  : natural;
		gear       : natural;
		device     : fpga_devices;
		ba_latency : natural);
	port (
		grst      : in  std_logic := '0';
		clk       : in  std_logic;
		sys_rst   : in  std_logic_vector(gear-1 downto 0) := (others => '-');
		sys_cs    : in  std_logic_vector(gear-1 downto 0);
		sys_cke   : in  std_logic_vector(gear-1 downto 0);
		sys_b     : in  std_logic_vector(gear*bank_size-1 downto 0);
		sys_a     : in  std_logic_vector(gear*addr_size-1 downto 0);
		sys_ras   : in  std_logic_vector(gear-1 downto 0);
		sys_cas   : in  std_logic_vector(gear-1 downto 0);
		sys_we    : in  std_logic_vector(gear-1 downto 0);
		sys_odt   : in  std_logic_vector(gear-1 downto 0);

		sdram_rst : out std_logic;
		sdram_cs  : out std_logic_vector;
		sdram_cke : out std_logic_vector;
		sdram_odt : out std_logic_vector;
		sdram_ras : out std_logic;
		sdram_cas : out std_logic;
		sdram_we  : out std_logic;
		sdram_b   : out std_logic_vector(bank_size-1 downto 0);
		sdram_a   : out std_logic_vector(addr_size-1 downto 0));
end;

architecture xilinx of xc_sdrbaphy is

	signal rst : std_logic_vector(gear-1 downto 0) := (others => '-');
	signal cs  : std_logic_vector(gear-1 downto 0);
	signal cke : std_logic_vector(gear-1 downto 0);
	signal b   : std_logic_vector(gear*bank_size-1 downto 0);
	signal a   : std_logic_vector(gear*addr_size-1 downto 0);
	signal ras : std_logic_vector(gear-1 downto 0);
	signal cas : std_logic_vector(gear-1 downto 0);
	signal we  : std_logic_vector(gear-1 downto 0);
	signal odt : std_logic_vector(gear-1 downto 0);

begin

	latency_b : block
	begin
    	b_e : entity hdl4fpga.latency
    	generic map (
    		n => sys_b'length,
    		d => (sys_b'range => ba_latency))
    	port map (
    		clk => clk,
    		di  => sys_b,
    		do  => b);

    	a_e : entity hdl4fpga.latency
    	generic map (
    		n => sys_a'length,
    		d => (sys_a'range => ba_latency))
    	port map (
    		clk => clk,
    		di  => sys_a,
    		do  => a);

    	sysrst_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_rst,
    		do => rst);

    	cs_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_cs,
    		do => cs);

    	cke_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_cke,
    		do => cke);

    	ras_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_ras,
    		do => ras);

    	cas_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_cas,
    		do => cas);

    	we_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_we,
    		do => we);

    	odt_e : entity hdl4fpga.latency
    	generic map (
    		n => gear,
    		d => (0 to gear-1=> ba_latency))
    	port map (
    		clk   => clk,
    		di => sys_odt,
    		do => odt);
	end block;

	rst_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => 1,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => rst,
		q(0)      => sdram_rst);

	cke_g : for i in sdram_cke'range generate
		cke_i : entity hdl4fpga.ogbx
		generic map (
			device    => device,
			size      => 1,
			gear      => gear)
		port map (
			rst       => grst,
			clk       => clk,
			d         => cke,
			q(0)      => sdram_cke(i));
	end generate;

	cs_g : for i in sdram_cs'range generate
		cs_i : entity hdl4fpga.ogbx
		generic map (
			device    => device,
			size      => 1,
			gear      => gear)
		port map (
			rst       => grst,
			clk       => clk,
			d         => cs,
			q(0)      => sdram_cs(i));
	end generate;

	ras_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => 1,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => ras,
		q(0)      => sdram_ras);

	cas_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => 1,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => cas,
		q(0)      => sdram_cas);

	we_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => 1,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => we,
		q(0)      => sdram_we);

	odt_g : for i in sdram_odt'range generate
		odt_i : entity hdl4fpga.ogbx
		generic map (
			device    => device,
			size      => 1,
			gear      => gear)
		port map (
			rst       => grst,
			clk       => clk,
			d         => odt,
			q(0)      => sdram_odt(i));
	end generate;

	ba_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => sdram_b'length,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => b,
		q         => sdram_b);

	a_i : entity hdl4fpga.ogbx
	generic map (
		device    => device,
		size      => sdram_a'length,
		gear      => gear)
	port map (
		rst       => grst,
		clk       => clk,
		d         => a,
		q         => sdram_a);

end;