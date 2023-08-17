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
use hdl4fpga.usbpkg.all;

entity usbphycrc is
   	generic (
		oversampling : natural := 0;
		watermark    : natural := 0;
		bit_stuffing : natural := 6);
	port (
		tp     : out std_logic_vector(1 to 32);
		dp     : inout std_logic := 'Z';
		dn     : inout std_logic := 'Z';
		idle   : buffer std_logic;
		clk    : in  std_logic;
		cken   : buffer std_logic;

		txen   : in  std_logic;
		txbs   : buffer std_logic;
		txd    : in  std_logic;

		rxpid  : out std_logic_vector(4-1 downto 0);
		rxpidv : out std_logic;
		rxdv   : buffer std_logic;
		rxbs   : buffer std_logic;
		rxd    : buffer std_logic;
		rxerr  : out std_logic;
		phyerr : out std_logic;
		crcerr : buffer std_logic;
		tkerr  : buffer std_logic);

	constant length_of_sync  : natural := 8;
	constant length_of_pid   : natural := 8;
	constant length_of_crc5  : natural := 5;
	constant length_of_crc16 : natural := 16;
end;

architecture def of usbphycrc is

	signal phy_txen  : std_logic;
	signal phy_txbs  : std_logic;
	signal phy_txd   : std_logic;
	signal phy_rxbs  : std_logic;
	signal phy_rxdv  : std_logic;
	signal phy_rxd   : std_logic;
	signal phy_rxerr : std_logic;

	signal data      : std_logic;
	signal crc0      : std_logic;
	signal crcen     : std_logic;
	signal crcact_rx : std_logic;
	signal crcact_tx : std_logic;
	signal crcdv     : std_logic;
	signal crcd      : std_logic;
	signal crc5      : std_logic_vector(0 to 5-1);
	signal crc16     : std_logic_vector(0 to 16-1);
	signal crc5_16   : std_logic;
	signal crcerr_d  : std_logic;
	signal crcerr_q  : std_logic;

	signal echo      : std_logic;
	signal chken     : std_logic;
	signal pidv      : std_logic;
begin

	-- tp(1) <= '1'  when txen='1' else rxdv;
	-- tp(2) <= txbs when txen='1' else rxbs;
	-- tp(3) <= txd  when txen='1' else rxd;
	data <= txd when txen='1' else phy_rxd;
	usbphy_e : entity hdl4fpga.usbphy
   	generic map (
		oversampling => oversampling,
		watermark    => watermark,
		bit_stuffing => bit_stuffing)
	port map (
		tp    => tp,
		dp    => dp,
		dn    => dn,
		clk   => clk,
		cken  => cken,
		idle  => idle,

		txen  => phy_txen,
		txbs  => phy_txbs,
		txd   => phy_txd,

		rxdv  => phy_rxdv,
		rxbs  => phy_rxbs,
		rxd   => phy_rxd,
		rxerr => phy_rxerr);

	crcdv <= 
		crcact_tx when     txen='1' else 
		crcact_rx when phy_rxdv='1' else
		'0';

	crcen <= 
		cken and not phy_txbs when crcact_tx='1' else
		cken and not phy_rxbs when crcact_rx='1' else 
		cken;

	crc0 <= not crcact_rx and not crcact_tx;
	usbcrc_e : entity hdl4fpga.usbcrc
	port map (
		clk   => clk,
		cken  => crcen,
		init  => crc0,
		dv    => crcdv,
		data  => data,
		crc5  => crc5,
		crc16 => crc16);

	chken <= crcact_rx and not crcdv;
	crcerr_d <=
		setif(crc5/=b"0_1100")               when crc5_16='0' else
		setif(crc16/=b"1000_0000_0000_1101") when crc5_16='1' else
		'-';
	chkcrc_p : process (clk, crcerr_d)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if chken='1' then
					crcerr_q <= crcerr_d;
				end if;
			end if;
		end if;
	end process;
	crcerr <= crcerr_d when chken='1'   else crcerr_q;
	crcd   <= crc16(0) when crc5_16='1' else crc5(0);

	pktfmt_p : process (clk)
		type states is (s_pid, s_tx, s_rx, s_crc);
		variable state : states;
		variable cntr  : natural range 0 to max(length_of_crc16,length_of_crc5)-1+length_of_pid-1;
		variable pid   : unsigned(8-1 downto 0);
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_pid =>
					if (txen or phy_rxdv)='0' then
						cntr := length_of_pid-1;
						pidv    <= '0';
						crcact_rx <= '0';
						crcact_tx <= '0';
					elsif (phy_txbs or phy_rxbs)='0' then
						pid(0) := data;
						pid := pid ror 1;
						if cntr /= 0 then
							tkerr     <= '0';
							crcact_rx <= '0';
							crcact_tx <= '0';
							cntr := cntr - 1;
						else
							if txen='1' then
								crcact_tx <= '1';
								state     := s_tx;
							else 
								if pid(2-1 downto 0)=resize(unsigned(hs_ack),2) then
									crcact_rx <= '0';
								else
									crcact_rx <= '1';
								end if;
								pidv <= '1';
								state := s_rx;
							end if;
							rxpid <= std_logic_vector(pid(4-1 downto 0));
							if (pid(8-1 downto 4) xor pid(4-1 downto 0))/=x"f" then
								tkerr <= '1';
							else
								tkerr <= '0';
							end if;
						end if;
					end if;
					if pid(2-1 downto 0)=resize(unsigned(data0),2) then
						crc5_16 <= '1';
					else
						crc5_16 <= '0';
					end if;
				when s_rx =>
					pidv <= '0';
					if phy_rxdv='0' then
						crcact_rx <= '0';
						state := s_pid;
					end if;
				when s_tx =>
					if    pid(2-1 downto 0)=resize(unsigned(hs_ack),2) then
						cntr := length_of_sync-2;                 -- Handshake long
					elsif pid(2-1 downto 0)=resize(unsigned(data0), 2) then
						cntr := length_of_sync-2+length_of_crc16; -- Data long
					elsif pid(2-1 downto 0)=resize(unsigned(tk_out),2) then
						cntr := length_of_sync-2+length_of_crc5;  -- Token long
					else
						cntr := length_of_sync-2;                 -- Handshake long
					end if;
					if txen='0' then
						if phy_txbs='0' then
							state := s_crc;
						end if;
					end if;
				when s_crc =>
					if phy_txbs='0' then
						if cntr /= 0 then
							cntr := cntr - 1;
						else
							if (txen or phy_rxdv)='0' then
								cntr  := length_of_pid-1;
								state := s_pid;
							end if;
							crcact_tx <= '0';
						end if;
					end if;
				end case;
			end if;
		end if;
	end process;

	echo_p : process (clk)
	begin
		if rising_edge(clk) then
			if cken='1' then
				if phy_txen='1' then
					echo <= '1';
				elsif phy_rxdv='0' then
					echo <= '0';
				end if;
			end if;
		end if;
	end process;

	rxerr  <= tkerr or phy_rxerr or crcerr;
	phyerr <= phy_rxerr;
	rxdv <=
		'0' when txen='1'      else
		'0' when echo='1'      else
		'0' when crcact_rx='0' else
		phy_rxdv;
	rxpidv <= pidv;

	rxbs <= phy_rxbs;
	rxd  <= phy_rxd;

	phy_txen <= '1'      when txen='1' else crcact_tx;
	txbs     <= phy_txbs when txen='1' else crcact_tx or phy_rxdv;
	phy_txd  <= txd      when txen='1' else not crcd;

end;