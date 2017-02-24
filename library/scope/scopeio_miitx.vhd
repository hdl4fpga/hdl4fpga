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

entity miitx_udp is
	generic (
		payload_size : natural := 512;
		mac_destaddr : std_logic_vector(0 to 48-1) := x"ffffffffffff");

	port (
		mii_txc     : in  std_logic;

		miidma_req  : out std_logic;
		miidma_rxen : in  std_logic;
		miidma_rxd  : in  std_logic_vector;

		mii_treq    : in  std_logic;
		mii_trdy    : out std_logic;
		mii_txen    : out std_logic;
		mii_txd     : out std_logic_vector);
end;

architecture mix of miitx_udp is

	subtype xword is std_logic_vector(mii_txd'range);
	type xword_vector is array (natural range <>) of xword;

	constant n     : natural := 3;

	constant txpre : natural := 0;
	constant txmac : natural := 1;
	constant txpld : natural := 2;
	constant txcrc : natural := 3;

	signal txdat   : xword_vector(n downto 0);
	signal txena   : std_logic_vector(n   downto 0);
	signal txreq   : std_logic_vector(n+1 downto 0);

	signal txen    : std_logic;
	signal txd     : std_logic_vector(0 to mii_txd'length-1);
	signal rdy     : std_logic_vector(n downto 0);
	signal dat     : xword_vector(n downto 0);
	signal ena     : std_logic_vector(n downto 0);
	signal crc_ted : std_logic;

begin

	miitx_pre_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data =>  x"5555_5555_5555_55d5")
	port map (
		mii_txc  => mii_txc,
		mii_treq => txreq(txpre),
		mii_txen => txena(txpre),
		mii_txd  => txdat(txpre));

	miitx_macudp_e  : entity hdl4fpga.miitx_mem
	generic map (
		mem_data => 
			mac_destaddr    &
			x"000000010203"	&       -- MAC Source Address
			x"0800"         &       -- MAC Protocol ID
			ipheader_checksumed(
				x"4500"         &	-- IP  Version, header length, TOS
				std_logic_vector(to_unsigned(payload_size+28,16)) &	-- IP  Length
				x"0000"         &	-- IP  Identification
				x"0000"         &	-- IP  Fragmentation
				x"0511"         &	-- IP  TTL, protocol
				x"0000"         &	-- IP  Checksum
				x"c0a802c8"     &	-- IP  Source address
				x"ffffffff")    &	-- IP  Destination address
			x"04000400"         &   -- UDP Source port, Destination port
			std_logic_vector(to_unsigned(payload_size+8,16)) & -- UDP Length,
			x"0000")	   	        -- Checksum
	port map (
		mii_txc  => mii_txc,
		mii_treq => txreq(txmac),
		mii_txen => txena(txmac),
		mii_txd  => txdat(txmac));

	miidma_req   <= txreq(txpld);
	txena(txpld) <= miidma_rxen;
	txdat(txpld) <= miidma_rxd;

	miitx_crc_e : entity hdl4fpga.miitx_crc
	port map (
		mii_txc  => mii_txc,
		mii_treq => mii_treq,
		mii_ted  => crc_ted,
		mii_txi  => txd,
		mii_txen => txena(txcrc),
		mii_txd  => txdat(txcrc));

	crc_ted  <= rdy(0) and not rdy(n-1);
	txen     <= (ena(0) or rdy(0)) and not rdy(n) and mii_treq; 
	mii_txen <= txen;

	txreq(0) <= mii_treq;
	miitx_cat_g : for i in 0 to n generate
	begin
		txreq(i+1) <= (not txena(i) and ena(i)) or rdy(i);
		process (mii_txc)
		begin
			if rising_edge(mii_txc) then
				if mii_treq='0' then
					rdy(i) <= '0';
					ena(i) <= '0';
				elsif txena(i)='0' then
					if ena(i)='1' then
						rdy(i) <= '1';
					end if;
				end if;
				ena(i) <= txena(i);
				dat(i) <= txdat(i);
			end if;
		end process;
	end generate;

	process (dat, rdy)
	begin
		txd <= (others => '-');
		for i in n-1 downto 0 loop
			if rdy(i)/='1' then
				txd <= dat(i);
			end if;
		end loop;
	end process;

	mii_trdy <= rdy(n);
	mii_txd  <= txdat(n) when rdy(n-1)='1' else txd;
end;
