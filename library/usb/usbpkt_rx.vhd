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

entity usbpkt_rx is
	port (
		clk    : in  std_logic;
		cken   : in  std_logic;

		rx_req : buffer std_logic;
		rx_rdy : in  std_logic;

		rxdv   : in  std_logic;
		rxpid  : in  std_logic_vector(4-1 downto 0);
		rxbs   : in  std_logic;
		rxd    : in  std_logic;
		-- USB Device protocol
		addr   : out std_logic_vector(7-1 downto 0);
		endp   : out std_logic_vector(4-1 downto 0);
		-- USB Device Framework 
		bmrequesttype : out std_logic_vector( 8-1 downto 0);
		brequest      : out std_logic_vector( 8-1 downto 0);
		wvalue        : out std_logic_vector(16-1 downto 0);
		windex        : out std_logic_vector(16-1 downto 0);
		wlength       : out std_logic_vector(16-1 downto 0));

	constant tk_out   : std_logic_vector := b"0001";
	constant tk_in    : std_logic_vector := b"1001";
	constant tk_setup : std_logic_vector := b"1101";
	constant tk_sof   : std_logic_vector := b"0101";

	constant data0    : std_logic_vector := b"0011";
	constant data1    : std_logic_vector := b"1011";

	constant hs_ack   : std_logic_vector := b"0010";
	constant hs_nack  : std_logic_vector := b"1010";
	constant hs_stall : std_logic_vector := b"1110";

end;

architecture def of usbpkt_rx is
begin

	process (clk)
		type states is (s_idle, s_token, s_data);
		variable state : states;
		variable rgtr  : unsigned(0 to 8*8+15-1); -- address + end point, setup data + crc16
	begin
		if rising_edge(clk) then
			if cken='1' then
				if (rx_rdy xor rx_req)='0' then
   					if rxdv='1' then
   						if rxbs='0' then
   							rgtr := rgtr rol 1;
   							rgtr(0) := rxd;
   						end if;
					end if;
					case state is
					when s_idle =>
						if rxdv='1' then
   							case rxpid is
   							when tk_setup|tk_in|tk_out|tk_sof =>
								state := s_token;
   							when data0|data1 =>
   								state := s_data;
							when others =>
   							end case;
						end if;
					when s_token =>
						if rxdv='0' then
							endp <= reverse(std_logic_vector(rgtr(0 to endp'length-1)));
							rgtr := rgtr rol endp'length;
							addr <= reverse(std_logic_vector(rgtr(0 to addr'length-1)));
							rgtr := rgtr rol addr'length;
							rx_req <= not rx_rdy;
						end if;
					when s_data =>
						if rxdv='0' then
							wlength       <= reverse(std_logic_vector(rgtr(0 to wlength'length-1)),8);
							rgtr := rgtr rol wlength'length;
							windex        <= reverse(std_logic_vector(rgtr(0 to windex'length-1)),8);
							rgtr := rgtr rol windex'length;
							wvalue        <= reverse(std_logic_vector(rgtr(0 to wvalue'length-1)),8);
							rgtr := rgtr rol wvalue'length;
							brequest      <= reverse(std_logic_vector(rgtr(0 to brequest'length-1)),8);
							rgtr := rgtr rol brequest'length;
							bmrequesttype <= reverse(std_logic_vector(rgtr(0 to bmrequesttype'length-1)),8);
							rgtr := rgtr rol bmrequesttype'length;
							rx_req <= not rx_rdy;
						end if;
					when others =>
						rx_req <= not rx_rdy;
					end case;
				else
					state := s_idle;
				end if;
			end if;
		end if;
	end process;

end;