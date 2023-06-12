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
		tp   : out std_logic_vector(1 to 32);
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
	signal phy_rxdv : std_logic;

	signal dv     : bit;
	signal data   : std_logic;
	signal crcrq  : std_logic;
	signal crcdv  : std_logic;
	signal crcen  : std_logic;
	signal crc5   : std_logic_vector(0 to 5-1);
	signal crc16  : std_logic_vector(0 to 16-1);
	signal bs     : std_logic;
	signal pktdat : std_logic;
begin

	tp(1 to 3) <= (phy_txen, phy_txbs, phy_txd);
	rxdv <= phy_rxdv and not phy_txen;

	phytx_and_crc_ena_p : process (txen, rxdv, crcrq, clk)
		type states is (s_idle, s_tx, s_rx);
		variable state : states;
	begin
		memory : if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_idle =>
					if txen='1' then
						state := s_tx;
					elsif rxdv='1' then
						state := s_rx;
					end if;
				when s_tx =>
					if txen='0' then
						if crcrq='0' then
							state := s_idle;
						end if;
					end if;
				when s_rx =>
					if crcrq='0' then
						state := s_idle;
					end if;
				end case;
			end if;
		end if;
		combimatorial : case state is
		when s_idle =>
			phy_txen <= txen;
			crcdv    <= txen or rxdv;
		when s_tx =>
			phy_txen <= txen or crcrq;
			crcdv    <= crcrq and txen;
		when s_rx =>
			phy_txen <= '0';
			crcdv    <= rxdv;
		end case;
	end process;
	crcen <= (crcrq and not bs) when cken='1' else '0';

	phy_txd  <= 
		txd          when txen='1'   else 
		not crc16(0) when pktdat='1' else
		not crc5(0);

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

		rxdv => phy_rxdv,
		rxbs => rxbs,
		rxd  => rxd);

	bs   <= phy_txbs or rxbs;
	dv   <= 
		'1' when     txen='1' else 
		'0' when phy_txen='1' else
		'1' when phy_rxdv='1' else
		'0';
	data <= txd when txen='1' else rxd;

	process (clk)
		constant length_of_sync  : natural := 8;
		constant length_of_pid   : natural := 8;
		constant length_of_crc5  : natural := 5;
		constant length_of_crc16 : natural := 16;
		type states is (s_pid, s_data, s_crc);
		variable state : states;
		variable cntr  : natural range 0 to max(length_of_crc16,length_of_crc5)-1+length_of_pid-1;
		variable pid   : unsigned(8-1 downto 0);
	begin
		if rising_edge(clk) then
			case state is
			when s_pid =>
				if dv='0' then
					cntr := length_of_pid-1;
					crcrq  <= '0';
				elsif cken='1' then
					if bs='0' then
						if cntr /= 0 then
							cntr := cntr - 1;
							crcrq  <= '0';
						else 
							crcrq  <= txen or rxdv;
							state := s_data;
						end if;
						pid(0) := data;
						pid := pid ror 1;
					end if;
				else
					crcrq <= '0';
				end if;
				if pid(2-1 downto 0)="11" then
					pktdat <= '1';
				else
					pktdat <= '0';
				end if;
			when s_data =>
				if dv='0' then
					if cken='1' then
						if crcrq='1' then
							state := s_crc;
						else
							state := s_pid;
						end if;
					end if;
				end if;
				if pktdat='1' then
					cntr := (length_of_crc16-1)+length_of_sync-1;
				else
					cntr := (length_of_crc5-1)+length_of_sync-1;
				end if;
			when s_crc =>
				if cken='1' then
					if bs='0' then
						if cntr /= 0 then
							cntr := cntr - 1;
						else
							crcrq <= '0';
							state := s_pid;
						end if;
					end if;
				end if;
			end case;
		end if;
	end process;

	usbcrc_e : entity hdl4fpga.usbcrc
	port map (
		clk   => clk,
		cken  => crcen,
		dv    => crcdv,
		data  => data,
		crc5  => crc5,
		crc16 => crc16);

end;