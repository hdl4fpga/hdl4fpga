-- Copyright (c) 2015 Miguel Angel Sagreras                                       --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
--                                                                                --

library ieee;
use ieee.std_logic_1164.all;

library hdl4fpga;
use hdl4fpga.profiles.all;

entity alt_sdrbaphy is
	generic (
		device    : fpga_devices;
		data_edge : string  := "SAME_EDGE";
		gear      : natural := 2;
		bank_size : natural := 2;
		addr_size : natural := 13);
	port (
		rst       : in  std_logic := '0';
		clk0      : in  std_logic;
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

architecture xilinx of alt_sdrbaphy is
begin

	rst_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => 1,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_rst,
		q(0)      => sdram_rst);

	cke_g : for i in sdram_cke'range generate
		cke_i : entity hdl4fpga.alt_ogbx
		generic map (
			device    => device,
			data_edge => data_edge,
			size      => 1,
			gear      => gear)
		port map (
			rst       => rst,
			clk       => clk0,
			d         => sys_cke,
			q(0)      => sdram_cke(i));
	end generate;

	cs_g : for i in sdram_cs'range generate
		cs_i : entity hdl4fpga.alt_ogbx
		generic map (
			device    => device,
			data_edge => data_edge,
			size      => 1,
			gear      => gear)
		port map (
			rst       => rst,
			clk       => clk0,
			d         => sys_cs,
			q(0)      => sdram_cs(i));
	end generate;

	ras_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => 1,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_ras,
		q(0)      => sdram_ras);

	cas_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => 1,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_cas,
		q(0)      => sdram_cas);

	we_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => 1,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_we,
		q(0)      => sdram_we);

	odt_g : for i in sdram_odt'range generate
		odt_i : entity hdl4fpga.alt_ogbx
		generic map (
			device    => device,
			data_edge => data_edge,
			size      => 1,
			gear      => gear)
		port map (
			rst       => rst,
			clk       => clk0,
			d         => sys_odt,
			q(0)      => sdram_odt(i));
	end generate;

	ba_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => sdram_b'length,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_b,
		q         => sdram_b);

	a_i : entity hdl4fpga.alt_ogbx
	generic map (
		device    => device,
		data_edge => data_edge,
		size      => sdram_a'length,
		gear      => gear)
	port map (
		rst       => rst,
		clk       => clk0,
		d         => sys_a,
		q         => sdram_a);

end;




