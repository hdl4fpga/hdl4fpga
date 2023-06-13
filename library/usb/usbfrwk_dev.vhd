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

entity usbfrwk_dev is
	port (
		dp   : out std_logic_vector(1 to 32);
		clk  : in  std_logic;
		cken : in  std_logic;

		txen : out std_logic;
		txbs : in  std_logic;
		txd  : out std_logic;

		rxdv : in  std_logic;
		rxbs : in  std_logic;
		rxd  : in  std_logic);

end;

architecture def of usbfrwk_dev is
	constant tk_out   : std_logic_vector := reverse(not b"0001" & b"0001");
	constant tk_in    : std_logic_vector := reverse(not b"1001" & b"1001");
	constant tk_sof   : std_logic_vector := reverse(not b"0101" & b"0101");
	constant tk_setup : std_logic_vector := reverse(not b"1101" & b"1101");

	constant data0    : std_logic_vector := reverse(not b"0011" & b"0011");
	constant data1    : std_logic_vector := reverse(not b"1011" & b"1011");

	constant hs_ack   : std_logic_vector := reverse(not b"0010" & b"0010");

begin


	setup_p : process (clk)
		type states is (s_setup, s_data, s_ack);
		variable state : states;
		variable rgtr  : unsigned(0 to 8+64+16-1);
		alias  token   : unsigned(24-1 downto 0) is rgtr(0 to 24-1);
		alias  data    : unsigned(0 to 8+64+16-1) is rgtr(0 to 8+64+16-1);
		alias  pid     : unsigned(8-1 downto 0) is rgtr(0 to 8-1);
		variable txpid : unsigned(8-1 downto 0);
		variable cntr  : natural range 0 to 8-1;
		variable rcvd  : std_logic;
	begin
		if rising_edge(clk) then
			if cken='1' then
				case state is
				when s_setup =>
					if rxdv='1' then
						if rxbs='0' then
							token := token rol 1;
							token(0) := rxd;
						end if;
					elsif pid=unsigned(tk_setup) then
						rcvd  := '0';
						state := s_data;
					end if;
					txen <= '0';
				when s_data =>
					if rxdv='1' then
						if rxbs='0' then
							data(0) := rxd;
							data := data ror 1;
						end if;
					elsif rcvd='1' then
						if pid=unsigned(data0) then
							cntr  := 0;
							txpid := unsigned(not hs_ack) & unsigned(hs_ack);
							state := s_ack;
						else
							state := s_setup;
						end if;
					end if;
					txen <= '0';
				when s_ack =>
					if txbs='0' then
						if cntr < 7 then
							cntr := cntr + 1;
						else
							state := s_setup;
						end if;
					end if;
					txd   <= txpid(0);
					txpid := txpid srl 1;
					txen  <= '1';
				end case;
			end if;
		end if;
	end process;

end;