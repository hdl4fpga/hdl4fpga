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

entity ethfcs_tx is
	port (
		mii_clk  : in  std_logic;
		dll_frm  : in  std_logic;
		dll_irdy : in  std_logic;
		dll_txd  : in  std_logic_vector;
		mii_frm  : out std_logic;
		mii_irdy : out std_logic;
		mii_trdy : in  std_logic;
		mii_data : out std_logic_vector);
end;

architecture mix of ethfcs_tx is

	constant mii_pre  : std_logic_vector := reverse(x"5555_5555_5555_55d5", 8);

	signal pre_data  : std_logic_vector(dll_txd'range);
	signal pre_end   : std_logic;

	constant latency : natural := mii_pre'length/mii_data'length;
	signal lat_frm   : std_logic;
	signal lat_data  : std_logic_vector(dll_txd'range);

	constant crc32_size : natural := 32;
	signal crc32_init : std_logic;
	signal crc32      : std_logic_vector(0 to crc32_size-1);
	signal crc32_irdy : std_logic;

	signal rdy        : std_logic;

begin

	rdy <= dll_irdy and mii_trdy;
	miitx_pre_e  : entity hdl4fpga.mii_rom
	generic map (
		mem_data => mii_pre)
	port map (
		mii_clk  => mii_clk,
		mii_frm  => dll_frm,
		mii_irdy => rdy,
		mii_end  => pre_end,
		mii_data => pre_data);

	lattxd_e : entity hdl4fpga.align
	generic map (
		n  => mii_data'length,
		d  => (0 to mii_data'length-1 => latency))
	port map (
		clk => mii_clk,
		ena => rdy,
		di  => dll_txd,
		do  => lat_data);

	lattxdv_e : entity hdl4fpga.align
	generic map (
		n => 1,
		d => (0 to mii_data'length-1 => latency))
	port map (
		clk   => mii_clk,
		ena   => rdy,
		di(0) => dll_frm,
		do(0) => lat_frm);

	fcs_p : process (lat_frm, mii_clk)
		variable cntr : unsigned(0 to unsigned_num_bits(crc32_size/lat_data'length-1)) := ('1', others => '-');
		variable cy   : std_logic;
		variable q    : std_logic;
	begin
		if rising_edge(mii_clk) then
			if crc32_irdy='0' then
				if to_stdulogic(to_bit(lat_frm))='1' then
					cntr := to_unsigned(crc32_size/lat_data'length-1, cntr'length);
				end if;
			elsif cy='0' then
				cntr := cntr - 1;
			end if;

			if to_stdulogic(to_bit(lat_frm))='1' then
				if cy='1' then
					q := '0';
				end if;
			else
				q := '1';
			end if;

			cy := to_stdulogic(to_bit(cntr(0)));
		end if;
		crc32_init <= not to_stdulogic(to_bit(lat_frm)) and cy;
		crc32_irdy <= not to_stdulogic(to_bit(lat_frm)) and not cy;
	end process;

	crc32_e : entity hdl4fpga.crc
	port map (
		g    => x"04c11db7",
		clk  => mii_clk,
		init => crc32_init,
		ena  => rdy,
		data => lat_data,
		sero => crc32_irdy,
		crc  => crc32);

	mii_data <= wirebus(pre_data & lat_data & crc32(mii_data'range), not pre_end & lat_frm & crc32_irdy);
	mii_frm  <= not pre_end or lat_frm or crc32_irdy;

end;
