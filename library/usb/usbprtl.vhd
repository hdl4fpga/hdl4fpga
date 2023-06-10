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
use hdl4fpga.base.all;

entity usbprtl is
   	generic (
		oversampling : natural := 0;
		watermark    : natural := 0;
		bit_stuffing : natural := 6);
	port (
		dp   : inout std_logic := 'Z';
		dn   : inout std_logic := 'Z';
		clk  : in  std_logic;
		cken : buffer std_logic;

		txen : in  std_logic;
		txbs : buffer std_logic;
		txd  : in  std_logic;

		rxdv : buffer std_logic;
		rxbs : buffer std_logic;
		rxd  : buffer std_logic);
end;

architecture def of usbprtl is
	signal phy_txen : std_logic;
	alias  phy_txbs is txbs;
	signal phy_txd  : std_logic;

	signal dv    : std_logic;
	signal data  : std_logic;
	signal ena   : std_logic;
	signal crcdv : std_logic;
	signal crcen : std_logic;
	signal crc5  : std_logic_vector(0 to 5-1);
	signal crc16 : std_logic_vector(0 to 16-1);
	signal bs    : std_logic;
begin

	phy_txen <= txen or ena;
	phy_txd  <= txd when txen='1' else not crc16(0);
	usbphy_e : entity hdl4fpga.usbphy
   	generic map (
		oversampling => oversampling,
		watermark    => watermark,
		bit_stuffing => bit_stuffing)
	port map (
		dp   => dp,
		dn   => dn,
		clk  => clk,
		cken => cken,

		txen => phy_txen,
		txbs => phy_txbs,
		txd  => phy_txd,

		rxdv => rxdv,
		rxbs => rxbs,
		rxd  => rxd);

	bs   <= phy_txbs or rxbs;
	dv   <= to_stdulogic(to_bit(txen or rxdv));
	data <= txd  when txen='1' else rxd;
	process (clk)
		type states is (s_pid, s_data, s_crc);
		variable state : states;
		variable cntr  : natural range 0 to 15;
		variable pid   : unsigned(8-1 downto 0);
	begin
		if rising_edge(clk) then
			case state is
			when s_pid =>
				if dv='0' then
					cntr  := 0;
					ena <= '0';
				elsif cken='1' then
					if bs='0' then
						if cntr < 7 then
							cntr := cntr + 1;
							ena <= '0';
						else 
							cntr  := 0;
							ena   <= '1';
							state := s_data;
						end if;
						pid(0) := data;
						pid := pid ror 1;
					end if;
				else
					ena <= '0';
				end if;
			when s_data =>
				if dv='0' then
					if cken='1' then
						state := s_crc;
						cntr  := cntr + 1;
					end if;
				end if;
				ena <= '1';
			when s_crc =>
				if cken='1' then
					if bs='0' then
						if cntr < 15 then
							cntr := cntr + 1;
						else
							ena   <= '0';
							state := s_pid;
						end if;
					end if;
				end if;
			end case;
		end if;
	end process;

	crcen <= ena and not bs;
	crcdv <= ena and txen;
	usbcrc_e : entity hdl4fpga.usbcrc
	port map (
		clk   => clk,
		cken  => cken,
		dv    => crcdv,
		data  => data,
		crc5  => crc5,
		crc16 => crc16);

end;