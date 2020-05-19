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

library ecp5u;
use ecp5u.components.all;

library hdl4fpga;
use hdl4fpga.std.all;

entity sdrphy is
	generic (
		f200MHz   : boolean := false;
		loopback  : boolean := false;
		rgtr_dout : boolean := true;
		bank_size : natural := 2;
		addr_size : natural := 13;
		word_size : natural := 16;
		byte_size : natural := 8);
	port (
		sys_clk : in  std_logic;
		sys_rst : in std_logic;

		phy_cs    : in  std_logic;
		phy_cke   : in  std_logic;
		phy_b     : in  std_logic_vector(bank_size-1 downto 0);
		phy_a     : in  std_logic_vector(addr_size-1 downto 0);
		phy_ras   : in  std_logic;
		phy_cas   : in  std_logic;
		phy_we    : in  std_logic;
		phy_dmt   : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dmi   : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dmo   : out std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dqt   : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dqo   : out std_logic_vector(word_size-1 downto 0);
		phy_dqi   : in  std_logic_vector(word_size-1 downto 0);
		phy_dqso  : out std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dqst  : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dqsi  : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		phy_sti   : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_sto   : out std_logic_vector(word_size/byte_size-1 downto 0);

		sdr_rst : out std_logic;
		sdr_cs  : out std_logic := '0';
		sdr_cke : out std_logic := '1';
		sdr_clk : inout std_logic;
		sdr_odt : out std_logic;
		sdr_ras : out std_logic;
		sdr_cas : out std_logic;
		sdr_we  : out std_logic;
		sdr_b   : out std_logic_vector(bank_size-1 downto 0);
		sdr_a   : out std_logic_vector(addr_size-1 downto 0);

		sdr_dm  : inout std_logic_vector(word_size/byte_size-1 downto 0);
		sdr_dq  : inout std_logic_vector(word_size-1 downto 0));
end;

library hdl4fpga;
use hdl4fpga.std.all;

architecture ecp of sdrphy is
	subtype byte is std_logic_vector(byte_size-1 downto 0);
	type byte_vector is array (natural range <>) of byte;

	signal dmt : std_logic_vector(word_size/byte_size-1 downto 0);
	signal dmo : std_logic_vector(word_size/byte_size-1 downto 0);

	signal dqt : std_logic_vector(sdr_dq'range);
	signal dqo : std_logic_vector(sdr_dq'range);

	signal dsi : std_logic;
begin

	sdrbaphy_i : entity hdl4fpga.sdrbaphy
	generic map (
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clk => sys_clk,
          
		phy_cs  => phy_cs,
		phy_cke => phy_cke,
		phy_b   => phy_b,
		phy_a   => phy_a,
		phy_ras => phy_ras,
		phy_cas => phy_cas,
		phy_we  => phy_we,
        
		sdr_rst => sdr_rst,
		sdr_clk => sdr_clk,
		sdr_cke => sdr_cke,
		sdr_odt => sdr_odt,
		sdr_cs  => sdr_cs,
		sdr_ras => sdr_ras,
		sdr_cas => sdr_cas,
		sdr_we  => sdr_we,
		sdr_b   => sdr_b,
		sdr_a   => sdr_a);

	byte_g : for i in 0 to word_size/byte_size-1 generate
		sdrdqphy_i : entity hdl4fpga.sdrdqphy
		generic map (
			byte_size => byte_size)
		port map (
			sys_clk => sys_clk,

			phy_dmi => phy_dmi(i),
			phy_dmt => phy_dmt(i),
			phy_dmo => phy_dmo(i),
			phy_dqi => phy_dqi((i+1)*byte_size-1 downto i*byte_size),
			phy_dqt => phy_dqt(i),
			phy_dqo => phy_dqo((i+1)*byte_size-1 downto i*byte_size),

			sdr_ds  => dsi,
			sdr_dmi => sdr_dm(i),
			sdr_dmt => dmt(i),
			sdr_dmo => dmo(i),

			sdr_dqi => sdr_dq((i+1)*byte_size-1 downto  i*byte_size),
			sdr_dqt => dqt((i+1)*byte_size-1 downto  i*byte_size),
			sdr_dqo => dqo((i+1)*byte_size-1 downto  i*byte_size));

	end generate;

	process (dqo, dqt)
	begin
		for i in dqo'range loop
			if dqt(i)='0' then
				sdr_dq(i) <= 'Z';
			else
				sdr_dq(i) <= dqo(i);
			end if;
		end loop;
	end process;

	process (dmo, dmt)
	begin
		for i in dmo'range loop
			if dmt(i)='0' then
				sdr_dm(i) <= 'Z';
			else
				sdr_dm(i) <= dmo(i);
			end if;
		end loop;
	end process;


	sto : entity hdl4fpga.align
	generic map (
		n => phy_sto'length,
		d => (0 to phy_sto'length-1 => setif(f200Mhz, 3,2)))
	port map (
		clk => sys_clk,
		di  => phy_sti,
		do  => phy_sto);
	
	dsi <= not sys_clk when f200MHz else sys_clk;
	phy_dqso <= (others => dsi);
end;
