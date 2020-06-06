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
		latency   : boolean := false;
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
		phy_dso   : out std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dst   : in  std_logic_vector(word_size/byte_size-1 downto 0);
		phy_dsi   : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
		phy_sti   : in  std_logic_vector(word_size/byte_size-1 downto 0) := (others => '-');
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

	signal phy1_cs  : std_logic;
	signal phy1_cke : std_logic;
	signal phy1_b   : std_logic_vector(phy_b'range);
	signal phy1_a   : std_logic_vector(phy_a'range);
	signal phy1_ras : std_logic;
	signal phy1_cas : std_logic;
	signal phy1_we  : std_logic;
	signal phy1_dmt : std_logic_vector(phy_dmt'range);
	signal phy1_dmi : std_logic_vector(phy_dmi'range);
	signal phy1_dqt : std_logic_vector(phy_dqt'range);
	signal phy1_dqi : std_logic_vector(phy_dqi'range);
	signal phy1_dst : std_logic_vector(phy_dst'range);
	signal phy1_sti : std_logic_vector(phy_sti'range);

begin

	latency_b : block
		signal cs  : std_logic;
		signal cke : std_logic;
		signal b   : std_logic_vector(phy_b'range);
		signal a   : std_logic_vector(phy_a'range);
		signal ras : std_logic;
		signal cas : std_logic;
		signal we  : std_logic;
		signal dmt : std_logic_vector(phy_dmt'range);
		signal dmi : std_logic_vector(phy_dmi'range);
		signal dqt : std_logic_vector(phy_dqt'range);
		signal dqi : std_logic_vector(phy_dqi'range);
		signal dst : std_logic_vector(phy_dst'range);
		signal sti : std_logic_vector(phy_sti'range);

	begin
		process (sys_clk)
		begin
			if rising_edge(sys_clk) then
				cs  <= phy_cs;
				cke <= phy_cke;
				b   <= phy_b;
				a   <= phy_a;
				ras <= phy_ras;
				cas <= phy_cas;
				we  <= phy_we;
				dmt <= phy_dmt;
				dmi <= phy_dmi;
				dqt <= phy_dqt;
				dqi <= phy_dqi;
				dst <= phy_dst;
				sti <= phy_sti;
			end if;
		end process;

		phy1_cs  <= cs  when latency else phy_cs; 
		phy1_cke <= cke when latency else phy_cke;
		phy1_b   <= b   when latency else phy_b;  
		phy1_a   <= a   when latency else phy_a;  
		phy1_ras <= ras when latency else phy_ras;
		phy1_cas <= cas when latency else phy_cas;
		phy1_we  <= we  when latency else phy_we; 
		phy1_dmt <= dmt when latency else phy_dmt;
		phy1_dmi <= dmi when latency else phy_dmi;
		phy1_dqt <= dqt when latency else phy_dqt;
		phy1_dqi <= dqi when latency else phy_dqi;
		phy1_dst <= dst when latency else phy_dst;
		phy1_sti <= sti when false else phy_sti;
	end block;

	sdrbaphy_i : entity hdl4fpga.sdrbaphy
	generic map (
		bank_size => bank_size,
		addr_size => addr_size)
	port map (
		sys_clk => sys_clk,
          
		phy_cs  => phy1_cs,
		phy_cke => phy1_cke,
		phy_b   => phy1_b,
		phy_a   => phy1_a,
		phy_ras => phy1_ras,
		phy_cas => phy1_cas,
		phy_we  => phy1_we,
        
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

			phy_dmi => phy1_dmi(i),
			phy_dmt => phy1_dmt(i),
			phy_dmo => phy_dmo(i),
			phy_dqi => phy1_dqi((i+1)*byte_size-1 downto i*byte_size),
			phy_dqt => phy1_dqt(i),
			phy_dqo => phy_dqo((i+1)*byte_size-1 downto i*byte_size),

			sdr_ds  => phy_dsi(i),
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
		n => phy_sti'length,
		d => (0 to phy_sti'length-1 => 2))
	port map (
		clk => sys_clk,
		di  => phy1_sti,
		do  => phy_sto);

	phy_dso <= phy_dsi;
end;
