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

library ecp3;
use ecp3.components.all;

entity ecp3_sdrbaphy is
	generic (
		cmmd_gear  : natural := 2;
		bank_size  : natural := 2;
		addr_size  : natural := 13);
	port (
		sclk       : in  std_logic;
		sclk2x     : in  std_logic;

		phy_rst    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cs     : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cke    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_b      : in  std_logic_vector(cmmd_gear*bank_size-1 downto 0);
		phy_a      : in  std_logic_vector(cmmd_gear*addr_size-1 downto 0);
		phy_ras    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_cas    : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_we     : in  std_logic_vector(cmmd_gear-1 downto 0);
		phy_odt    : in  std_logic_vector(cmmd_gear-1 downto 0);

		sdr_rst    : out std_logic;
		sdr_cs     : out std_logic;
		sdr_ck     : out std_logic;
		sdr_cke    : out std_logic;
		sdr_odt    : out std_logic;
		sdr_ras    : out std_logic;
		sdr_cas    : out std_logic;
		sdr_we     : out std_logic;
		sdr_b      : out std_logic_vector(bank_size-1 downto 0);
		sdr_a      : out std_logic_vector(addr_size-1 downto 0));
end;

architecture ecp3 of ecp3_sdrbaphy is

	attribute oddrapps : string;
	attribute oddrapps of ck_i : label is "SCLK_CENTERED";
	attribute oddrapps of ras_i, cas_i, we_i, cs_i, cke_i, odt_i, rst_i : label is "SCLK_ALIGNED";

begin

	ck_i : oddrxd1
	port map (
		sclk => sclk2x,
		da   => '0',
		db   => '1',
		q    => sdr_ck);

	b_g : for i in 0 to bank_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sclk,
			da   => phy_b(cmmd_gear*i+0),
			db   => phy_b(cmmd_gear*i+1),
			q    => sdr_b(i));
	end generate;

	a_g : for i in 0 to addr_size-1 generate
		attribute oddrapps of oddr_i: label is "SCLK_ALIGNED";
	begin
		oddr_i : oddrxd1
		port map (
			sclk => sclk,
			da   => phy_a(cmmd_gear*i+0),
			db   => phy_a(cmmd_gear*i+1),
			q    => sdr_a(i));
	end generate;

	ras_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_ras(0),
		db   => phy_ras(1),
		q    => sdr_ras);

	cas_i :oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cas(0),
		db   => phy_cas(1),
		q    => sdr_cas);

	we_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_we(0),
		db   => phy_we(1),
		q    => sdr_we);

	cs_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cs(0),
		db   => phy_cs(1),
		q    => sdr_cs);

	cke_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_cke(0),
		db   => phy_cke(1),
		q    => sdr_cke);

	odt_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_odt(0),
		db   => phy_odt(1),
		q    => sdr_odt);

	rst_i : oddrxd1
	port map (
		sclk => sclk,
		da   => phy_rst(0),
		db   => phy_rst(1),
		q    => sdr_rst);

end;
